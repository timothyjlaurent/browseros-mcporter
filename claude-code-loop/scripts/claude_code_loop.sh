#!/usr/bin/env bash
set -euo pipefail

PROMPT=""
MODEL=""

usage() {
  cat <<'USAGE'
Usage: claude_code_loop.sh -p "prompt" [-m model]
       PROMPT_FILE=./PROMPT.md claude_code_loop.sh

Options:
  -p, --prompt   Prompt text to pass to `claude -p`.
  -m, --model    Model name to pass as --model.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prompt) PROMPT="$2"; shift 2;;
    -m|--model) MODEL="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  if [[ -n "${PROMPT_FILE:-}" && -f "${PROMPT_FILE}" ]]; then
    PROMPT=$(cat "$PROMPT_FILE")
  else
    echo "Error: provide -p/--prompt or set PROMPT_FILE." >&2
    exit 1
  fi
fi

if [[ -n "$MODEL" ]]; then
  claude -p "$PROMPT" --model "$MODEL" --dangerously-skip-permissions
else
  claude -p "$PROMPT" --dangerously-skip-permissions
fi
