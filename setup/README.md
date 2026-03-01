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

## Model Routing (Cost Optimization)

By default we use **Sonnet as the daily driver** with **Opus as fallback** for heavy reasoning tasks:

```json5
model: {
  primary: "anthropic/claude-sonnet-4-5",    // ~1/5 the cost of Opus
  fallbacks: ["anthropic/claude-opus-4-6"],   // auto-fallback or /model opus
}
```

**Switch models in chat:**
- `/model opus` — escalate to Opus for complex tasks
- `/model sonnet` — back to Sonnet
- `/model` — see available models

**Heartbeat** runs on Sonnet to avoid burning Opus tokens on routine checks.

**Other cost-saving options:**
- **OpenRouter** (`OPENROUTER_API_KEY`) — single key for many providers, access to cheaper/free models
- **Claude Max $200/mo plan** — flat rate via `claude-max-api-proxy` (wraps Claude Code CLI as OpenAI-compatible API). See [claude-max-api-proxy](https://github.com/atalovesyou/claude-max-api-proxy)
- **Multiple auth profiles** — rotate between OAuth subscription + API key with auto-failover

## Cost Breakdown

| Item | Cost |
|------|------|
| DigitalOcean VPS | $6/mo (free for 60 days with $200 credit) |
| Anthropic API (Sonnet primary) | ~$0.20-0.50/hr when actively chatting |
| Anthropic API (Opus when escalated) | ~$1-2/hr when actively chatting |
| Heartbeat (48 turns/day, Sonnet) | ~$0.10-0.25/day estimate |

## Security Notes

- Gateway binds to loopback ONLY (127.0.0.1)
- Access dashboard only via SSH tunnel
- API key stored in `~/.openclaw/.env` (chmod 600)
- WhatsApp uses pairing mode (manual approval for each contact)
- Docker sandbox for non-main sessions
- Run `openclaw doctor` regularly
