@echo off
REM ============================================================
REM  Claude Code Internal — Windows bootstrap
REM  Run once per machine after `git clone` into ~/.claude-internal
REM  作用:
REM    1) 探测本机 Rider 安装路径(支持 Program Files / Toolbox)
REM    2) 生成 bin\code-wait.cmd, 内容是 "<rider>" --wait %*
REM    3) 把 EDITOR 持久化到用户级环境变量(setx)
REM ============================================================

setlocal EnableDelayedExpansion

set "RIDER_EXE="

REM ---- 1) 常规安装位置: C:\Program Files\JetBrains\JetBrains Rider <ver>\bin\rider64.exe ----
for /d %%D in ("%ProgramFiles%\JetBrains\JetBrains Rider*") do (
    if exist "%%D\bin\rider64.exe" set "RIDER_EXE=%%D\bin\rider64.exe"
)

REM ---- 2) JetBrains Toolbox: %LOCALAPPDATA%\Programs\Rider\bin\rider64.exe (新 Toolbox 默认布局) ----
if not defined RIDER_EXE (
    if exist "%LOCALAPPDATA%\Programs\Rider\bin\rider64.exe" (
        set "RIDER_EXE=%LOCALAPPDATA%\Programs\Rider\bin\rider64.exe"
    )
)

REM ---- 3) JetBrains Toolbox: %LOCALAPPDATA%\JetBrains\Toolbox\apps\Rider\ch-0\<ver>\bin\rider64.exe (旧布局) ----
if not defined RIDER_EXE (
    for /d %%D in ("%LOCALAPPDATA%\JetBrains\Toolbox\apps\Rider\ch-0\*") do (
        if exist "%%D\bin\rider64.exe" set "RIDER_EXE=%%D\bin\rider64.exe"
    )
)

if not defined RIDER_EXE (
    echo [bootstrap] ERROR: Rider not found.
    echo [bootstrap] Checked:
    echo   - %ProgramFiles%\JetBrains\JetBrains Rider*
    echo   - %LOCALAPPDATA%\Programs\Rider
    echo   - %LOCALAPPDATA%\JetBrains\Toolbox\apps\Rider\ch-0\*
    exit /b 1
)

echo [bootstrap] Found Rider: !RIDER_EXE!

REM ---- 写 wrapper ----
set "WRAPPER_DIR=%USERPROFILE%\.claude-internal\bin"
set "WRAPPER=%WRAPPER_DIR%\code-wait.cmd"

if not exist "%WRAPPER_DIR%" mkdir "%WRAPPER_DIR%"

> "%WRAPPER%" echo @echo off
>> "%WRAPPER%" echo "!RIDER_EXE!" --wait %%*

echo [bootstrap] Wrote wrapper: %WRAPPER%

REM ---- 设置 EDITOR ----
setx EDITOR "%WRAPPER%" > nul
if errorlevel 1 (
    echo [bootstrap] ERROR: setx EDITOR failed.
    exit /b 1
)

echo [bootstrap] Set EDITOR=%WRAPPER%
echo.
echo [bootstrap] DONE. Restart Claude Code for changes to take effect.
echo [bootstrap] In editor flow: edit -^> Ctrl+S -^> Ctrl+F4 (close tab) to release wait.

endlocal
