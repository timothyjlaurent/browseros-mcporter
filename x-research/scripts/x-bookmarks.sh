#!/bin/bash
#
# X Bookmarks - Get your X/Twitter bookmarks
# Usage: ./x-bookmarks.sh [--limit N] [--folder-id ID]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIMIT=10
FOLDER_ID=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --limit|-l)
      LIMIT="$2"
      shift 2
      ;;
    --folder-id|-f)
      FOLDER_ID="$2"
      shift 2
      ;;
    *)
      LIMIT="$1"
      shift
      ;;
  esac
done

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

OPTS="-n $LIMIT"
if [ -n "$FOLDER_ID" ]; then
  OPTS="$OPTS --folder-id $FOLDER_ID"
fi

bird bookmarks $OPTS
