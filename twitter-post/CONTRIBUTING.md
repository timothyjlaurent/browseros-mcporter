# Contributing to twitter-post

We need your help. This skill works... sometimes. Let's make it work *reliably*.

## Quick Start for Contributors

```bash
# Clone and setup
cd ~/clawd/skills/twitter-post
npm install  # if we add deps later

# Test your changes
./scripts/post.sh --file examples/test.txt --dry-run
```

## Development Philosophy

**Be honest about failures.** If X changes their DOM and the skill breaks, document it.

**Prefer retries over perfection.** X is flaky. Handle it.

**Screenshots are debugging gold.** Always capture on failure.

## Current Pain Points (Priority Order)

### 1. Element Detection (HIGH)
X changes class names constantly. We need:
- Multiple fallback selectors
- ARIA attribute detection
- Visual verification (screenshot + confirm)

### 2. Thread Posting (HIGH)
Currently fails after ~3 tweets. Needs:
- Better "Add post" button detection
- Wait-for-element logic
- Graceful degradation (post what we can)

### 3. Rate Limiting (MEDIUM)
X has strict limits. We need:
- Pre-flight check
- Backoff strategy
- Clear error messages

### 4. Auth Handling (MEDIUM)
If session expires mid-post:
- Detect it
- Pause (don't fail silently)
- Allow re-auth

## Submitting Changes

**Local improvements:** Just commit to your `~/clawd` and push.

**PRs:** 
1. Fork the repo
2. Branch: `fix/element-detection` or `feature/retry-logic`
3. Include: what you fixed, how you tested it
4. Screenshots of success/failure help

## Code of Conduct

Be kind. X's frontend engineers are doing their best. We're all just trying to automate tweets. 🤷

---

**Questions?** Open an issue. Even if it's "this didn't work and I don't know why." That's useful data.
