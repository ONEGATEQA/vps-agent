#!/usr/bin/env bash
# attach.sh — attach to an existing project session
# Usage: attach.sh [project-name]
set -euo pipefail

PROJECT="${1:-}"

# If no project given, show picker
if [[ -z "$PROJECT" ]]; then
  SESSIONS=$(tmux ls -F "#{session_name}" 2>/dev/null || true)
  if [[ -z "$SESSIONS" ]]; then
    echo "No active sessions. Start one with: new-session.sh <project-name>"
    exit 1
  fi
  COUNT=$(echo "$SESSIONS" | wc -l)
  if [[ "$COUNT" -eq 1 ]]; then
    PROJECT="$SESSIONS"
  else
    echo "Active sessions:"
    echo "$SESSIONS" | nl -w2 -s") "
    echo ""
    read -rp "Enter session number or name: " CHOICE
    if [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
      PROJECT=$(echo "$SESSIONS" | sed -n "${CHOICE}p")
    else
      PROJECT="$CHOICE"
    fi
  fi
fi

if ! tmux has-session -t "$PROJECT" 2>/dev/null; then
  echo "Session '$PROJECT' not found."
  echo ""
  echo "Active sessions:"
  tmux ls 2>/dev/null || echo "(none)"
  exit 1
fi

echo "Attaching to: $PROJECT"
tmux attach -t "$PROJECT"
