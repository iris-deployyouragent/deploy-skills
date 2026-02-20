# Clawdbot Deep Dive - Deploy Your Agent Business Intel

**Date:** February 20, 2026  
**Version:** Clawdbot 2026.1.24-3  
**Purpose:** Comprehensive analysis of Clawdbot capabilities for Deploy Your Agent business

---

## Executive Summary

Clawdbot is a **personal AI assistant platform** that enables AI agents to:
- Connect to multiple messaging channels (WhatsApp, Telegram, Discord, Slack, etc.)
- Execute code, browse the web, manage files
- Use voice and TTS capabilities
- Run scheduled tasks and webhooks
- Work in multi-agent configurations
- Deploy with sandboxing and security controls

**For our business**, this is the perfect foundation for deploying AI agents to clients. We can offer:
- White-label AI assistants across any channel
- Customizable skills and personas
- Secure, sandboxed deployments
- Automated workflows via cron/webhooks

---

## 1. Channel Integrations (ALL Supported Channels)

### Built-in Channels
| Channel | Status | Best For | Notes |
|---------|--------|----------|-------|
| **WhatsApp** | ✅ Core | Personal/Business messaging | Uses Baileys (web protocol), multi-account support |
| **Telegram** | ✅ Core | Bots, groups | Full Bot API via grammY, threads/topics supported |
| **Discord** | ✅ Core | Communities | Guild management, DMs, rich formatting |
| **Slack** | ✅ Core | Enterprise | Bolt SDK, workspace apps |
| **Signal** | ✅ Core | Privacy-focused | Requires signal-cli |
| **iMessage** | ✅ Core | Apple users | macOS only (imsg CLI) |
| **Google Chat** | ✅ Core | G Suite users | Chat API |
| **WebChat** | ✅ Core | Web apps | Built-in widget, embeddable |

### Plugin Channels (Extensions)
| Channel | Status | Install |
|---------|--------|---------|
| **Microsoft Teams** | Plugin | `@clawdbot/msteams` |
| **Matrix** | Plugin | `@clawdbot/matrix` |
| **Nostr** | Plugin | `@clawdbot/nostr` |
| **Zalo** | Plugin | `@clawdbot/zalo` |
| **Zalo Personal** | Plugin | `@clawdbot/zalouser` |
| **BlueBubbles** | Extension | `bluebubbles` |
| **Mattermost** | Extension | Built-in |
| **Nextcloud Talk** | Extension | `@clawdbot/nextcloud-talk` |

### Business Recommendation
- **Standard install**: WhatsApp + Telegram (covers 90% of users)
- **Enterprise**: Add Slack + Teams
- **Privacy-focused**: Signal + Matrix

---

## 2. Gateway Features (The Control Plane)

### Core Gateway Capabilities

```json5
{
  gateway: {
    port: 18789,            // WebSocket + HTTP
    bind: "loopback",       // loopback | lan | tailnet | custom
    auth: {
      mode: "token",        // token | password | off
      token: "SECRET"
    },
    tailscale: {
      mode: "serve"         // off | serve | funnel
    }
  }
}
```

### Key Features for Business

1. **Remote Access Options**
   - Tailscale Serve (tailnet-only) 
   - Tailscale Funnel (public HTTPS)
   - SSH tunnels
   - Custom reverse proxy

2. **Control UI Dashboard**
   - Web-based management at `http://127.0.0.1:18789/`
   - Session management
   - Config editing with JSON Schema validation
   - Real-time logs

3. **Health Monitoring**
   - `clawdbot health` - API health check
   - `clawdbot doctor` - Full diagnostics
   - `clawdbot security audit` - Security checks

---

## 3. Multi-Agent Architecture

### What This Means for Business
We can deploy **multiple agents on a single gateway** - each with:
- Separate workspace (files, persona, memory)
- Separate auth profiles (API keys)
- Separate session stores
- Different tool access

### Configuration Example

```json5
{
  agents: {
    list: [
      {
        id: "support",
        name: "Customer Support",
        workspace: "~/agents/support",
        model: "anthropic/claude-sonnet-4-5"
      },
      {
        id: "sales",
        name: "Sales Assistant", 
        workspace: "~/agents/sales",
        model: "anthropic/claude-opus-4-5"
      }
    ]
  },
  bindings: [
    { agentId: "support", match: { channel: "whatsapp", peer: { kind: "group", id: "SUPPORT_GROUP_ID" } } },
    { agentId: "sales", match: { channel: "telegram" } }
  ]
}
```

### Broadcast Groups (Multiple Agents on Same Chat)
Send same message to multiple agents simultaneously:

```json5
{
  broadcast: {
    strategy: "parallel",
    "GROUP_JID": ["code-reviewer", "security-scanner", "docs-generator"]
  }
}
```

---

## 4. Skills System (Extensibility)

### Skill Locations (Precedence Order)
1. **Workspace skills**: `<workspace>/skills/` (per-agent, highest)
2. **Managed skills**: `~/.clawdbot/skills/` (shared across agents)
3. **Bundled skills**: Shipped with Clawdbot (lowest)

### Built-in Skills (52 total!)
| Category | Skills |
|----------|--------|
| **Productivity** | apple-notes, apple-reminders, bear-notes, notion, obsidian, things-mac, trello |
| **Communication** | discord, slack, bluebubbles, himalaya (email) |
| **Media** | camsnap, video-frames, openai-image-gen, gifgrep, songsee |
| **Voice** | sag (ElevenLabs TTS), openai-whisper, sherpa-onnx-tts |
| **Development** | coding-agent, github, skill-creator |
| **IoT/Home** | openhue (Philips Hue), sonoscli, weather |
| **AI/Search** | gemini, summarize, oracle |
| **Location** | local-places, goplaces |
| **Utilities** | canvas, session-logs, model-usage, tmux |

### Skill Format (SKILL.md)

```markdown
---
name: my-skill
description: What it does
metadata: {"clawdbot":{"emoji":"🎯","requires":{"bins":["node"],"env":["API_KEY"]}}}
---

# My Skill

Instructions for the agent...
```

### ClawdHub - Skills Registry
- **URL**: https://clawdhub.com
- **Install**: `clawdhub install <skill-slug>`
- **Update**: `clawdhub update --all`
- **Publish**: `clawdhub publish ./my-skill`

### Creating Custom Skills for Clients
```bash
# Install skill-creator skill
clawdbot skills enable skill-creator

# Create new skill
mkdir -p ~/clawd/skills/client-custom
# Write SKILL.md with instructions
```

---

## 5. Automation Features

### Cron Jobs (Scheduled Tasks)

```bash
# One-shot reminder
clawdbot cron add \
  --name "Morning report" \
  --at "2026-02-21T08:00:00Z" \
  --session isolated \
  --message "Generate daily summary" \
  --deliver \
  --channel whatsapp \
  --to "+15551234567"

# Recurring job
clawdbot cron add \
  --name "Weekly analysis" \
  --cron "0 9 * * 1" \
  --tz "America/Los_Angeles" \
  --session isolated \
  --message "Weekly project analysis" \
  --model "opus" \
  --thinking high
```

### Heartbeats (Proactive Checks)

```json5
{
  agents: {
    defaults: {
      heartbeat: {
        every: "30m",
        target: "last",
        prompt: "Read HEARTBEAT.md. If nothing needs attention, reply HEARTBEAT_OK."
      }
    }
  }
}
```

**HEARTBEAT.md** example:
```markdown
# Heartbeat Checklist
- Check inbox for urgent items
- Review upcoming calendar events
- Check on active projects
```

### Webhooks (External Triggers)

```json5
{
  hooks: {
    enabled: true,
    token: "SECRET",
    path: "/hooks"
  }
}
```

Endpoints:
- `POST /hooks/wake` - Wake the agent
- `POST /hooks/agent` - Run isolated agent turn
- `POST /hooks/gmail` - Gmail push notifications

---

## 6. Hooks (Event-Driven Automation)

### Built-in Hooks
| Hook | Event | Purpose |
|------|-------|---------|
| `session-memory` | `command:new` | Save session to memory files |
| `command-logger` | `command` | Audit log of all commands |
| `boot-md` | `gateway:startup` | Run BOOT.md on gateway start |
| `soul-evil` | `agent:bootstrap` | Personality swapping (fun!) |

### Enable Hooks
```bash
clawdbot hooks list
clawdbot hooks enable session-memory
clawdbot hooks enable command-logger
```

### Custom Hooks
Create in `~/.clawdbot/hooks/my-hook/`:
- `HOOK.md` - Metadata
- `handler.ts` - Implementation

---

## 7. Text-to-Speech (TTS)

### Supported Providers
| Provider | Key Required | Quality | Cost |
|----------|--------------|---------|------|
| **ElevenLabs** | Yes | Excellent | Paid |
| **OpenAI** | Yes | Very Good | Paid |
| **Edge TTS** | No | Good | Free |

### Configuration

```json5
{
  messages: {
    tts: {
      auto: "always",           // off | always | inbound | tagged
      provider: "elevenlabs",   // elevenlabs | openai | edge
      elevenlabs: {
        voiceId: "voice_id",
        modelId: "eleven_v3"
      }
    }
  }
}
```

### Voice Commands
```
/tts always          # Always reply with audio
/tts inbound         # Reply with audio only when voice received
/tts audio Hello!    # One-off audio generation
```

---

## 8. Browser Control

Clawdbot manages its own Chrome/Chromium instance for web automation.

### Capabilities
- Page snapshots (DOM/ARIA)
- Click, type, scroll actions
- Screenshot capture
- Form filling
- File uploads
- Console access

### Configuration

```json5
{
  browser: {
    enabled: true,
    headless: true,
    controlToken: "SECRET"  // For remote control
  }
}
```

### CLI
```bash
clawdbot browser start
clawdbot browser stop
clawdbot browser status
clawdbot browser tabs
```

---

## 9. Security & Sandboxing

### DM Policies
| Policy | Behavior |
|--------|----------|
| `pairing` | Unknown senders get code, must be approved |
| `allowlist` | Only explicit allowlist can message |
| `open` | Anyone can message (requires `"*"` in allowlist) |
| `disabled` | No DMs accepted |

### Sandboxing

```json5
{
  agents: {
    defaults: {
      sandbox: {
        mode: "all",      // off | all | untrusted
        scope: "session", // session | agent | shared
        docker: {
          image: "node:22-slim",
          setupCommand: "apt-get update && apt-get install -y git"
        }
      }
    }
  }
}
```

### Tool Restrictions

```json5
{
  agents: {
    list: [{
      id: "restricted-agent",
      tools: {
        allow: ["read", "exec"],
        deny: ["write", "browser"]
      }
    }]
  }
}
```

### Security Audit
```bash
clawdbot security audit
clawdbot security audit --deep
clawdbot security audit --fix
```

---

## 10. Plugins System

### Plugin Types
- **Channel plugins** - Add new messaging platforms
- **Provider plugins** - Add auth methods
- **Tool plugins** - Add agent capabilities
- **Command plugins** - Add CLI/slash commands

### Official Plugins
| Plugin | Purpose |
|--------|---------|
| `@clawdbot/voice-call` | Phone call capabilities (Twilio) |
| `@clawdbot/msteams` | Microsoft Teams channel |
| `@clawdbot/matrix` | Matrix channel |
| `memory-lancedb` | Long-term memory with auto-recall |

### Plugin Management
```bash
clawdbot plugins list
clawdbot plugins install @clawdbot/voice-call
clawdbot plugins enable voice-call
clawdbot plugins disable untrusted-plugin
```

### Creating Plugins

```typescript
// clawdbot.plugin.json
{
  "id": "my-plugin",
  "configSchema": { ... },
  "skills": ["./skills/my-skill"]
}

// index.ts
export default function(api) {
  api.registerGatewayMethod("myplugin.status", ({respond}) => {
    respond(true, { ok: true });
  });
  
  api.registerTool("my_tool", {
    description: "Does something",
    parameters: { ... },
    execute: async (params, ctx) => { ... }
  });
}
```

---

## 11. Node System (Mobile/Desktop Companions)

### Node Capabilities
| Platform | Features |
|----------|----------|
| **macOS** | Menu bar app, Voice Wake, Canvas, Camera, Screen recording |
| **iOS** | Canvas, Voice Wake, Camera, Location |
| **Android** | Canvas, Camera, Screen recording, Optional SMS |

### Commands
```bash
clawdbot nodes list           # List paired nodes
clawdbot nodes camera snap    # Take photo from node camera
clawdbot nodes screen record  # Record node screen
clawdbot nodes location       # Get node location
```

---

## 12. Memory System

### Memory Plugin Slots
| Plugin | Purpose |
|--------|---------|
| `memory-core` | Basic memory search (default) |
| `memory-lancedb` | Long-term memory with auto-capture |

### Memory Search Tool
```bash
clawdbot memory search "what did we discuss about project X"
```

---

## 13. Workspace Structure

### Standard Layout
```
~/clawd/
├── AGENTS.md          # Agent instructions
├── SOUL.md            # Personality/identity
├── USER.md            # User preferences
├── TOOLS.md           # Tool-specific notes
├── HEARTBEAT.md       # Heartbeat checklist
├── MEMORY.md          # Long-term memory
├── memory/            # Daily notes (YYYY-MM-DD.md)
├── skills/            # Per-agent skills
├── hooks/             # Per-agent hooks
└── projects/          # Work directory
```

### Bootstrap Files (Injected to Agent)
1. `AGENTS.md` - Instructions (always)
2. `SOUL.md` - Identity (main sessions only)
3. `TOOLS.md` - Tool notes (always)
4. `USER.md` - User context (main sessions only)
5. `MEMORY.md` - Memory (main sessions only)
6. `HEARTBEAT.md` - Heartbeat (heartbeat runs only)
7. `IDENTITY.md` - Agent identity (if exists)

---

## 14. CLI Commands Reference

### Essential Commands
```bash
# Setup & Config
clawdbot onboard              # Full setup wizard
clawdbot configure            # Quick config
clawdbot doctor               # Health check + fixes
clawdbot config set <path>    # Set config value
clawdbot config get           # View config

# Gateway
clawdbot gateway              # Start gateway
clawdbot gateway --force      # Kill existing + start
clawdbot health               # Health check
clawdbot status               # Channel status
clawdbot dashboard            # Open Control UI

# Channels
clawdbot channels login       # Login to channels (QR code)
clawdbot channels logout      # Logout from channels
clawdbot channels status      # Channel health

# Agent
clawdbot agent --message "Hi" # Run agent turn
clawdbot sessions             # List sessions
clawdbot sessions --delete-all # Clear all sessions

# Tools
clawdbot cron list            # List cron jobs
clawdbot hooks list           # List hooks
clawdbot skills list          # List skills
clawdbot plugins list         # List plugins

# Security
clawdbot security audit       # Security check
clawdbot pairing list         # List pending pairings
clawdbot approvals            # Exec approval management
```

---

## 15. For Deploy Your Agent Business

### Standard Client Configuration

```json5
{
  // Basic setup
  gateway: {
    port: 18789,
    auth: { token: "${GATEWAY_TOKEN}" }
  },
  
  // Agent setup
  agents: {
    defaults: {
      workspace: "~/clawd",
      sandbox: { mode: "all", scope: "session" },
      heartbeat: { every: "30m" }
    }
  },
  
  // Channel setup (customize per client)
  channels: {
    whatsapp: {
      dmPolicy: "pairing",
      allowFrom: ["${CLIENT_PHONE}"]
    },
    telegram: {
      enabled: true
    }
  },
  
  // Security
  tools: {
    elevated: { enabled: false }
  }
}
```

### Deployment Checklist

- [ ] Install Clawdbot globally
- [ ] Run `clawdbot onboard`
- [ ] Configure channels (WhatsApp/Telegram)
- [ ] Set up workspace with persona files
- [ ] Install relevant skills
- [ ] Enable recommended hooks
- [ ] Configure heartbeat schedule
- [ ] Set up cron jobs for client workflows
- [ ] Enable sandboxing if needed
- [ ] Run security audit
- [ ] Test all integrations
- [ ] Document for client

### Features to Highlight to Clients

1. **Multi-channel presence** - WhatsApp, Telegram, Slack, etc.
2. **Scheduled automation** - Cron jobs, heartbeats
3. **Voice capabilities** - TTS replies, voice notes
4. **Browser automation** - Web research, form filling
5. **Secure execution** - Sandboxing, tool restrictions
6. **Proactive monitoring** - Heartbeat checks
7. **Multi-agent setup** - Different bots for different purposes
8. **Webhook integration** - Connect external systems

### Pricing Considerations

| Feature | Complexity | Suggested Tier |
|---------|------------|----------------|
| Single channel + basic skills | Low | Basic |
| Multi-channel + custom skills | Medium | Pro |
| Multi-agent + webhooks + voice | High | Enterprise |
| Full customization + support | Very High | Custom |

### What to Document for Henry's Dashboard

1. **Channel status** - Which channels connected
2. **Agent status** - Which agents configured
3. **Cron jobs** - Scheduled tasks
4. **Heartbeat config** - Proactive checks
5. **Skills installed** - Active capabilities
6. **Security settings** - DM policies, sandboxing
7. **Usage stats** - Token usage, model costs
8. **Gateway health** - Status, uptime

---

## 16. Configuration Reference Summary

### Essential Config Paths

| Path | Purpose |
|------|---------|
| `gateway.port` | Gateway port |
| `gateway.auth.token` | Auth token |
| `agents.defaults.workspace` | Default workspace |
| `agents.defaults.heartbeat.every` | Heartbeat interval |
| `agents.defaults.sandbox.mode` | Sandbox mode |
| `channels.whatsapp.dmPolicy` | WhatsApp DM policy |
| `channels.telegram.groups` | Telegram group settings |
| `messages.tts.auto` | TTS mode |
| `skills.entries.<name>.enabled` | Skill toggle |
| `plugins.entries.<id>.enabled` | Plugin toggle |
| `hooks.internal.entries.<name>.enabled` | Hook toggle |
| `cron.enabled` | Cron system toggle |

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `CLAWDBOT_CONFIG_PATH` | Custom config location |
| `CLAWDBOT_STATE_DIR` | Custom state directory |
| `CLAWDBOT_PROFILE` | Profile name |
| `CLAWDBOT_GATEWAY_PORT` | Gateway port |
| `CLAWDBOT_GATEWAY_TOKEN` | Gateway auth token |
| `ELEVENLABS_API_KEY` | TTS API key |
| `OPENAI_API_KEY` | OpenAI key |

---

## 17. Quick Reference - Most Useful Commands

```bash
# Day-to-day
clawdbot gateway              # Start gateway
clawdbot status               # Quick status check
clawdbot dashboard            # Open web UI
clawdbot logs -f              # Follow logs

# Troubleshooting
clawdbot doctor               # Diagnose issues
clawdbot doctor --fix         # Auto-fix issues
clawdbot security audit       # Security check
clawdbot channels login       # Re-authenticate

# Agent management
clawdbot sessions             # View sessions
clawdbot agent --message "X"  # Test agent
clawdbot cron list            # View scheduled tasks

# Configuration
clawdbot config get           # View full config
clawdbot config set X Y       # Set value
clawdbot gateway --reset      # Reset gateway state
```

---

## 18. Resources

- **Docs**: https://docs.clawd.bot
- **ClawdHub**: https://clawdhub.com
- **Discord**: https://discord.gg/clawd
- **GitHub**: https://github.com/clawdbot/clawdbot

---

## Summary

Clawdbot is an incredibly powerful platform for deploying AI agents. For Deploy Your Agent:

1. **Use it as our core platform** - It handles everything we need
2. **Create standard configs** - Template configs for different client types
3. **Build custom skills** - Client-specific capabilities via skills
4. **Document everything** - Create clear guides for Henry's dashboard
5. **Offer tiers** - Basic → Pro → Enterprise based on features used

The platform is production-ready and actively maintained. We should build on top of it rather than reinventing the wheel.
