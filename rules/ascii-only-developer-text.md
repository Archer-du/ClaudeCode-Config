# Developer-facing text must be ASCII unless the project clearly uses non-ASCII

凡是写给开发者看的文本——源代码注释、标识符、日志输出 / `echo` / `print` / `console.log`、commit message、文件名 / 路径——一律 ASCII。这是默认规则，对新项目 / 空目录 / 仓库，无条件生效。

**例外**：当前工作目录的项目本身通常使用非 ASCII（中文 / 其他语言）才允许沿用。判定方式：取样既有代码注释与既有 commit history，看非 ASCII 占多数才认为是"该项目的惯例"。"现有事实"驱动，无需用户声明。

**不受约束**：用户可见的 UI 字符串、`.md` 文档 / README、聊天回复 / 对话文本。

## How to apply

写代码 / 写脚本 / 写 commit 前，自检三步：
1. **新项目 / 空目录** → 直接 ASCII，不查。
2. **既存项目** → 先快扫 1-2 个相关源文件的注释，或 `git log --oneline -20` 看 commit message。
   - 非 ASCII 占多数 → 沿用非 ASCII（与项目惯例一致）；
   - ASCII 占多数或目录无既有代码 → ASCII。
3. 不确定时默认 ASCII——成本最低，事后改也容易。

具体子项：
- 注释：`#` / `//` / `/* */` / `REM` 后的内容 ASCII；
- 标识符：变量 / 函数 / 文件名 / 路径 ASCII；
- 日志 / echo / print：脚本输出 ASCII（用 `->` 不用 `→`，用 `^` 不用 `↑`）；
- commit message：ASCII（除非 `git log` 显示该仓库一贯用非 ASCII）；
- 字符串字面量中"写给开发者看的"部分（debug log / error message）ASCII；用户可见的 UI 字符串不受约束。

## Why

2026-06-23 写 `~/.claude-internal/bootstrap.cmd` 时用了中文注释。文件存 UTF-8，但中文 Win 上 CMD 默认 GBK 936——按 GBK 读 UTF-8 字节流时，中文字符被错位解析，连带把后面的英文命令也搅烂。脚本在 `set "WRAPPER=..."` 那行被搅乱后变量未赋值，下游 `setx EDITOR "%WRAPPER%"` 退化成 `setx EDITOR ""`，直接把已配置的 EDITOR 清空。

这是 shell 脚本的 GBK 解码坑，但同型问题广泛存在：
- 非 ASCII 标识符在不同 locale / 编译器 / 工具链下解析不一致；
- 非 ASCII commit message 在 CI / mail / 老 git 客户端上经常乱码；
- 非 ASCII 日志在 grep / awk / 容器 stdout 管道里可能丢字节；
- 跨平台 / 跨编码协作时，UTF-8 vs GBK vs CP1252 的来回转换是事故温床。

ASCII-only 是最便宜的统一防御：放弃极少数表达便利，换来全链路工具兼容性。只有当项目惯例已经接受了非 ASCII 的代价时，才沿用。

相关：verify-parent-scope-before-writing-config.md, no-fabricated-identity-values.md
