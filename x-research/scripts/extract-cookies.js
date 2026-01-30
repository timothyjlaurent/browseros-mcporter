#!/usr/bin/env node
/**
 * Extract X/Twitter cookies from BrowserOS via CDP
 * Outputs AUTH_TOKEN and CT0 for bird CLI
 */

const { chromium } = require('playwright');
const { execSync } = require('child_process');

async function findBrowserOSPort() {
  try {
    // Try to find BrowserOS CDP port (skip 9100 and 10864 which are MCP servers)
    const cmd = "ss -tlnp | grep browseros | grep -v '9100\\|10864' | head -1 | awk '{print $4}' | cut -d: -f2";
    const port = execSync(cmd, { encoding: 'utf8' }).trim();
    if (port) return port;
  } catch (e) {
    // Fallback to netstat
    try {
      const cmd = "netstat -tlnp 2>/dev/null | grep browseros | grep -v '9100\\|10864' | head -1 | awk '{print $4}' | cut -d: -f2";
      const port = execSync(cmd, { encoding: 'utf8' }).trim();
      if (port) return port;
    } catch (e2) {
      // Ignore
    }
  }
  return null;
}

async function extractCookies() {
  // Check for env var override
  let port = process.env.BROWSEROS_PORT;
  
  if (!port) {
    port = await findBrowserOSPort();
  }
  
  if (!port) {
    console.error('Error: Could not find BrowserOS CDP port');
    console.error('Make sure BrowserOS is running:');
    console.error('  ~/clawd/skills/browseros-mcporter/scripts/ensure_browseros.sh');
    console.error('Or set BROWSEROS_PORT env var');
    process.exit(1);
  }
  
  const cdpUrl = `http://127.0.0.1:${port}`;
  
  try {
    const browser = await chromium.connectOverCDP(cdpUrl);
    const context = browser.contexts()[0];
    
    // Get cookies for x.com
    const cookies = await context.cookies('https://x.com');
    
    const authToken = cookies.find(c => c.name === 'auth_token');
    const ct0 = cookies.find(c => c.name === 'ct0');
    
    if (!authToken || !ct0) {
      console.error('Error: X cookies not found');
      console.error('Make sure you are logged into x.com in BrowserOS');
      console.error('Available cookies:', cookies.map(c => c.name).join(', '));
      await browser.close();
      process.exit(1);
    }
    
    console.log(`AUTH_TOKEN=${authToken.value}`);
    console.log(`CT0=${ct0.value}`);
    
    await browser.close();
  } catch (err) {
    console.error('Error connecting to BrowserOS:', err.message);
    console.error('CDP URL:', cdpUrl);
    process.exit(1);
  }
}

extractCookies();
