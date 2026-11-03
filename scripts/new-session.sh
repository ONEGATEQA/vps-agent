#!/usr/bin/env bash
# new-session.sh — create a new named tmux session for a project
# Usage: new-session.sh <project-name> [/path/to/project]
set -euo pipefail

PROJECT="${1:-}"
PROJECT_DIR="${2:-$HOME/projects/$PROJECT}"

[[ -z "$PROJECT" ]] && { echo "Usage: new-session.sh <project-name> [/path/to/project]"; exit 1; }

# Check if session already exists
if tmux has-session -t "$PROJECT" 2>/dev/null; then
  echo "Session '$PROJECT' already exists. Attaching..."
  tmux attach -t "$PROJECT"
  exit 0
fi

# Create project directory if it doesn't exist
mkdir -p "$PROJECT_DIR"

echo "Creating session: $PROJECT"
echo "Project dir:      $PROJECT_DIR"

# Create the session with 4 windows
tmux new-session  -d -s "$PROJECT" -n "agent"  -c "$PROJECT_DIR"
tmux new-window      -t "$PROJECT" -n "git"    -c "$PROJECT_DIR"
tmux new-window      -t "$PROJECT" -n "tests"  -c "$PROJECT_DIR"
tmux new-window      -t "$PROJECT" -n "logs"   -c "$PROJECT_DIR"

# Focus the agent window
tmux select-window -t "$PROJECT:agent"

# Print session info
echo ""
echo "Session '$PROJECT' created with windows:"
echo "  0: agent   ← your AI coding agent"
echo "  1: git     ← git operations and PRs"
echo "  2: tests   ← test runner"
echo "  3: logs    ← server/app logs"
echo ""
echo "Attaching..."
tmux attach -t "$PROJECT"
