#!/bin/bash

# Human-Agent-in-the-Loop Development Loop Controller
# Manages HAIL workflow state and automates step advancement

set -euo pipefail

STATE_FILE=".gemini/hail-state.json"

show_help() {
  cat << 'EOF'
Human-Agent-in-the-Loop (HAIL) Workflow Controller

USAGE:
  bash hail-loop.sh [COMMAND] [ARGS]

COMMANDS:
  init [DESIGN_DOC_PATH] [PLAN_PATH]
      Initialize the HAIL workflow loop.

  status
      Print current phase and next steps.

  advance
      Advance to the next phase (after review passes or step completes).

  revert <PHASE_NUMBER>
      Revert to a specific phase (after review finds issues).
      Use phase 2 when design doc review (phase 4) finds issues.
      Use phase 6 when plan review (phase 7) finds issues.

  cancel
      Reset or terminate the workflow.

PHASES:
  1. Discuss Phase (Discuss direction and architecture)
  2. Write Design Doc (Write technical design document)
  3. Human Review (Initial human review of design doc)
  4. Subagent Review Doc (code-reviewer subagent verification)
  5. Human Review Optional (Final review of design doc)
  6. Write Plan (Write execution plan)
  7. Subagent Review Plan (code-reviewer subagent verification)
  8. Human Final Review (Final approval of execution plan)
  9. Implement Phase (TDD and implementation phase)
EOF
}

init_state() {
  local doc_path="${1:-docs/design-doc.md}"
  local plan_path="${2:-docs/plan.md}"
  
  # Escape quotes for clean JSON heredoc
  doc_path="${doc_path//\"/\\\"}"
  plan_path="${plan_path//\"/\\\"}"
  
  mkdir -p .gemini
  
  cat > "$STATE_FILE" <<EOF
{
  "active": true,
  "phase": 1,
  "phase_name": "Discuss Phase",
  "design_doc_path": "$doc_path",
  "plan_path": "$plan_path",
  "doc_review_iterations": 0,
  "plan_review_iterations": 0,
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
  echo "✅ HAIL Loop initialized successfully!"
  show_status
}

read_json_field() {
  local field="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r ".$field" "$STATE_FILE"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import json; print(json.load(open('$STATE_FILE')).get('$field', ''))"
  else
    # Simple regex fallback if python/jq are missing
    grep -o "\"$field\": *\"*[^\",]*\"*" "$STATE_FILE" | cut -d':' -f2 | tr -d ' ",' 
  fi
}

show_status() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ HAIL loop is not initialized. Run 'bash hail-loop.sh init' to start."
    return 1
  fi
  
  local active phase name doc plan doc_iter plan_iter
  active=$(read_json_field "active")
  phase=$(read_json_field "phase")
  name=$(read_json_field "phase_name")
  doc=$(read_json_field "design_doc_path")
  plan=$(read_json_field "plan_path")
  doc_iter=$(read_json_field "doc_review_iterations")
  plan_iter=$(read_json_field "plan_review_iterations")
  doc_iter="${doc_iter:-0}"
  plan_iter="${plan_iter:-0}"

  echo "🔄 HAIL Current State:"
  echo "-----------------------------------"
  echo "  Active:      $active"
  echo "  Phase:       $phase ($name)"
  echo "  Design Doc:  $doc"
  echo "  Plan Path:   $plan"
  [[ $doc_iter -gt 0 ]] && echo "  Doc Review:  iteration $doc_iter"
  [[ $plan_iter -gt 0 ]] && echo "  Plan Review: iteration $plan_iter"
  echo "-----------------------------------"

  case "$phase" in
    1) echo "👉 Next Step: Discuss direction and architecture with the human." ;;
    2) echo "👉 Next Step: Write design doc to '$doc'." ;;
    3) echo "👉 Next Step: Request human review on '$doc'." ;;
    4) echo "👉 Next Step: Run subagent code review on '$doc'. [Doc Review Iteration $doc_iter]" ;;
    5) echo "👉 Next Step: (Optional) Request final human review on '$doc'." ;;
    6) echo "👉 Next Step: Write execution plan to '$plan'." ;;
    7) echo "👉 Next Step: Run subagent code review on '$plan'. [Plan Review Iteration $plan_iter]" ;;
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

write_phase() {
  local current_phase="$1"
  local new_phase="$2"
  local new_name="$3"
  local increment_key="${4:-}"  # optional: field name to increment by 1
  local timestamp
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    d = json.load(f)
d['phase'] = $new_phase
d['phase_name'] = '$new_name'
d['last_updated'] = '$timestamp'
$(if [[ -n "$increment_key" ]]; then echo "d['$increment_key'] = d.get('$increment_key', 0) + 1"; fi)
with open('$STATE_FILE', 'w') as f:
    json.dump(d, f, indent=2)
"
  elif command -v jq >/dev/null 2>&1; then
    local tmp jq_expr
    tmp=$(mktemp)
    jq_expr=".phase = $new_phase | .phase_name = \"$new_name\" | .last_updated = \"$timestamp\""
    if [[ -n "$increment_key" ]]; then
      jq_expr="$jq_expr | .$increment_key = (.$increment_key // 0) + 1"
    fi
    jq "$jq_expr" "$STATE_FILE" > "$tmp"
    mv "$tmp" "$STATE_FILE"
  else
    local is_mac=false
    [[ "$(uname)" == "Darwin" ]] && is_mac=true
    sed_i() { if $is_mac; then sed -i '' "$1" "$STATE_FILE"; else sed -i "$1" "$STATE_FILE"; fi; }
    sed_i "s/\"phase\": $current_phase/\"phase\": $new_phase/"
    sed_i "s/\"phase_name\": \"[^\"]*\"/\"phase_name\": \"$new_name\"/"
    sed_i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$timestamp\"/"
    if [[ -n "$increment_key" ]]; then
      local cur_val
      cur_val=$(grep -o "\"$increment_key\": *[0-9]*" "$STATE_FILE" | grep -o '[0-9]*' || echo "0")
      cur_val="${cur_val:-0}"
      local new_val=$(( cur_val + 1 ))
      sed_i "s/\"$increment_key\": $cur_val/\"$increment_key\": $new_val/"
    fi
  fi
}

advance_phase() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "❌ HAIL loop is not initialized."
    return 1
  fi

  local current_phase
  current_phase=$(read_json_field "phase")

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
  show_status
}

revert_phase() {
  if [[ $# -lt 1 ]]; then
    echo "❌ Usage: bash hail-loop.sh revert <PHASE_NUMBER>"
    echo "   Example: bash hail-loop.sh revert 2  (revert to Write Design Doc after review issues)"
    echo "   Example: bash hail-loop.sh revert 6  (revert to Write Plan after review issues)"
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

  local target_name
  target_name=$(phase_name_for "$target_phase")

  write_phase "$current_phase" "$target_phase" "$target_name"
  echo "⏪ Reverted from Phase $current_phase to Phase $target_phase ($target_name)"
  show_status
}

cancel_workflow() {
  if [[ -f "$STATE_FILE" ]]; then
    rm -f "$STATE_FILE"
    echo "✅ HAIL Loop cancelled and state reset."
  else
    echo "❌ No active HAIL loop to cancel."
  fi
}

# Parse subcommand
if [[ $# -lt 1 ]]; then
  show_help
  exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
  init)
    init_state "$@"
    ;;
  status)
    show_status
    ;;
  advance)
    advance_phase
    ;;
  revert)
    revert_phase "$@"
    ;;
  cancel)
    cancel_workflow
    ;;
  *)
    show_help
    exit 1
    ;;
esac
