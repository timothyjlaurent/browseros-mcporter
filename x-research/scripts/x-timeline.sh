#!/bin/bash
#
# X Timeline - Get your X/Twitter home timeline
# Usage: ./x-timeline.sh [--limit N]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIMIT="${1:-10}"

# Extract cookies
echo "Authenticating..." >&2
COOKIES=$(cd "$SCRIPT_DIR" && node extract-cookies.js 2>&1)
if [ $? -ne 0 ]; then
  echo "$COOKIES" >&2
  exit 1
fi

AUTH_TOKEN=$(echo "$COOKIES" | grep "^AUTH_TOKEN=" | cut -d= -f2-)
CT0=$(echo "$COOKIES" | grep "^CT0=" | cut -d= -f2-)

export AUTH_TOKEN CT0
bird home -n "$LIMIT"
