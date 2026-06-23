#!/usr/bin/env bash
# ============================================================
#  Claude Code Internal - macOS / Linux bootstrap
#  Run once per machine after `git clone` into ~/.claude-internal
#  Purpose:
#    1) Detect Rider install path (/Applications / JetBrains Toolbox)
#    2) Generate bin/code-wait.sh containing: exec "<rider>" --wait "$@"
#    3) Persist EDITOR to ~/.zshrc (or ~/.bash_profile)
# ============================================================

set -eu

RIDER_BIN=""

# --- 1) macOS standard install: /Applications/Rider.app ---
if [ -x "/Applications/Rider.app/Contents/MacOS/rider" ]; then
    RIDER_BIN="/Applications/Rider.app/Contents/MacOS/rider"
fi

# --- 2) JetBrains Toolbox (new layout): ~/Applications/JetBrains Toolbox/Rider.app ---
if [ -z "$RIDER_BIN" ] && [ -x "$HOME/Applications/JetBrains Toolbox/Rider.app/Contents/MacOS/rider" ]; then
    RIDER_BIN="$HOME/Applications/JetBrains Toolbox/Rider.app/Contents/MacOS/rider"
fi

# --- 3) JetBrains Toolbox (old layout): ~/Library/Application Support/JetBrains/Toolbox/apps/Rider/ch-0/<ver>/Rider.app ---
if [ -z "$RIDER_BIN" ]; then
    TOOLBOX_BASE="$HOME/Library/Application Support/JetBrains/Toolbox/apps/Rider/ch-0"
    if [ -d "$TOOLBOX_BASE" ]; then
        for VER_DIR in "$TOOLBOX_BASE"/*/; do
            CAND="$VER_DIR/Rider.app/Contents/MacOS/rider"
            if [ -x "$CAND" ]; then
                RIDER_BIN="$CAND"
            fi
        done
    fi
fi

# --- 4) Linux fallback: rider on PATH ---
if [ -z "$RIDER_BIN" ] && command -v rider >/dev/null 2>&1; then
    RIDER_BIN="$(command -v rider)"
fi

if [ -z "$RIDER_BIN" ]; then
    echo "[bootstrap] ERROR: Rider not found."
    echo "[bootstrap] Checked:"
    echo "  - /Applications/Rider.app"
    echo "  - ~/Applications/JetBrains Toolbox/Rider.app"
    echo "  - ~/Library/Application Support/JetBrains/Toolbox/apps/Rider/ch-0/*"
    echo "  - rider in PATH"
    exit 1
fi

echo "[bootstrap] Found Rider: $RIDER_BIN"

# --- Write wrapper ---
WRAPPER_DIR="$HOME/.claude-internal/bin"
WRAPPER="$WRAPPER_DIR/code-wait.sh"

mkdir -p "$WRAPPER_DIR"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec "$RIDER_BIN" --wait "\$@"
EOF
chmod +x "$WRAPPER"

echo "[bootstrap] Wrote wrapper: $WRAPPER"

# --- Persist EDITOR to shell rc ---
# Prefer zsh (macOS default); fall back to bash_profile
if [ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = "zsh" ]; then
    RC="$HOME/.zshrc"
else
    RC="$HOME/.bash_profile"
fi

LINE="export EDITOR=\"\$HOME/.claude-internal/bin/code-wait.sh\""

touch "$RC"
if grep -Fxq "$LINE" "$RC"; then
    echo "[bootstrap] EDITOR already set in $RC"
else
    {
        echo ""
        echo "# Added by claude-internal bootstrap"
        echo "$LINE"
    } >> "$RC"
    echo "[bootstrap] Appended EDITOR export to $RC"
fi

echo ""
echo "[bootstrap] DONE."
echo "[bootstrap] Run:  source \"$RC\"   (or open a new terminal) then restart Claude Code."
echo "[bootstrap] Editor flow: edit -> Cmd+S -> Cmd+W (close tab) to release wait."
