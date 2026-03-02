# OpenClaw Personal Assistant - BillieJoe 🎸

**Personal AI assistant running on OpenClaw with punk rock energy.**

Brutally honest accountability partner for life management, not a cheerleader.

---

## Quick Stats

- **Host:** Ubuntu 24.04 VPS (DigitalOcean)
- **Model:** Sonnet (primary) → Opus (fallback)
- **Channels:** Telegram, WhatsApp
- **Integrations:** Obsidian Vault, Google Calendar, Gmail, Whoop, FatSecret
- **Philosophy:** ACTION > PERFECTION

---

## What This Does

BillieJoe is a personal AI assistant that:

- **Tracks your life:** Daily notes, goals, habits via Obsidian vault
- **Holds you accountable:** Brutally honest feedback on progress
- **Manages integrations:** Email, calendar, health data (Whoop), food tracking
- **Proactive monitoring:** Heartbeat checks every 30 min during active hours
- **Weekly reviews:** Sunday 8 PM automatic review + planning reminder
- **Cost-optimized:** Sonnet for daily use (~1/5 cost of Opus)

**Core Philosophy:** Push for action over perfection. Celebrate ANY progress. Call out avoidance patterns.

---

## Repository Structure

```
OpenClaw_Harsh/
├── README.md              # This file
├── CLAUDE.md              # Agent instructions (references workspace/SOUL.md)
├── setup/                 # Setup scripts and configs
│   ├── README.md          # Detailed setup guide
│   ├── openclaw-config.json5  # OpenClaw configuration
│   └── soul.md            # (Legacy - moved to workspace)
└── docs/                  # Documentation
    └── telegram-setup.md  # Telegram bot setup
```

**Agent workspace lives on VPS:**
- Location: `~/.openclaw/workspace/`
- Contains: `SOUL.md`, `AGENTS.md`, `TOOLS.md`, `HEARTBEAT.md`, `MEMORY.md`
- Git-tracked separately for version control

---

## Setup Guide

See [`setup/README.md`](setup/README.md) for complete deployment instructions.

**Quick version:**
1. Deploy VPS (Ubuntu 24.04, 1GB RAM, $6/mo)
2. Install OpenClaw
3. Configure Telegram/WhatsApp
4. Set up model routing (Sonnet → Opus)
5. Clone Obsidian vault
6. Configure cron jobs
7. Complete OAuth for Google services

---

## Integrations

### ✅ Active

**Obsidian Vault:**
- Location: `/home/openclaw/ObsidianVault` (git-synced)
- Auto-pull: Every 15 min
- Auto-backup: Daily at 10 PM PT
- Contains: DaytoDay notes, Goals, Habits, Tasks

**Cron Jobs:**
- Vault sync (every 15 min)
- Daily backup (10 PM PT)
- Morning daily note check (9 AM PT)
- Sunday weekly review reminder (8 PM PT)

**Tools Installed:**
- `himalaya` v1.2.0 (email CLI)
- `gog` v0.11.0 (Google Workspace CLI)

**Repos Cloned:**
- `ObsidianHelper` (MCP integrations)
- `wealthmanagement` (Schwab API)
- `ObsidianVault` (life management system)

### 🔜 Pending OAuth

**Google Calendar + Gmail:**
- Credentials configured
- Needs browser OAuth completion
- See: `~/.openclaw/workspace/SETUP_TODO.md`

**Email (Himalaya):**
- Alternative 1: App password (quick)
- Alternative 2: OAuth (same as gog)

---

## Agent Philosophy (SOUL.md)

**Core Identity:**
- Name: BillieJoe 🎸
- Role: Accountability partner, not cheerleader
- Style: Brutally honest, direct, action-oriented

**Mantras:**
- **ACTION > PERFECTION**
- **DONE > PERFECT**
- **SOMETHING > NOTHING**
- **PROGRESS > PERFECT DAYS**

**Coaching Approach:**
- Call out avoidance patterns
- Push for smallest action over waiting for perfect conditions
- Celebrate ANY progress
- Hold Harsh to his own standard: "I have infinite will"

**Workflow:**
- Morning: Check yesterday's progress, set today's P0s (max 3)
- Evening: Log what actually happened, honest feedback
- Sunday 8 PM: Weekly review + next week planning

**Read full SOUL.md:** `~/.openclaw/workspace/SOUL.md` on VPS

---

## Cost Optimization

**Current Setup:**
- **Primary:** Sonnet (~$0.20-0.50/hr active chatting)
- **Fallback:** Opus (~$1-2/hr when escalated)
- **Heartbeat:** Sonnet (~$0.10-0.25/day)
- **VPS:** $6/mo (free for 60 days with DigitalOcean credit)

**Upgrade Path:**
If monthly costs approach **$200**, switch to Claude Max plan:
- Flat $200/mo → unlimited Opus
- Via `claude-max-api-proxy`
- Threshold: >$7/day average

See: [`setup/README.md#when-to-switch-to-claude-max-plan`](setup/README.md#when-to-switch-to-claude-max-plan)

---

## Useful Commands

**On VPS:**
```bash
# Check cron jobs
openclaw cron list

# Check vault sync status
cd ~/ObsidianVault && git status

# View heartbeat config
cat ~/.openclaw/workspace/HEARTBEAT.md

# Manual vault pull
cd ~/ObsidianVault && git pull

# View agent memory
cat ~/.openclaw/workspace/MEMORY.md
```

**Model switching in chat:**
```
/model opus     # Escalate to Opus
/model sonnet   # Back to Sonnet
/model          # List available
```

**Check session status:**
```
/status         # Token usage, model, thinking level
```

---

## Repository Maintenance

**Local changes (on your machine):**
```bash
cd OpenClaw_Harsh
# Edit setup/openclaw-config.json5 or docs/

git add -A
git commit -m "Update config/docs"
git push
```

**VPS workspace changes:**
- Workspace git repo: `~/.openclaw/workspace/.git`
- Auto-committed by cron jobs
- Memory files update automatically

---

## Links

- **OpenClaw Docs:** https://docs.openclaw.ai
- **Community:** https://discord.com/invite/clawd
- **Skills:** https://clawhub.com
- **Source:** https://github.com/openclaw/openclaw

---

**Built with OpenClaw v2026.2.14**  
**Agent: BillieJoe 🎸**  
**Philosophy: ACTION > PERFECTION**
