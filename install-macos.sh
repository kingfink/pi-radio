#!/bin/sh

set -eu

if [ "$(uname -s)" != Darwin ]; then
    echo "This installer is for macOS. Use ./install-linux.sh on Linux." >&2
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this installer without sudo: ./install-macos.sh" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ARCH=$(uname -m)

if [ "$ARCH" = arm64 ] && [ -x /opt/homebrew/bin/brew ]; then
    BREW=/opt/homebrew/bin/brew
elif command -v brew >/dev/null 2>&1; then
    BREW=$(command -v brew)
else
    echo "Homebrew is required: https://brew.sh" >&2
    exit 1
fi

BREW_PREFIX=$("$BREW" --prefix)

if [ "$ARCH" = arm64 ] && [ "$BREW_PREFIX" = /usr/local ]; then
    echo "Native Apple Silicon Homebrew is required: https://brew.sh" >&2
    exit 1
fi

BIN_DIR=$BREW_PREFIX/bin
MPV=$BIN_DIR/mpv
AGENT_DIR=$HOME/Library/LaunchAgents
STATE_DIR=$HOME/Library/Caches/pi-radio
AGENT_PATH=$AGENT_DIR/com.kingfink.pi-radio.plist
DOMAIN=gui/$(id -u)

echo "Using Homebrew: $BREW"

if [ ! -x "$MPV" ]; then
    "$BREW" install mpv
fi

mkdir -p "$BIN_DIR" "$AGENT_DIR" "$STATE_DIR"
chmod 0700 "$STATE_DIR"
install -m 0755 "$SCRIPT_DIR/radio" "$BIN_DIR/radio"
install -m 0644 "$SCRIPT_DIR/com.kingfink.pi-radio.plist" "$AGENT_PATH"

launchctl bootout "$DOMAIN" "$AGENT_PATH" >/dev/null 2>&1 || true
launchctl bootstrap "$DOMAIN" "$AGENT_PATH"

case ":$PATH:" in
    *":$BIN_DIR:"*) RADIO_COMMAND=radio ;;
    *) RADIO_COMMAND=$BIN_DIR/radio ;;
esac

echo "Radio installed. Start listening with: $RADIO_COMMAND play"
