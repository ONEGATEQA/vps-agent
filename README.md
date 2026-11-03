# vps-agent

**Run a persistent AI coding agent on a $6/month VPS.**

Most developers run AI coding agents on their laptop. The session dies when you close the lid. You come back the next day to a blank terminal and lost context.

This guide shows how to move your agent to a cheap VPS — always on, always connected, picking up exactly where you left off.

---

## Why VPS

| Laptop agent | VPS agent |
|---|---|
| Session dies when laptop sleeps | Session runs 24/7 |
| Context lost on disconnect | tmux keeps everything alive |
| Slow on battery | Dedicated CPU/RAM |
| One machine | SSH from anywhere |
| Local git operations only | Direct push/PR from server |

**Cost**: Hetzner CX22 or DigitalOcean Basic — $4–6/month. Less than a coffee.

---

## What you get

```
Your phone / laptop / tablet
        │  SSH
        ▼
   VPS (Ubuntu 24.04)
        │
   tmux session ──── agent workspace
        │                  │
        │            git worktrees
        │            test runner
        └──── always alive, always ready
```

- **Persistent sessions** via tmux — disconnect anytime, agent keeps running
- **Multiple projects** in separate tmux windows
- **One command** to attach from any device
- **Structured workflow** — agent commits to branches, you merge

---

## Quick start

### 1. Provision a VPS

Any Ubuntu 24.04 VPS works. Minimum specs:

```
RAM:  2 GB
CPU:  2 vCPU
Disk: 20 GB SSD
```

Providers: [Hetzner](https://hetzner.com) · [DigitalOcean](https://digitalocean.com) · [Vultr](https://vultr.com)

### 2. Bootstrap the server

```bash
# On your VPS (as root or sudo user)
curl -fsSL https://raw.githubusercontent.com/ONEGATEQA/vps-agent/main/setup/bootstrap.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/ONEGATEQA/vps-agent.git
cd vps-agent
bash setup/bootstrap.sh
```

### 3. Start your agent session

```bash
bash scripts/new-session.sh my-project
```

### 4. Attach from any device

```bash
ssh user@your-vps
bash scripts/attach.sh my-project
```

---

## Session structure

Each project gets its own named tmux session:

```
tmux session: my-project
├── window 0: agent        ← AI coding agent runs here
├── window 1: git          ← git operations, PR creation
├── window 2: tests        ← test runner
└── window 3: logs         ← server/app logs
```

Switch between projects:

```bash
tmux switch -t other-project
```

List all active sessions:

```bash
tmux ls
```

---

## File structure

```
vps-agent/
├── setup/
│   ├── bootstrap.sh          # One-time VPS setup
│   ├── install-tools.sh      # Dev tools (git, node, docker, etc.)
│   └── configure-ssh.sh      # Hardened SSH config
├── scripts/
│   ├── new-session.sh        # Create a new project session
│   ├── attach.sh             # Attach to existing session
│   ├── list-sessions.sh      # Show all sessions and status
│   └── kill-session.sh       # Clean up a project session
├── docs/
│   ├── workflow.md           # The agent workflow model
│   ├── multi-project.md      # Running multiple projects
│   └── ssh-from-phone.md     # Mobile SSH setup
└── examples/
    ├── session-rules.md      # Example agent instructions
    └── AGENT.md              # Drop this in any project repo
```

---

## The workflow model

The agent handles implementation. You handle decisions.

```
You (anywhere)
    │
    ├─ SSH into VPS
    ├─ attach to project session
    └─ give the agent a task
            │
            ▼
        Agent works:
        reads code → implements → runs tests → commits → pushes branch → opens PR
            │
            ▼
        Agent stops and reports
            │
            ▼
        You review the PR on GitHub
        You merge (or reject)
            │
            ▼
        Next task
```

**The agent never merges its own PRs. You do.**

See [docs/workflow.md](docs/workflow.md) for the full model.

---

## Agent instructions

Drop an `AGENT.md` file in your project repo to give the agent its operating rules. Example in [examples/AGENT.md](examples/AGENT.md).

Core rules every project should have:

```markdown
## What requires my approval before you proceed

- Merging any pull request
- Deploying to beta or production
- Destructive database operations
- Any change that cannot be reverted with git revert
```

---

## SSH from your phone

Full guide: [docs/ssh-from-phone.md](docs/ssh-from-phone.md)

Short version:
- iOS: **Blink Shell** or **Termius**
- Android: **Termux** or **Termius**
- Generate a key on your phone, add it to `~/.ssh/authorized_keys` on the VPS

---

## Security

- SSH key auth only (password login disabled by bootstrap)
- `fail2ban` installed by default
- Non-root user for agent work
- Agent runs in its own tmux session, isolated from system

---

## Contributing

Issues and PRs welcome. Keep it simple — this repo is a guide, not a framework.

---

## License

MIT

---

Built by [OneGate](https://onegate.qa)
