#!/usr/bin/env python3
"""
search_local_web.py — Query a locally running SearXNG instance and print
ranked results in a format that is easy for an LLM to parse.

Usage:
    python3 search_local_web.py --query "OpenClaw latest release" [--limit 5] [--engine bing]

Environment variables (override defaults):
    LOCAL_SEARCH_URL     Base URL of the SearXNG search endpoint  (default: http://127.0.0.1:18080/search)
    LOCAL_SEARCH_ENGINE  Preferred engine name                     (default: bing)
"""

import argparse
import json
import os
import sys
import urllib.parse
import urllib.request
from pathlib import Path


DEFAULT_URL = os.environ.get("LOCAL_SEARCH_URL", "http://127.0.0.1:18080/search")
DEFAULT_ENGINE = os.environ.get("LOCAL_SEARCH_ENGINE", "bing")
FALLBACK_ENGINES = ["bing", "duckduckgo", "google"]


def _project_root() -> str:
    """Return the project root path stored by sync_openclaw_workspace.sh, or a generic hint."""
    marker = (
        Path.home()
        / ".openclaw"
        / "workspace"
        / "skills"
        / "local-web-search"
        / ".project_root"
    )
    if marker.exists():
        return marker.read_text().strip()
    return "<your-project-directory>"


def fetch(query: str, limit: int, engine: str) -> dict:
    params = urllib.parse.urlencode(
        {
            "q": query,
            "format": "json",
            "language": "zh-CN",
            "pageno": "1",
            "engines": engine,
        }
    )
    url = f"{DEFAULT_URL}?{params}"
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "OpenClawLocalSearch/1.0",
            "Accept": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=20) as response:
        payload = response.read().decode("utf-8")
    data = json.loads(payload)
    data["results"] = data.get("results", [])[:limit]
    return data


def fetch_with_fallback(query: str, limit: int, preferred_engine: str) -> tuple:
    """Try the preferred engine first, then fall back through FALLBACK_ENGINES."""
    engines_to_try = [preferred_engine] + [
        e for e in FALLBACK_ENGINES if e != preferred_engine
    ]
    last_exc = None
    for eng in engines_to_try:
        try:
            data = fetch(query, limit, eng)
            if data.get("results"):
                return data, eng
        except Exception as exc:  # noqa: BLE001
            last_exc = exc
            continue
    raise RuntimeError(f"All engines failed. Last error: {last_exc}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Search the local SearXNG instance."
    )
    parser.add_argument("--query", required=True, help="Search query")
    parser.add_argument(
        "--limit", type=int, default=5, help="Max result count (default: 5)"
    )
    parser.add_argument(
        "--engine",
        default=DEFAULT_ENGINE,
        help="Preferred SearXNG engine (default: bing). Falls back to duckduckgo/google automatically.",
    )
    args = parser.parse_args()

    try:
        data, used_engine = fetch_with_fallback(args.query, args.limit, args.engine)
    except Exception as exc:  # noqa: BLE001
        root = _project_root()
        print("ERROR: local SearXNG is unavailable.", file=sys.stderr)
        print(
            f'Start it with: cd "{root}" && ./start_local_search.sh',
            file=sys.stderr,
        )
        print(f"DETAIL: {exc}", file=sys.stderr)
        return 1

    print(f"Query: {args.query}")
    print(f"Engine: {used_engine}")
    print(f'Results: {len(data.get("results", []))}')
    print()

    for index, item in enumerate(data.get("results", []), start=1):
        title = item.get("title", "").strip() or "(no title)"
        url = item.get("url", "").strip() or "(no url)"
        content = " ".join((item.get("content") or "").split())
        engine_name = item.get("engine", "").strip()

        print(f"{index}. {title}")
        print(f"   URL: {url}")
        if engine_name:
            print(f"   Engine: {engine_name}")
        if content:
            print(f"   Snippet: {content}")
        print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
