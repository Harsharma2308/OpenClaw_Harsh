# ObsidianHelper MCP Servers

Model Context Protocol (MCP) servers for deep Obsidian + Google Workspace + Health integrations.

**Repo:** `github.com:Harsharma2308/ObsidianHelper`  
**Location:** `/home/openclaw/ObsidianHelper/`  
**Designed for:** Cursor IDE (Claude Desktop integration)  
**Status with OpenClaw:** Not currently integrated (uses direct file access instead)

---

## What is MCP?

**Model Context Protocol:** Standard for connecting AI assistants to external data sources.

**Architecture:**
```
AI Assistant (Cursor/Claude) ──→ MCP Server ──→ Data Source
                                                (Obsidian, Sheets, etc.)
```

**Benefits:**
- Standardized interface
- Bidirectional data flow
- Tool-based interaction (not just file reads)
- Real-time updates

---

## Available MCP Servers

### 1. Obsidian MCP Server

**Purpose:** Programmatic vault access  
**Location:** `~/ObsidianHelper/obsidian-mcp-server/`  

**Capabilities:**
- Search vault by content
- Read specific notes
- Create/update notes
- List recent notes
- Tag operations

**Setup:**
1. Install Obsidian plugin: "Local REST API"
2. Enable HTTP Server in plugin settings
3. Copy API key
4. Configure in `start-obsidian-mcp.sh`

**Start:**
```bash
cd ~/ObsidianHelper
./start-obsidian-mcp.sh
```

### 2. Google Sheets MCP Server

**Purpose:** Metrics tracking and data logging  
**Location:** `~/ObsidianHelper/` (uses Google Sheets API)  

**Capabilities:**
- Read spreadsheet data
- Write to specific cells/ranges
- Append rows
- Update formulas

**Harsh's Sheet:**
- **Name:** Life Tracking - 2025
- **ID:** `15aUGibPF-FyPcx8UBuZKyalni3hLRMbOMklt287dsMA`
- **Tabs:** Master Goals, Weekly Tracking, Health Metrics, Habit Tracker, Financial

**Setup:**
1. Google Cloud project
2. Enable Sheets API
3. Create service account
4. Share sheet with service account email
5. Download credentials JSON

**Start:**
```bash
cd ~/ObsidianHelper
./start-google-sheets-mcp.sh
```

### 3. Google Calendar MCP Server

**Purpose:** Event scheduling and calendar management  
**Location:** `~/ObsidianHelper/google-calendar-mcp/`  

**Capabilities:**
- List upcoming events
- Create events
- Update events
- Delete events
- Check availability

**Setup:**
1. Google Cloud OAuth setup
2. Enable Calendar API
3. Create OAuth credentials
4. Run OAuth flow

**Start:**
```bash
cd ~/ObsidianHelper
./start-google-calendar-mcp.sh
```

### 4. Whoop MCP Server

**Purpose:** Health data from Whoop wearable  
**Location:** `~/ObsidianHelper/whoop-mcp-server/`  

**Capabilities:**
- Recovery score
- Sleep metrics (hours, quality, HRV, RHR)
- Strain data
- Whoop age

**Setup:**
1. Whoop account
2. Get API credentials
3. Configure in start script

**Re-auth:** Feb 4, 2026 (valid for ~90 days)

**Start:**
```bash
cd ~/ObsidianHelper
./start-whoop-mcp.sh
```

### 5. FatSecret MCP Server

**Purpose:** Nutrition and food tracking  
**Location:** `~/ObsidianHelper/fatsecret-mcp/`  

**Capabilities:**
- Search foods
- Log meals
- Get nutrition data
- Track calories/macros

**Setup:**
1. FatSecret account
2. API credentials
3. Configure OAuth

---

## MCP vs OpenClaw Direct File Access

### Current Setup (OpenClaw)

**Approach:** Direct file system access  
**How it works:**
- Read files: `read ~/.openclaw/workspace/AGENTS.md`
- Write files: `write /home/openclaw/ObsidianVault/DaytoDay/2026-03-02.md`
- Git operations: `cd ~/ObsidianVault && git add -A && git commit -m "Update" && git push`

**Pros:**
- ✅ Simple, no additional setup
- ✅ Works out of the box
- ✅ Full git integration
- ✅ No external dependencies

**Cons:**
- ❌ Limited to file operations
- ❌ No structured queries (e.g., "find all notes mentioning X")
- ❌ No real-time Obsidian UI updates

### MCP Server Approach

**Approach:** Structured API access via MCP  
**How it works:**
- Define tools (e.g., `search_vault`, `create_note`)
- OpenClaw calls MCP server
- MCP server interacts with Obsidian API
- Results returned to OpenClaw

**Pros:**
- ✅ Structured queries (semantic search)
- ✅ Real-time Obsidian UI updates
- ✅ Richer metadata (tags, links, backlinks)
- ✅ Standardized interface

**Cons:**
- ❌ More complex setup
- ❌ Requires Obsidian plugin running
- ❌ Additional dependency

---

## Future Integration Path

**Potential use cases for MCP + OpenClaw:**

### 1. Semantic Search
```
"Find all notes where I mentioned feeling stuck about career"
→ MCP searches vault semantically
→ Returns relevant notes with context
```

### 2. Whoop Auto-Pull
```
# Morning cron job
1. Query Whoop MCP for last night's data
2. Write to today's daily note
3. Commit to vault
```

### 3. Calendar → Task Sync
```
# When Harsh mentions a deadline
1. Create calendar event via Calendar MCP
2. Add task to ALL_TASKS_DUMP.md
3. Link calendar event in daily note
```

### 4. Google Sheets Metrics
```
# Weekly review cron
1. Pull week's habit data from daily notes
2. Write to Google Sheets via Sheets MCP
3. Update goal progress in vault
```

---

## Setting Up MCP with OpenClaw (Future)

**Step 1: Define MCP Tool Wrappers**
```typescript
// In OpenClaw skill or plugin
async function searchVault(query: string) {
  const mcpClient = await connectMCP('obsidian');
  return await mcpClient.callTool('search', { query });
}
```

**Step 2: Start MCP Servers**
```bash
# Add to system startup or supervisor
~/ObsidianHelper/start-obsidian-mcp.sh &
~/ObsidianHelper/start-whoop-mcp.sh &
```

**Step 3: Configure OpenClaw**
```json
{
  "tools": {
    "obsidian_search": {
      "type": "mcp",
      "server": "http://localhost:3000",
      "endpoint": "/search"
    }
  }
}
```

**Step 4: Use in AGENTS.md**
```markdown
## Skills
- obsidian_search: Semantic vault search via MCP
- whoop_data: Pull health metrics from Whoop
```

---

## Current Status (March 2026)

**MCP Servers:**
- ✅ Installed and configured
- ✅ Tested with Cursor IDE
- ⏳ Not integrated with OpenClaw (using direct file access)

**Google OAuth:**
- ⏳ Pending browser OAuth flow for Calendar + Sheets
- Credentials configured
- Needs completion

**Whoop:**
- ✅ Re-authenticated Feb 4, 2026
- Valid for ~90 days (re-auth needed ~May 2026)

**Decision:** Keep using direct file access for now. MCP integration is future enhancement when needed for semantic search or real-time updates.

---

## Documentation

**Full setup guide:** `~/ObsidianHelper/README.md`  
**Setup checklist:** `~/ObsidianHelper/docs/SETUP_CHECKLIST.md`  
**MCP servers doc:** `~/ObsidianHelper/docs/MCP_SERVERS.md`  

---

_Last updated: 2026-03-02 by BillieJoe 🎸_
