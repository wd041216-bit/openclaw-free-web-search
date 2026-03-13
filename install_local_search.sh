#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/common.sh"

PYTHON_BIN="$(python3_bin || true)"

if [[ -z "${PYTHON_BIN}" ]]; then
  log "未找到 python3，无法安装本地搜索服务。"
  exit 1
fi

mkdir -p "${LOCAL_SEARCH_ROOT}"

log "安装目录: ${LOCAL_SEARCH_ROOT}"
log "下载 SearXNG 源码（GitHub 较慢时会自动续传）"
curl -L -C - --retry 5 --retry-all-errors --retry-delay 2 \
  https://codeload.github.com/searxng/searxng/tar.gz/refs/heads/master \
  -o "${LOCAL_SEARCH_ARCHIVE}"

rm -rf "${LOCAL_SEARCH_SRC_PARENT}"
mkdir -p "${LOCAL_SEARCH_SRC_PARENT}"
tar -xzf "${LOCAL_SEARCH_ARCHIVE}" -C "${LOCAL_SEARCH_SRC_PARENT}"

SRC_DIR="$(find "${LOCAL_SEARCH_SRC_PARENT}" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [[ -z "${SRC_DIR}" ]]; then
  log "源码解压失败，未找到 SearXNG 目录。"
  exit 1
fi

log "创建 Python 虚拟环境"
"${PYTHON_BIN}" -m venv "${LOCAL_SEARCH_VENV_DIR}"

log "安装依赖"
"${LOCAL_SEARCH_VENV_DIR}/bin/python" -m pip install -U pip setuptools wheel
"${LOCAL_SEARCH_VENV_DIR}/bin/pip" install -U pyyaml msgspec typing_extensions
"${LOCAL_SEARCH_VENV_DIR}/bin/pip" install waitress
"${LOCAL_SEARCH_VENV_DIR}/bin/pip" install --use-pep517 --no-build-isolation -e "${SRC_DIR}"

if [[ ! -f "${LOCAL_SEARCH_SETTINGS_FILE}" ]]; then
  LOCAL_SECRET="$(generate_local_search_secret)"
  cat > "${LOCAL_SEARCH_SETTINGS_FILE}" <<EOF
use_default_settings: true

general:
  debug: false
  instance_name: "Local SearXNG"

search:
  safe_search: 1
  autocomplete: "duckduckgo"
  formats:
    - html
    - json

server:
  base_url: ${LOCAL_SEARCH_URL}/
  port: ${LOCAL_SEARCH_PORT}
  bind_address: "${LOCAL_SEARCH_HOST}"
  secret_key: "${LOCAL_SECRET}"
  limiter: false
  image_proxy: false

engines:
  - name: bing
    disabled: false
  - name: duckduckgo
    disabled: false
  - name: google
    disabled: false
EOF
  log "已生成配置: ${LOCAL_SEARCH_SETTINGS_FILE}"
else
  log "保留现有配置: ${LOCAL_SEARCH_SETTINGS_FILE}"
fi

if [[ -x "${ROOT_DIR}/sync_openclaw_workspace.sh" ]]; then
  log "同步 OpenClaw workspace 配置"
  "${ROOT_DIR}/sync_openclaw_workspace.sh"
fi

log "安装完成。下一步执行 ./start_local_search.sh"
