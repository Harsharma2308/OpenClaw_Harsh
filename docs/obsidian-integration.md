# Obsidian Integration with OpenClaw

How BillieJoe (OpenClaw) integrates with Harsh's Obsidian vault for life management.

---

## Overview

**Obsidian Vault Location:** `/home/openclaw/ObsidianVault/`  
**Git Repo:** `github.com:Harsharma2308/ObsidianVault`  
**Sync:** Every 15 min via system cron (auto-pull)  

BillieJoe has **direct read/write access** to the vault and uses it as the **source of truth** for:
- Daily notes and reflections
- Goals and habits tracking
- Task management
- Life decisions and patterns
- Personal context and relationships

---

## What BillieJoe Does with Obsidian

### Read Operations (Context Loading)

**Every new session, BillieJoe reads:**
1. `VAULT_OVERVIEW.md` — Master context doc (goals, people, current focus)
2. `DaytoDay/YYYY-MM-DD.md` — Today's and yesterday's daily notes
3. `ALL_TASKS_DUMP.md` — Task backlog (pick 1-3 daily P0s)
4. `AllMyGoals/MASTER_HUB.md` — Goal dashboard

**On-demand reads:**
- Weekly notes (`WeektoWeek/`)
- Specific goal docs (`AllMyGoals/`)
- Philosophy and principles (`My life doc/PHILOSOPHY.md`)
- People reference (`Notes/People Around Me.md`)
- Project ideas (`Notes/Ideas.md`)

### Write Operations

**Daily log (10 PM PT cron):**
- Review conversation history
- Write to `DaytoDay/YYYY-MM-DD.md`:
  - What we discussed
  - Tasks completed
  - Decisions made
  - Patterns observed
- Commit and push changes

**Habit tracking:**
- Update daily habits checklist (5 core habits)
- Track sleep, meditation, movement, phone-free time, deep work

**Task management:**
- Move tasks from `ALL_TASKS_DUMP.md` → daily note
- Mark completed tasks
- Move undone tasks back to dump

**Weekly review (Sunday 8 PM PT):**
- Review week's daily notes
- Identify patterns (good and bad)
- Call out drift from goals
- Prepare next week's priorities

---

## Vault Structure (Quick Reference)

```
ObsidianVault/
├── VAULT_OVERVIEW.md          # 📋 Master context doc (READ THIS FIRST)
├── ALL_TASKS_DUMP.md          # Brain dump of ALL tasks
├── DaytoDay/                  # Daily notes (YYYY-MM-DD.md)
├── WeektoWeek/                # Weekly reviews
├── AllMyGoals/                # Goal tracking
│   ├── MASTER_HUB.md          # Central dashboard
│   ├── Health-Whoop-Age.md    # Reduce Whoop age by 6 years
│   └── ...
├── My life doc/               # Personal philosophy, reflections
│   └── PHILOSOPHY.md          # Core principles
├── Notes/
│   ├── People Around Me.md    # Relationship reference
│   └── Ideas.md               # Project ideas
├── MyTemplates/               # Templates for notes
│   └── Habits Checklist.md    # 5 daily habits
└── Learning/                  # Technical notes, research
```

**Full structure:** See [obsidian-vault-structure.md](obsidian-vault-structure.md)

---

## Sync Workflow

### Automatic Pull (Every 15 min)

```bash
# System cron (no LLM cost)
*/15 * * * * cd /home/openclaw/ObsidianVault && git pull --quiet
```

**Why:** Harsh may edit vault on his laptop → VPS needs latest changes

### Automatic Push (Daily at 10 PM PT)

```bash
# OpenClaw cron (systemEvent, no LLM needed)
cd /home/openclaw/ObsidianVault && \
  git add -A && \
  git commit -m 'Daily backup: $(date +%Y-%m-%d)' && \
  git push || true
```

**Why:** BillieJoe writes to vault daily → push to GitHub backup

### Manual Operations

```bash
# Check status
cd ~/ObsidianVault && git status

# Manual pull
cd ~/ObsidianVault && git pull

# Manual commit
cd ~/ObsidianVault && git add -A && git commit -m "Update" && git push
```

---

## Integration with ObsidianHelper

**ObsidianHelper Location:** `/home/openclaw/ObsidianHelper/`  
**Git Repo:** `github.com:Harsharma2308/ObsidianHelper`  

ObsidianHelper contains **MCP (Model Context Protocol) servers** for deep integrations:
- **Obsidian MCP** - Programmatic vault access
- **Google Sheets MCP** - Metrics tracking
- **Google Calendar MCP** - Event scheduling
- **Whoop MCP** - Health data (recovery, sleep, HRV)
- **FatSecret MCP** - Nutrition tracking

**Status with OpenClaw:**
- MCP servers designed for Cursor IDE integration
- OpenClaw uses **direct file access** instead (simpler, works out of the box)
- MCP could be integrated later via custom tool if needed

**See:** [obsidian-helper-mcp.md](obsidian-helper-mcp.md) for MCP server details

---

## Coaching Philosophy (How BillieJoe Uses Vault Context)

**Core approach:** Brutally honest accountability using vault data as evidence.

### Morning Check-In
1. Read yesterday's daily note
2. Compare planned tasks vs actually done
3. Ask: "You said you'd do X yesterday. Did you?"
4. Set today's P0 tasks (max 3)

### Evening Log
1. Review conversation history
2. Log to today's daily note:
   - What we discussed
   - Tasks completed
   - Decisions made
3. Honest feedback: "You planned 3 tasks, did 1. What happened?"

### Weekly Review (Sunday 8 PM)
1. Read all daily notes from the week
2. Identify patterns:
   - Good: Consistent meditation, early sleep
   - Bad: Scrolling loops, avoiding deep work
3. Call out drift from goals in `MASTER_HUB.md`
4. Prepare next week's priorities

### Mantras (from SOUL.md)
- **ACTION > PERFECTION**
- **DONE > PERFECT**
- **SOMETHING > NOTHING**
- Celebrate ANY action over perfect inaction

---

## Key Files BillieJoe Monitors

### Daily (Read Every Session)
- `VAULT_OVERVIEW.md` - Master context
- `DaytoDay/YYYY-MM-DD.md` - Today + yesterday
- `ALL_TASKS_DUMP.md` - Task backlog

### Weekly (Sunday Review)
- `DaytoDay/` - All notes from the week
- `AllMyGoals/MASTER_HUB.md` - Goal progress
- `WeektoWeek/YYYY-W##.md` - Last week's review

### On-Demand (When Relevant)
- `My life doc/PHILOSOPHY.md` - Core principles
- `Notes/People Around Me.md` - Relationship context
- `AllMyGoals/Health-Whoop-Age.md` - Specific goal docs
- `Learning/` - Research notes when discussing projects

---

## Permissions & Security

**BillieJoe can:**
- ✅ Read entire vault
- ✅ Write to daily notes
- ✅ Update task lists
- ✅ Commit and push changes
- ✅ Run git operations

**BillieJoe never:**
- ❌ Deletes files (always commit first, recoverable)
- ❌ Shares vault content publicly
- ❌ Loads `MEMORY.md` in group chats (personal context)

**Security model:**
- Vault is private (Harsh only)
- BillieJoe only accessed in main session (direct chat with Harsh)
- No vault data exposed in public contexts

---

## Troubleshooting

### Vault out of sync
```bash
cd ~/ObsidianVault
git status                    # Check for uncommitted changes
git pull                      # Pull latest
git add -A && git commit -m "Sync" && git push  # Push changes
```

### BillieJoe wrote bad data
```bash
cd ~/ObsidianVault
git log                       # Find the commit
git revert <commit-hash>      # Undo the change
git push
```

### Cron not pulling
```bash
crontab -l | grep Obsidian    # Check cron entry
# Re-add if missing (see sync workflow above)
```

---

## Future Enhancements

**Potential integrations:**
- [ ] Whoop data auto-pull to daily notes
- [ ] Google Calendar sync (create events from tasks)
- [ ] Financial tracking updates (from Schwab API)
- [ ] MCP server integration (if needed for complex operations)
- [ ] Weekly note auto-generation from daily notes

**See:** `~/ObsidianHelper/` for MCP server capabilities

---

_Last updated: 2026-03-02 by BillieJoe 🎸_
