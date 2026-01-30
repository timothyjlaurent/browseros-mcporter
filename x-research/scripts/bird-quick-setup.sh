#!/bin/bash
# Quick setup for bird CLI - one-time manual login required

set -e

BIRD_CONFIG="$HOME/.config/bird"
BIRD_CONFIG_FILE="$BIRD_CONFIG/config.json5"

echo "🔧 bird CLI Quick Setup"
echo ""
echo "📦 Prerequisites:"
echo "  1. Install bird: npm install -g @steipete/bird"
echo "  2. Login to X/Twitter at https://x.com"
echo "  3. Run: bird check"
echo ""
echo "💡 bird will auto-extract cookies from your browser."
echo "   No manual setup needed!"
echo ""

mkdir -p "$BIRD_CONFIG"

# Check if bird is installed
if ! command -v bird &> /dev/null; then
  echo "⚠️  bird CLI not found"
  echo "   Install with: npm install -g @steipete/bird"
  echo ""
  echo "   Or via Homebrew:"
  echo "   brew install steipete/tap/bird"
  exit 1
fi

# Test bird
echo "🧪 Testing bird CLI..."
if OUTPUT=$(bird check 2>&1); then
  echo "✅ bird CLI is configured!"
  echo ""
  echo "📝 You can now:"
  echo "  bird tweet 'your message'"
  echo "  bird thread <url>"
  echo "  bird search 'query' -n 10"
  exit 0
else
  echo "⚠️  bird needs cookies"
  echo ""
  echo "🔑 Quick fix:"
  echo "   1. Open https://x.com in Chrome/Safari/Firefox"
  echo "   2. Make sure you're logged in"
  echo "   3. Run: bird check"
  echo ""
  echo "   bird will automatically find and use your browser cookies."
  exit 1
fi
