#!/bin/bash

# Human-Agent-in-the-Loop Development Loop Controller
# Manages HAIL workflow state and automates step advancement

set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
STATE_FILE="$PROJECT_ROOT/.gemini/hail-state.json"
LOCK_DIR="$PROJECT_ROOT/.gemini/.hail.lock"
MAX_REVIEW_ITERATIONS=10

LOCK_ACQUIRED=false
TEMP_FILES=()

# --------------------------------------------------------------------------
# Global Helpers
# --------------------------------------------------------------------------

release_lock() {
  if [[ "$LOCK_ACQUIRED" == "true" ]]; then
    rmdir "$LOCK_DIR" 2>/dev/null || true
    LOCK_ACQUIRED=false
  fi
}

cleanup() {
  release_lock
  local f
  # FIX(LOW): ${arr[@]+...} expands only when array is non-empty, avoiding a
  # spurious "rm -f ''" iteration that ${arr[@]:-} produces on bash 3.2
  for f in "${TEMP_FILES[@]+"${TEMP_FILES[@]}"}"; do
    rm -f "$f" 2>/dev/null || true
  done
}

trap cleanup EXIT INT TERM

sed_i() {
  local expr="$1"
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$expr" "$STATE_FILE"
  else
    sed -i "$expr" "$STATE_FILE"
  fi
}

show_help() {
  cat << 'EOF'
Human-Agent-in-the-Loop (HAIL) Workflow Controller

USAGE:
  bash hail-loop.sh [COMMAND] [ARGS]

COMMANDS:
  init [--force] [DESIGN_DOC_PATH] [PLAN_PATH]
      Initialize the HAIL workflow loop.
      --force  Overwrite an in-progress workflow without warning.

  status
      Print current phase, iteration counts, and next steps.

  advance
      Advance to the next phase (after review passes or step completes).
      Warns when a review loop reaches the iteration cap (MAX_REVIEW_ITERATIONS).

  revert [--force] <PHASE_NUMBER>
      Revert to a specific phase (after review finds issues).
      Blocked when the iteration cap is reached — use --force to override.
      Common targets:
        revert 2  — design doc review (phase 4) found issues
        revert 6  — plan review (phase 7) found issues

  complete
      Mark the workflow as complete when implementation is done.
      Preserves state for reference; run 'init' to start a new workflow.

  cancel
      Reset or terminate the workflow (removes state file).

PHASES:
  1. Discuss Phase          (Discuss direction and architecture)
  2. Write Design Doc       (Write technical design document)
  3. Human Review           (Initial human review of design doc)
  4. Subagent Review Doc    (code-reviewer subagent verification)
  5. Human Review Optional  (Final review of design doc)
  6. Write Plan             (Write execution plan)
  7. Subagent Review Plan   (code-reviewer subagent verification)
  8. Human Final Review     (Final approval of execution plan)
  9. Implement Phase        (TDD and implementation phase)
EOF
}

# --------------------------------------------------------------------------
# Locking — mkdir is atomic on Linux/macOS; prevents concurrent advance/revert
# --------------------------------------------------------------------------

acquire_lock() {
  mkdir -p "$PROJECT_ROOT/.gemini"
  local retries=0
  while ! mkdir "$LOCK_DIR" 2>/dev/null; do
    retries=$((retries + 1))
    if [[ $retries -ge 2 && -d "$LOCK_DIR" ]]; then
      local mtime
      if mtime=$(stat -c %Y "$LOCK_DIR" 2>/dev/null || stat -f %m "$LOCK_DIR" 2>/dev/null); then
        local lock_age=$(( $(date +%s) - mtime ))
        if [[ $lock_age -gt 30 ]]; then
          echo "⚠️  Stale lock detected (${lock_age}s old). Removing automatically."
          rmdir "$LOCK_DIR" 2>/dev/null || true
          continue
        fi
      fi
    fi
    if [[ $retries -ge 20 ]]; then
      echo "❌ Could not acquire state lock after 10s. Remove '$LOCK_DIR' if stale."
      return 1
    fi
    sleep 0.5
  done
  LOCK_ACQUIRED=true
}

# --------------------------------------------------------------------------
# State helpers
# --------------------------------------------------------------------------

init_state() {
  local force=false
  if [[ "${1:-}" == "--force" ]]; then
    force=true
    shift
  fi

  local doc_path="${1:-docs/design-doc.md}"
  local plan_path="${2:-docs/plan.md}"

  # FIX(HIGH): acquire lock before reading state to prevent TOCTOU race
  acquire_lock || return 1

  if [[ -f "$STATE_FILE" ]] && ! $force; then
    local current_phase current_active
    current_phase=$(read_json_field "phase" 2>/dev/null || echo "unknown")
    current_active=$(read_json_field "active" 2>/dev/null || echo "true")
    if [[ "$current_active" != "false" && "$current_phase" != "9" ]]; then
      echo "❌ A HAIL loop is already active (Phase $current_phase)."
      echo "   Use '--force' to overwrite: bash hail-loop.sh init --force [DOC] [PLAN]"
      return 1
    fi
  fi

  mkdir -p "$PROJECT_ROOT/.gemini"

  local started_at
  started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  local state_tmp
  state_tmp=$(mktemp "$PROJECT_ROOT/.gemini/.hail-init.XXXXXX")
  TEMP_FILES+=("$state_tmp")

  if command -v python3 >/dev/null 2>&1; then
    # FIX(LOW): pass paths via env vars to avoid heredoc expansion and single-quote injection
    HAIL_STATE_FILE="$state_tmp" \
    HAIL_DOC_PATH="$doc_path" \
    HAIL_PLAN_PATH="$plan_path" \
    HAIL_TIMESTAMP="$started_at" \
    python3 - <<'PYEOF'
import json, os
d = {
    "active": True,
    "phase": 1,
    "phase_name": "Discuss Phase",
    "design_doc_path": os.environ['HAIL_DOC_PATH'],
    "plan_path": os.environ['HAIL_PLAN_PATH'],
    "doc_review_iterations": 0,
    "plan_review_iterations": 0,
    "started_at": os.environ['HAIL_TIMESTAMP'],
    "last_updated": os.environ['HAIL_TIMESTAMP'],
}
with open(os.environ['HAIL_STATE_FILE'], 'w') as f:
    json.dump(d, f, indent=2)
PYEOF
  elif command -v jq >/dev/null 2>&1; then
    # FIX(LOW): use --arg so jq handles all JSON escaping for paths
    jq -n \
      --arg doc "$doc_path" \
      --arg plan "$plan_path" \
      --arg ts "$started_at" \
      '{"active": true, "phase": 1, "phase_name": "Discuss Phase",
        "design_doc_path": $doc, "plan_path": $plan,
        "doc_review_iterations": 0, "plan_review_iterations": 0,
        "started_at": $ts, "last_updated": $ts}' > "$state_tmp"
  else
    # FIX(LOW): sanitize \, $, ` before injecting into heredoc to prevent expansion
    local doc_safe="${doc_path//\\/\\\\}"
    doc_safe="${doc_safe//\$/\\\$}"
    doc_safe="${doc_safe//\`/\\\`}"
    doc_safe="${doc_safe//\"/\\\"}"
    local plan_safe="${plan_path//\\/\\\\}"
    plan_safe="${plan_safe//\$/\\\$}"
    plan_safe="${plan_safe//\`/\\\`}"
    plan_safe="${plan_safe//\"/\\\"}"
    cat > "$state_tmp" <<EOF
{
  "active": true,
  "phase": 1,
  "phase_name": "Discuss Phase",
  "design_doc_path": "$doc_safe",
  "plan_path": "$plan_safe",
  "doc_review_iterations": 0,
  "plan_review_iterations": 0,
  "started_at": "$started_at",
  "last_updated": "$started_at"
}
EOF
  fi

  mv "$state_tmp" "$STATE_FILE"
  echo "✅ HAIL Loop initialized successfully!"
  show_status
}

read_json_field() {
  local field="$1"
  if command -v jq >/dev/null 2>&1; then
    # FIX(HIGH): avoid // empty which treats boolean false as falsy and returns ""
    # Use explicit null check so false → "false", true → "true", null → empty
    jq -r ".$field | if . == null then empty else . end" "$STATE_FILE"
  elif command -v python3 >/dev/null 2>&1; then
    # FIX(HIGH+MEDIUM): pass STATE_FILE via env var; normalize bool with lower()
    # so Python False → "false" not "False", matching grep fallback and jq output
    HAIL_STATE_FILE="$STATE_FILE" python3 -c \
      "import json,os; v=json.load(open(os.environ['HAIL_STATE_FILE'])).get('$field'); print('' if v is None else (str(v).lower() if isinstance(v, bool) else v))"
  else
    grep -o "\"$field\": *\"*[^\",]*\"*" "$STATE_FILE" | cut -d':' -f2 | tr -d ' ",'
  fi
}

show_status() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ HAIL loop is not initialized. Run 'bash hail-loop.sh init' to start."
    return 1
  fi

  # Guard against empty or corrupted JSON
  if [[ ! -s "$STATE_FILE" ]]; then
    echo "❌ State file is empty: $STATE_FILE"
    echo "   Run 'bash hail-loop.sh init --force' to reset."
    return 1
  fi
  if command -v jq >/dev/null 2>&1 && ! jq -e . "$STATE_FILE" >/dev/null 2>&1; then
    echo "❌ State file is corrupted: $STATE_FILE"
    echo "   Run 'bash hail-loop.sh init --force' to reset."
    return 1
  fi

  local active phase name doc plan doc_iter plan_iter
  active=$(read_json_field "active")
  phase=$(read_json_field "phase")
  name=$(read_json_field "phase_name")
  doc=$(read_json_field "design_doc_path")
  plan=$(read_json_field "plan_path")
  doc_iter=$(read_json_field "doc_review_iterations"); doc_iter="${doc_iter:-0}"
  plan_iter=$(read_json_field "plan_review_iterations"); plan_iter="${plan_iter:-0}"

  echo "🔄 HAIL Current State:"
  echo "-----------------------------------"
  echo "  Active:      $active"
  echo "  Phase:       $phase ($name)"
  echo "  Design Doc:  $doc"
  echo "  Plan Path:   $plan"
  [[ $doc_iter -gt 0 ]]  && echo "  Doc Review:  iteration $doc_iter / $MAX_REVIEW_ITERATIONS"
  [[ $plan_iter -gt 0 ]] && echo "  Plan Review: iteration $plan_iter / $MAX_REVIEW_ITERATIONS"
  echo "-----------------------------------"

  # FIX(LOW): show completed state instead of "Ready to Implement" after complete
  if [[ "$active" == "false" ]]; then
    echo "✅ Workflow complete. Run 'bash hail-loop.sh init' to start a new workflow."
    return 0
  fi

  case "$phase" in
    1) echo "👉 Next Step: Discuss direction and architecture with the human." ;;
    2) echo "👉 Next Step: Write design doc to '$doc'." ;;
    3) echo "👉 Next Step: Request human review on '$doc'." ;;
    4) echo "👉 Next Step: Run subagent code review on '$doc'. [Doc Review Iteration $doc_iter / $MAX_REVIEW_ITERATIONS]" ;;
    5) echo "👉 Next Step: (Optional) Request final human review on '$doc'." ;;
    6) echo "👉 Next Step: Write execution plan to '$plan'." ;;
    7) echo "👉 Next Step: Run subagent code review on '$plan'. [Plan Review Iteration $plan_iter / $MAX_REVIEW_ITERATIONS]" ;;
    8) echo "👉 Next Step: Request final human review on '$plan'." ;;
    9) echo "🎉 Ready to Implement! Proceed with TDD and coding." ;;
  esac
}

phase_name_for() {
  case "$1" in
    1) echo "Discuss Phase" ;;
    2) echo "Write Design Doc" ;;
    3) echo "Human Review" ;;
    4) echo "Subagent Review Doc" ;;
    5) echo "Human Review Optional" ;;
    6) echo "Write Plan" ;;
    7) echo "Subagent Review Plan" ;;
    8) echo "Human Final Review" ;;
    9) echo "Implement Phase" ;;
    *) echo "" ;;
  esac
}

# write_phase: update phase/name/timestamp in state JSON, optionally increment a counter.
# Uses atomic write (temp file + replace) for python3 and jq paths.
write_phase() {
  local current_phase="$1"
  local new_phase="$2"
  local new_name="$3"
  local increment_key="${4:-}"
  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if command -v python3 >/dev/null 2>&1; then
    # FIX(MEDIUM): pass all values via env vars + quoted <<'PYEOF' to prevent
    # single-quote injection in STATE_FILE path and heredoc shell expansion
    HAIL_STATE_FILE="$STATE_FILE" \
    HAIL_NEW_PHASE="$new_phase" \
    HAIL_NEW_NAME="$new_name" \
    HAIL_TIMESTAMP="$timestamp" \
    HAIL_INCREMENT_KEY="${increment_key:-}" \
    python3 - <<'PYEOF'
import json, os, tempfile
state_file = os.environ['HAIL_STATE_FILE']
with open(state_file, 'r') as f:
    d = json.load(f)
d['phase'] = int(os.environ['HAIL_NEW_PHASE'])
d['phase_name'] = os.environ['HAIL_NEW_NAME']
d['last_updated'] = os.environ['HAIL_TIMESTAMP']
inc_key = os.environ.get('HAIL_INCREMENT_KEY', '')
if inc_key:
    d[inc_key] = d.get(inc_key, 0) + 1
dir_name = os.path.dirname(state_file) or '.'
with tempfile.NamedTemporaryFile('w', dir=dir_name, delete=False, suffix='.tmp') as tf:
    json.dump(d, tf, indent=2)
    tmp_path = tf.name
os.replace(tmp_path, state_file)
PYEOF
  elif command -v jq >/dev/null 2>&1; then
    local tmp jq_expr
    tmp=$(mktemp "$PROJECT_ROOT/.gemini/.hail-state-tmp.XXXXXX")
    # FIX(MEDIUM): register in TEMP_FILES so EXIT trap cleans up on jq failure
    TEMP_FILES+=("$tmp")
    jq_expr=".phase = $new_phase | .phase_name = \"$new_name\" | .last_updated = \"$timestamp\""
    if [[ -n "$increment_key" ]]; then
      jq_expr="$jq_expr | .$increment_key = (.$increment_key // 0) + 1"
    fi
    jq "$jq_expr" "$STATE_FILE" > "$tmp"
    mv "$tmp" "$STATE_FILE"
  else
    sed_i "s/\"phase\": $current_phase/\"phase\": $new_phase/"
    sed_i "s/\"phase_name\": \"[^\"]*\"/\"phase_name\": \"$new_name\"/"
    sed_i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/"
    if [[ -n "$increment_key" ]]; then
      local cur_val
      # FIX(LOW): use [0-9]+ (one-or-more) to avoid zero-length matches from GNU grep
      cur_val=$(grep -o "\"$increment_key\": *[0-9]*" "$STATE_FILE" | grep -oE '[0-9]+' | head -1 || echo "0")
      cur_val="${cur_val:-0}"
      local new_val=$(( cur_val + 1 ))
      sed_i "s/\"$increment_key\": $cur_val/\"$increment_key\": $new_val/"
    fi
  fi
}

# --------------------------------------------------------------------------
# Phase transitions
# --------------------------------------------------------------------------

advance_phase() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ HAIL loop is not initialized."
    return 1
  fi

  acquire_lock || return 1

  local current_phase active
  current_phase=$(read_json_field "phase")
  active=$(read_json_field "active")

  # FIX(LOW): guard against advancing a completed workflow
  if [[ "$active" == "false" ]]; then
    echo "❌ Workflow is already complete. Run 'bash hail-loop.sh init' to start a new one."
    return 1
  fi

  if [[ ! "$current_phase" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: Could not read a valid phase from $STATE_FILE"
    return 1
  fi

  local next_phase=$((current_phase + 1))

  if [[ $next_phase -gt 9 ]]; then
    echo "🎉 Already at final implementation phase!"
    return 0
  fi

  local next_name increment_key=""
  next_name=$(phase_name_for "$next_phase")
  [[ $next_phase -eq 4 ]] && increment_key="doc_review_iterations"
  [[ $next_phase -eq 7 ]] && increment_key="plan_review_iterations"

  write_phase "$current_phase" "$next_phase" "$next_name" "$increment_key"
  echo "➡️ Advanced from Phase $current_phase to Phase $next_phase ($next_name)"

  # Warn when the iteration cap is reached so the agent knows to escalate
  if [[ -n "$increment_key" ]]; then
    local new_iter
    new_iter=$(read_json_field "$increment_key"); new_iter="${new_iter:-0}"
    if [[ $new_iter -ge $MAX_REVIEW_ITERATIONS ]]; then
      local label
      [[ "$increment_key" == "doc_review_iterations" ]] && label="Design Doc" || label="Plan"
      echo ""
      echo "⚠️  ITERATION CAP REACHED: $label review is at iteration $new_iter / $MAX_REVIEW_ITERATIONS."
      echo "   If this review finds issues, DO NOT revert. Escalate to the human instead."
    fi
  fi

  show_status
}

revert_phase() {
  local force=false
  if [[ "${1:-}" == "--force" ]]; then
    force=true
    shift
  fi

  if [[ $# -lt 1 ]]; then
    echo "❌ Usage: bash hail-loop.sh revert [--force] <PHASE_NUMBER>"
    echo "   Example: bash hail-loop.sh revert 2  (design doc review found issues)"
    echo "   Example: bash hail-loop.sh revert 6  (plan review found issues)"
    return 1
  fi

  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ HAIL loop is not initialized."
    return 1
  fi

  local target_phase="$1"

  if [[ ! "$target_phase" =~ ^[1-9]$ ]]; then
    echo "❌ Invalid phase '$target_phase'. Must be a number between 1 and 9."
    return 1
  fi

  acquire_lock || return 1

  local current_phase
  current_phase=$(read_json_field "phase")

  if [[ ! "$current_phase" =~ ^[0-9]+$ ]]; then
    echo "❌ Error: Could not read a valid phase from $STATE_FILE"
    return 1
  fi

  if [[ $target_phase -ge $current_phase ]]; then
    echo "❌ Cannot revert to Phase $target_phase — current phase is $current_phase. Use 'advance' to move forward."
    return 1
  fi

  # Warn for non-canonical revert paths
  local is_canonical=false
  [[ $current_phase -eq 4 && $target_phase -eq 2 ]] && is_canonical=true
  [[ $current_phase -eq 7 && $target_phase -eq 6 ]] && is_canonical=true
  if ! $is_canonical; then
    echo "⚠️  Non-canonical revert: Phase $current_phase → Phase $target_phase."
    echo "   Standard paths: revert 2 (from phase 4), revert 6 (from phase 7)."
  fi

  # Block the loop when the iteration cap is reached for the two canonical revert paths
  local cap_key=""
  [[ $current_phase -eq 4 && $target_phase -eq 2 ]] && cap_key="doc_review_iterations"
  [[ $current_phase -eq 7 && $target_phase -eq 6 ]] && cap_key="plan_review_iterations"

  if [[ -n "$cap_key" ]] && ! $force; then
    local cur_iter
    cur_iter=$(read_json_field "$cap_key"); cur_iter="${cur_iter:-0}"
    if [[ $cur_iter -ge $MAX_REVIEW_ITERATIONS ]]; then
      local label
      [[ "$cap_key" == "doc_review_iterations" ]] && label="Design Doc" || label="Plan"
      echo "🚨 ESCALATE — $label review has run $cur_iter / $MAX_REVIEW_ITERATIONS times."
      echo "   Stop looping. Present outstanding issues to the human for a final decision."
      echo "   To override: bash hail-loop.sh revert --force $target_phase"
      return 1
    fi
  fi

  local target_name
  target_name=$(phase_name_for "$target_phase")

  write_phase "$current_phase" "$target_phase" "$target_name"
  echo "⏪ Reverted from Phase $current_phase to Phase $target_phase ($target_name)"
  show_status
}

complete_workflow() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ No active HAIL loop to complete."
    return 1
  fi

  acquire_lock || return 1

  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if command -v python3 >/dev/null 2>&1; then
    # FIX(MEDIUM): pass values via env vars + quoted <<'PYEOF' to prevent injection
    HAIL_STATE_FILE="$STATE_FILE" \
    HAIL_TIMESTAMP="$timestamp" \
    python3 - <<'PYEOF'
import json, os, tempfile
state_file = os.environ['HAIL_STATE_FILE']
with open(state_file, 'r') as f:
    d = json.load(f)
d['active'] = False
d['phase'] = 9
d['phase_name'] = 'Implement Phase'
d['last_updated'] = os.environ['HAIL_TIMESTAMP']
dir_name = os.path.dirname(state_file) or '.'
with tempfile.NamedTemporaryFile('w', dir=dir_name, delete=False, suffix='.tmp') as tf:
    json.dump(d, tf, indent=2)
    tmp_path = tf.name
os.replace(tmp_path, state_file)
PYEOF
  elif command -v jq >/dev/null 2>&1; then
    local tmp
    tmp=$(mktemp "$PROJECT_ROOT/.gemini/.hail-state-tmp.XXXXXX")
    # FIX(MEDIUM): register in TEMP_FILES so EXIT trap cleans up on jq failure
    TEMP_FILES+=("$tmp")
    jq ".active = false | .phase = 9 | .phase_name = \"Implement Phase\" | .last_updated = \"$timestamp\"" "$STATE_FILE" > "$tmp"
    mv "$tmp" "$STATE_FILE"
  else
    # FIX(MEDIUM): update all fields in the sed fallback, not just "active"
    sed_i "s/\"active\": true/\"active\": false/"
    sed_i "s/\"phase\": [0-9]*/\"phase\": 9/"
    sed_i "s/\"phase_name\": \"[^\"]*\"/\"phase_name\": \"Implement Phase\"/"
    sed_i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/"
  fi

  echo "✅ HAIL workflow marked as complete. State preserved for reference."
  echo "   Run 'bash hail-loop.sh init' to start a new workflow."
}

cancel_workflow() {
  if [[ -f "$STATE_FILE" ]]; then
    # FIX(MEDIUM): acquire lock before deleting to prevent race with concurrent advance/revert
    acquire_lock || return 1
    rm -f "$STATE_FILE"
    echo "✅ HAIL Loop cancelled and state reset."
  else
    echo "❌ No active HAIL loop to cancel."
  fi
}

# --------------------------------------------------------------------------
# Entry point
# --------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
  init)     init_state "$@" ;;
  status)   show_status ;;
  advance)  advance_phase ;;
  revert)   revert_phase "$@" ;;
  complete) complete_workflow ;;
  cancel)   cancel_workflow ;;
  *)        show_help; exit 1 ;;
esac
