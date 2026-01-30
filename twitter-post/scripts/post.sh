#!/bin/bash
#
# twitter-post: Post tweets via browseros-mcporter
# 
# Usage: ./post.sh [options] --file <tweet-file>
#
# Options:
#   --file FILE       Path to tweet content
#   --format FORMAT   'single' (default) or 'thread'
#   --dry-run         Validate but don't post
#   --retries N       Retry N times on failure (default: 3)
#   --screenshot      Capture screenshot on failure
#
# Environment:
#   BROWSEROS_MCPORTER_PATH  Path to browseros-mcporter skill
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"

# Defaults
FILE=""
FORMAT="single"
DRY_RUN=false
RETRIES=3
SCREENSHOT=false
BROWSEROS_MCPORTER_PATH="${BROWSEROS_MCPORTER_PATH:-$HOME/clawd/skills/browseros-mcporter}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    echo "twitter-post: Post tweets via browseros-mcporter"
    echo ""
    echo "Usage: $0 --file <tweet-file> [options]"
    echo ""
    echo "Options:"
    echo "  --file FILE       Path to tweet content (required)"
    echo "  --format FORMAT   'single' (default) or 'thread'"
    echo "  --dry-run         Validate but don't post"
    echo "  --retries N       Retry N times on failure (default: 3)"
    echo "  --screenshot      Capture screenshot on failure"
    echo "  --help            Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --file tweet.txt"
    echo "  $0 --file thread.json --format thread --dry-run"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --file)
            FILE="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --retries)
            RETRIES="$2"
            shift 2
            ;;
        --screenshot)
            SCREENSHOT=true
            shift
            ;;
        --help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required args
if [[ -z "$FILE" ]]; then
    log_error "--file is required"
    usage
fi

if [[ ! -f "$FILE" ]]; then
    log_error "File not found: $FILE"
    exit 1
fi

# Validate format
if [[ "$FORMAT" != "single" && "$FORMAT" != "thread" ]]; then
    log_error "Invalid format: $FORMAT (must be 'single' or 'thread')"
    exit 1
fi

# Check dependencies
if [[ ! -d "$BROWSEROS_MCPORTER_PATH" ]]; then
    log_error "browseros-mcporter skill not found at $BROWSEROS_MCPORTER_PATH"
    log_info "Set BROWSEROS_MCPORTER_PATH or install: clawdhub install browseros-mcporter"
    exit 1
fi

# Read tweet content
TWEET_CONTENT=$(cat "$FILE")
if [[ -z "$TWEET_CONTENT" ]]; then
    log_error "Tweet file is empty: $FILE"
    exit 1
fi

CHAR_COUNT=$(echo -n "$TWEET_CONTENT" | wc -c)
log_info "Tweet length: $CHAR_COUNT characters"

# Check length limits
if [[ "$FORMAT" == "single" && $CHAR_COUNT -gt 4000 ]]; then
    log_warn "Tweet exceeds 4000 char limit for Premium users"
    log_warn "Standard limit is 280 chars"
fi

# Dry run mode
if [[ "$DRY_RUN" == true ]]; then
    log_info "DRY RUN: Would post the following:"
    echo "---"
    echo "$TWEET_CONTENT"
    echo "---"
    log_info "Validation passed. Use without --dry-run to post."
    exit 0
fi

# Post with retries
ATTEMPT=0
while [[ $ATTEMPT -lt $RETRIES ]]; do
    ATTEMPT=$((ATTEMPT + 1))
    log_info "Posting attempt $ATTEMPT of $RETRIES..."
    
    # TODO: Implement actual posting via browseros-mcporter
    # This is where we'd call the MCP tools
    
    if [[ $ATTEMPT -lt $RETRIES ]]; then
        log_warn "Post failed, waiting before retry..."
        sleep $((ATTEMPT * 2))  # Exponential backoff
    fi
done

log_error "Failed to post after $RETRIES attempts"
exit 1
