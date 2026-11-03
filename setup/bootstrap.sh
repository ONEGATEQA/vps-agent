#!/usr/bin/env bash
# bootstrap.sh — one-time VPS setup for vps-agent
# Run as root or with sudo on a fresh Ubuntu 24.04 server
# Usage: bash setup/bootstrap.sh [username]
set -euo pipefail

AGENT_USER="${1:-agent}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log()  { echo "[bootstrap] $*"; }
die()  { echo "[bootstrap] ERROR: $*" >&2; exit 1; }

[[ "$(id -u)" -eq 0 ]] || die "Run as root or with sudo"

# ── System update ────────────────────────────────────────────────────────────
log "Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

# ── Core packages ────────────────────────────────────────────────────────────
log "Installing core packages..."
apt-get install -y -qq \
  tmux \
  git \
  curl \
  wget \
  unzip \
  jq \
  htop \
  fail2ban \
  ufw \
  vim \
  build-essential \
  ca-certificates \
  gnupg

# ── Create agent user ────────────────────────────────────────────────────────
if ! id "$AGENT_USER" &>/dev/null; then
  log "Creating user: $AGENT_USER"
  useradd -m -s /bin/bash "$AGENT_USER"
  usermod -aG sudo "$AGENT_USER"
fi

# ── SSH hardening ────────────────────────────────────────────────────────────
log "Hardening SSH..."
cat > /etc/ssh/sshd_config.d/99-agent.conf << 'EOF'
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
MaxAuthTries 3
ClientAliveInterval 120
ClientAliveCountMax 3
EOF
systemctl restart sshd

# ── Firewall ─────────────────────────────────────────────────────────────────
log "Configuring firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

# ── fail2ban ─────────────────────────────────────────────────────────────────
log "Configuring fail2ban..."
cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
bantime  = 1h
findtime = 10m
maxretry = 5
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# ── tmux config ──────────────────────────────────────────────────────────────
log "Installing tmux config..."
TMUX_CONF="/home/$AGENT_USER/.tmux.conf"
cat > "$TMUX_CONF" << 'EOF'
# vps-agent tmux config
set -g default-terminal "screen-256color"
set -g history-limit 50000
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1

# Status bar
set -g status-bg colour235
set -g status-fg colour255
set -g status-left "#[fg=colour82,bold] #S #[fg=colour255]│ "
set -g status-right "#[fg=colour245] %Y-%m-%d %H:%M "
set -g status-left-length 30

# Window title
setw -g window-status-format         " #I:#W "
setw -g window-status-current-format " #[fg=colour82,bold]#I:#W "

# Easy pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"
EOF
chown "$AGENT_USER:$AGENT_USER" "$TMUX_CONF"

# ── Install scripts ───────────────────────────────────────────────────────────
log "Installing agent scripts..."
SCRIPTS_DIR="/home/$AGENT_USER/.local/bin"
mkdir -p "$SCRIPTS_DIR"

cp "$SCRIPT_DIR/../scripts/"*.sh "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/"*.sh
chown -R "$AGENT_USER:$AGENT_USER" "$SCRIPTS_DIR"

# Add to PATH
BASHRC="/home/$AGENT_USER/.bashrc"
if ! grep -q "\.local/bin" "$BASHRC" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
fi

# ── Node.js (via nvm) ─────────────────────────────────────────────────────────
log "Installing Node.js via nvm..."
sudo -u "$AGENT_USER" bash << 'NVMEOF'
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm use --lts
  npm install -g pnpm
NVMEOF

# ── Git defaults ──────────────────────────────────────────────────────────────
log "Setting git defaults..."
sudo -u "$AGENT_USER" git config --global init.defaultBranch main
sudo -u "$AGENT_USER" git config --global pull.rebase false
sudo -u "$AGENT_USER" git config --global core.editor vim

# ── Done ─────────────────────────────────────────────────────────────────────
log ""
log "Bootstrap complete."
log ""
log "Next steps:"
log "  1. Add your SSH public key:"
log "     mkdir -p /home/$AGENT_USER/.ssh"
log "     echo 'YOUR_PUBLIC_KEY' >> /home/$AGENT_USER/.ssh/authorized_keys"
log "     chmod 700 /home/$AGENT_USER/.ssh"
log "     chmod 600 /home/$AGENT_USER/.ssh/authorized_keys"
log "     chown -R $AGENT_USER:$AGENT_USER /home/$AGENT_USER/.ssh"
log ""
log "  2. SSH in as $AGENT_USER and start a session:"
log "     ssh $AGENT_USER@YOUR_VPS_IP"
log "     new-session.sh my-project"
log ""
