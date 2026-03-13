#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_WORKSPACE_DIR="${ROOT_DIR}/openclaw-workspace"
TARGET_WORKSPACE_DIR="${HOME}/.openclaw/workspace"
TARGET_SKILL_DIR="${TARGET_WORKSPACE_DIR}/skills/local-web-search"
SOURCE_SKILL_DIR="${REPO_WORKSPACE_DIR}/skills/local-web-search"
TARGET_AGENTS_FILE="${TARGET_WORKSPACE_DIR}/AGENTS.md"
TARGET_TOOLS_FILE="${TARGET_WORKSPACE_DIR}/TOOLS.md"

mkdir -p "${TARGET_SKILL_DIR}/scripts"

if [[ -d "${SOURCE_SKILL_DIR}" ]]; then
  cp "${SOURCE_SKILL_DIR}/SKILL.md" "${TARGET_SKILL_DIR}/SKILL.md"
  cp "${SOURCE_SKILL_DIR}/scripts/search_local_web.py" "${TARGET_SKILL_DIR}/scripts/search_local_web.py"
  chmod +x "${TARGET_SKILL_DIR}/scripts/search_local_web.py"
fi

# Write the project root path so the search script can generate correct error messages
printf '%s\n' "${ROOT_DIR}" > "${TARGET_SKILL_DIR}/.project_root"

if [[ -f "${TARGET_AGENTS_FILE}" ]]; then
  python3 - "${TARGET_AGENTS_FILE}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
start = "<!-- codex:local-web-search:start -->"
end = "<!-- codex:local-web-search:end -->"
block = """<!-- codex:local-web-search:start -->

## Local Web Search

When the user asks for latest, current, today's, breaking, real-time, price, release, version, or other time-sensitive information:

1. Run `python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py --query "<query>" --limit 5`
2. Review the results and pick the most relevant URLs.
3. Use `web_fetch` to read the selected pages before answering.
4. Include dates and links when recency matters.

`local-web-search` finds current candidate links. `web_fetch` reads the page content. Use them together.

If the local search service is unavailable, tell the user to run:
`cd "$(cat ~/.openclaw/workspace/skills/local-web-search/.project_root)" && ./start_local_search.sh`

Do not claim current facts from memory alone when this workflow is available.

<!-- codex:local-web-search:end -->"""

if start in text and end in text:
    before = text.split(start, 1)[0]
    after = text.split(end, 1)[1]
    text = before + block + after
elif "## Make It Yours" in text:
    text = text.replace("## Make It Yours", block + "\n\n## Make It Yours", 1)
else:
    text = text.rstrip() + "\n\n" + block + "\n"

path.write_text(text)
PY
fi

if [[ -f "${TARGET_TOOLS_FILE}" ]]; then
  python3 - "${TARGET_TOOLS_FILE}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
start = "<!-- codex:local-web-search-tools:start -->"
end = "<!-- codex:local-web-search-tools:end -->"
block = """<!-- codex:local-web-search-tools:start -->

### Local Web Search

- Search command:
  `python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py --query "<query>" --limit 5`
- Default engine: `bing` (auto-falls back to DuckDuckGo / Google)
- Use this for latest, current, today, real-time, versions, prices, releases, and news.
- After search, use `web_fetch` on the most relevant URLs before answering.
- If unavailable, start it with:
  `cd "$(cat ~/.openclaw/workspace/skills/local-web-search/.project_root)" && ./start_local_search.sh`

<!-- codex:local-web-search-tools:end -->"""

if start in text and end in text:
    before = text.split(start, 1)[0]
    after = text.split(end, 1)[1]
    text = before + block + after
else:
    text = text.rstrip() + "\n\n" + block + "\n"

path.write_text(text)
PY
fi

if command -v openclaw >/dev/null 2>&1; then
  openclaw gateway restart >/dev/null 2>&1 || true
fi

printf 'Workspace sync complete.\n'
