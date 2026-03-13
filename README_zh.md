# OpenClaw + 本地 Qwen3 + Ollama（macOS Apple Silicon）

这是一套尽量便宜、尽量稳定、尽量傻瓜化的本地部署方案，目标是在 Apple Silicon Mac 上用 Ollama 跑 `qwen3:14b`，再通过官方命令 `ollama launch openclaw` 启动 OpenClaw。默认只做纯本地链路，不强制接 Telegram、WhatsApp、Slack 等平台。

另外，这个项目现在也支持一套“真 0 元”的免费联网方案：

- 本机运行自建 `SearXNG`
- OpenClaw 通过本地 skill 先搜索
- 已启用的 `web_fetch` 再负责读取网页正文
- 仓库内保留一份可同步的 workspace 版本：`openclaw-workspace/skills/local-web-search`

## 为什么主模型选 `qwen3:14b`

`qwen3:14b` 是这台 `36 GB` 内存 MacBook Pro 上比较均衡的主力模型：质量明显高于小模型，资源压力又低于更大的 30B/32B 级别，适合本地常驻、调试、问答和轻量 agent 使用。对“稳定优先”的目标来说，它比追求极限参数量更合适。

## 可选的 `qwen3-coder` 是干什么的

`qwen3-coder` 适合写代码、解释报错、重构和生成脚本。它不是 OpenClaw 启动所必需，只是给后续本地 coding / 调试预留。当前 README 默认示例用 `qwen3-coder:30b` 作为可选值，但只有在 Ollama 稳定运行后再建议下载。

## 当前状态

官方 `Ollama.app` 已安装完成，崩溃的 Homebrew 版已移除，`OpenClaw` 也已经通过官方安装器装好，主模型 `qwen3:14b` 已完成下载并通过本地联调。可选代码模型 `qwen3-coder:30b` 已启动后台下载。

另外，已经额外安装一批 GitHub/ClawHub 生态里热度较高、且当前机器可直接加载的 OpenClaw skills，目录位于 `~/.openclaw/workspace/skills/`：

- `self-improvement`
- `skillcraft`
- `memory-manager`
- `prompt-guard`
- `topic-monitor`
- `agent-development`
- `context-recovery`
- `conventional-commits`
- `deepwiki`
- `hybrid-memory`
- `project-management-skills`
- `remember-all-prompts-daily`
- `secret-scanner`
- `skillguard`
- `vestige`

<!-- deployment log removed in open-source version -->

## 首次安装流程

1. 安装官方 Ollama。
2. 启动 Ollama 服务。
3. 拉取主模型：

```bash
ollama pull qwen3:14b
```

4. 做最小测试：

```bash
ollama run qwen3:14b "用一句话确认你已就绪。"
```

5. 首次以前台方式启动 OpenClaw，便于处理官方交互：

```bash
OPENCLAW_FOREGROUND=1 ./start_openclaw.sh
```

## 日常启动流程

如果首次配置已经完成，之后通常只需要：

```bash
./start_openclaw.sh
```

停止：

```bash
./stop_openclaw.sh
```

如果连 Ollama 也要一起停掉：

```bash
./stop_openclaw.sh --with-ollama
```

本地搜索服务单独安装 / 启动 / 停止：

```bash
./install_local_search.sh
./start_local_search.sh
./stop_local_search.sh
```

同步仓库里的 OpenClaw workspace 配置到本机：

```bash
./sync_openclaw_workspace.sh
```

## 如何查看日志

- Ollama 日志：`logs/ollama.log`
- OpenClaw 日志：`logs/openclaw.log`
- 主模型下载日志：`logs/qwen3-14b-pull.log`
- 本地搜索日志：`logs/searxng.log`
- 安装记录：`docs/deployment-log.md`
- OpenClaw 网关实时日志：`openclaw logs`

如果要检查后台下载会话是否还在：

```bash
screen -ls
```

如果要实时看主模型下载进度：

```bash
tail -f logs/qwen3-14b-pull.log
```

如果要看可选代码模型下载进度：

```bash
tail -f logs/qwen3-coder-30b-pull.log
```

如果要看本地搜索日志：

```bash
tail -f logs/searxng.log
```

## 已安装的附加 Skills

当前已验证为 `ready` 的新增 skills：

- `self-improvement`
  适合把错误、修正和经验沉淀到 `.learnings/`
- `skillcraft`
  适合后续把你的脚本或工作流打包成 OpenClaw skill
- `memory-manager`
  适合做本地上下文快照、检索和记忆整理
- `prompt-guard`
  适合群聊/机器人场景下的提示注入防护
- `topic-monitor`
  适合后续做主题监控和定时摘要
- `agent-development`
  适合后续定制和优化 agent 提示词/委派模式
- `context-recovery`
  适合会话压缩后恢复上下文
- `conventional-commits`
  适合统一 git commit message 规范
- `deepwiki`
  适合后续查询 GitHub 仓库文档；实际使用时依赖其 MCP 能力
- `hybrid-memory`
  适合补充本地记忆使用策略
- `project-management-skills`
  适合较长周期、多步骤项目管理
- `remember-all-prompts-daily`
  适合做会话归档与连续性保留
- `secret-scanner`
  适合扫代码库里的密钥、token、凭证泄露
- `skillguard`
  适合安装第三方 skill 前做安全审查
- `vestige`
  适合做更长期的本地记忆管理

检查技能状态：

```bash
openclaw skills list
openclaw skills check
```

## 如何排查常见问题

先运行：

```bash
./doctor.sh
```

常见结果：

- `Ollama 服务: 不可达`
  说明 Ollama 没启动，或本机 `Ollama.app` 没成功打开。
- `主模型 qwen3:14b: 未安装`
  先执行 `ollama pull qwen3:14b`。
- `OpenClaw 进程: 未检测到`
  首次安装请改用 `OPENCLAW_FOREGROUND=1 ./start_openclaw.sh` 查看官方引导。
- `本地搜索服务: 已安装但未运行`
  执行 `./start_local_search.sh`。
- 模型下载长期卡住、日志出现 `stalled` 或 `connection reset by peer`
  当前方案已经切到本机代理 `127.0.0.1:7890`。如果你之后再次手动拉模型，建议保留同样的代理环境。

## 如何切换到别的 Ollama 模型

在 `.env` 中覆盖：

```bash
OPENCLAW_MODEL=其他模型名
```

例如：

```bash
OPENCLAW_MODEL=qwen3:8b
```

切换前先确认该模型已经拉取完成。

## 如何验证免费联网已生效

1. 安装并启动本地搜索：

```bash
./install_local_search.sh
./start_local_search.sh
```

2. 直接测本地搜索 API：

```bash
curl "http://127.0.0.1:18080/search?q=openclaw&format=json"
```

3. 直接测 OpenClaw skill 附带的搜索脚本：

```bash
python3 ~/.openclaw/workspace/skills/local-web-search/scripts/search_local_web.py --query "OpenClaw latest release"
```

说明：

- 这条免费联网链路不依赖 Brave / Perplexity / Gemini 的搜索 API key
- 它不是 OpenClaw 官方内置 `web_search` provider，而是“本地搜索 + 本地 skill + `web_fetch`”
- `./sync_openclaw_workspace.sh` 会把仓库里的 `local-web-search` 和全局自动触发规则同步到 `~/.openclaw/workspace`
- 自动触发规则已经写入 OpenClaw workspace 的 `AGENTS.md` 和 `TOOLS.md`
- 对本机私用、只监听 `127.0.0.1` 的场景，这已经够用

## 如何在不连接聊天平台时先做本地测试

建议先完成下面两步：

1. `ollama run qwen3:14b "你好"`，确认本地模型本身能响应。
2. `OPENCLAW_FOREGROUND=1 ./start_openclaw.sh`，只完成 OpenClaw 与本地 Ollama 的连接，不继续授权任何聊天平台。

如果 OpenClaw 首次启动要求配置 provider，请优先选择本地 Ollama，地址用 `http://127.0.0.1:11434`，不要额外加 `/v1`。

## 哪些权限和风险需要特别注意

- 安装官方 Ollama App 时，macOS 可能要求后台运行、网络访问或登录项权限。
- 首次 `ollama launch openclaw` 时，可能会安装 npm 包和 gateway 组件。
- 如果后续接 Telegram / Slack / iMessage，需要账号登录、机器人 token、系统自动化权限或消息读取权限；这些都应在确认后再做。
- 本项目脚本默认不主动接入任何聊天平台，也不默认把 Ollama 注册成长期系统守护。
