---
name: browseros-mcporter
description: Use BrowserOS MCP tools from inside Clawdbot by calling the browseros MCP server via the mcporter CLI. Auto-launches BrowserOS MCP server if not already running. Use for BrowserOS automation tasks (browser_get_active_tab, browser_navigate, browser_get_interactive_elements, browser_click_element, browser_type_text, screenshots, page content extraction) when you want deterministic terminal-driven automation.
---

# browseros-mcporter

This skill is a thin wrapper around **mcporter** to call the local **browseros** MCP server.

## Features
- **Auto-launch**: Automatically starts BrowserOS MCP server if not already running
- **Health checks**: Verifies BrowserOS server is ready before making calls
- **Timeout handling**: Waits up to 30 seconds for BrowserOS to initialize

## Setup

1. Configure the BrowserOS launch command in `scripts/ensure_browseros.sh`:
   ```bash
   export BROWSEROS_CMD="npx @browseros/mcp-server"  # or your launch command
   ```

2. Ensure `mcporter list` shows a server named `browseros`

## Quick Example: Navigate to X.com

```bash
# This will auto-start BrowserOS if needed, then navigate to x.com
~/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_navigate '{"url":"https://x.com"}'
```

## Quick checks

```bash
mcporter list
mcporter list browseros --schema | head
```

## How to call a tool

Preferred: use the helper script so quoting is consistent.

```bash
/home/dadmin/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_get_active_tab '{}'
/home/dadmin/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_navigate '{"url":"https://x.com"}'
```

### Common patterns

Get active tab:
```bash
browseros_call.sh browser_get_active_tab '{}'
```

Navigate:
```bash
browseros_call.sh browser_navigate '{"url":"https://example.com"}'
```

List interactive elements (then grep locally):
```bash
browseros_call.sh browser_get_interactive_elements '{"tabId": <TAB_ID>}'
```

Click / type:
```bash
browseros_call.sh browser_click_element '{"tabId": <TAB_ID>, "nodeId": <NODE_ID>}'
browseros_call.sh browser_type_text '{"tabId": <TAB_ID>, "nodeId": <NODE_ID>, "text": "hello"}'
```

## Standalone Usage
This skill operates independently. It wraps BrowserOS's MCP server into callable scripts — no other skills required.

## Notes
- To discover exact tool names + arg schemas: `mcporter list browseros --schema`.
- If BrowserOS becomes unresponsive, restart it: `./scripts/ensure_browseros.sh`
