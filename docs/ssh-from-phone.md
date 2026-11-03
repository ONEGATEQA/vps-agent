# SSH from Your Phone

Attach to your VPS agent session from iOS or Android.

---

## iOS

**Blink Shell** (recommended) — $20 one-time, best SSH client on iOS.

1. Install [Blink Shell](https://blink.sh) from the App Store
2. Open Blink → Settings → Keys → Add a new key
3. Generate an Ed25519 key — copy the public key
4. On your VPS:
   ```bash
   echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys
   ```
5. In Blink: Settings → Hosts → New host
   - Host: your VPS IP or domain
   - User: your agent username
   - Key: select the key you created
6. Connect: `ssh your-vps` or tap the host

**Termius** — free tier works, cross-platform.

---

## Android

**Termux** — free, powerful, runs a full Linux environment.

1. Install [Termux](https://f-droid.org/en/packages/com.termux/) from F-Droid (not Play Store — use F-Droid version)
2. In Termux:
   ```bash
   pkg install openssh
   ssh-keygen -t ed25519 -C "my-phone"
   cat ~/.ssh/id_ed25519.pub
   ```
3. Copy the public key output
4. On your VPS:
   ```bash
   echo 'YOUR_PUBLIC_KEY' >> ~/.ssh/authorized_keys
   ```
5. Back in Termux:
   ```bash
   ssh user@YOUR_VPS_IP
   ```

**Termius** — free tier works, same as iOS.

---

## Quick connect alias

Add this to your phone's SSH config for one-tap connect:

On your phone, create `~/.ssh/config`:
```
Host agent
  HostName YOUR_VPS_IP
  User YOUR_USERNAME
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
```

Then connect with just:
```bash
ssh agent
```

---

## Attach to session from phone

```bash
ssh agent
attach.sh my-project
```

You're now looking at exactly what was running — nothing lost.

---

## Keep connection alive

Add to your phone's SSH config:
```
ServerAliveInterval 30
ServerAliveCountMax 6
```

This sends keepalive packets every 30 seconds so the connection doesn't drop on mobile networks.
