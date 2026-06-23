# Shell 脚本只允许 ASCII 字符

写入任何会被 shell 解释器（`cmd.exe` / `bash` / `sh` / `powershell`）执行的脚本文件（`.cmd` / `.bat` / `.sh` / `.ps1` 等），禁止使用非 ASCII 字符——包括中文 / 全角符号 / emoji / 智能引号 / `→` 等。所有注释、echo 输出、变量名一律用纯英文 ASCII。

## How to apply

写脚本前自检：
1. 注释一律用英文（`REM` / `#`）；
2. echo 输出一律 ASCII（用 `->` 不用 `→`，用 `^` 不用 `↑`）；
3. 需要展示中文给用户看的内容，从脚本里拿出来，放到 README.md 或对话里说；
4. 文件本身保持 UTF-8 存盘（git / 编辑器默认即可），不要为了适配 CMD 转 GBK——那会让仓库跨平台同步时乱码。

## Why

2026-06-23 写 `~/.claude-internal/bootstrap.cmd` 时加了中文注释（"探测本机 Rider"等）。文件存 UTF-8，但中文 Windows 上 CMD 默认 OEM 代码页 GBK 936——CMD 按 GBK 读 UTF-8 字节流时，中文字符被错位解析，连带把后面的英文命令也搅乱（`'Windows' is not recognized`、`'M' is not recognized`、`'ho' is not recognized` 等大量噪声）。

更严重：脚本在 `set "WRAPPER=..."` 那行被噪声搅乱后变量未赋值，下游 `setx EDITOR "%WRAPPER%"` 退化成 `setx EDITOR ""`，直接把已配置的 EDITOR 清空——副作用比"脚本不跑"恶劣得多。

bash / sh / powershell 也有类似坑（系统 locale 与文件编码不一致时表现各异）。ASCII-only 是最便宜的统一防御。

## 例外

只有"用户可见的纯输出文档"（README.md / 行内文档）可以用中文。任何被 shell 当作可执行字节解释的文件，无例外。

相关：verify-parent-scope-before-writing-config.md, no-fabricated-identity-values.md
