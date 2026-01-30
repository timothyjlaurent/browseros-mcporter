#!/bin/bash
#
# Setup script for x-research skill
# Installs dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "Setting up x-research skill..."

# Check for node/npm
if ! command -v node &> /dev/null; then
  echo "Error: Node.js not found"
  exit 1
fi

# Install dependencies
echo "Installing npm dependencies..."
npm install

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Ensure BrowserOS is running"
echo "  2. Log into x.com in BrowserOS"
echo "  3. Run: ./scripts/x-search.sh \"your query\""
