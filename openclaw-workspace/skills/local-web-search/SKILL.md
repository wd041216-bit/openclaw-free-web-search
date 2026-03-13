---
name: local-web-search
description: Search the live web for current information using the user's self-hosted local SearXNG service when built-in web_search is unavailable or not configured. Use for requests about latest news, current events, real-time facts, prices, releases, versions, or anything that requires internet search without paid API keys.
---

# Local Web Search

Use this skill when the user needs current or real-time web information and the environment is using the free local SearXNG setup instead of OpenClaw's paid `web_search` providers.

## Workflow

1. Run the local search helper script:

```bash
python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py --query "YOUR QUERY" --limit 5
```

2. Review the returned titles, URLs, engines, and snippets.
3. Use OpenClaw's built-in `web_fetch` to read the most relevant URLs before answering.
4. Summarize findings with dates and links when recency matters.

## Rules

- Prefer narrow, factual queries over broad conversational ones.
- Default to the fastest stable engine for automatic runs. The script auto-falls back to DuckDuckGo and Google if Bing is unavailable.
- When the script reports that the local service is unavailable, tell the user to start it with:

```bash
cd "$(cat ~/.openclaw/workspace/skills/local-web-search/.project_root)" && ./start_local_search.sh
```

- Do not invent search results if the local service fails.
- `local-web-search` and `web_fetch` are complementary: search first, fetch second.
