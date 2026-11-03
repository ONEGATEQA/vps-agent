#!/usr/bin/env bash
# kill-session.sh — cleanly remove a project session
# Usage: kill-session.sh <project-name>
set -euo pipefail

PROJECT="${1:-}"
[[ -z "$PROJECT" ]] && { echo "Usage: kill-session.sh <project-name>"; exit 1; }

if ! tmux has-session -t "$PROJECT" 2>/dev/null; then
  echo "Session '$PROJECT' not found."
  exit 1
fi

read -rp "Kill session '$PROJECT'? This cannot be undone. [y/N] " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

tmux kill-session -t "$PROJECT"
echo "Session '$PROJECT' removed."
