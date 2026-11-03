#!/usr/bin/env bash
# list-sessions.sh — show all active agent sessions with status
set -euo pipefail

echo ""
echo "Active agent sessions"
echo "─────────────────────────────────────────────────────"

if ! tmux ls 2>/dev/null; then
  echo "(no sessions running)"
  echo ""
  echo "Start one with: new-session.sh <project-name>"
  exit 0
fi

echo ""
echo "Attach with: attach.sh <session-name>"
echo ""
