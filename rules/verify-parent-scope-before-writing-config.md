# Verify parent scope before writing config

写入任何带继承层级 / 作用域的配置之前，必须先读父层当前值，再决定是否在子层写入。命令报错"缺某字段"≠"需要在当前层补"——可能父层早已有值，子层覆写反而持续污染。

适用范围（不完整列举）：
- `git config <key> <value>`（仓库级写入前先 `git config --global --get <key>`）
- `setx VAR VALUE` / 写 `~/.zshrc` `export VAR=...`（先 `echo %VAR%` / `echo $VAR`）
- 任何 settings.json / .ini / CSS 等 cascade 系统

## How to apply

看到"命令缺 X"的报错，第一反应是"X 在祖先层是否已定义"，不是"在当前层填 X"。先调只读的 `--get` / `echo` / `cat` 验证，再决定是否写入。代价不到 1 秒。

## Why

2026-06-23 初始化 `~/.claude-internal` 为 git 仓库时，遇 `git commit` 缺 `user.email/name`，反射性地用 `git config user.email "einsdu@local"` 写到仓库级配置——但用户全局早已配 `Archer-du <dupengche@gmail.com>`，子层覆写将持续污染该仓库所有提交身份。

相关：no-fabricated-identity-values.md
