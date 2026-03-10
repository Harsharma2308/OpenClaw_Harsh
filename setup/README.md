# OpenClaw Personal Assistant - Setup Guide

## Prerequisites

1. **DigitalOcean account** with $200 free trial credit
   - Sign up at digitalocean.com
   - Create a droplet: Ubuntu 24.04, $6/mo (Basic, Regular, 1GB RAM)
   - Add your SSH key during creation

2. **Claude Max subscription** ($200/mo) — recommended for $0 API cost via proxy
   - OR **Anthropic API key** from console.anthropic.com (pay-per-use)

3. **Telegram** — primary messaging channel (WhatsApp blocked by Meta, see below)

## Quick Deploy

```bash
# First time: bootstrap VPS + deploy config
./deploy.sh <DROPLET_IP> <ANTHROPIC_API_KEY>

# SSH in to set up Telegram + Claude Max proxy
ssh openclaw@<DROPLET_IP>

# Set up Telegram bot (create via @BotFather first)
# Add bot token to ~/.openclaw/.env.secrets

# Set up Claude Max proxy (if using Max subscription)
npm install -g claude-max-api-proxy
claude login   # Opens URL — authorize on phone browser
systemctl --user start claude-max-proxy
systemctl --user enable claude-max-proxy

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

### Claude Max Proxy (Current Setup — $0 API cost)

Uses Claude Max subscription ($200/mo flat) via `claude-max-api-proxy`, which wraps Claude Code CLI as an OpenAI-compatible API.

```json5
// In openclaw.json → models.providers
"claude-max": {
  "baseUrl": "http://localhost:3456/v1",
  "apiKey": "not-needed",
  "api": "openai-completions",
  "models": [
    { "id": "claude-sonnet-4-5", "cost": { "input": 0, "output": 0 } },
    { "id": "claude-opus-4-6", "cost": { "input": 0, "output": 0 } }
  ]
}

// Primary model
model: { primary: "claude-max/claude-sonnet-4-5" }
```

**Setup:**
1. Subscribe to Claude Max at https://claude.ai/settings/billing
2. Install: `npm install -g claude-max-api-proxy`
3. Install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
4. Authenticate: `claude login` → opens URL, authorize on phone browser
   - **DO NOT use `apiKeyHelper` in `~/.claude/settings.json`** — it overrides the subscription with an API key
5. Create systemd service (see `claude-max-proxy.service`)
6. Runs at `http://localhost:3456/v1/chat/completions`

**E2BIG fix applied:**
The stock proxy passes conversation history as a CLI argument, which hits Linux's ~128KB `execve()` arg limit on long sessions. We patched `subprocess/manager.js` to pipe the prompt via **stdin** instead — no size limit.

**Patch location:** `/home/openclaw/.npm-global/lib/node_modules/claude-max-api-proxy/dist/subprocess/manager.js`
**Warning:** `npm update -g claude-max-api-proxy` will overwrite this patch. Re-apply after updates.

**Fallback for safety:**
```json5
model: {
  primary: "claude-max/claude-sonnet-4-5",  // $0 via Max proxy
  fallbacks: ["haimaker/anthropic/claude-sonnet-4-5"]  // if proxy fails for any reason
}
```

### Fallback: haimaker.ai (Pay-per-use)

Cheaper alternative when Max proxy is down:
```json5
"haimaker": {
  "baseUrl": "https://api.haimaker.ai/v1",
  "apiKey": "<key>",
  "api": "openai-completions"
}
```

**Switch models in chat:**
- `/model opus` — escalate to Opus for complex tasks
- `/model sonnet` — back to Sonnet
- `/model` — see available models

## Cost Breakdown

| Item | Cost |
|------|------|
| DigitalOcean VPS | $6/mo (free for 60 days with $200 credit) |
| Claude Max subscription | $200/mo flat (unlimited Sonnet/Opus) |
| **Total with Max** | **$206/mo ($0 API cost)** |
| Anthropic API (if no Max) | ~$0.20-2/hr depending on model |
| haimaker.ai (fallback) | ~$0.25-2.85/M input tokens |

## claude-max-proxy: Garbled Messages (`[object Object]`)

The `claude-max-api-proxy` package has a bug where it assumes `message.content` is always
a string. OpenClaw sends content as an array of blocks (`[{"type":"text","text":"..."}]`),
which the proxy serializes as `[object Object]` — so Claude receives garbage and responds with confusion.

**Fix (already applied on this VPS):** Patched `openai-to-cli.js` to extract text from array content blocks.

**⚠️ This patch lives in node_modules — it gets wiped if the package is updated.**
After any `npm install -g claude-max-api-proxy`, re-run:

```bash
~/OpenClaw_Harsh/setup/patch-claude-max-proxy.sh
```

`deploy.sh` runs this automatically on fresh VPS setup.

---

## After Updates: API Keys / Telegram Stops Working

`openclaw update` regenerates `~/.openclaw/.env` from a template, wiping real keys back to `${PLACEHOLDER}`.

**The fix (already applied on this VPS):** Keys live in `~/.openclaw/.env.secrets` + a systemd drop-in injects them into the gateway service. This file is never touched by openclaw.

```
~/.openclaw/.env.secrets                              ← real keys live here
~/.config/systemd/user/openclaw-gateway.service.d/
    secrets.conf                                      ← drop-in: EnvironmentFile= pointing to above
```

If you rebuild a fresh VPS, `deploy.sh` sets this up automatically when you pass the API keys as arguments.

If things break after an update:
```bash
# Verify secrets file still has real values
cat ~/.openclaw/.env.secrets

# Reload and restart
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway

# Check it's working
openclaw status
```

---

## Troubleshooting: VPS OOM During `openclaw update`

The 1GB RAM droplet can OOM-kill npm during `openclaw update` or `npm install -g openclaw`. Symptoms: update hangs for 10+ min, exit code 137, or `ENOTEMPTY` errors on retry.

**Root cause:** Stale Claude sessions from previous terminals accumulate in swap, leaving no room for npm's dependency resolution (~600MB peak).

**Fix:**

```bash
# 1. Kill stale Claude/bash processes from old sessions
ps aux | grep -E "claude|bash.*openclaw" | grep -v grep
kill <stale_pids>

# 2. Add a temporary second swap file
sudo fallocate -l 1G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2

# 3. Clear any partial install and retry
rm -rf ~/.npm-global/lib/node_modules/openclaw
NODE_OPTIONS="--max-old-space-size=256" npm install -g openclaw --no-fund --no-audit

# 4. Remove the extra swap after install succeeds
sudo swapoff /swapfile2 && sudo rm /swapfile2
```

**Prevention:** Before updating, check memory with `free -h`. If swap is >50% used, kill old sessions first.

---

## Troubleshooting: Gateway Crash Loop (SIGTERM on startup)

**Symptom:** Gateway starts, runs for ~15 seconds, gets SIGTERM, restarts endlessly.

**Cause 1 — Lingering not enabled:**
Without `loginctl enable-linger openclaw`, systemd kills ALL user services when the last SSH session disconnects. With `Restart=always`, the service restarts but gets killed again on the next SSH disconnect.

```bash
# Check
loginctl show-user openclaw | grep Linger
# Fix
sudo loginctl enable-linger openclaw
```

**Cause 2 — Service version mismatch:**
After `openclaw update`, the binary version changes but the systemd service file still references the old version. OpenClaw detects the mismatch and triggers a restart loop.

```bash
# Fix: regenerate service file
openclaw daemon install --force
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway
```

## Troubleshooting: Claude Max Proxy E2BIG

**Symptom:** Telegram bot receives messages but never replies. Proxy logs show `spawn E2BIG`.

**Cause:** The stock `claude-max-api-proxy` passes conversation history as a CLI argument to `claude --print`. Linux's `execve()` syscall limits a single arg to ~128KB (`MAX_ARG_STRLEN`). This is NOT a memory issue — it happens on any server regardless of RAM.

**Fix (already applied):** Patch `subprocess/manager.js` to pipe the prompt via stdin:
```bash
# In ~/.npm-global/lib/node_modules/claude-max-api-proxy/dist/subprocess/manager.js:
# 1. Store prompt: this._stdinPrompt = prompt;
# 2. Remove prompt from buildArgs() return array
# 3. Write to stdin: if (this._stdinPrompt) { this.process.stdin?.write(this._stdinPrompt); }
#    before this.process.stdin?.end();
```

**If it recurs after proxy update:**
```bash
# Quick fix: archive the bloated session and re-apply stdin patch
cd ~/.openclaw/agents/main/sessions/
ls -lhS *.jsonl | head -5
mv <session-id>.jsonl <session-id>.jsonl.bak
# Then re-apply the stdin patch above
systemctl --user restart claude-max-proxy openclaw-gateway
```

## Troubleshooting: WhatsApp "Can't link devices"

**Status: BROKEN (as of 2026-03).**

WhatsApp has blocked the Baileys library (unofficial API) that OpenClaw uses. This is a known upstream issue (OpenClaw issues #20281, #4686). No workaround exists.

**Use Telegram instead** — works reliably via BotFather polling.

## Channels Setup

### Telegram (Primary — working)
1. Create bot via `@BotFather` on Telegram → get bot token
2. Send `/start` to your bot to get your chat ID
3. Add to `~/.openclaw/.env.secrets`:
   ```
   TELEGRAM_BOT_TOKEN=<token from BotFather>
   ```
4. Configure in `openclaw.json`:
   ```json
   "telegram": {
     "enabled": true,
     "dmPolicy": "allowlist",
     "botToken": "${TELEGRAM_BOT_TOKEN}",
     "allowFrom": [<your_telegram_id>]
   }
   ```

### WhatsApp (Broken — blocked by Meta)
See troubleshooting section above.

## Security Notes

- Gateway binds to loopback ONLY (127.0.0.1)
- Access dashboard only via SSH tunnel
- API keys stored in `~/.openclaw/.env.secrets` (chmod 600), injected via systemd drop-in
- Telegram uses allowlist mode (only approved chat IDs)
- Docker sandbox for non-main sessions
- Run `openclaw doctor` regularly
