#!/bin/sh

set -eu

if [ "$(uname -s)" != Darwin ]; then
    echo "This installer is for macOS. Use ./install.sh on Linux." >&2
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this installer without sudo: ./install-macos.sh" >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required: https://brew.sh" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BREW=$(command -v brew)
BIN_DIR=$("$BREW" --prefix)/bin
AGENT_DIR=$HOME/Library/LaunchAgents
STATE_DIR=$HOME/Library/Caches/pi-radio
AGENT_PATH=$AGENT_DIR/com.kingfink.pi-radio.plist
DOMAIN=gui/$(id -u)

if ! command -v mpv >/dev/null 2>&1; then
    "$BREW" install mpv
fi

mkdir -p "$BIN_DIR" "$AGENT_DIR" "$STATE_DIR"
chmod 0700 "$STATE_DIR"
install -m 0755 "$SCRIPT_DIR/radio" "$BIN_DIR/radio"
install -m 0644 "$SCRIPT_DIR/com.kingfink.pi-radio.plist" "$AGENT_PATH"

launchctl bootout "$DOMAIN" "$AGENT_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "$DOMAIN" "$AGENT_PATH"

echo "Radio installed. Start listening with: radio play"
