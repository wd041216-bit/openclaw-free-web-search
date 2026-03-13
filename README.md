# openclaw-local-web-search

[中文版](./README_zh.md)

**Zero-cost live web search for OpenClaw on Apple Silicon Mac.**

Run a self-hosted [SearXNG](https://github.com/searxng/searxng) instance locally and give your OpenClaw agent real-time internet access — no Brave API key, no Perplexity subscription, no cloud dependency.

```
User query
   │
   ▼
OpenClaw  (qwen3:14b via Ollama)
   │  triggers local-web-search skill
   ▼
SearXNG  ──► Bing / DuckDuckGo / Google  (auto-fallback)
   │
   ▼
search_local_web.py  (ranked results)
   │
   ▼
web_fetch  (reads page content)
   │
   ▼
Answer with citations
```

---

## Requirements

| Requirement | Notes |
|---|---|
| macOS (Apple Silicon recommended) | Scripts use `open -a Ollama.app`; Intel Mac works with minor adjustments |
| [Ollama](https://ollama.com) | Install the official `.app` or CLI |
| `qwen3:14b` model | `ollama pull qwen3:14b` (~9 GB) |
| OpenClaw | Install via `ollama launch openclaw` or the official installer |
| Python 3.9+ | Pre-installed on macOS 12+ |

---

## Quick Start

### 1. Clone this repo

```bash
git clone https://github.com/wd041216-bit/openclaw-local-web-search.git
cd openclaw-local-web-search
```

### 2. (Optional) Copy `.env.example` to `.env` and adjust

```bash
cp .env.example .env
# Edit .env to change model, port, etc.
```

### 3. Start OpenClaw (first time — foreground mode)

```bash
OPENCLAW_FOREGROUND=1 ./start_openclaw.sh
```

After the first-time setup is complete, use background mode for daily use:

```bash
./start_openclaw.sh
```

### 4. Install and start local web search

```bash
./install_local_search.sh   # one-time setup (~2 min)
./start_local_search.sh
```

### 5. Sync the skill into your OpenClaw workspace

```bash
./sync_openclaw_workspace.sh
```

This copies the `local-web-search` skill and injects auto-trigger rules into your `AGENTS.md` and `TOOLS.md`.

### 6. Verify it works

```bash
# Test SearXNG directly
curl "http://127.0.0.1:18080/search?q=openclaw&format=json"

# Test the skill script
python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py \
  --query "OpenClaw latest release"
```

---

## Daily Usage

| Task | Command |
|---|---|
| Start OpenClaw | `./start_openclaw.sh` |
| Stop OpenClaw | `./stop_openclaw.sh` |
| Stop OpenClaw + Ollama | `./stop_openclaw.sh --with-ollama` |
| Start local search | `./start_local_search.sh` |
| Stop local search | `./stop_local_search.sh` |
| Sync workspace skill | `./sync_openclaw_workspace.sh` |
| Diagnose issues | `./doctor.sh` |

---

## How the Search Skill Works

Once synced, OpenClaw will automatically use `local-web-search` whenever you ask about:

- Latest news, current events, today's updates
- Software versions, release notes, changelogs
- Real-time prices, stock, weather
- Anything that requires live internet data

The workflow is:

1. `search_local_web.py` queries your local SearXNG → returns ranked titles, URLs, and snippets
2. OpenClaw picks the most relevant URLs and calls `web_fetch` to read the full page content
3. OpenClaw answers with citations and dates

The script automatically falls back from Bing → DuckDuckGo → Google if an engine is unavailable.

---

## Configuration

All settings are controlled via `.env` (copy from `.env.example`):

| Variable | Default | Description |
|---|---|---|
| `OLLAMA_HOST` | `http://127.0.0.1:11434` | Ollama API endpoint |
| `OPENCLAW_MODEL` | `qwen3:14b` | Main LLM model |
| `OPENCLAW_CODE_MODEL` | `qwen3-coder:30b` | Optional coding model |
| `OPENCLAW_FOREGROUND` | `0` | Set to `1` for first-time setup |
| `LOCAL_SEARCH_HOST` | `127.0.0.1` | SearXNG bind address |
| `LOCAL_SEARCH_PORT` | `18080` | SearXNG port |

To switch models:

```bash
echo "OPENCLAW_MODEL=qwen3:8b" >> .env
```

---

## Logs

| Log file | Content |
|---|---|
| `logs/ollama.log` | Ollama server output |
| `logs/openclaw.log` | OpenClaw gateway output |
| `logs/searxng.log` | SearXNG server output |
| `logs/qwen3-14b-pull.log` | Model download progress |

```bash
tail -f logs/searxng.log
```

---

## Troubleshooting

Run the built-in doctor first:

```bash
./doctor.sh
```

| Symptom | Fix |
|---|---|
| `Ollama service: unreachable` | Open `Ollama.app` or run `ollama serve` |
| `Model qwen3:14b: not installed` | `ollama pull qwen3:14b` |
| `OpenClaw: not detected` | Use `OPENCLAW_FOREGROUND=1 ./start_openclaw.sh` |
| `Local search: installed but not running` | `./start_local_search.sh` |
| Download stalled / `connection reset` | Set your proxy: `export https_proxy=http://127.0.0.1:7890` |

---

## Security Notes

- SearXNG only binds to `127.0.0.1` — it is never exposed to the network.
- `settings.yml` is auto-generated with a random `secret_key` on first install and is excluded from version control via `.gitignore`.
- No API keys are required or stored anywhere in this project.

---

## Project Structure

```
openclaw-local-web-search/
├── .env.example                          # Configuration template
├── .gitignore
├── install_local_search.sh               # One-time SearXNG setup
├── start_local_search.sh / stop_local_search.sh
├── start_openclaw.sh / stop_openclaw.sh
├── sync_openclaw_workspace.sh            # Sync skill into OpenClaw workspace
├── doctor.sh                             # Diagnose all components
├── scripts/
│   └── common.sh                         # Shared shell functions
├── local-search/searxng/
│   └── settings.yml.template             # SearXNG config template
└── openclaw-workspace/skills/local-web-search/
    ├── SKILL.md                          # OpenClaw skill definition
    └── scripts/
        └── search_local_web.py           # Search helper script
```

---

## License

MIT
