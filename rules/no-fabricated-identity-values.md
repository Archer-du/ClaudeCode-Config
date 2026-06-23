# Never fabricate identity / credential values

身份类、凭据类、显示名类字段（`user.name` / `user.email` / author / committer / username / token / display name），如果当前无法从用户消息或上下文中拿到正确值，禁止编造占位符让命令通过。必须停下来询问用户，或先 `--get` 父层确认。

## How to apply

需要填身份 / 凭据 / 显示值、当前不知道真值时：
1. 先 `--get` 父层（global / user-level）是否已配；
2. 父层无值 → 直接问用户，不允许造占位符；
3. 哪怕"反正后面会改"，对身份类字段也禁用——commit hash / push 一旦发生，痕迹就留下了。

## Why

2026-06-23 初始化 git 仓库时，编造 `einsdu / einsdu@local` 作为 commit 身份——尽管用户消息里早已给出 GitHub 账号 `Archer-du`。这些字段一旦写入 commit 对象 / 远程平台，不可改或需 `--amend` / force push 撤销，传播代价极高。

相关：verify-parent-scope-before-writing-config.md
