# Headless Internet Radio

A minimal command-line controller for a headless internet-radio player. It currently plays one Radio Woodstock 100.1 WDST stream delivered by iHeart, using `mpv` for playback and `socat` to send commands over a local IPC socket.

The Raspberry Pi is the first host because there is one available to put to use, not because the player depends on Pi hardware. The same design can run on another Debian-based Linux machine with systemd and an audio output.

The service starts at boot and waits silently. Playback begins only when you run `radio-play`.

## How it fits together

```text
Radio Woodstock stream
          ↓
mpv playback service
          ↑
radio-play / radio-stop / radio-volume
          ↑
optional SSH, Tailscale, or web control plane
```

This is not a general iHeartRadio client yet: it does not search for stations, manage accounts, or resolve arbitrary iHeart URLs. It is a small player and CLI with one stream hard-coded for the initial use case.

## What is included

- One Radio Woodstock stream
- One systemd service
- Three commands: `radio-play`, `radio-stop`, and `radio-volume`
- One safe-to-rerun installer

There is no Docker, Python, database, web interface, or configuration framework.

## Install

The included installer targets Raspberry Pi OS Lite on a Raspberry Pi 4. It should also work on a Debian-based systemd Linux host with `apt`, an internet connection, and a working audio output.

Attach your speakers or audio adapter, then run:

```bash
git clone <your-repository-url> pi-radio
cd pi-radio
sudo ./install.sh
```

The installer:

1. Installs `mpv` and `socat`.
2. Creates an unprivileged `pi-radio` service account and control group.
3. Adds the user who invoked `sudo` to the control group.
4. Copies the three commands to `/usr/local/bin`.
5. Installs and enables the systemd service.
6. Restarts the service so rerunning the installer applies updates.

After the first installation, disconnect and reconnect your SSH session so the new group membership takes effect. The control socket is available only to members of the `pi-radio` group.

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

To authorize another local or SSH user to control the radio, add that user to the control group and have them log in again:

```bash
sudo usermod --append --groups pi-radio <username>
```

## Check the service

```bash
systemctl status radio
journalctl -u radio -n 50 --no-pager
```

Restart it if the control socket is missing:

```bash
sudo systemctl restart radio
```

The player runs as the dedicated, unprivileged `pi-radio` user. Its IPC socket is restricted to the `pi-radio` group; it is not a public network endpoint and should not be exposed directly through Tailscale Funnel or another proxy.

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

## Possible control plane

The three commands are the local control interface. SSH can expose them remotely today. Tailscale can provide private network access later, and a small site or API can sit on top as a friendlier control plane without changing the underlying player.

Other possible additions include station presets and discovery. They are intentionally outside the first version.
