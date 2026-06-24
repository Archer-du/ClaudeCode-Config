@echo off
REM ============================================================
REM  Claude Code Internal - Windows bootstrap
REM  Run once per machine after `git clone` / `git init` into a
REM  Claude config dir (e.g. ~/.claude-internal, ~/.tclaude).
REM  Purpose:
REM    1) Detect Rider install path (Program Files / Toolbox layouts)
REM    2) Generate <script-dir>\bin\code-wait.cmd containing
REM       "<rider>" --wait %*
REM    3) Persist EDITOR to user-level env var via setx
REM ============================================================

setlocal EnableDelayedExpansion

REM Anchor on the directory this script lives in. %~dp0 always ends with backslash.
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

set "RIDER_EXE="

REM --- 1) Standard install: C:\Program Files\JetBrains\JetBrains Rider <ver>\bin\rider64.exe ---
for /d %%D in ("%ProgramFiles%\JetBrains\JetBrains Rider*") do (
    if exist "%%D\bin\rider64.exe" set "RIDER_EXE=%%D\bin\rider64.exe"
)

REM --- 2) JetBrains Toolbox (new layout): %LOCALAPPDATA%\Programs\Rider\bin\rider64.exe ---
if not defined RIDER_EXE (
    if exist "%LOCALAPPDATA%\Programs\Rider\bin\rider64.exe" (
        set "RIDER_EXE=%LOCALAPPDATA%\Programs\Rider\bin\rider64.exe"
    )
)

REM --- 3) JetBrains Toolbox (old layout): %LOCALAPPDATA%\JetBrains\Toolbox\apps\Rider\ch-0\<ver>\bin\rider64.exe ---
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

REM --- Write wrapper ---
set "WRAPPER_DIR=%BASE_DIR%\bin"
set "WRAPPER=%WRAPPER_DIR%\code-wait.cmd"

if not exist "%WRAPPER_DIR%" mkdir "%WRAPPER_DIR%"

> "%WRAPPER%" echo @echo off
>> "%WRAPPER%" echo "!RIDER_EXE!" --wait %%*

echo [bootstrap] Wrote wrapper: %WRAPPER%

REM --- Set EDITOR ---
setx EDITOR "%WRAPPER%" > nul
if errorlevel 1 (
    echo [bootstrap] ERROR: setx EDITOR failed.
    exit /b 1
)

echo [bootstrap] Set EDITOR=%WRAPPER%
echo.
echo [bootstrap] DONE. Restart Claude Code for changes to take effect.
echo [bootstrap] Editor flow: edit -^> Ctrl+S -^> Ctrl+F4 (close tab) to release wait.

endlocal
