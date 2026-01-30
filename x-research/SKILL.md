---
name: x-research
description: X/Twitter research automation via BrowserOS CDP and bird CLI. Use when researching topics on X/Twitter, searching tweets, analyzing trends, or extracting social data. Automatically handles BrowserOS cookie extraction for authentication. Supports search, timeline, mentions, bookmarks, and aggregated research reports.
---

# X Research

Automated X/Twitter research via BrowserOS CDP and bird CLI.

## Quick Start

### 1. Install Dependencies

```bash
cd /path/to/x-research
./scripts/setup.sh
```

Or manually:
```bash
npm install  # Installs playwright
```

### 2. Run Searches

```bash
# Single search
./scripts/x-search.sh "AI genomics" --limit 10

# Multi-query research
./scripts/x-research.sh "GeneDx competitors" --queries 3 --limit 15

# Your timeline
./scripts/x-timeline.sh --limit 20
```

## Authentication

This skill automatically extracts cookies from BrowserOS. Prerequisites:

1. BrowserOS running with X.com logged in
2. Playwright installed: `npm install playwright`

The scripts auto-detect BrowserOS CDP port and extract `auth_token` + `ct0` cookies.

See [references/auth.md](references/auth.md) for manual extraction details.

## Scripts

### x-search.sh
Search X/Twitter with automatic auth.

```bash
./scripts/x-search.sh "query" [--limit N] [--freshness pd|pw|pm]
```

Examples:
```bash
./scripts/x-search.sh "rare disease AI" --limit 20
./scripts/x-search.sh "genomics" --limit 50 --freshness pw  # past week
```

### x-research.sh
Deep research with multiple queries and aggregation.

```bash
./scripts/x-research.sh "topic" [--queries N] [--limit N]
```

Spawns sub-agents to run related searches, then aggregates results into a markdown report.

### x-timeline.sh
Your home timeline.

```bash
./scripts/x-timeline.sh [--limit N]
```

### x-mentions.sh
Your mentions.

```bash
./scripts/x-mentions.sh [--limit N]
```

### x-bookmarks.sh
Your bookmarks.

```bash
./scripts/x-bookmarks.sh [--limit N] [--folder-id ID]
```

## Posting to X/Twitter

### Initial Setup (One-time)

**Option 1: Automatic (Recommended)**

```bash
# Login to https://x.com in Chrome/Safari/Firefox, then:
./scripts/bird-cookie-setup.sh
```

**Option 2: Quick Test**

```bash
# If you're already logged into x.com, just test:
bird check
# bird will auto-extract cookies from your browser
```

### Post a Thread

```bash
# Single tweet
bird tweet "Your message here"

# Thread from markdown file
./scripts/post-thread.sh /path/to/thread.md
```

**Thread format:** Separate tweets with `---` on its own line:

```markdown
First tweet here...

---

Second tweet here...

---

Third tweet...
```

Example:
```bash
./scripts/post-thread.sh /tmp/tweet_ai_native.txt
```

## Advanced Usage

### Custom Cookie Extraction

If auto-extraction fails, manually extract and export:

```bash
node scripts/extract-cookies.js
export AUTH_TOKEN="..."
export CT0="..."
bird search "query"
```

### Raw Bird Access

With cookies exported, use bird directly:

```bash
bird search "query" -n 10
bird user-tweets @handle -n 20
bird news -n 10
```

## Troubleshooting

**"BrowserOS not found"**
- Start BrowserOS: `~/clawd/skills/browseros-mcporter/scripts/ensure_browseros.sh`
- Log into X.com in BrowserOS

**"Not authenticated"**
- Check login: Tab URL should be `x.com/home` not `x.com/login`
- Re-run extraction: `node scripts/extract-cookies.js`

**"CDP port not found"**
- BrowserOS may use different port. Check: `ss -tlnp | grep browseros`
- Update script or specify: `BROWSEROS_PORT=33181 ./scripts/x-search.sh ...`

## Dependencies

- `bird` CLI (npm: `@steipete/bird`)
- `playwright` (npm)
- `jq` (optional, for JSON formatting)
- BrowserOS running with X.com session
