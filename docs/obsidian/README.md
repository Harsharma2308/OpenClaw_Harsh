# Obsidian Integration - Documentation

This directory contains references to Obsidian vault structure, workflow, and integration patterns.

---

## Source: ObsidianHelper

The full Obsidian workflow documentation lives in the **ObsidianHelper** repository:
- Location on VPS: `/home/openclaw/ObsidianHelper/`
- GitHub: https://github.com/Harsharma2308/ObsidianHelper (private)

**Key docs:**
- `ObsidianHelper/CLAUDE.md` — Complete AI assistant instructions for Obsidian workflow
- `ObsidianHelper/docs/` — Setup guides, MCP server docs, philosophy

---

## Vault Structure

**Vault location:** `/home/openclaw/ObsidianVault/`

### Key Documents

**Master Context (Read First):**
- `VAULT_OVERVIEW.md` — Master doc (goals, people, current focus, what Harsh is targeting/letting go)
- `Notes/People Around Me.md` — People in Harsh's life

**Task Management:**
- `ALL_TASKS_DUMP.md` — Brain dump of ALL tasks. Pick 1-3 daily → daily note → undone goes back.

**Goals:**
- `AllMyGoals/MASTER_HUB.md` — Central dashboard with links to all goals
- Individual goal docs (Career, Health, Relationships, etc.)

**Daily Workflow:**
- `DaytoDay/YYYY-MM-DD.md` — Daily notes with brain dumps, reflections, habits
- `WeektoWeek/YYYY-W##.md` — Weekly reviews and planning
- `MonthtoMonth/YYYY-MM-[Month].md` — Monthly goals and reflections

**Templates:**
- `MyTemplates/Daily Note Template.md` — Structure for daily notes
- `MyTemplates/Habits Checklist.md` — 5 daily habits + Whoop auto-pull

**Philosophy:**
- `My life doc/PHILOSOPHY.md` — Core philosophy and principles

---

## Workflow Integration

### Daily Cycle

**Morning (9 AM cron):**
1. Check if today's daily note exists
2. If not, remind Harsh to start his day
3. If yes, check if P0 tasks are set

**Throughout Day (Heartbeats every 30 min):**
- Check daily note for task progress
- Monitor for dopamine loops (scrolling, porn, drama)
- Track habits (meditation, movement, deep work)

**Evening (10 PM cron):**
1. Ask: "What all happened today? What did we discuss?"
2. Log everything to daily note
3. Commit and push vault changes

**Sunday (8 PM cron):**
1. Review week's daily notes
2. Provide honest feedback on progress
3. Remind to do weekly planning
4. Financial check-in

### Task Flow

```
ALL_TASKS_DUMP.md (everything)
       ↓ pick 1-3 daily
DaytoDay/YYYY-MM-DD.md (today's tasks + habits)
       ↓ not done?
ALL_TASKS_DUMP.md (goes back)
```

### 5 Daily Habits

From `MyTemplates/Habits Checklist.md`:
1. **Sleep before 11pm** (discipline, not just hours)
2. **Morning phone-free 30min** (no scrolling first thing)
3. **Meditation** (even 5 min)
4. **Movement** (Pull/Push/Run/Abs/Walk)
5. **Deep work** (focused work block)

---

## Core Philosophy

From `My life doc/PHILOSOPHY.md`:

**Central Insight:**
> Remove dopamine addiction + practice concentration = half of life's problems solved.

**Mantras:**
- **ACTION > PERFECTION**
- **DONE > PERFECT**
- **SOMETHING > NOTHING**
- **PROGRESS > PERFECT DAYS**

**The Problem:**
Perfectionism → Paralysis → Avoidance
- "Didn't sleep right, so can't workout" → Does 0
- "Didn't eat right, so skip the day" → Makes it worse
- Wants to do EVERYTHING → Does NOTHING

**The Solution:**
- Celebrate ANY action over perfect inaction
- Push for SMALLEST action: "Can't do full workout? Do 10 pushups NOW"
- Call out "waiting for perfect conditions" as avoidance

---

## Google Sheets Integration

**Active Tracking Sheet:**
- Name: "Life Tracking - 2025"
- ID: `15aUGibPF-FyPcx8UBuZKyalni3hLRMbOMklt287dsMA`
- Link: https://docs.google.com/spreadsheets/d/15aUGibPF-FyPcx8UBuZKyalni3hLRMbOMklt287dsMA/edit

**Tabs:**
- Master Goals — Goal targets and current state
- Weekly Tracking — Hours worked, workouts, meditation, dates, reading
- Health Metrics — Weight, heart rate, sleep, HRV
- Habit Tracker — Daily checkboxes with streak counters
- Financial — Expenses, savings, net worth

**Workflow:**
- User updates Sheet with metrics (workouts, meditation, weight, etc.)
- AI updates Obsidian with context and reflections
- Both systems work together: Sheets = data, Obsidian = narrative

---

## MCP Servers (ObsidianHelper)

These MCP servers were built for Cursor, but patterns can be adapted:

### 1. Obsidian MCP Server
- Read/write notes
- Search vault
- Manage tags and frontmatter

### 2. Google Sheets MCP Server
- Read/write tracking data
- Update habits and metrics

### 3. Google Calendar MCP Server
- Create/update events
- Check upcoming schedule

### 4. Whoop MCP Server
- Pull recovery, sleep, strain data
- Auto-populate health metrics

### 5. FatSecret MCP Server
- Search food database
- Log meals to diary

---

## For OpenClaw Integration

**Currently:**
- ✅ Vault cloned and auto-synced (every 15 min)
- ✅ Daily backup (10 PM PT)
- ✅ Cron jobs for morning check, evening logging, weekly review
- 🔜 Google OAuth (calendar + email)

**When OAuth Complete:**
- Create calendar events from tasks
- Check email for urgent items
- Add time blocks to calendar

**Key Files in OpenClaw Workspace:**
- `~/.openclaw/workspace/PROACTIVE_ACTIONS.md` — What I can do automatically
- `~/.openclaw/workspace/SOUL.md` — Core identity and philosophy
- `~/.openclaw/workspace/HEARTBEAT.md` — Proactive check-in tasks

---

## Reference Documentation

**Full workflow guide:**  
See `/home/openclaw/ObsidianHelper/CLAUDE.md` (sections on vault structure, task flow, coaching philosophy)

**MCP setup:**  
See `/home/openclaw/ObsidianHelper/docs/SETUP_CHECKLIST.md`

**Philosophy:**  
See `/home/openclaw/ObsidianHelper/docs/ANTI-PERFECTIONISM-MANTRA.md`

---

**This is personal. This is important. This is his life.**

The goal: Track everything, provide accountability, push for action over perfection.
