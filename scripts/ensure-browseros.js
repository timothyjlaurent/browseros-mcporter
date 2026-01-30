#!/usr/bin/env node
/**
 * Cross-platform BrowserOS launcher
 * Ensures BrowserOS is running, auto-launches if needed
 */

const { spawn, exec } = require('child_process');
const net = require('net');
const os = require('os');
const path = require('path');
const fs = require('fs');

const BROWSEROS_HEALTH_PORT = 9100;
const BROWSEROS_HEALTH_URL = `http://127.0.0.1:${BROWSEROS_HEALTH_PORT}/health`;
const LAUNCH_TIMEOUT = 30000; // 30 seconds

// Platform-specific BrowserOS executables
function getBrowserOSCommand() {
  // Allow override via env var
  if (process.env.BROWSEROS_CMD) {
    return process.env.BROWSEROS_CMD;
  }

  const platform = process.platform;
  const homeDir = os.homedir();
  
  switch (platform) {
    case 'linux':
      return path.join(homeDir, 'AppImages', 'browseros.appimage');
    case 'darwin':
      return '/Applications/BrowserOS.app/Contents/MacOS/BrowserOS';
    case 'win32':
      return path.join(process.env.LOCALAPPDATA || '', 'BrowserOS', 'BrowserOS.exe');
    default:
      throw new Error(`Unsupported platform: ${platform}`);
  }
}

// Check if BrowserOS health endpoint is responding
function checkBrowserOS() {
  return new Promise((resolve) => {
    const req = net.connect(BROWSEROS_HEALTH_PORT, '127.0.0.1', () => {
      req.write('GET /health HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n');
    });

    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
    });

    req.on('end', () => {
      resolve(data.includes('"status":"ok"'));
    });

    req.on('error', () => {
      resolve(false);
    });

    req.setTimeout(2000, () => {
      req.destroy();
      resolve(false);
    });
  });
}

// Check if BrowserOS process is running
function checkBrowserOSProcess() {
  return new Promise((resolve) => {
    const platform = process.platform;
    let cmd;

    if (platform === 'win32') {
      cmd = 'tasklist /FI "IMAGENAME eq BrowserOS.exe"';
    } else {
      cmd = 'pgrep -f "browseros"';
    }

    exec(cmd, (error, stdout) => {
      if (platform === 'win32') {
        resolve(stdout.includes('BrowserOS.exe'));
      } else {
        resolve(!error && stdout.trim().length > 0);
      }
    });
  });
}

// Launch BrowserOS
function launchBrowserOS() {
  return new Promise((resolve, reject) => {
    const cmd = getBrowserOSCommand();
    
    if (!fs.existsSync(cmd)) {
      reject(new Error(`BrowserOS not found at: ${cmd}\nSet BROWSEROS_CMD env var to override`));
      return;
    }

    console.error('BrowserOS not running. Launching...');

    const logFile = path.join(os.tmpdir(), 'browseros.log');
    const out = fs.openSync(logFile, 'a');
    const err = fs.openSync(logFile, 'a');

    const child = spawn(cmd, [], {
      detached: true,
      stdio: ['ignore', out, err],
      env: {
        ...process.env,
        DESKTOPINTEGRATION: '1'
      }
    });

    child.unref();

    // Wait for BrowserOS to be ready
    const startTime = Date.now();
    const checkInterval = setInterval(async () => {
      const isReady = await checkBrowserOS();
      
      if (isReady) {
        clearInterval(checkInterval);
        console.error('BrowserOS is ready!');
        resolve();
      } else if (Date.now() - startTime > LAUNCH_TIMEOUT) {
        clearInterval(checkInterval);
        reject(new Error(`Timeout waiting for BrowserOS. Check log: ${logFile}`));
      } else {
        const waited = Math.floor((Date.now() - startTime) / 1000);
        console.error(`Waiting for BrowserOS... (${waited}/${LAUNCH_TIMEOUT/1000})`);
      }
    }, 1000);
  });
}

// Main
async function main() {
  try {
    // Check if already running
    if (await checkBrowserOS()) {
      console.log('BrowserOS is running');
      process.exit(0);
    }

    // Check if process exists but not responding
    if (await checkBrowserOSProcess()) {
      console.error('BrowserOS process found but health check failed.');
      console.error('Restart to fix.');
      process.exit(1);
    }

    // Launch BrowserOS
    await launchBrowserOS();
    process.exit(0);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

main();
