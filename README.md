# pi-radio

A tiny CLI for playing Radio Woodstock on a Raspberry Pi, Linux machine, or Mac.

It uses `mpv` for playback. The first host was a Raspberry Pi because I had one available, but nothing here depends on Pi hardware.

## Install on Raspberry Pi or Linux

Designed for Raspberry Pi OS Lite. It should also work on Debian-based Linux systems using systemd.

```bash
git clone https://github.com/kingfink/pi-radio.git
cd pi-radio
sudo ./install-linux.sh
```

Reconnect after the first install so your new group membership takes effect. The installer is safe to rerun.

## Install on macOS

Install [Homebrew](https://brew.sh), then run:

```bash
git clone https://github.com/kingfink/pi-radio.git
cd pi-radio
./install-macos.sh
```

The macOS installer runs the player as a user LaunchAgent. It does not need `sudo`.

## Use

```bash
radio play
radio play woodstock
radio status
radio volume
radio volume 40
radio volume up
radio volume down
radio stations
radio stop
```

Volume starts at `50` and accepts `0` through `100`. `radio status` shows playback state, station, current song, and volume. The player waits silently after boot until `radio play` is called.

## Remote control

Use SSH directly or over Tailscale:

```bash
ssh pi@radio radio play
ssh pi@radio radio volume 35
ssh pi@radio radio status
ssh pi@radio radio stop
```

## Troubleshooting

Check or restart the service:

```bash
systemctl status radio
journalctl -u radio -n 50 --no-pager
sudo systemctl restart radio
```

On macOS:

```bash
launchctl kickstart -k gui/$(id -u)/com.kingfink.pi-radio
```

On Raspberry Pi OS, select the audio output with:

```bash
sudo raspi-config
```

On Linux, the service runs as an unprivileged `pi-radio` user and restricts its local control socket to the `pi-radio` group. On macOS, the LaunchAgent and socket run as your user.

This is an unofficial personal project and is not affiliated with Radio Woodstock or iHeart.

MIT licensed. See [LICENSE](LICENSE).
