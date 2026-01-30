#!/bin/bash
#
# X Search - Search X/Twitter with automatic BrowserOS auth
# Usage: ./x-search.sh "query" [--limit N] [--freshness pd|pw|pm]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIMIT=10
FRESHNESS=""
QUERY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --limit|-l)
      LIMIT="$2"
      shift 2
      ;;
    --freshness|-f)
      FRESHNESS="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 \"search query\" [--limit N] [--freshness pd|pw|pm]"
      echo ""
      echo "Options:"
      echo "  --limit N       Number of results (default: 10)"
      echo "  --freshness     pd=past day, pw=past week, pm=past month"
      echo "  --help          Show this help"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      QUERY="$1"
      shift
      ;;
  esac
done

if [ -z "$QUERY" ]; then
  echo "Error: Search query required"
  echo "Usage: $0 \"search query\" [--limit N]"
  exit 1
fi

# Check if bird is installed
if ! command -v bird &> /dev/null; then
  echo "Error: bird CLI not found"
  echo "Install: npm install -g @steipete/bird"
  exit 1
fi

# Extract cookies from BrowserOS
echo "Extracting cookies from BrowserOS..." >&2
COOKIES=$(cd "$SCRIPT_DIR" && node extract-cookies.js 2>&1)

if [ $? -ne 0 ]; then
  echo "$COOKIES" >&2
  exit 1
fi

# Parse cookies
AUTH_TOKEN=$(echo "$COOKIES" | grep "^AUTH_TOKEN=" | cut -d= -f2-)
CT0=$(echo "$COOKIES" | grep "^CT0=" | cut -d= -f2-)

if [ -z "$AUTH_TOKEN" ] || [ -z "$CT0" ]; then
  echo "Error: Failed to extract cookies" >&2
  exit 1
fi

# Build bird command
BIRD_OPTS="-n $LIMIT"
if [ -n "$FRESHNESS" ]; then
  BIRD_OPTS="$BIRD_OPTS --freshness $FRESHNESS"
fi

# Run search
export AUTH_TOKEN
export CT0
bird search "$QUERY" $BIRD_OPTS
