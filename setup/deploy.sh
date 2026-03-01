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

# 3. Set API keys in .env
if [ -n "$API_KEY" ] || [ -n "$TELEGRAM_TOKEN" ]; then
    echo "[3/5] Writing ~/.openclaw/.env..."
    ENV_CONTENT=""
    [ -n "$API_KEY" ]        && ENV_CONTENT+="ANTHROPIC_API_KEY=${API_KEY}\n"
    [ -n "$TELEGRAM_TOKEN" ] && ENV_CONTENT+="TELEGRAM_BOT_TOKEN=${TELEGRAM_TOKEN}\n"
    ssh "${SSH_USER}@${DROPLET_IP}" "printf '${ENV_CONTENT}' > ~/.openclaw/.env && chmod 600 ~/.openclaw/.env"
else
    echo "[3/5] No keys provided. Set them manually:"
    echo "  ssh ${SSH_USER}@${DROPLET_IP}"
    echo "  cat > ~/.openclaw/.env <<'EOF'"
    echo "  ANTHROPIC_API_KEY=sk-ant-..."
    echo "  TELEGRAM_BOT_TOKEN=<token>"
    echo "  EOF"
    echo "  chmod 600 ~/.openclaw/.env"
fi

# 4. Run onboarding
echo "[4/5] Running OpenClaw onboarding..."
ssh "${SSH_USER}@${DROPLET_IP}" "export PATH=\"/home/openclaw/.npm-global/bin:\$PATH\" && openclaw onboard --non-interactive --accept-risk" || true

# 5. Channel setup (interactive)
echo "[5/5] Channel setup (interactive)..."
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
