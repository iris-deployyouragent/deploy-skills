# Deploy Skills

> **40 curated, battle-tested skills for AI agents** — ready to deploy to any business.

The official skill library for [Deploy Your Agent](https://deployyouragent.com) client installations.

## Skills Library (40)

### 🤖 AI Agent Core
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `self-improvement` | 9.4k | Learn from corrections, compound knowledge |
| `proactive-agent` | 2.2k | Anticipate needs, pre-compaction memory |
| `memory-setup` | 1.2k | Configure persistent memory |
| `compound-engineering` | 666 | Auto-learn from sessions |

### 📧 Email & Communication
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `gog` | 5.6k | Google Workspace (Gmail, Calendar, Drive) |
| `agentmail` | 708 | Dedicated email inboxes for AI agents |
| `email-management` | — | Read, send, organize emails |
| `morning-email-rollup` | 509 | Daily email + calendar summary |

### 📅 Productivity & Tasks
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `todoist` | 1.2k | Task management |
| `remind-me` | 3.3k | Natural language reminders |
| `apple-reminders` | 833 | macOS Reminders integration |
| `calendar` | — | Schedule meetings, manage events |
| `linear` | 556 | Project/issue tracking |
| `focus-deep-work` | 219 | Deep work sessions |

### 💼 CRM & Sales
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `hubspot` | 224 | HubSpot CRM integration |
| `crm` | — | Lead and deal management |
| `linkedin-monitor` | 109 | LinkedIn inbox monitoring |
| `linkedin-inbox` | 77 | LinkedIn message management |

### 💳 E-commerce & Payments
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `stripe` | 120 | Payment processing |
| `shopping-expert` | 209 | Product search and comparison |
| `pinch-to-post` | 171 | WordPress/WooCommerce automation |
| `invoice-generator` | 135 | Generate PDF invoices |
| `invoicing` | — | Track payments |
| `inventory` | — | Stock level management |

### 📄 Documents & Content
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `summarize` | 4k | Summarize URLs, PDFs, videos |
| `excel` | 1k | Read/write Excel files |
| `pptx-creator` | 341 | Create PowerPoint presentations |
| `ai-pdf-builder` | 283 | Generate professional PDFs |
| `document-management` | — | Organize and share files |
| `de-ai-ify` | 214 | Remove AI jargon from text |

### 📱 Social Media
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `twitter` | 477 | Post tweets, manage engagement |
| `instagram` | 357 | Post content, view insights |
| `marketing-mode` | 1.8k | 23 marketing skills in one |

### 📊 Analytics & Research
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `ga4-analytics` | 235 | Google Analytics 4 reporting |
| `daily-review` | 242 | Performance tracking |
| `deep-research` | 1.6k | Multi-source research agent |
| `youtube-watcher` | 2.1k | Video transcript extraction |

### 🔧 Operations & Automation
| Skill | Downloads | Description |
|-------|-----------|-------------|
| `n8n` | 573 | Workflow automation |
| `customer-service` | — | Handle support tickets |
| `event-planner` | 122 | Schedule events, book venues |

## Installation

```bash
# Clone the repo
git clone https://github.com/iris-deployyouragent/deploy-skills.git

# Use the installer for client setups
./installer/deploy-install.sh
```

## Structure

```
deploy-skills/
├── skills/           # 40 curated skills
│   ├── gog/
│   ├── stripe/
│   ├── hubspot/
│   └── ...
├── installer/        # Client installation scripts
├── registry/         # Skill definitions & versions
└── email-assistant/  # Email PA module
```

## For Deploy Clients

Each skill includes:
- `SKILL.md` — Instructions for the AI agent
- `scripts/` — Helper scripts (where applicable)
- `references/` — API docs and examples

Skills are designed to work with [Clawdbot](https://clawdbot.com) and compatible AI agent frameworks.

---

**Maintained by [Deploy Your Agent](https://deployyouragent.com)**
