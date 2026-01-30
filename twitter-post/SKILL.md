# twitter-post

Post tweets and threads to X/Twitter using browser automation via browseros-mcporter.

## What We Learned (The Hard Way)

This skill exists because posting to X via browser automation is *harder than it looks*.

### Failure Modes We Hit

1. **"Click extension icon" rituals** — @openclaw requires manual intervention every session
2. **Element detection flakiness** — X's DOM changes, ARIA labels shift, timing issues
3. **BrowserOS connection drops** — MCP server needs health checks and retries
4. **Subagent chaos** — spawning tasks that run independently, can't truly "cancel"

### The Solution Stack

```
twitter-post (this skill)
    ↓ calls
browseros-mcporter (MCP bridge)
    ↓ calls
@browseros MCP server (AI-native browser)
    ↓ automates
X/Twitter web app
```

## Installation

1. Install browseros-mcporter skill first:
   ```bash
   clawdhub install browseros-mcporter
   ```

2. Install this skill:
   ```bash
   clawdhub install twitter-post
   ```

3. Ensure you're logged into X in BrowserOS

## Usage

```bash
# Post single tweet
twitter-post --file tweet.txt

# Post thread
twitter-post --file thread.json --format thread

# Dry run (validate only)
twitter-post --file tweet.txt --dry-run

# With retries
twitter-post --file tweet.txt --retries 3
```

## Help Wanted / Contributing

This skill needs work. Seriously.

### Known Issues
- [ ] Retry logic is basic (no exponential backoff)
- [ ] Element detection uses fragile selectors
- [ ] No handling for X's rate limits
- [ ] Thread posting often fails after 3rd tweet
- [ ] No screenshot-on-failure for debugging

### How to Contribute

**Local improvements:** Edit in `~/clawd/skills/twitter-post/`, test, commit.

**PRs welcome:** Fork, fix, submit. See CONTRIBUTING.md.

**Priority areas:**
1. Robust element detection (use ARIA, not nth-child)
2. Better error handling with screenshots
3. Rate limit awareness
4. Thread posting reliability

## License

MIT — share your fixes back!
