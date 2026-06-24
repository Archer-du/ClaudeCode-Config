# ClaudeCode-Config

跨设备 / 跨发行版共享的 Claude Code 用户级配置（CLAUDE.md / rules / settings.json / skills / commands）。

支持的挂载点（任选其一）：
- `~/.claude-internal/`（CodeBuddy / Claude Code Internal 早期发行版）
- `~/.tclaude/`（Claude Code Internal 后续替代发行版）
- 其他 Claude Code 内部发行版的同结构目录

bootstrap 脚本基于自身所在目录定位 wrapper，不再硬编码挂载点。

## 首次安装（新设备 / 新发行版）

### 方式 A：空目录直接 clone

```bash
cd ~
git clone git@github.com:Archer-du/ClaudeCode-Config.git .claude-internal   # 或 .tclaude
```

### 方式 B：已有非空目录（如 .tclaude 已被发行版初始化）

```bash
cd ~/.tclaude
git init
git remote add origin git@github.com:Archer-du/ClaudeCode-Config.git
git fetch origin
git checkout -t origin/main
# 仓库里的 CLAUDE.md / rules / bootstrap.* 会落到当前目录
# 本地的 daemon.json / cache/ 等已在 .gitignore 中，不会被覆盖
```

### 跑 bootstrap（每个发行版各跑一次）

```bash
# macOS:
bash ~/.tclaude/bootstrap.sh
source ~/.zshrc

# Windows (cmd):
%USERPROFILE%\.tclaude\bootstrap.cmd
```

bootstrap 会把 `<挂载点>/bin/code-wait.*` 设为 `$EDITOR`。最后跑的一次决定当前 EDITOR 指向哪个发行版。

## 日常同步流程

**A 设备改了 rules / settings → push**：
```bash
cd ~/.tclaude
git status
git add CLAUDE.md rules/ settings.json skills/ commands/ agents/
git commit -m "config: <one line>"
git push
```

**B 设备开工前 → pull**：
```bash
cd ~/.tclaude
git pull --ff-only
```

## 冲突处理

- `rules/*.md` 新增文件不冲突；同一文件两边都改才会冲突，手动 merge
- `settings.json` 两边都改时手动 merge（注意：各发行版的 settings schema 可能不同，合并时别把对方发行版不认识的字段塞进来）
- 实在解不开：`git stash` → `git pull --rebase` → `git stash pop`

## 纪律

- **不要两台机器同时跑 Claude Code 会话**（最便宜的去冲突策略）
- 切换设备前后做 "A push → B pull" 握手
- 配置修改后及时 push，别累积太久

## 不入仓库的东西（已在 .gitignore）

- `config.json` — **含 OAuth token**
- `.claude.json*` — 会话状态
- `projects/` — 项目级 auto memory（官方位置 `~/.claude/projects/<project>/memory/`，machine-local，路径哈希因机而异，跨机无意义）
- `bin/` — 本机生成的 editor wrapper（每台机器路径不同）
- `sessions/` `runtime/` `cache/` `logs/` `locks/` `shell-snapshots/` `paste-cache/` 等运行时
- `daemon.json` `daemon.port` — 各发行版守护进程本地状态
- `history.jsonl` `proxy.log` 等本机日志
- `plugins/` — 含本机绝对路径，按官方文档不应共享

## Rider 编辑器流程

`/memory` / `Ctrl+G` 会通过 wrapper 拉起 Rider：
- 编辑临时 `.md` 文件 → **Ctrl+S 保存**
- **关闭那个 tab**（Win: Ctrl+F4 / mac: Cmd+W）→ `--wait` 进程退出 → prompt 回流
- 只关 tab 即可，不必关整个 Rider 主窗口
