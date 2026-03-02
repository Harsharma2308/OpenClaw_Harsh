# Repository Structure

This repository documents BillieJoe's setup and contains symlinks to active workspace files.

---

## Directory Layout

```
OpenClaw_Harsh/
├── README.md              # Overview and quick reference
├── STRUCTURE.md           # This file - explains repo organization
├── workspace/             # 🔗 SYMLINKS to ~/.openclaw/workspace/
│   ├── AGENTS.md          # Core instructions (read every session)
│   ├── SOUL.md            # Persona and coaching philosophy
│   ├── USER.md            # Info about Harsh
│   ├── TOOLS.md           # Local tool config (camera names, SSH, etc.)
│   ├── IDENTITY.md        # Who BillieJoe is
│   ├── HEARTBEAT.md       # Proactive check-in tasks
│   ├── MEMORY.md          # Long-term curated memories (main session only)
│   ├── SYSTEMS.md         # Architecture & design decisions
│   ├── SETUP.md           # Configuration & API keys guide
│   ├── MIGRATION.md       # How to move to new machine
│   └── memory/            # Daily conversation logs (YYYY-MM-DD.md)
├── setup/                 # Setup scripts and configs
│   ├── README.md          # Detailed deployment guide
│   └── openclaw-config.json5  # OpenClaw configuration template
└── docs/                  # Additional documentation
    └── telegram-setup.md  # Telegram bot setup guide
```

---

## What Lives Where

### Active Runtime Files (Symlinked)

**Location on VPS:** `~/.openclaw/workspace/`  
**Symlinked in repo:** `OpenClaw_Harsh/workspace/`  

These are the **actual** files OpenClaw loads at runtime. The repo contains symlinks for:
- **Backup:** Everything pushed to GitHub nightly
- **Visibility:** Easy to browse workspace on GitHub
- **Documentation:** See what the agent is actually using

**Files:**
- `AGENTS.md` — Core behavior and workflows
- `SOUL.md` — Persona (direct, punk rock energy, accountability)
- `USER.md` — Info about Harsh
- `TOOLS.md` — Local environment notes (camera names, SSH hosts, etc.)
- `IDENTITY.md` — Who BillieJoe is
- `HEARTBEAT.md` — Checklist for periodic checks
- `MEMORY.md` — Long-term memory (main session only, contains personal context)
- `SYSTEMS.md` — Architecture decisions, cost optimization, cron setup
- `SETUP.md` — API keys, configuration, emergency procedures
- `MIGRATION.md` — How to move OpenClaw to a new machine
- `memory/` — Daily logs (YYYY-MM-DD.md format)

### Documentation (Native Files)

**Location:** `OpenClaw_Harsh/` (not symlinked)

- `README.md` — Overview, philosophy, quick reference
- `STRUCTURE.md` — This file
- `setup/README.md` — Full deployment guide
- `docs/` — Additional guides

### Other Important Locations (Not in Repo)

**OpenClaw config:**
- Location: `~/.openclaw/openclaw.json`
- Contains: Model routing, channel config, cron setup
- **Not tracked** — contains tokens/secrets
- Template available: `setup/openclaw-config.json5`

**Environment variables:**
- Location: `~/.openclaw/.env`
- Contains: All API keys (ANTHROPIC_API_KEY, BRAVE_API_KEY, etc.)
- Auto-loaded via `.bashrc`
- **Not tracked** — sensitive credentials
- Documented in: `workspace/SETUP.md`

**Obsidian Vault:**
- Location: `/home/openclaw/ObsidianVault/`
- Separate git repo: `github.com:Harsharma2308/ObsidianVault`
- Synced every 15 min via system cron
- BillieJoe reads/writes daily notes, tasks, goals

---

## Backup Strategy

**What's backed up to GitHub:**
- ✅ Workspace files (via symlinks in this repo)
- ✅ Documentation (native in this repo)
- ✅ Obsidian vault (separate repo)

**What's NOT backed up:**
- ⚠️ `~/.openclaw/openclaw.json` (contains secrets)
- ⚠️ `~/.openclaw/.env` (sensitive credentials)
- ℹ️ Session history (ephemeral, not needed)

**Manual backup for secrets:**
```bash
# Backup config + credentials
tar -czf openclaw-secrets-backup.tar.gz \
  ~/.openclaw/.env \
  ~/.openclaw/openclaw.json

# Store encrypted somewhere safe (password manager, encrypted drive)
```

---

## How Changes Propagate

### Workspace Files (Symlinked)

**When you edit on VPS:**
```bash
# Edit actual file
vim ~/.openclaw/workspace/SOUL.md

# Changes instantly reflected in repo (symlink)
cd ~/OpenClaw_Harsh
git add workspace/SOUL.md
git commit -m "Update SOUL.md"
git push
```

**When you pull from GitHub:**
```bash
cd ~/OpenClaw_Harsh
git pull

# Changes reflect in actual workspace (symlink works both ways)
# OpenClaw picks up changes immediately
```

### Documentation Files (Native)

Edit directly in `OpenClaw_Harsh/` and push.

---

## Cron Auto-Backup

**Nightly push (11 PM PT):**
```bash
# OpenClaw repo
cd /home/openclaw/OpenClaw_Harsh && \
  git add -A && \
  git commit -m 'Daily sync: $(date +%Y-%m-%d)' && \
  git push || true

# Workspace changes auto-committed (11:05 PM PT)
cd ~/.openclaw/workspace && \
  git add -A && \
  git commit -m 'Daily sync: $(date +%Y-%m-%d)' || true
```

Both repos stay in sync automatically.

---

## Quick Reference

**Find a specific doc:**
- Agent behavior → `workspace/AGENTS.md`
- Coaching style → `workspace/SOUL.md`
- API keys guide → `workspace/SETUP.md`
- Architecture → `workspace/SYSTEMS.md`
- Migration guide → `workspace/MIGRATION.md`
- Deployment → `setup/README.md`

**Edit agent behavior:**
```bash
vim ~/.openclaw/workspace/SOUL.md    # Changes take effect immediately
cd ~/OpenClaw_Harsh && git add -A && git commit -m "Update" && git push
```

**Browse on GitHub:**
- Workspace files: `github.com:Harsharma2308/OpenClaw_Harsh/tree/main/workspace`
- Setup guide: `github.com:Harsharma2308/OpenClaw_Harsh/blob/main/setup/README.md`

---

_Last updated: 2026-03-02 by BillieJoe 🎸_
