#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   browseros_call.sh <toolName> '<jsonArgs>'
# Example:
#   browseros_call.sh browser_navigate '{"url":"https://x.com"}'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure BrowserOS is running (auto-launch if needed)
"${SCRIPT_DIR}/ensure_browseros.sh" >/dev/null 2>&1 || {
    echo '{"error":"BrowserOS not available"}'
    exit 1
}

TOOL_NAME="${1:?toolName required}"
# NOTE: default JSON must escape braces; otherwise bash parses `${2:-{}}` as `{}` + extra `}`.
ARGS_JSON="${2:-'{}'}"

# Always emit JSON for easy parsing.
mcporter call "browseros.${TOOL_NAME}" --args "${ARGS_JSON}" --output json
