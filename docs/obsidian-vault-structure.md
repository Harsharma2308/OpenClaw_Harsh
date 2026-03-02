# Obsidian Vault Structure

Complete guide to Harsh's Obsidian vault organization and file system.

**Vault Location:** `/home/openclaw/ObsidianVault/`  
**Git Repo:** `github.com:Harsharma2308/ObsidianVault` (private)  
**Last Updated:** March 2, 2026  

---

## Quick Navigation

| Category | Key Files | Purpose |
|----------|-----------|---------|
| **Master Docs** | `VAULT_OVERVIEW.md` | Overall context and current focus |
| | `ALL_TASKS_DUMP.md` | Brain dump of all tasks |
| **Daily** | `DaytoDay/YYYY-MM-DD.md` | Daily notes, habits, reflections |
| **Weekly** | `WeektoWeek/YYYY-W##.md` | Weekly reviews and planning |
| **Goals** | `AllMyGoals/MASTER_HUB.md` | Goal dashboard |
| | `AllMyGoals/Health-Whoop-Age.md` | Health goal tracking |
| **Philosophy** | `My life doc/PHILOSOPHY.md` | Core principles and values |
| **People** | `Notes/People Around Me.md` | Relationships and context |
| **Projects** | `Notes/Ideas.md` | Project ideas and concepts |
| **Templates** | `MyTemplates/Habits Checklist.md` | Daily habit template |

---

## Root-Level Files

### VAULT_OVERVIEW.md 📋
**Purpose:** Master context document  
**Contains:**
- Vault structure explanation
- Current focus areas (career, health, relationships)
- Dopamine problem and solutions
- Key people in Harsh's life
- Core philosophy summary
- Links to all major sections

**When to read:** Start of every new conversation with BillieJoe

### ALL_TASKS_DUMP.md 📝
**Purpose:** Brain dump of ALL tasks (no prioritization)  
**Workflow:**
1. Dump all tasks here (no filtering)
2. Pick 1-3 P0 tasks daily
3. Add to daily note
4. Undone tasks go back to dump

**Format:**
```markdown
## Career
- [ ] Task description

## Health
- [ ] Task description

## Personal
- [ ] Task description
```

---

## DaytoDay/ (Daily Notes)

**Format:** `YYYY-MM-DD.md` (e.g., `2026-03-02.md`)  
**Frequency:** One per day  
**Auto-created:** Via template or manually  

**Standard Structure:**
```markdown
# Monday, March 02, 2026

## 🌅 Morning Routine
- Woke up: 
- [ ] No phone on wake
- [ ] Water
- [ ] Physiological sighs
- [ ] Sunlight
- [ ] Meditation
- [ ] Gym/Exercise
- [ ] Shower
- [ ] Eat

## 📊 Whoop Data (Auto)
| Metric | Value |
|--------|-------|
| Sleep Performance | - |
| Recovery | - |
| HRV | - |
| Resting HR | - |

## 🎯 Today's Tasks (P0)
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## 💰 Expenses
| Item | Cost |
|------|------|

## ✅ What I Actually Did Today
*(filled by BillieJoe at end of day)*

## 💭 Notes / Reflections
```

**BillieJoe updates:**
- "What I Actually Did Today" section (10 PM PT)
- Habits completion status
- Reflections on progress

---

## WeektoWeek/ (Weekly Reviews)

**Format:** `YYYY-W##.md` (e.g., `2026-W09.md`)  
**Frequency:** One per week (created Sunday 8 PM PT)  
**Triggered by:** OpenClaw cron job  

**Standard Structure:**
```markdown
# Week 09, 2026 (Mar 3 - Mar 9)

## Wins This Week
- 

## Losses / Misses
- 

## Patterns Observed
### Good
- 

### Bad
- 

## Next Week Priorities
1. 
2. 
3. 

## Reflections
```

---

## AllMyGoals/

Goal tracking system with central dashboard and individual goal docs.

### MASTER_HUB.md (Dashboard)
**Purpose:** Central goal tracking  
**Contains:**
- Active goals across all areas
- Progress indicators
- Links to detailed goal docs
- Priority rankings

### Individual Goal Docs
- `Health-Whoop-Age.md` - Reduce Whoop age by 6 years
- `Financial-Net-Worth.md` - Financial goals
- `Career-IC3-Nvidia.md` - Career progression
- `Relationships-*.md` - Relationship goals

**Standard Goal Doc Format:**
```markdown
# Goal: [Goal Name]

## Target
- What: [Specific outcome]
- By When: [Deadline]
- Current: [Current state]

## Why This Matters
[Motivation]

## Action Plan
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Progress Log
### YYYY-MM-DD
- Update here

## Obstacles
- Challenge 1: [How to address]
- Challenge 2: [How to address]

## Related
- [[Link to related goal]]
- [[Link to daily note]]
```

---

## My life doc/

Personal philosophy, values, and deep reflections.

### PHILOSOPHY.md (Core Principles)
**Contains:**
- Core insight: "Remove dopamine addiction + practice concentration = half of life's problems solved"
- What Harsh actually wants (beach, coffee, fit body, meditation, books, conversations)
- Key principles (ACTION > PERFECTION, Joy > Pleasure, etc.)
- Dopamine problem explanation
- Values and fears

**Referenced by:** BillieJoe when making major decisions or giving life advice

---

## Notes/

### People Around Me.md
**Purpose:** Reference doc for relationships  
**Contains:**
- Close friends (Shirsendu, Utkarsh, Mandeep, Wesley, Anand)
- Relationship context (Anagha, Akshita, Kershia)
- Hackathon team members
- Work relationships (kept separate from personal)

**Updated:** When relationships change or new people enter life

### Ideas.md
**Purpose:** Project brainstorming  
**Contains:**
- LifeLog (life management system)
- Moltbot (AI assistant project)
- Research ideas
- Technical concepts

---

## MyTemplates/

### Habits Checklist.md
**5 Core Daily Habits:**
1. Sleep before 11pm
2. Morning phone-free 30min
3. Meditation (even 5 min)
4. Movement (Pull/Push/Run/Abs/Walk)
5. Deep work block

**Used in:** Daily notes, habit tracking

---

## Learning/

### Clear Thinking in the AI Age.md
**Purpose:** Research on cognition and AI  
**Contains:**
- Notes on AI offloading vs scrolling
- Concentration research
- Clear thinking frameworks

**Other docs:**
- Technical notes
- Paper summaries
- Project research

---

## Habits/

Habit tracking and analysis (if exists).

---

## MonthtoMonth/

**Format:** `YYYY-MM-Month.md` (e.g., `2026-03-March.md`)  
**Frequency:** One per month  
**Contains:**
- Monthly goals
- Weekly breakdowns
- End-of-month reflection

---

## File Naming Conventions

**Daily notes:** `YYYY-MM-DD.md` (ISO 8601)  
**Weekly notes:** `YYYY-W##.md` (ISO week number)  
**Monthly notes:** `YYYY-MM-Month.md` (month name)  
**Goal docs:** `Category-Specific-Goal.md` (kebab-case)  
**Reference docs:** `Topic Name.md` (title case)  

---

## Linking Strategy

**Internal links:** `[[File Name]]` or `[[File Name|Display Text]]`  
**Sections:** `[[File Name#Section]]`  
**Tags:** `#tag-name` (used sparingly)  

**Common link patterns:**
- Daily → Weekly → Monthly (temporal progression)
- Goal → Daily note (tracking progress)
- Philosophy → Decision notes (value alignment)
- People → Relationship updates (context)

---

## Vault Maintenance

### Auto-Sync (System Cron)
```bash
# Pull every 15 min
*/15 * * * * cd /home/openclaw/ObsidianVault && git pull --quiet
```

### Auto-Backup (OpenClaw Cron)
```bash
# Push daily at 10 PM PT
cd /home/openclaw/ObsidianVault && \
  git add -A && \
  git commit -m 'Daily backup: $(date +%Y-%m-%d)' && \
  git push || true
```

### Manual Operations
```bash
# Status check
cd ~/ObsidianVault && git status

# Commit changes
cd ~/ObsidianVault && git add -A && git commit -m "Update notes" && git push

# View history
cd ~/ObsidianVault && git log --oneline -10
```

---

## Integration with External Systems

### Google Sheets (via ObsidianHelper MCP)
- Life Tracking 2025 sheet
- Metrics: Goals, Habits, Health, Financial
- Whoop data auto-sync

### Whoop (Health Data)
- Recovery, strain, sleep, HRV
- Auto-pulled to daily notes (when configured)
- Tracked monthly in `AllMyGoals/Health-Whoop-Age.md`

### Google Calendar (via ObsidianHelper MCP)
- Events can be created from tasks
- Pending OAuth setup

---

## Best Practices

**For Harsh:**
- ✅ Brain dump to `ALL_TASKS_DUMP.md` freely
- ✅ Pick 1-3 P0 tasks daily (max)
- ✅ Fill "What I Actually Did" each evening
- ✅ Sunday weekly review (8 PM PT)
- ✅ Let BillieJoe handle structure and reminders

**For BillieJoe:**
- ✅ Read `VAULT_OVERVIEW.md` in new conversations
- ✅ Check today + yesterday's daily notes
- ✅ Update daily notes at end of day (10 PM PT)
- ✅ Call out patterns (good and bad)
- ✅ Hold Harsh accountable to stated goals
- ❌ Never delete without confirmation
- ❌ Always commit before major changes

---

_Last updated: 2026-03-02 by BillieJoe 🎸_
