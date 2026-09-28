# pi-radio

A tiny CLI for playing Radio Woodstock on a headless Linux machine.

It uses `mpv` for playback and three commands for control. The first host is a Raspberry Pi because I had one available, but nothing here depends on Pi hardware.

## Install

Designed for Raspberry Pi OS Lite. It should also work on Debian-based Linux systems using systemd.

```bash
git clone https://github.com/kingfink/pi-radio.git
cd pi-radio
sudo ./install.sh
```

Reconnect after the first install so your new group membership takes effect. The installer is safe to rerun.

## Use

```bash
radio-play
radio-volume 40
radio-stop
```

Volume accepts `0` through `100`. The player waits silently after boot until `radio-play` is called.

## Remote control

Use SSH directly or over Tailscale:

```bash
ssh pi@radio radio-play
ssh pi@radio radio-volume 35
ssh pi@radio radio-stop
```

## Troubleshooting

Check or restart the service:

```bash
systemctl status radio
journalctl -u radio -n 50 --no-pager
sudo systemctl restart radio
```

If sound comes from the wrong output, select the correct device with:

```bash
sudo raspi-config
```

The service runs as an unprivileged `pi-radio` user. Its local control socket is available only to members of the `pi-radio` group.

This is an unofficial personal project and is not affiliated with Radio Woodstock or iHeart.

MIT licensed. See [LICENSE](LICENSE).
