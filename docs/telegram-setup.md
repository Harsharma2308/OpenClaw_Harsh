# Telegram Channel Setup

This guide covers adding Telegram as a messaging channel to your OpenClaw personal assistant.

> **Note:** All commands in this guide can be run directly on the VPS (`ssh openclaw@<DROPLET_IP>`) or from your local machine using the `ssh ... '<command>'` prefix shown in the examples.

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

From local machine:
```bash
ssh openclaw@<DROPLET_IP> "echo 'TELEGRAM_BOT_TOKEN=<your-bot-token>' >> ~/.openclaw/.env && chmod 600 ~/.openclaw/.env"
```

Or directly on the VPS:
```bash
echo 'TELEGRAM_BOT_TOKEN=<your-bot-token>' >> ~/.openclaw/.env
chmod 600 ~/.openclaw/.env
```

## 4. Update the Config

In `setup/openclaw-config.json5`, fill in your Telegram user ID in `allowFrom`:

```json5
telegram: {
  botToken: "${TELEGRAM_BOT_TOKEN}",
  dmPolicy: "allowlist",
  allowFrom: [8092664267],  // your numeric Telegram user ID
  groupPolicy: "disabled"
}
```

Then copy the config to the OpenClaw directory. If running **on the VPS**:
```bash
cp setup/openclaw-config.json5 ~/.openclaw/openclaw.json
```

If running **from local machine**:
```bash
./setup/deploy.sh <DROPLET_IP>
```

## 5. Restart the Gateway

Telegram reads the bot token from `.env` automatically — no separate login step needed.

On VPS or via SSH:
```bash
systemctl --user restart openclaw-gateway
# Confirm it's running:
journalctl --user-unit openclaw-gateway --no-pager -n 10
# Look for: [telegram] [default] starting provider (@your_bot_name)
```

## 6. Test It

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
