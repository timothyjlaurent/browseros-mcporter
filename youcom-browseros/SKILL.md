---
name: youcom-browseros
description: Automate you.com queries using BrowserOS via mcporter. Use when you need to run searches/chat prompts on You.com with different models and agents, collect responses, compare outputs, or summarize results from multiple runs. Always use BrowserOS (not Playwright) for these tasks.
---

# You.com via BrowserOS

## Overview
Run You.com queries with specific models/agents using BrowserOS automation. Capture outputs for comparison or summaries.

## Quick start
1. Use BrowserOS via mcporter (never Playwright). If you need CLI usage, read `/home/dadmin/clawd/skills/browseros-mcporter/SKILL.md`.
2. Open or attach to an active BrowserOS tab, navigate to https://you.com.
3. Ensure you’re on the chat/search interface. If login is required, stop and ask unless explicitly told to sign in.
4. Select the desired **model** and **agent**, run the query, capture the response text.
5. Repeat for other model/agent combinations; return a clean comparison summary.

## References
- **Available agents:** `references/agents.md` (refresh when user asks)
- **Update procedure:** `references/update.md`
- **Old conversation search:** `references/conversations.md`

## Workflow

### 1) Session + navigation
- Check BrowserOS health and open a tab if needed.
- Navigate to https://you.com and wait for the UI to load.
- Use BrowserOS element discovery (interactive elements) to locate:
  - Prompt input box
  - Model selector
  - Agent selector (if present)
  - Submit button

### 2) Configure model + agent
- Open the model selector (often labeled **Auto**) and choose the requested model.
- If a dropdown appears with **Auto Pro / Express / Custom**, choose **Custom** to expose agent choices.
- The agent list may appear inside the model dropdown; select the agent there (e.g., **Chef bot**).
- If the labels differ from the request, pick the closest match and note the discrepancy.
- If the agent isn’t discoverable in the DOM, try the direct agent URL (e.g., `https://you.com/?chatMode=<agent_id>`). Then re-open the model selector → **Custom** to expose the agent entry.

### 3) Run query
- Type the query into the prompt input.
- Submit and wait for completion (watch for a stable response area or “stop generating” to disappear).
- If the send action isn’t exposed in the DOM, ask the user to press Enter once to submit.
- Extract the response text (and citations/links if visible).

### 4) Multi-run comparisons
- For each model/agent pair:
  - Set model + agent
  - Run the same query
  - Capture output
- Return a concise comparison: key differences, strengths/weaknesses, and notable citations.

### 5) Old conversation search
- Use the sidebar/history and search if available.
- Follow `references/conversations.md`.

## Output guidance
- Default: bullets grouped by model/agent.
- If the user wants a structured output, return JSON with fields:
  - `model`, `agent`, `response`, `citations` (if any)

## Notes
- Don’t sign in or connect accounts unless explicitly asked.
- Prefer stable element discovery over hardcoded selectors; UI can shift.
- When uncertain about UI state, take a screenshot and re-scan elements.
