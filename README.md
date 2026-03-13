# OpenClaw Free Web Search v2.0

> **Zero-cost, zero-API-key, privacy-first web search for OpenClaw.**  
> Self-hosted SearXNG on Mac + multi-engine parallel search + Browse/Viewing + anti-hallucination.

[中文文档](./README_zh.md)

---

## What's New in v2.0

| Feature | Description |
|---|---|
| **Agent Reach** | Intent-aware query expansion — one query becomes 2–3 targeted sub-queries |
| **Multi-engine parallel** | Bing, DuckDuckGo, Google, Startpage, Qwant run simultaneously |
| **Browse/Viewing** | `browse_page.py` fetches full page text — no browser, no Playwright |
| **Anti-hallucination** | Cross-engine validation + domain authority scoring + confidence levels |
| **Invalid page filter** | Auto-removes paywalls, 404s, login walls, JS-only pages |
| **Deduplication** | URL-level dedup + cross-engine appearance counting |
| **Public fallback** | Auto-falls back to `searx.be` if local SearXNG is down |

---

## Requirements

- macOS (Apple Silicon or Intel)
- Docker Desktop (for SearXNG)
- Python 3.8+ (stdlib only — no pip installs needed)
- OpenClaw desktop app

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/wd041216-bit/openclaw-free-web-search.git
cd openclaw-free-web-search

# 2. Install SearXNG (one-time)
./install_local_search.sh

# 3. Start SearXNG
./start_local_search.sh

# 4. Sync skill into OpenClaw workspace
./sync_openclaw_workspace.sh

# 5. Restart OpenClaw — the skill is now active
```

---

## Usage

### Web Search

```bash
python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py \
  --query "OpenAI latest model" \
  --intent factual \
  --limit 5
```

### Browse a Page

```bash
python3 ~/.openclaw/workspace/skills/local-web-search/scripts/browse_page.py \
  --url "https://openai.com/blog/..." \
  --max-words 600
```

### Intent Options

| Intent | Best for | Engines |
|---|---|---|
| `general` | Default | bing, ddg, google |
| `factual` | Facts, docs | bing, google, ddg |
| `news` | Breaking news | bing, ddg, google |
| `research` | Papers, GitHub | google, startpage, bing |
| `tutorial` | How-to, examples | google, bing, ddg |
| `comparison` | A vs B | google, bing, startpage |
| `privacy` | Sensitive queries | ddg, startpage, qwant |

---

## Recommended Workflow

```
1. search_local_web.py  →  review Score + [cross-validated] results
2. browse_page.py       →  read full content, check Confidence level
3. HIGH confidence      →  safe to answer
4. LOW confidence       →  try next URL, never fabricate
```

---

## Management

```bash
./start_local_search.sh    # Start SearXNG
./stop_local_search.sh     # Stop SearXNG
./doctor.sh                # Health check
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `LOCAL_SEARCH_URL` | `http://127.0.0.1:18080` | Local SearXNG base URL |
| `LOCAL_SEARCH_FALLBACK_URL` | `https://searx.be` | Public fallback |

---

## License

MIT © 2025
