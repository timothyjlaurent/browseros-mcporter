# X Research Skill

Automated X/Twitter research via BrowserOS CDP and bird CLI. Extracts authentication tokens programmatically and performs searches, timeline retrieval, and more.

## Why This Exists

The Clawdbot browser extension requires clicking an icon every session to attach tabs. This skill eliminates that by using BrowserOS's native CDP (Chrome DevTools Protocol) and MCP (Model Context Protocol) exposure.

**Key insight:** BrowserOS exposes CDP on a dynamic port, allowing programmatic extraction of HttpOnly cookies (like X's `auth_token`) that JavaScript can't access.

## Prerequisites

- [BrowserOS](https://browseros.com) installed and running
- Logged into X.com in BrowserOS
- Node.js and npm
- `bird` CLI: `npm install -g @steipete/bird`

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/x-research.git
cd x-research
npm install
```

## Usage

### Single Search

```bash
./scripts/x-search.sh "AI genomics" --limit 10
```

### Your Timeline

```bash
./scripts/x-timeline.sh --limit 20
```

### Mentions

```bash
./scripts/x-mentions.sh --limit 10
```

### Bookmarks

```bash
./scripts/x-bookmarks.sh --limit 20
```

### Deep Research (Multi-Query)

```bash
./scripts/x-research.sh "GeneDx competitors" --queries 3 --limit 15
```

## How It Works

### Architecture

```
x-research skill
├── CDP Layer (extract-cookies.js)
│   └── Playwright → BrowserOS CDP → HttpOnly cookies
├── MCP Layer (via browseros-mcporter)
│   └── mcporter → BrowserOS MCP → browser automation
└── bird CLI
    └── X API queries with extracted auth
```

### The Auth Flow

1. **Find BrowserOS CDP port:** Auto-detected via `ss -tlnp` (skips MCP ports 9100/10864)
2. **Connect via Playwright:** `chromium.connectOverCDP('http://127.0.0.1:PORT')`
3. **Extract cookies:** `context.cookies('https://x.com')` gets `auth_token` + `ct0`
4. **Export to bird:** Environment variables set, `bird` CLI runs authenticated

### Why CDP + MCP?

| Protocol | Use Case | BrowserOS Exposure |
|----------|----------|-------------------|
| **CDP** | Cookie extraction, network interception, deep control | Dynamic port (e.g., 33181) |
| **MCP** | Navigation, clicking, form filling, screenshots | Port 9100 |

CDP is the escape hatch for what MCP can't touch (HttpOnly cookies). MCP is the productivity layer for structured automation.

## Scripts

| Script | Purpose |
|--------|---------|
| `extract-cookies.js` | CDP-based cookie extraction from BrowserOS |
| `x-search.sh` | Search X with auto-auth |
| `x-timeline.sh` | Your home timeline |
| `x-mentions.sh` | Your mentions |
| `x-bookmarks.sh` | Your bookmarks |
| `x-research.sh` | Multi-query research with aggregation |
| `setup.sh` | Install dependencies |

## Troubleshooting

**"BrowserOS not found"**
```bash
~/clawd/skills/browseros-mcporter/scripts/ensure_browseros.sh
```

**"Not authenticated"**
- Verify login: Tab URL should be `x.com/home`
- Re-run: `node scripts/extract-cookies.js`

**"CDP port not found"**
```bash
ss -tlnp | grep browseros  # Find the CDP port (not 9100/10864)
BROWSEROS_PORT=33181 ./scripts/x-search.sh "query"
```

## Comparison: Browser Extension vs BrowserOS

| | Clawdbot Extension | BrowserOS |
|---|---|---|
| **Setup** | Install extension, click per session | Run app, protocols exposed natively |
| **CDP Access** | Port 18792 (flaky) | Dynamic port, always available |
| **MCP** | ❌ | ✅ Port 9100 |
| **HttpOnly Cookies** | ✅ (when connected) | ✅ (reliable) |
| **Scheduling** | ❌ (requires click) | ✅ (fully programmatic) |
| **Headless** | ❌ | ✅ |

## Dependencies

- `playwright` — CDP connection
- `bird` — X CLI (`npm install -g @steipete/bird`)
- `mcporter` — MCP client (for related BrowserOS workflows)

## License

MIT

## Related

- [browseros-mcporter](https://github.com/YOUR_USERNAME/browseros-mcporter) — MCP wrapper for BrowserOS
- [bird](https://github.com/steipete/bird) — X/Twitter CLI
- [BrowserOS](https://browseros.com) — Browser automation infrastructure
