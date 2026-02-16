#!/usr/bin/env bash
# Deploy OpenClaw config to VPS
# Usage: ./deploy.sh <DROPLET_IP> [ANTHROPIC_API_KEY]
set -euo pipefail

DROPLET_IP="${1:?Usage: ./deploy.sh <DROPLET_IP> [ANTHROPIC_API_KEY]}"
API_KEY="${2:-}"
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

# 3. Set API key
if [ -n "$API_KEY" ]; then
    echo "[3/5] Setting Anthropic API key..."
    ssh "${SSH_USER}@${DROPLET_IP}" "echo 'ANTHROPIC_API_KEY=${API_KEY}' > ~/.openclaw/.env && chmod 600 ~/.openclaw/.env"
else
    echo "[3/5] No API key provided. Set it manually:"
    echo "  ssh ${SSH_USER}@${DROPLET_IP}"
    echo "  echo 'ANTHROPIC_API_KEY=sk-ant-...' > ~/.openclaw/.env"
    echo "  chmod 600 ~/.openclaw/.env"
fi

# 4. Run onboarding
echo "[4/5] Running OpenClaw onboarding..."
ssh "${SSH_USER}@${DROPLET_IP}" "openclaw onboard --non-interactive --accept-risk" || true

# 5. WhatsApp setup (interactive - needs QR scan)
echo "[5/5] WhatsApp setup (interactive)..."
echo ""
echo "SSH into the VPS and run WhatsApp login:"
echo "  ssh ${SSH_USER}@${DROPLET_IP}"
echo "  openclaw channels login --channel whatsapp"
echo "  # Scan the QR code with WhatsApp > Linked Devices"
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
