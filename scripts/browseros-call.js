#!/usr/bin/env node
/**
 * Cross-platform BrowserOS MCP tool caller
 * Usage: node browseros-call.js <toolName> '<jsonArgs>'
 * Example: node browseros-call.js browser_navigate '{"url":"https://x.com"}'
 */

const { spawn } = require('child_process');
const path = require('path');

const SCRIPT_DIR = path.dirname(__filename);
const ENSURE_SCRIPT = path.join(SCRIPT_DIR, 'ensure-browseros.js');

async function ensureBrowserOS() {
  return new Promise((resolve, reject) => {
    const child = spawn('node', [ENSURE_SCRIPT], {
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let stderr = '';
    child.stderr.on('data', (data) => {
      stderr += data.toString();
      // Suppress stderr output unless error
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(stderr || 'BrowserOS not available'));
      }
    });
  });
}

async function callTool(toolName, argsJson) {
  return new Promise((resolve, reject) => {
    const mcporterArgs = [
      'call',
      `browseros.${toolName}`,
      '--args',
      argsJson,
      '--output',
      'json'
    ];

    const child = spawn('mcporter', mcporterArgs, {
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    child.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve(stdout);
      } else {
        reject(new Error(stderr || `mcporter exited with code ${code}`));
      }
    });

    child.on('error', (err) => {
      if (err.code === 'ENOENT') {
        reject(new Error('mcporter not found. Install: npm install -g mcporter'));
      } else {
        reject(err);
      }
    });
  });
}

async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.error('Usage: node browseros-call.js <toolName> \'<jsonArgs>\'');
    console.error('Example: node browseros-call.js browser_navigate \'{"url":"https://x.com"}\'');
    process.exit(1);
  }

  const toolName = args[0];
  const argsJson = args[1] || '{}';

  try {
    // Ensure BrowserOS is running
    await ensureBrowserOS();

    // Call the tool
    const result = await callTool(toolName, argsJson);
    console.log(result);
  } catch (error) {
    console.error(JSON.stringify({ error: error.message }));
    process.exit(1);
  }
}

main();
