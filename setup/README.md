# OpenClaw Personal Assistant - Setup Guide

## Prerequisites

1. **DigitalOcean account** with $200 free trial credit
   - Sign up at digitalocean.com
   - Create a droplet: Ubuntu 24.04, $6/mo (Basic, Regular, 1GB RAM)
   - Add your SSH key during creation

2. **Anthropic API key**
   - Sign up at console.anthropic.com (personal account)
   - Create an API key (starts with `sk-ant-api03-`)
   - Add credit ($20 to start is fine)

3. **WhatsApp** on your phone

## Quick Deploy

```bash
# First time: bootstrap VPS + deploy config
./deploy.sh <DROPLET_IP> <ANTHROPIC_API_KEY>

# Then SSH in to finish WhatsApp setup
ssh openclaw@<DROPLET_IP>
openclaw channels login --channel whatsapp
# Scan QR code with your phone

# Start the gateway
systemctl --user start openclaw-gateway
systemctl --user enable openclaw-gateway
```

## Update Config

After editing `openclaw-config.json5` or `soul.md` locally:
```bash
./deploy.sh <DROPLET_IP>
ssh openclaw@<DROPLET_IP> 'systemctl --user restart openclaw-gateway'
```

## Access Dashboard

```bash
ssh -L 18789:127.0.0.1:18789 openclaw@<DROPLET_IP>
# Open http://localhost:18789 in your browser
```

## Useful Commands

```bash
# Check status
ssh openclaw@<DROPLET_IP> 'openclaw gateway status'

# View logs
ssh openclaw@<DROPLET_IP> 'journalctl --user-unit openclaw-gateway -f'

# Security audit
ssh openclaw@<DROPLET_IP> 'openclaw doctor'

# Update OpenClaw
ssh openclaw@<DROPLET_IP> 'openclaw update --channel stable'

# Backup
ssh openclaw@<DROPLET_IP> 'tar -czf ~/backup-$(date +%Y%m%d).tar.gz ~/.openclaw/'
scp openclaw@<DROPLET_IP>:~/backup-*.tar.gz ./
```

## Cost Breakdown

| Item | Cost |
|------|------|
| DigitalOcean VPS | $6/mo (free for 60 days with $200 credit) |
| Anthropic API | ~$1-2/hr when actively chatting |
| Heartbeat (48 turns/day) | ~$0.50-1/day estimate |

## Security Notes

- Gateway binds to loopback ONLY (127.0.0.1)
- Access dashboard only via SSH tunnel
- API key stored in `~/.openclaw/.env` (chmod 600)
- WhatsApp uses pairing mode (manual approval for each contact)
- Docker sandbox for non-main sessions
- Run `openclaw doctor` regularly
