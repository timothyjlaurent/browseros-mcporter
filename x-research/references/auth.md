# X/Twitter Authentication via BrowserOS CDP

## Overview

`bird` requires two cookies for authentication:
- `auth_token` (HttpOnly — not accessible via JavaScript)
- `ct0` (accessible via JavaScript)

On Linux, Chrome encrypts cookies using the system keyring, making direct SQLite extraction impossible. The solution is **Chrome DevTools Protocol (CDP)**.

BrowserOS exposes CDP natively, allowing full cookie access including HttpOnly tokens.

## How It Works

BrowserOS runs Chromium with remote debugging enabled on a dynamic port. Playwright connects via CDP and can read all cookies (including HttpOnly) because CDP runs inside the browser with DevTools privileges.

```
┌─────────────┐      CDP      ┌──────────────┐
│  Playwright │  ◄─────────►  │  BrowserOS   │
│  (Node.js)  │   HTTP/WS     │  Chromium    │
└─────────────┘               └──────────────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │  x.com       │
                              │  (logged in) │
                              └──────────────┘
```

## Finding the CDP Port

BrowserOS CDP port is dynamic. Find it with:

```bash
# Method 1: ss (preferred)
ss -tlnp | grep browseros

# Method 2: netstat
netstat -tlnp | grep browseros

# Method 3: One-liner
PORT=$(ss -tlnp | grep browseros | grep -v '9100\|10864' | head -1 | awk '{print $4}' | cut -d: -f2)
echo "BrowserOS CDP port: $PORT"
```

**Skip ports 9100 and 10864** — those are BrowserOS MCP server ports, not CDP.

Expected output:
```
LISTEN 127.0.0.1:33181 ... browseros   ← CDP port (use this)
LISTEN 0.0.0.0:9100    ... browseros_server  ← MCP (ignore)
LISTEN 127.0.0.1:10864 ... browseros_server  ← MCP (ignore)
```

## Manual Cookie Extraction

### 1. Ensure BrowserOS is Running

```bash
~/clawd/skills/browseros-mcporter/scripts/ensure_browseros.sh
```

### 2. Navigate to X.com and Login

```bash
~/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_navigate '{"url":"https://x.com"}'
```

Verify login:
```bash
~/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_get_active_tab '{}'
# Should show: "URL": "https://x.com/home"
```

### 3. Extract Cookies via CDP

```javascript
const { chromium } = require('playwright');

(async () => {
  // Use the port you found
  const browser = await chromium.connectOverCDP('http://127.0.0.1:33181');
  const context = browser.contexts()[0];
  
  // Get all cookies for x.com (includes HttpOnly)
  const cookies = await context.cookies('https://x.com');
  
  const authToken = cookies.find(c => c.name === 'auth_token');
  const ct0 = cookies.find(c => c.name === 'ct0');
  
  console.log('AUTH_TOKEN=' + authToken.value);
  console.log('CT0=' + ct0.value);
  
  await browser.close();
})();
```

### 4. Configure Bird

```bash
export AUTH_TOKEN="a35073dd7bd8f2c03b8cac630f6148dfaa61512a"
export CT0="3da3aab847d94802cf1706fdbd7438a2a3eba1c675ba0c465761bebdfc8113dccdca48168b4597d02be298f254dfe76b22f5b470df5fc76bb81bc8f2265b826c9690e83cb3c531c9e4f5795f53f3ed96"
bird whoami
```

## Troubleshooting

### "Not logged in" Error

Check the active tab URL:
```bash
~/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_get_active_tab '{}'
```

- **Good**: `"url": "https://x.com/home"`
- **Bad**: `"url": "https://x.com/login"` → Log in via BrowserOS UI

### "CDP port not found"

1. Check BrowserOS is running:
   ```bash
   pgrep -f browseros
   ```

2. List all listening ports:
   ```bash
   ss -tlnp | grep -E "(browseros|chrome)"
   ```

3. Try restarting BrowserOS:
   ```bash
   pkill -f browseros
   ~/clawd/skills/browseros-mcporter/scripts/ensure_browseros.sh
   ```

### "auth_token cookie not found"

Cookies may have expired. Re-log into X.com in BrowserOS:
```bash
~/clawd/skills/browseros-mcporter/scripts/browseros_call.sh browser_navigate '{"url":"https://x.com/logout"}'
# Then log back in via BrowserOS UI
```

## Security Considerations

- **AUTH_TOKEN provides full X account access** — store securely
- Never commit tokens to git
- Don't share screenshots with tokens visible
- If compromised, revoke sessions at x.com/settings/sessions
- Tokens expire periodically — re-extraction is normal

## Alternative: Chrome Extension (Deprecated)

If BrowserOS is unavailable, the Clawdbot Browser Relay extension can be used, but it's less reliable:

1. Open X.com in Chrome
2. Click Clawdbot Browser Relay extension (badge turns ON)
3. CDP available at `http://127.0.0.1:18792`
4. Same extraction process as BrowserOS

**Issues**: Extension detaches randomly, requires re-attachment per session, interferes with normal Chrome usage.
