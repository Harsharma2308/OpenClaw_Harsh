#!/usr/bin/env bash
# OpenClaw VPS Bootstrap Script
# Run as root on a fresh Ubuntu 24.04 DigitalOcean droplet
set -euo pipefail

echo "=== OpenClaw VPS Setup ==="

# 1. Create non-root user
if ! id "openclaw" &>/dev/null; then
    echo "[1/7] Creating openclaw user..."
    adduser --disabled-password --gecos "" openclaw
    usermod -aG sudo openclaw
    echo "openclaw ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/openclaw
    # Copy SSH keys from root
    mkdir -p /home/openclaw/.ssh
    cp /root/.ssh/authorized_keys /home/openclaw/.ssh/
    chown -R openclaw:openclaw /home/openclaw/.ssh
    chmod 700 /home/openclaw/.ssh
    chmod 600 /home/openclaw/.ssh/authorized_keys
else
    echo "[1/7] openclaw user already exists, skipping..."
fi

# 2. System updates
echo "[2/7] Updating system packages..."
apt-get update -qq && apt-get upgrade -y -qq

# 3. Install Node.js 22
echo "[3/7] Installing Node.js 22..."
if ! command -v node &>/dev/null || [[ $(node --version | cut -d. -f1 | tr -d 'v') -lt 22 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
fi
echo "Node.js version: $(node --version)"

# 4. Install Docker
echo "[4/7] Installing Docker..."
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker openclaw
fi

# 5. Add swap (important for 1GB RAM droplets)
echo "[5/7] Configuring 1GB swap..."
if [ ! -f /swapfile ]; then
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# 6. Configure firewall
echo "[6/7] Configuring UFW firewall..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment "SSH"
# Gateway stays on loopback - NO public port exposure
ufw --force enable

# 7. Install OpenClaw as openclaw user
echo "[7/7] Installing OpenClaw..."
su - openclaw -c 'curl -fsSL https://openclaw.ai/install.sh | bash'

# Enable systemd lingering so services persist after logout
loginctl enable-linger openclaw

echo ""
echo "=== Setup Complete ==="
echo "Next steps:"
echo "  1. SSH as openclaw: ssh openclaw@$(hostname -I | awk '{print $1}')"
echo "  2. Copy openclaw-config.json5 to ~/.openclaw/openclaw.json"
echo "  3. Copy soul.md to ~/.openclaw/workspace/SOUL.md"
echo "  4. Set ANTHROPIC_API_KEY in ~/.openclaw/.env"
echo "  5. Run: openclaw onboard --non-interactive --accept-risk"
echo "  6. Run: openclaw channels login --channel whatsapp"
echo "  7. Run: systemctl --user start openclaw-gateway"
echo "  8. Run: systemctl --user enable openclaw-gateway"
