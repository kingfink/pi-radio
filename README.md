# Raspberry Pi Internet Radio

A minimal internet radio for Raspberry Pi OS Lite on a Raspberry Pi 4. It plays Radio Woodstock 100.1 WDST through `mpv`, controlled through a local IPC socket with `socat`.

The service starts at boot and waits silently. Playback begins only when you run `radio-play`.

## What is included

- One Radio Woodstock stream
- One systemd service
- Three commands: `radio-play`, `radio-stop`, and `radio-volume`
- One safe-to-rerun installer

There is no Docker, Python, database, web interface, or configuration framework.

## Install

Start with a Raspberry Pi 4 running Raspberry Pi OS Lite and connected to the internet. Attach your speakers or audio adapter, then run:

```bash
git clone <your-repository-url> pi-radio
cd pi-radio
sudo ./install.sh
```

The installer:

1. Installs `mpv` and `socat`.
2. Copies the three commands to `/usr/local/bin`.
3. Installs and enables the systemd service.
4. Restarts the service so rerunning the installer applies updates.

It is safe to rerun after updating the files:

```bash
git pull
sudo ./install.sh
```

## Use

```bash
radio-play
radio-volume 40
radio-stop
```

Volume accepts a whole number from `0` to `100`. The service starts at volume `40` after a boot or restart.

The radio does not automatically play at boot. The service only starts the idle player so it is ready for commands.

## Control it over SSH

Replace `radio` with the Raspberry Pi hostname or IP address, and replace `pi` with your Raspberry Pi username if needed:

```bash
ssh pi@radio radio-play
ssh pi@radio radio-volume 35
ssh pi@radio radio-stop
```

SSH keys make these commands convenient without repeated password prompts.

## Check the service

```bash
systemctl status radio
journalctl -u radio -n 50 --no-pager
```

Restart it if the control socket is missing:

```bash
sudo systemctl restart radio
```

## Troubleshoot audio output

First confirm that Linux can see the audio devices:

```bash
aplay -l
```

On Raspberry Pi OS, use `raspi-config` to select the output when more than one is available:

```bash
sudo raspi-config
```

Look under **System Options** or **Audio**, depending on the Raspberry Pi OS version, and choose HDMI, the analog/headphone output, or your USB audio device.

You can also test the stream outside the service:

```bash
sudo systemctl stop radio
mpv --no-video https://stream.revma.ihrhls.com/zc7332
sudo systemctl start radio
```

If that command plays through the wrong device, list `mpv` audio outputs:

```bash
mpv --audio-device=help
```

Then add the selected device to the `ExecStart` line in `/etc/systemd/system/radio.service`, for example:

```text
--audio-device=alsa/sysdefault:CARD=Headphones
```

Apply the change:

```bash
sudo systemctl daemon-reload
sudo systemctl restart radio
```

To keep a custom audio-device change across future installer runs, make the same edit in this repository's `radio.service` file before rerunning `install.sh`.

## Later additions

Tailscale remote access, station presets, and a small web interface can be added later without changing the basic player-and-IPC design.
