#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "Run this installer as root: sudo ./install.sh" >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SERVICE_USER=pi-radio
CONTROL_GROUP=pi-radio

echo "Installing mpv and socat..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes mpv socat

echo "Creating the restricted radio service account..."
if ! getent group "$CONTROL_GROUP" >/dev/null 2>&1; then
    groupadd --system "$CONTROL_GROUP"
fi

if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
    useradd \
        --system \
        --gid "$CONTROL_GROUP" \
        --groups audio \
        --home-dir /nonexistent \
        --no-create-home \
        --shell /usr/sbin/nologin \
        "$SERVICE_USER"
else
    usermod --append --groups audio "$SERVICE_USER"
fi

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != root ] && id -u "$SUDO_USER" >/dev/null 2>&1; then
    case " $(id -nG "$SUDO_USER") " in
        *" $CONTROL_GROUP "*)
            ADDED_CONTROL_USER=
            ;;
        *)
            usermod --append --groups "$CONTROL_GROUP" "$SUDO_USER"
            ADDED_CONTROL_USER=$SUDO_USER
            ;;
    esac
else
    ADDED_CONTROL_USER=
fi

echo "Installing the radio command and service..."
install -m 0755 "$SCRIPT_DIR/radio" /usr/local/bin/radio
rm -f /usr/local/bin/radio-play /usr/local/bin/radio-stop /usr/local/bin/radio-volume
install -m 0644 "$SCRIPT_DIR/radio.service" /etc/systemd/system/radio.service

systemctl daemon-reload
systemctl enable radio.service
systemctl restart radio.service

echo "Radio installed."
if [ -n "$ADDED_CONTROL_USER" ]; then
    echo "Reconnect or log in again before running radio commands as $ADDED_CONTROL_USER."
fi
echo "Start listening with: radio play"
