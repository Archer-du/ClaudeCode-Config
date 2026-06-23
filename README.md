# ClaudeCode-Config

跨设备共享的 Claude Code 用户级配置（CLAUDE.md / memory / skills / commands / settings）。

仓库挂载点：`~/.claude-internal/`（Win 上是 `%USERPROFILE%\.claude-internal\`）。

## 首次安装（新设备）

```bash
# 1. 克隆到用户级目录
cd ~          # Win: cd %USERPROFILE%
git clone git@github.com:Archer-du/ClaudeCode-Config.git .claude-internal

# 2. 跑本机 bootstrap（探测 Rider + 设置 $EDITOR）
# macOS:
bash ~/.claude-internal/bootstrap.sh
source ~/.zshrc

# Windows (cmd):
%USERPROFILE%\.claude-internal\bootstrap.cmd

# 3. 重启 Claude Code
```

## 日常同步流程

**A 设备改了 memory → push**（Claude 自动写入 `MEMORY.md` / `memory/`，会话结束后手动 push）：
```bash
cd ~/.claude-internal
git status                                  # 看哪些变了
git add CLAUDE.md MEMORY.md memory/ skills/ commands/ agents/ settings.json
git commit -m "memory: <一句话>"
git push
```

**B 设备开工前 → pull**：
```bash
cd ~/.claude-internal
git pull --ff-only                          # 拉不下来就立刻停下手动处理
# 然后启动 Claude Code
```

## 冲突处理

- `MEMORY.md` 是无序索引，冲突时两边条目都保留即可
- `memory/*.md` 新增文件不冲突；同一 entry 两边都改才会冲突，手动 merge
- 实在解不开：`git stash` → `git pull --rebase` → `git stash pop`

## 纪律

- **不要两台机器同时跑 Claude Code 会话**（最便宜的去冲突策略）
- 切换设备前后做 "A push → B pull" 握手
- memory 修改后及时 push，别累积太久

## 不入仓库的东西（已在 .gitignore）

- `config.json` — **含 OAuth token**
- `.claude.json*` — 会话状态
- `projects/` — 项目级 memory（路径哈希因机不同，跨机无用）
- `bin/` — 本机生成的 editor wrapper（每台机器路径不同）
- `sessions/` `runtime/` `shell-snapshots/` `paste-cache/` 等运行时缓存
- `history.jsonl` `proxy.log` 等本机日志
- `plugins/` 内部数据；**仅保留** `plugins/known_marketplaces.json`

## Rider 编辑器流程

`/memory` / `Ctrl+G` 会通过 wrapper 拉起 Rider：
- 编辑临时 `.md` 文件 → **Ctrl+S 保存**
- **关闭那个 tab**（Win: Ctrl+F4 / mac: Cmd+W）→ `--wait` 进程退出 → prompt 回流
- 只关 tab 即可，不必关整个 Rider 主窗口
