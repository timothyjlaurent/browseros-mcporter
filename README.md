# browseros-mcporter

MCP (Model Context Protocol) wrapper for BrowserOS. Enables deterministic terminal-driven browser automation via `mcporter`.

## What This Does

BrowserOS exposes two interfaces:
- **CDP** (Chrome DevTools Protocol) on dynamic port — raw browser control
- **MCP** (Model Context Protocol) on port 9100 — structured tool interface

This skill wraps the **MCP interface** into callable scripts for Clawdbot/moltbot.

## Why MCP?

MCP provides:
- **Schema discovery**: `mcporter list browseros --schema` shows all available tools
- **Type validation**: Parameters are validated against the schema
- **Self-documenting**: Tool names and args describe themselves
- **Auto-launch**: BrowserOS starts automatically when called

Compare to raw CDP:
- CDP: `Storage.getCookies` with JSON-RPC framing
- MCP: `browser_get_active_tab` with clear args

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/browseros-mcporter.git
```

## Dependencies

- [BrowserOS](https://browseros.com) installed
- `mcporter` CLI: `npm install -g mcporter`

## Setup

Configure the BrowserOS launch command in `scripts/ensure_browseros.sh`:

```bash
export BROWSEROS_CMD="env DESKTOPINTEGRATION=1 /path/to/browseros.appimage %U"
```

## Usage

### Direct Tool Calls

```bash
# Navigate to a URL
./scripts/browseros_call.sh browser_navigate '{"url":"https://x.com"}'

# Get active tab info
./scripts/browseros_call.sh browser_get_active_tab '{}'

# List interactive elements on page
./scripts/browseros_call.sh browser_get_interactive_elements '{"tabId": 123}'

# Click an element
./scripts/browseros_call.sh browser_click_element '{"tabId": 123, "nodeId": 456}'

# Type text
./scripts/browseros_call.sh browser_type_text '{"tabId": 123, "nodeId": 456, "text": "hello"}'
```

### Ensure BrowserOS is Running

```bash
./scripts/ensure_browseros.sh
```

Auto-launches BrowserOS if not running, with health checks.

### Discover Available Tools

```bash
# List all tools
mcporter list browseros --schema

# List with filtering
mcporter list browseros --schema | grep "function"
```

## Available Tools

Common BrowserOS MCP tools:

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Navigate to URL |
| `browser_get_active_tab` | Get current tab info |
| `browser_list_tabs` | List all tabs |
| `browser_open_tab` | Open new tab |
| `browser_close_tab` | Close specific tab |
| `browser_get_interactive_elements` | List clickable elements |
| `browser_click_element` | Click by nodeId |
| `browser_type_text` | Type into input |
| `browser_get_screenshot` | Capture screenshot |
| `browser_get_page_content` | Extract page text |
| `browser_execute_javascript` | Run JS in page |
| `list_network_requests` | Monitor network |

## Architecture

```
Clawdbot/moltbot
    ↓
browseros_call.sh
    ↓
ensure_browseros.sh (auto-launch if needed)
    ↓
mcporter call browseros.<tool>
    ↓
BrowserOS MCP server (port 9100)
    ↓
BrowserOS Chromium
```

## Comparison: MCP vs CDP

| | MCP (this skill) | CDP (direct) |
|---|---|---|
| **Interface** | Named tools with schemas | Raw DevTools protocol |
| **Discovery** | `mcporter list --schema` | Read Chrome DevTools docs |
| **Calling** | `browser_navigate {...}` | JSON-RPC over WebSocket |
| **Use case** | Navigation, clicking, screenshots | Cookie extraction, network interception |
| **Port** | 9100 (MCP server) | Dynamic (DevTools) |

**Use both:** MCP for structured tasks, CDP for escape-hatch power.

## Troubleshooting

**"BrowserOS not available"**
```bash
# Check if BrowserOS is running
curl http://127.0.0.1:9100/health

# Manually launch
./scripts/ensure_browseros.sh
```

**"mcporter: command not found"**
```bash
npm install -g mcporter
```

**Tool not working**
- Check schema: `mcporter list browseros --schema | grep <toolName>`
- Verify args match schema exactly
- Check BrowserOS tab is active and loaded

## Related

- [BrowserOS](https://browseros.com) — The browser automation platform
- [MCP](https://modelcontextprotocol.io) — Model Context Protocol specification
- [mcporter](https://github.com/clawdbot/mcporter) — MCP client CLI

## License

MIT
