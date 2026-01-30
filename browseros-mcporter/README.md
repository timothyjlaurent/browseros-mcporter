# ⚠️ DEPRECATED

This repository is deprecated. Development has moved to the [agent-skills monorepo](https://github.com/timothyjlaurent/agent-skills).

**Please use:** [github.com/timothyjlaurent/agent-skills/tree/master/browseros-mcporter](https://github.com/timothyjlaurent/agent-skills/tree/master/browseros-mcporter)

This standalone repo will no longer receive updates.

---

# browseros-mcporter

MCP (Model Context Protocol) wrapper for BrowserOS. Enables deterministic terminal-driven browser automation via `mcporter`.

## What This Does

BrowserOS exposes two interfaces:
- **CDP** (Chrome DevTools Protocol) on dynamic port — raw browser control
- **MCP** (Model Context Protocol) on port 9100 — structured tool interface

This skill wraps the **MCP interface** into callable scripts for Clawdbot/moltbot.

This skill wraps the **MCP interface** into callable scripts for Clawdbot/moltbot.
