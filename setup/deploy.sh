#!/usr/bin/env bash
# Deploy OpenClaw config to VPS
# Usage: ./deploy.sh <DROPLET_IP> [ANTHROPIC_API_KEY]
set -euo pipefail

DROPLET_IP="${1:?Usage: ./deploy.sh <DROPLET_IP> [ANTHROPIC_API_KEY] [TELEGRAM_BOT_TOKEN]}"
API_KEY="${2:-}"
TELEGRAM_TOKEN="${3:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_USER="openclaw"

echo "=== Deploying OpenClaw to ${DROPLET_IP} ==="

# 1. Run bootstrap if needed (as root)
echo "[1/5] Running VPS bootstrap (if first time)..."
ssh "root@${DROPLET_IP}" "bash -s" < "${SCRIPT_DIR}/droplet-setup.sh" || true

# 2. Copy config files
echo "[2/5] Copying configuration..."
ssh "${SSH_USER}@${DROPLET_IP}" "mkdir -p ~/.openclaw/workspace"
scp "${SCRIPT_DIR}/openclaw-config.json5" "${SSH_USER}@${DROPLET_IP}:~/.openclaw/openclaw.json"
scp "${SCRIPT_DIR}/soul.md" "${SSH_USER}@${DROPLET_IP}:~/.openclaw/workspace/SOUL.md"

# 3. Write secrets to .env.secrets (NOT .env — openclaw update wipes .env)
#    Keys live in .env.secrets + a systemd drop-in injects them into the service.
#    This survives openclaw updates automatically.
if [ -n "$API_KEY" ] || [ -n "$TELEGRAM_TOKEN" ]; then
    echo "[3/5] Writing ~/.openclaw/.env.secrets and systemd drop-in..."
    # Write secrets file
    SECRETS=""
    [ -n "$API_KEY" ]        && SECRETS+="ANTHROPIC_API_KEY=${API_KEY}\n"
    [ -n "$TELEGRAM_TOKEN" ] && SECRETS+="TELEGRAM_BOT_TOKEN=${TELEGRAM_TOKEN}\n"
    ssh "${SSH_USER}@${DROPLET_IP}" "printf '${SECRETS}' > ~/.openclaw/.env.secrets && chmod 600 ~/.openclaw/.env.secrets"
    # Install systemd drop-in so service picks up the secrets file
    ssh "${SSH_USER}@${DROPLET_IP}" "
        mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d
        cat > ~/.config/systemd/user/openclaw-gateway.service.d/secrets.conf <<'EOF'
[Service]
EnvironmentFile=%h/.openclaw/.env.secrets
EOF
        systemctl --user daemon-reload
    "
else
    echo "[3/5] No keys provided. Set them manually (use .env.secrets, not .env):"
    echo "  ssh ${SSH_USER}@${DROPLET_IP}"
    echo "  cat > ~/.openclaw/.env.secrets <<'EOF'"
    echo "  ANTHROPIC_API_KEY=sk-ant-..."
    echo "  TELEGRAM_BOT_TOKEN=<token>"
    echo "  EOF"
    echo "  chmod 600 ~/.openclaw/.env.secrets"
    echo "  mkdir -p ~/.config/systemd/user/openclaw-gateway.service.d"
    echo "  echo -e '[Service]\nEnvironmentFile=%h/.openclaw/.env.secrets' > ~/.config/systemd/user/openclaw-gateway.service.d/secrets.conf"
    echo "  systemctl --user daemon-reload"
fi

# 4. Install claude-max-api-proxy + systemd service
#    This routes all OpenClaw requests through your Claude subscription (no per-token cost)
echo "[4/6] Installing claude-max-api-proxy..."
ssh "${SSH_USER}@${DROPLET_IP}" "
    export PATH=\"/home/openclaw/.npm-global/bin:\$PATH\"
    NODE_OPTIONS='--max-old-space-size=256' npm install -g claude-max-api-proxy --no-fund --no-audit
    mkdir -p ~/.config/systemd/user
    cat > ~/.config/systemd/user/claude-max-proxy.service <<'EOF'
[Unit]
Description=Claude Max API Proxy
After=network.target

[Service]
ExecStart=/home/openclaw/.npm-global/bin/claude-max-api 3456
Restart=always
RestartSec=5
Environment=PATH=/home/openclaw/.npm-global/bin:/usr/local/bin:/usr/bin:/bin
Environment=CLAUDECODE=

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload
    systemctl --user enable claude-max-proxy
    systemctl --user start claude-max-proxy
"

# 5. Run onboarding
echo "[5/6] Running OpenClaw onboarding..."
ssh "${SSH_USER}@${DROPLET_IP}" "export PATH=\"/home/openclaw/.npm-global/bin:\$PATH\" && openclaw onboard --non-interactive --accept-risk" || true

# 6. Channel setup (interactive)
echo "[6/6] Channel setup (interactive)..."
echo ""
echo "SSH into the VPS to finish linking channels:"
echo "  ssh ${SSH_USER}@${DROPLET_IP}"
echo ""
echo "WhatsApp (QR scan):"
echo "  openclaw channels login --channel whatsapp"
echo "  # Scan the QR code with WhatsApp > Linked Devices"
echo ""
echo "Telegram (bot token already in .env - just activate):"
echo "  openclaw channels login --channel telegram"
echo "  # No QR needed — uses TELEGRAM_BOT_TOKEN from .env"
echo ""
echo "Then start the gateway:"
echo "  systemctl --user start openclaw-gateway"
echo "  systemctl --user enable openclaw-gateway"
echo ""
echo "Access dashboard via SSH tunnel:"
echo "  ssh -L 18789:127.0.0.1:18789 ${SSH_USER}@${DROPLET_IP}"
echo "  # Then open http://localhost:18789"
echo ""
echo "=== Deploy complete ==="
