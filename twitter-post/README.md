# twitter-post

Post tweets and threads to X/Twitter using browser automation.

## Prerequisites

1. **browseros-mcporter** skill installed
2. BrowserOS MCP server running (or auto-launch enabled)
3. Logged into X/Twitter in BrowserOS

## Quick Start

```bash
# Post a single tweet
twitter-post --file my-tweet.txt

# Dry run first (validate without posting)
twitter-post --file my-tweet.txt --dry-run

# Post with retries
twitter-post --file my-tweet.txt --retries 5

# Post a thread
twitter-post --file thread.json --format thread
```

## How It Works

```
twitter-post
    ↓
browseros-mcporter (MCP bridge)
    ↓
BrowserOS MCP server
    ↓
X/Twitter web app
```

## Known Issues

This is v0.1. It breaks sometimes. See [CONTRIBUTING.md](CONTRIBUTING.md) for what needs fixing.

## Contributing

PRs welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
