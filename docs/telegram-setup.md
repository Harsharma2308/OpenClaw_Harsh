# Telegram Channel Setup

This guide covers adding Telegram as a messaging channel to your OpenClaw personal assistant.

## 1. Create a Telegram Bot

1. Open Telegram and message `@BotFather`
2. Send `/newbot` and follow the prompts (pick a name and username)
3. Copy the **HTTP API token** BotFather gives you (format: `1234567890:AAE...`)

## 2. Get Your Telegram User ID

You need to whitelist your own Telegram user ID so the bot only responds to you.

1. Message `@userinfobot` on Telegram
2. It will reply with your numeric user ID (e.g. `123456789`)

## 3. Store the Token on the VPS

The bot token must live in `~/.openclaw/.env` — **never** committed to git.

```bash
ssh openclaw@<DROPLET_IP>
cat >> ~/.openclaw/.env <<'EOF'
TELEGRAM_BOT_TOKEN=<your-bot-token-here>
EOF
chmod 600 ~/.openclaw/.env
```

## 4. Update the Config

In `setup/openclaw-config.json5`, fill in your Telegram user ID in `allowFrom`:

```json5
telegram: {
  botToken: "${TELEGRAM_BOT_TOKEN}",
  dmPolicy: "allowlist",
  allowFrom: [123456789],  // your numeric Telegram user ID
  groupPolicy: "disabled"
}
```

Then redeploy the config:

```bash
./setup/deploy.sh <DROPLET_IP>
```

## 5. Activate the Channel

```bash
ssh openclaw@<DROPLET_IP>
openclaw channels login --channel telegram
# No QR code needed — reads token from .env automatically
```

## 6. Restart the Gateway

```bash
ssh openclaw@<DROPLET_IP> 'systemctl --user restart openclaw-gateway'
```

## 7. Test It

Send a message to your bot on Telegram. You should get a response from the assistant.

---

## Security Notes

- The bot token is equivalent to a password — store it only in `~/.openclaw/.env` (chmod 600)
- `dmPolicy: "allowlist"` means only user IDs in `allowFrom` can interact with the bot
- `groupPolicy: "disabled"` prevents the bot from responding in group chats
- Never expose the token in config files, logs, or git history

## Troubleshooting

```bash
# Check channel status
ssh openclaw@<DROPLET_IP> 'openclaw channels status'

# View gateway logs
ssh openclaw@<DROPLET_IP> 'journalctl --user-unit openclaw-gateway -f'

# Re-link if bot stops responding
ssh openclaw@<DROPLET_IP> 'openclaw channels login --channel telegram'
```
