# Agent Workflow Model

## The core idea

Your AI coding agent lives on the VPS. You connect to it from anywhere — laptop, phone, tablet. You give it tasks. It implements, tests, commits, and opens PRs. You review and merge.

The agent never merges its own work. You do.

---

## Session lifecycle

```
Morning (from your phone)
  │
  ├─ SSH into VPS
  ├─ attach to project session
  ├─ check what the agent did overnight (PR on GitHub)
  └─ give the next task

  Agent works...

Evening (from your laptop)
  │
  ├─ SSH into VPS
  ├─ attach to same session (still running)
  ├─ review the PR
  └─ disconnect — agent keeps working
```

You never lose context. The session is always there.

---

## The four windows

| Window | Purpose |
|---|---|
| `agent` | The AI coding agent runs here — give it tasks, read its output |
| `git` | Manual git operations, branch management, PR creation checks |
| `tests` | Watch test output, re-run specific tests |
| `logs` | Tail app logs or server output |

Switch between windows: `Ctrl+B` then the window number (`0`, `1`, `2`, `3`).

---

## What the agent does vs what you do

| Agent (automated) | You (required) |
|---|---|
| Read and understand code | Decide what to build |
| Write implementation | Review the PR |
| Write tests | Merge the PR |
| Commit to branch | Approve production deploys |
| Push branch | Handle escalated blockers |
| Open pull request | |
| Run CI locally | |

---

## Giving a task

Be specific. The agent works best with clear scope:

**Good:**
```
Fix the login form — it doesn't validate email format before submitting.
The form is in src/components/LoginForm.tsx.
Add a test for the validation case.
Open a PR when done.
```

**Too vague:**
```
Fix the bugs.
```

**Too broad:**
```
Refactor the entire auth module.
```

---

## Handling long tasks

For tasks that take hours:

1. Give the task
2. Detach from tmux (`Ctrl+B` then `D`)
3. Disconnect SSH — the session keeps running
4. Come back later and attach to check progress

The agent will be in the middle of work exactly where you left it.

---

## Multiple projects

Each project gets its own named tmux session:

```bash
new-session.sh project-a   # window 0, 1, 2, 3 for project A
new-session.sh project-b   # window 0, 1, 2, 3 for project B
```

Switch between projects:

```bash
tmux switch -t project-b
```

List all:

```bash
list-sessions.sh
```

---

## When something goes wrong

If the agent makes a mistake:

```bash
# On the git window
git log --oneline -10        # see recent commits
git diff HEAD~1              # see what changed
git revert HEAD              # undo the last commit safely
git push origin branch-name  # push the revert
```

Never force-push to shared branches. Revert, don't rewrite.
