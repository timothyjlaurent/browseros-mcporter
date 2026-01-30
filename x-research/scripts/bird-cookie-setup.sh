#!/bin/bash
# One-time bird CLI cookie setup guide

set -e

BIRD_CONFIG="$HOME/.config/bird"
BIRD_CONFIG_FILE="$BIRD_CONFIG/config.json5"

echo "🔧 bird CLI Cookie Setup"
echo ""
echo "📋 Option 1: Automatic (Recommended)"
echo "   1. Login to https://x.com in Chrome/Safari/Firefox"
echo "   2. Run: bird check"
echo "   3. That's it! bird auto-extracts cookies"
echo ""
echo "📋 Option 2: Manual (One-time setup)"
echo "   1. Open https://x.com in your browser"
echo "   2. Open DevTools (F12) → Application → Cookies → https://x.com"
echo "   3. Find 'auth_token' and 'ct0' cookies"
echo "   4. Copy their values"
echo ""
read -p "Have you logged into x.com? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Try automatic extraction
  echo "🔍 Attempting automatic cookie extraction..."

  if OUTPUT=$(bird check 2>&1); then
    echo "✅ Success! bird CLI is configured"
    echo ""
    echo "📝 You can now:"
    echo "  bird tweet 'your message'"
    exit 0
  fi

  echo "⚠️  Auto-extraction failed"
  echo ""
  echo "📝 Manual setup:"
  echo "   1. Open x.com in your browser"
  echo "   2. Open DevTools (F12)"
  echo "   3. Application → Cookies → https://x.com"
  echo "   4. Find auth_token and ct0"
  echo ""
  read -p "Enter AUTH_TOKEN value: " AUTH_TOKEN
  read -p "Enter CT0 value: " CT0

  mkdir -p "$BIRD_CONFIG"

  cat > "$BIRD_CONFIG_FILE" << EOF
{
  // bird CLI config for X/Twitter
  auth_token: "$AUTH_TOKEN",
  ct0: "$CT0",
  timeoutMs: 20000
}
EOF

  echo ""
  echo "✅ Configuration saved to $BIRD_CONFIG_FILE"
  echo ""
  echo "🧪 Testing..."
  if bird whoami &>/dev/null; then
    echo "✅ bird CLI is ready!"
  else
    echo "⚠️  Test failed, but config saved"
  fi
else
  echo "❌ Please login to x.com first, then run this script again"
  exit 1
fi
