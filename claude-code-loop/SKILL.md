---
name: claude-code-loop
description: Run Claude Code in a simple loop using the `claude` CLI with `-p` prompts and `--dangerously-skip-permissions`. Use when you want repeatable Claude Code iterations from the shell (fixed prompt, optional model).
---

# Claude Code Loop

## Overview
Use the included script to run Claude Code **once** with `-p` and `--dangerously-skip-permissions`.

## Quick start
```bash
# Single run
./scripts/claude_code_loop.sh -p "Fix failing tests" 

# Single run with model
./scripts/claude_code_loop.sh -p "Refactor module X" -m claude-3.7-sonnet

# Use prompt file
PROMPT_FILE=./PROMPT.md ./scripts/claude_code_loop.sh
```

## Notes
- Runs `claude -p "..." --dangerously-skip-permissions` exactly once.
- Optional `-m/--model` is passed as `--model`.

## Resources
### scripts/
- `claude_code_loop.sh`: CLI wrapper to run Claude Code with `-p` and `--dangerously-skip-permissions` in a loop.
