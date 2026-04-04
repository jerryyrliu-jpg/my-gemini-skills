#!/bin/bash
# web - Unified web skill router
# Routes to smart-fetch (fast extraction) or browser (interaction/search)

set -euo pipefail

SMART_FETCH="node $HOME/.openclaw/workspace/skills/smart-fetch/fetch.js"
BROWSER="$HOME/.openclaw/workspace/skills/browser/venv/bin/python3 $HOME/.openclaw/workspace/skills/browser/browser-agent-tool.py"

CMD="${1:-help}"
shift 2>/dev/null || true

case "$CMD" in
    fetch)
        # Route to smart-fetch (fast, token-efficient)
        $SMART_FETCH "$@"
        ;;
    search)
        # Route to browser (Google search simulation)
        $BROWSER search "$@"
        ;;
    screenshot)
        # Route to browser
        $BROWSER screenshot "$@"
        ;;
    click)
        # Route to browser (interaction)
        $BROWSER click "$@"
        ;;
    scroll)
        # Route to browser (interaction)
        $BROWSER scroll "$@"
        ;;
    help|*)
        cat <<'EOF'
Usage: web <command> [options]

Commands (smart-fetch backend - fast, token-efficient):
  fetch <url>                       Fetch and extract content
  fetch <url> --selector "css"      Extract specific elements
  fetch <url> --readability         Auto-clean article content
  fetch <url> --proxy               Use US proxy
  fetch <url> --format json|md|text Output format
  fetch <url> --screenshot out.png  Save screenshot
  fetch urls.txt --batch            Batch process URLs

Commands (browser backend - interaction/search):
  search --query "term"             Google search (top 10)
  screenshot --url <url> --name x   Full-page screenshot
  click --url <url> --selector "#x" Click element (needs approval)
  scroll --url <url>                Scroll to bottom
EOF
        ;;
esac
