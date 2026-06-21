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
      Advance to the next phase.
  
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
  
  local active phase name doc plan
  active=$(read_json_field "active")
  phase=$(read_json_field "phase")
  name=$(read_json_field "phase_name")
  doc=$(read_json_field "design_doc_path")
  plan=$(read_json_field "plan_path")

  echo "🔄 HAIL Current State:"
  echo "-----------------------------------"
  echo "  Active:      $active"
  echo "  Phase:       $phase ($name)"
  echo "  Design Doc:  $doc"
  echo "  Plan Path:   $plan"
  echo "-----------------------------------"
  
  case "$phase" in
    1) echo "👉 Next Step: Discuss direction and architecture with the human." ;;
    2) echo "👉 Next Step: Write design doc to '$doc'." ;;
    3) echo "👉 Next Step: Request human review on '$doc'." ;;
    4) echo "👉 Next Step: Run subagent code review on '$doc'." ;;
    5) echo "👉 Next Step: (Optional) Request final human review on '$doc'." ;;
    6) echo "👉 Next Step: Write execution plan to '$plan'." ;;
    7) echo "👉 Next Step: Run subagent code review on '$plan'." ;;
    8) echo "👉 Next Step: Request final human review on '$plan'." ;;
    9) echo "🎉 Ready to Implement! Proceed with TDD and coding." ;;
  esac
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
  
  local next_name=""
  case "$next_phase" in
    2) next_name="Write Design Doc" ;;
    3) next_name="Human Review" ;;
    4) next_name="Subagent Review Doc" ;;
    5) next_name="Human Review Optional" ;;
    6) next_name="Write Plan" ;;
    7) next_name="Subagent Review Plan" ;;
    8) next_name="Human Final Review" ;;
    9) next_name="Implement Phase" ;;
  esac

  # Safe json modification using Python or jq if available, fallback to sed
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
with open('$STATE_FILE', 'r') as f:
    d = json.load(f)
d['phase'] = $next_phase
d['phase_name'] = '$next_name'
d['last_updated'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$STATE_FILE', 'w') as f:
    json.dump(d, f, indent=2)
"
  elif command -v jq >/dev/null 2>&1; then
    local tmp
    tmp=$(mktemp)
    jq ".phase = $next_phase | .phase_name = \"$next_name\" | .last_updated = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$STATE_FILE" > "$tmp"
    mv "$tmp" "$STATE_FILE"
  else
    # sed backup
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s/\"phase\": $current_phase/\"phase\": $next_phase/" "$STATE_FILE"
      sed -i '' "s/\"phase_name\": \"[^\"]*\"/\"phase_name\": \"$next_name\"/" "$STATE_FILE"
      sed -i '' "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"/" "$STATE_FILE"
    else
      sed -i "s/\"phase\": $current_phase/\"phase\": $next_phase/" "$STATE_FILE"
      sed -i "s/\"phase_name\": \"[^\"]*\"/\"phase_name\": \"$next_name\"/" "$STATE_FILE"
      sed -i "s/\"last_updated\": \"[^\"]*\"/\"last_updated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"/" "$STATE_FILE"
    fi
  fi

  echo "➡️ Advanced from Phase $current_phase to Phase $next_phase ($next_name)"
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
  cancel)
    cancel_workflow
    ;;
  *)
    show_help
    exit 1
    ;;
esac
