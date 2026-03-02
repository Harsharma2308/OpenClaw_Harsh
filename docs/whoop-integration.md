# Whoop Integration - Complete Guide

**Last Updated:** 2026-03-02  
**Status:** ✅ Working (Direct Access Token)  
**Location:** `~/.openclaw/skills/whoop/`

---

## Overview

Automatic sync of Whoop health data (recovery, sleep, strain, workouts) to Obsidian daily notes.

**What gets synced:**
- Recovery score, HRV, resting heart rate
- Sleep performance, duration, efficiency, stages
- Daily strain score and energy expenditure
- Workout details (activity type, duration, strain)

**Where it goes:**
- `ObsidianVault/DaytoDay/YYYY-MM-DD.md` under `## 📊 Whoop Data` section
- Updates idempotently (replaces old data if re-run)

---

## Architecture

### Current Setup (Temporary)

**OAuth Flow Location:** Local machine (Harsh's laptop)  
**Why:** VPS has no GUI/browser for OAuth web flow  
**Token Lifetime:** ~1 hour  
**Refresh Strategy:** Manual re-auth when expired  

**How it works:**
1. Harsh runs OAuth flow on `localhost:3000` (local CC handles this)
2. Receives fresh **access token** + refresh token
3. Gives BillieJoe (OpenClaw) the **access token only**
4. BillieJoe uses token directly to hit Whoop API
5. When token expires (~1 hour), Harsh re-auths and provides fresh token

**Critical:** OpenClaw does NOT use refresh tokens. This prevents invalidating the local CC's refresh token (Whoop invalidates old refresh tokens when you use them).

### Future Setup (Planned)

Set up headless OAuth flow directly on VPS:
- Run OAuth server on VPS (port forwarding or ngrok)
- Whoop redirects back to VPS after auth
- Store refresh token in `.env`
- Auto-refresh access tokens as needed
- No manual token updates required

**Blocker:** Requires setting up public endpoint for OAuth callback.

---

## Files & Structure

### Skill Location
```
~/.openclaw/skills/whoop/
├── SKILL.md              # User-facing documentation
└── whoop-sync.js         # Sync script (Node.js)
```

### Configuration
**File:** `~/.openclaw/.env`

```bash
# Whoop - Direct access token (expires ~1 hour)
WHOOP_ACCESS_TOKEN=rjWv0uiRaOHQ__A4HH7yMqA4y0P8Z8WWTxPCt4sR7dg...

# Optional overrides
WHOOP_VAULT_PATH=/home/openclaw/ObsidianVault
WHOOP_DAILY_PATH=DaytoDay
```

**Security:** `.env` file is in `.gitignore` (never committed to repos)

---

## Whoop API Details

### Base URL
```
https://api.prod.whoop.com/developer/v1
```

### Authentication
- **Method:** Bearer token in `Authorization` header
- **Token Type:** OAuth 2.0 access token
- **Expiration:** ~1 hour (3600 seconds)
- **Refresh:** Not handled by OpenClaw (prevents token invalidation for local CC)

### Endpoints Used

| Endpoint | Purpose | Response |
|----------|---------|----------|
| `/recovery` | Recovery score, HRV, RHR | Latest recovery record for date range |
| `/sleep` | Sleep performance, stages, efficiency | Latest sleep record for date range |
| `/cycle` | Daily strain, energy, heart rate | Latest physiological cycle |
| `/workout` | Activities with duration and strain | Array of workouts for date range |

**Query Parameters:**
- `start` — ISO 8601 timestamp (e.g., `2026-03-01T00:00:00.000Z`)
- `end` — ISO 8601 timestamp (e.g., `2026-03-02T00:00:00.000Z`)
- `limit` — Max records to return (default: 25, we use 1 for single-day queries)

### Required OAuth Scopes

**App must have these enabled at developer.whoop.com:**
- ✅ `read:recovery` — Access recovery data
- ✅ `read:sleep` — Access sleep data
- ✅ `read:cycles` — Access strain/cycle data
- ✅ `read:workout` — Access workout data
- ✅ `offline` — Receive refresh tokens

**Without these scopes:** API returns `404 Not Found` for missing permissions.

---

## Usage

### Manual Sync

```bash
# Sync today's data
node ~/.openclaw/skills/whoop/whoop-sync.js

# Sync specific date
node ~/.openclaw/skills/whoop/whoop-sync.js 2026-03-01

# Custom vault path
node ~/.openclaw/skills/whoop/whoop-sync.js 2026-03-01 ~/MyVault
```

**Help:**
```bash
node ~/.openclaw/skills/whoop/whoop-sync.js --help
```

### From OpenClaw Chat

```
Run Whoop sync for today
```

OpenClaw will execute:
```bash
node ~/.openclaw/skills/whoop/whoop-sync.js
```

### Automated Daily Sync (Planned)

**Cron job (8 AM daily):**
```javascript
{
  "name": "Morning Whoop Sync",
  "schedule": { 
    "kind": "cron", 
    "expr": "0 8 * * *", 
    "tz": "America/Los_Angeles" 
  },
  "payload": {
    "kind": "agentTurn",
    "message": "Run Whoop sync: `node ~/.openclaw/skills/whoop/whoop-sync.js`. If token expired (401 error), notify Harsh to refresh token."
  },
  "sessionTarget": "isolated",
  "delivery": { "mode": "announce" }
}
```

**Not implemented yet:** Blocked on token expiration handling (currently requires manual token refresh every hour).

---

## Token Management

### Getting a Fresh Token

**On Harsh's laptop (where local CC runs):**

1. Ensure Whoop OAuth app is running on `localhost:3000`
2. Open browser to `http://localhost:3000`
3. Approve Whoop login
4. Copy **access token** from response
5. Paste into chat with BillieJoe

**BillieJoe adds it to `.env`:**
```bash
sed -i '/^WHOOP_ACCESS_TOKEN=/d' ~/.openclaw/.env
echo "WHOOP_ACCESS_TOKEN=new_token_here" >> ~/.openclaw/.env
```

### Token Expiration

**Symptoms:**
- API returns `401 Unauthorized`
- Sync script shows: "Auth failed - token expired or invalid"

**Solution:**
Re-authenticate and provide fresh access token (see above).

### Why Not Auto-Refresh?

**Problem:** Whoop OAuth invalidates old refresh tokens when you use them.

**If BillieJoe used refresh tokens:**
1. Local CC has refresh token A
2. BillieJoe uses refresh token A → gets new access token + refresh token B
3. Refresh token A is now **invalid**
4. Local CC can no longer refresh → breaks local CC

**Solution:** 
- Local CC keeps refresh token and manages its own tokens
- BillieJoe only uses short-lived access tokens
- No conflict, both systems work independently

---

## Data Format

### Markdown Output

Written to: `ObsidianVault/DaytoDay/YYYY-MM-DD.md`

**Example:**
```markdown
## 📊 Whoop Data

**Recovery:** 75%
- HRV: 62ms
- RHR: 52 bpm

**Sleep:** 85%
- Duration: 7h 32m
- Efficiency: 92%
- Respiratory: 14.2 rpm
- Stages: REM 105m | Deep 87m | Light 268m

**Strain:** 12.4
- Energy: 1842 kJ
- Avg HR: 98 bpm
- Max HR: 165 bpm

**Workouts:** 2
1. Running - 32min, Strain 9.2
2. Strength Training - 45min, Strain 11.3
```

### No Data Available

If Whoop hasn't synced data yet:

```markdown
## 📊 Whoop Data

*No data available*

> Typically available 1-2 hours after waking
```

**Timing:** Whoop processes overnight data 1-2 hours after you wake up. Running sync before then yields empty results.

---

## API Response Structure

### Recovery Endpoint

```json
{
  "records": [
    {
      "cycle_id": 1341482721,
      "sleep_id": 1304691825,
      "user_id": 11806751,
      "created_at": "2026-03-01T14:37:38.060Z",
      "updated_at": "2026-03-01T14:37:42.717Z",
      "score_state": "SCORED",
      "score": {
        "user_calibrating": false,
        "recovery_score": 75,
        "resting_heart_rate": 52,
        "hrv_rmssd_milli": 62.5,
        "spo2_percentage": 96.2,
        "skin_temp_celsius": 33.4
      }
    }
  ],
  "next_token": null
}
```

### Sleep Endpoint

```json
{
  "records": [
    {
      "id": 1304691825,
      "user_id": 11806751,
      "created_at": "2026-03-01T14:37:38.060Z",
      "updated_at": "2026-03-01T14:37:38.068Z",
      "start": "2026-02-29T06:15:23.000Z",
      "end": "2026-03-01T13:48:11.000Z",
      "timezone_offset": "-08:00",
      "nap": false,
      "score_state": "SCORED",
      "score": {
        "stage_summary": {
          "total_in_bed_time_milli": 27168000,
          "total_awake_time_milli": 1620000,
          "total_no_data_time_milli": 0,
          "total_light_sleep_duration_milli": 16080000,
          "total_slow_wave_sleep_duration_milli": 5220000,
          "total_rem_sleep_duration_milli": 6300000,
          "sleep_cycle_count": 4,
          "disturbance_count": 8
        },
        "sleep_needed": {
          "baseline_milli": 28800000,
          "need_from_sleep_debt_milli": 1200000,
          "need_from_recent_strain_milli": 600000,
          "need_from_recent_nap_milli": -1800000
        },
        "respiratory_rate": 14.2,
        "sleep_performance_percentage": 85,
        "sleep_consistency_percentage": 78,
        "sleep_efficiency_percentage": 92
      }
    }
  ]
}
```

### Cycle (Strain) Endpoint

```json
{
  "records": [
    {
      "id": 1341482721,
      "user_id": 11806751,
      "created_at": "2026-03-02T04:01:52.092Z",
      "updated_at": "2026-03-02T04:01:57.756Z",
      "start": "2026-03-01T06:37:38.060Z",
      "end": null,
      "timezone_offset": "-08:00",
      "score_state": "SCORED",
      "score": {
        "strain": 12.092192,
        "kilojoule": 3896.5952,
        "average_heart_rate": 75,
        "max_heart_rate": 192
      }
    }
  ]
}
```

### Workout Endpoint

```json
{
  "records": [
    {
      "id": 1740524561,
      "user_id": 11806751,
      "created_at": "2026-03-01T18:23:07.411Z",
      "updated_at": "2026-03-01T18:23:12.964Z",
      "start": "2026-03-01T17:45:23.000Z",
      "end": "2026-03-01T18:17:14.000Z",
      "timezone_offset": "-08:00",
      "sport_id": 1,
      "score_state": "SCORED",
      "score": {
        "strain": 9.2341,
        "average_heart_rate": 142,
        "max_heart_rate": 175,
        "kilojoule": 1456.32,
        "percent_recorded": 100,
        "distance_meter": 5200.0,
        "altitude_gain_meter": 42.0,
        "altitude_change_meter": -8.0,
        "zone_duration": {
          "zone_zero_milli": 0,
          "zone_one_milli": 420000,
          "zone_two_milli": 840000,
          "zone_three_milli": 540000,
          "zone_four_milli": 180000,
          "zone_five_milli": 0
        },
        "sport_name": "Running",
        "duration_milli": 1911000
      }
    }
  ]
}
```

---

## Troubleshooting

### 401 Unauthorized

**Cause:** Access token expired (lifetime ~1 hour)

**Solution:**
1. Re-authenticate at `localhost:3000`
2. Get fresh access token
3. Give to BillieJoe to update `.env`

### 404 Not Found (on specific endpoints)

**Cause:** OAuth app missing required scopes

**Check scopes at developer.whoop.com:**
- App → Settings → Scopes
- Ensure all `read:*` scopes are enabled
- Re-authenticate to get token with new scopes

### No Data Available

**Causes:**
1. **Too early:** Data typically available 1-2 hours after waking
2. **No Whoop data:** Device not worn or not synced
3. **Wrong date:** Check date range matches when you had Whoop on

**Solutions:**
- Wait until mid-morning and re-run sync
- Check Whoop app to confirm data is there
- Try yesterday's date if today is too recent

### Script Not Found

**Check installation:**
```bash
ls -la ~/.openclaw/skills/whoop/
```

**Expected:**
```
drwxrwxr-x 2 openclaw openclaw 4096 Mar  2 06:00 .
-rw-rw-r-- 1 openclaw openclaw 2795 Mar  2 05:45 SKILL.md
-rwxrwxr-x 1 openclaw openclaw 8991 Mar  2 06:15 whoop-sync.js
```

**If missing:** Re-create from backup or documentation.

### Rate Limiting

**Whoop API limits:** Not publicly documented, but generous

**If hit:**
- Wait 5-10 minutes
- Don't sync more than once per hour (data doesn't change that fast anyway)

---

## Security Considerations

### Access Token Storage

**Location:** `~/.openclaw/.env`  
**Permissions:** 600 (user read/write only)  
**Git:** Excluded via `.gitignore` (never committed)

**Risk:** Token grants full read access to Whoop account data

**Mitigation:**
- Tokens expire in ~1 hour (short window)
- VPS accessible only by Harsh
- No token refresh capability (limits damage window)

### OAuth App Credentials

**Client ID:** Public (safe to expose)  
**Client Secret:** Sensitive (keep in `.env` only)  
**Refresh Token:** Critical (stored on local CC only, never on VPS)

**Current setup:** VPS only has access tokens, not refresh capability.

### Scope Minimization

**Principle:** Only request scopes you need.

**Required:**
- `read:recovery` — For recovery score
- `read:sleep` — For sleep data
- `read:cycles` — For strain data
- `read:workout` — For workout history

**Not needed:**
- `write:*` scopes — OpenClaw never modifies Whoop data
- `delete:*` scopes — Never delete data
- `offline` — Only needed if storing refresh token (not on VPS currently)

---

## Future Improvements

### Priority 1: Headless OAuth on VPS

**Goal:** Eliminate manual token refresh

**Implementation:**
1. Set up OAuth callback server on VPS
2. Use ngrok or port forwarding for public endpoint
3. Register callback URL in Whoop developer portal
4. Store refresh token in `.env`
5. Auto-refresh access tokens before expiration

**Benefit:** Fully automated, no manual token updates

### Priority 2: Daily Auto-Sync Cron

**Goal:** Automatic morning sync of Whoop data

**Implementation:**
```javascript
{
  "name": "Morning Whoop Sync",
  "schedule": { "kind": "cron", "expr": "0 8 * * *", "tz": "America/Los_Angeles" },
  "payload": {
    "kind": "agentTurn",
    "message": "Run: node ~/.openclaw/skills/whoop/whoop-sync.js. Log success/failure to daily note."
  },
  "sessionTarget": "isolated",
  "delivery": { "mode": "announce" }
}
```

**Blocker:** Requires stable token (headless OAuth first)

### Priority 3: Historical Backfill

**Goal:** Sync past Whoop data into existing daily notes

**Implementation:**
```bash
# Backfill last 30 days
for i in {0..30}; do
  date=$(date -d "$i days ago" +%Y-%m-%d)
  node whoop-sync.js $date
done
```

**Use case:** Populate daily notes retroactively when first setting up skill

### Priority 4: Webhook Integration

**Goal:** Real-time updates when Whoop processes new data

**Whoop Webhook Support:** Yes (available in API docs)

**Implementation:**
1. Set up webhook endpoint on VPS
2. Register with Whoop to receive notifications
3. Auto-sync when new recovery/sleep data available
4. No more "data not ready yet" issues

**Benefit:** Always have fresh data without polling

---

## Related Documentation

- **Skill Documentation:** `~/.openclaw/skills/whoop/SKILL.md`
- **Obsidian Integration:** `docs/obsidian-integration.md`
- **Daily Note Structure:** `docs/obsidian-vault-structure.md`
- **Cron Jobs:** `SYSTEMS.md` > Cron Jobs & Automation

---

## Changelog

**2026-03-02:**
- ✅ Initial implementation with direct access token
- ✅ Tested with real Whoop account (Harsh Sharma)
- ✅ Confirmed API access to cycle/strain data
- ⚠️ Recovery/sleep endpoints returning 404 (scope issue or no data)
- 📝 Documented architecture and manual token flow

**Pending:**
- [ ] Set up headless OAuth on VPS
- [ ] Implement automatic token refresh
- [ ] Add daily auto-sync cron job
- [ ] Test with full data set (recovery + sleep)

---

_Maintained by BillieJoe 🎸 | Last updated: 2026-03-02_
