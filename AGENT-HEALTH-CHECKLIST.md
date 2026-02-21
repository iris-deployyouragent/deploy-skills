# 🩺 Agent Health Checklist

Run through this after every new agent installation to verify everything is working.

---

## 1. ✅ Gateway Running

```bash
clawdbot status
```

**Check for:**
- [ ] Gateway service: `running`
- [ ] Gateway: `reachable` (low ms)
- [ ] Agents: shows at least 1 agent

**If not running:**
```bash
clawdbot gateway start
```

---

## 2. ✅ Heartbeat Working

```bash
clawdbot status | grep -i heartbeat
```

**Check for:**
- [ ] Heartbeat shows interval (e.g., `15m (main)`)

**Verify it's actually firing:**
```bash
grep -i "heartbeat.*started" ~/.clawdbot/logs/gateway.log | tail -5
```

- [ ] Recent timestamps (within last 15-30 min)

**If not firing:**
- Check Mac isn't sleeping: `pmset -g | grep sleep`
- Prevent sleep when plugged in: `sudo pmset -c sleep 0`

---

## 3. ✅ Channel Connected

### Telegram
```bash
# Send a test message to the bot
# Check logs for incoming message
grep -i telegram ~/.clawdbot/logs/gateway.log | tail -5
```
- [ ] Bot responds to messages

### Discord
```bash
grep -i discord ~/.clawdbot/logs/gateway.log | tail -10
```
- [ ] No repeated "connection closed" errors
- [ ] Bot shows online in server

---

## 4. ✅ Skills Installed

```bash
ls -la ~/clawd/skills/  # or client's workspace path
```

**Check for:**
- [ ] Skill folders exist (email-management, calendar, etc.)
- [ ] Each skill has `SKILL.md`
- [ ] Variant references in `references/` folder

**Test a skill:**
Ask the agent to do something from each installed skill:
- [ ] "Check my email" (email-management)
- [ ] "What's on my calendar today?" (calendar)
- [ ] "Create an invoice for $500" (invoicing)
- [ ] "Add a new lead: John Smith" (crm)

---

## 5. ✅ Environment Variables

```bash
cat ~/clawd/.env | grep -v "^#" | grep -v "^$"
```

**Check for:**
- [ ] All required credentials are set (not empty)
- [ ] No placeholder values like `your-api-key-here`

**Test credentials work:**
- [ ] API calls don't return auth errors
- [ ] Agent can actually perform actions (not just respond)

---

## 6. ✅ Cron Jobs

```bash
clawdbot cron list
```

**Check for:**
- [ ] Jobs are listed
- [ ] Jobs show `enabled: true`
- [ ] `lastStatus: ok` (after first run)
- [ ] `nextRunAtMs` is in the future

**If no cron jobs needed:** Skip this section.

---

## 7. ✅ Memory & Context

```bash
clawdbot status | grep -i memory
```

**Check for:**
- [ ] Memory shows files indexed
- [ ] Vector/FTS ready

**Verify workspace files:**
```bash
ls ~/clawd/
```
- [ ] `AGENTS.md` exists
- [ ] `memory/` folder exists
- [ ] `HEARTBEAT.md` exists (if using heartbeat checks)

---

## 8. ✅ Mission Control (if deployed)

Open dashboard URL and check:

- [ ] Agent shows in agents list
- [ ] Status shows "active" or "online"
- [ ] Heartbeat graph shows green (not all red)
- [ ] Recent activity is logging

**Test dashboard → agent communication:**
- [ ] Create task in dashboard
- [ ] Agent picks it up on next heartbeat

---

## 9. ✅ Error Check

```bash
tail -50 ~/.clawdbot/logs/gateway.err.log
```

**Check for:**
- [ ] No repeated errors
- [ ] No auth failures
- [ ] No crash loops

**Common issues:**
| Error | Fix |
|-------|-----|
| `ANTHROPIC_API_KEY` invalid | Check API key in config |
| `WebSocket closed 1006` | Network/sleep issue |
| `rate limit` | Slow down or upgrade plan |
| `ECONNREFUSED` | Service not running |

---

## 10. ✅ Full Integration Test

Run through a real workflow:

1. [ ] Send message via Telegram/Discord
2. [ ] Agent responds correctly
3. [ ] Agent uses a skill successfully
4. [ ] Action is logged in Mission Control
5. [ ] Heartbeat fires on schedule
6. [ ] Cron job runs (if applicable)

---

## Quick Health Command

Run all checks at once:

```bash
echo "=== Gateway ===" && clawdbot status | head -20
echo ""
echo "=== Recent Heartbeats ===" && grep "heartbeat.*started" ~/.clawdbot/logs/gateway.log | tail -3
echo ""
echo "=== Skills ===" && ls ~/clawd/skills/ 2>/dev/null || echo "No skills folder"
echo ""
echo "=== Errors (last 5) ===" && tail -5 ~/.clawdbot/logs/gateway.err.log
echo ""
echo "=== Cron Jobs ===" && clawdbot cron list 2>/dev/null | head -10 || echo "No cron"
```

---

## Handoff to Client

Before leaving:

- [ ] Walk client through sending a message
- [ ] Show them the Mission Control dashboard
- [ ] Explain what heartbeats mean
- [ ] Leave them with support contact
- [ ] Document any client-specific quirks

---

*Last updated: Feb 21, 2026*
