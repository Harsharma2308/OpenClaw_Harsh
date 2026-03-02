# Documentation

Comprehensive documentation for BillieJoe OpenClaw setup.

---

## Quick Links

| Doc | Purpose |
|-----|---------|
| [Telegram Setup](telegram-setup.md) | Configure Telegram bot integration |
| [Obsidian Integration](obsidian-integration.md) | How BillieJoe uses Obsidian vault |
| [Obsidian Vault Structure](obsidian-vault-structure.md) | Complete vault layout reference |
| [Obsidian Helper MCP](obsidian-helper-mcp.md) | MCP servers for future integration |

---

## Documentation Structure

### Setup Guides
- **[telegram-setup.md](telegram-setup.md)** - Telegram bot configuration
- **[../setup/README.md](../setup/README.md)** - Full deployment guide
- **[../STRUCTURE.md](../STRUCTURE.md)** - Repository organization

### Integration Docs
- **[obsidian-integration.md](obsidian-integration.md)** - Obsidian + OpenClaw integration
  - How BillieJoe reads/writes vault
  - Sync workflow (15min pull, daily push)
  - Coaching philosophy using vault data
  - Key files monitored
- **[obsidian-vault-structure.md](obsidian-vault-structure.md)** - Vault layout
  - Complete file structure
  - Daily/weekly/monthly note formats
  - Goal tracking system
  - File naming conventions
  - Linking strategy
- **[obsidian-helper-mcp.md](obsidian-helper-mcp.md)** - MCP servers
  - Obsidian MCP (vault access)
  - Google Sheets MCP (metrics)
  - Google Calendar MCP (events)
  - Whoop MCP (health data)
  - FatSecret MCP (nutrition)

### Workspace Files (Symlinked)
See [../workspace/](../workspace/) for active agent configuration files:
- `AGENTS.md` - Core behavior
- `SOUL.md` - Persona and philosophy
- `SYSTEMS.md` - Architecture decisions
- `SETUP.md` - Configuration guide
- `MIGRATION.md` - Moving to new machine

---

## External References

**Official OpenClaw Docs:**
- https://docs.openclaw.ai - Official documentation
- https://discord.com/invite/clawd - Community Discord
- https://clawhub.com - Skill marketplace
- https://github.com/openclaw/openclaw - Source code

**Harsh's Repos:**
- `github.com:Harsharma2308/OpenClaw_Harsh` - This repo (documentation)
- `github.com:Harsharma2308/ObsidianVault` - Obsidian vault (private)
- `github.com:Harsharma2308/ObsidianHelper` - MCP servers

---

## Quick Reference

**Find specific documentation:**
```bash
# Telegram setup
cat docs/telegram-setup.md

# Obsidian integration
cat docs/obsidian-integration.md

# Vault structure
cat docs/obsidian-vault-structure.md

# MCP servers
cat docs/obsidian-helper-mcp.md

# Full deployment guide
cat setup/README.md

# Repository organization
cat STRUCTURE.md
```

**Browse on GitHub:**
- Docs: `https://github.com/Harsharma2308/OpenClaw_Harsh/tree/main/docs`
- Workspace: `https://github.com/Harsharma2308/OpenClaw_Harsh/tree/main/workspace`
- Setup: `https://github.com/Harsharma2308/OpenClaw_Harsh/tree/main/setup`

---

_Last updated: 2026-03-02 by BillieJoe 🎸_
