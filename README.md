# HTVE Platform Releases

Public, upstream-only installers for HTVE Platform.

Latest prerelease: v0.2.0-rc3

## Requirements

- Fresh Debian 13 amd64 installation
- Root shell
- Fire TV or Android TV device with ADB enabled
- Compatible HDMI encoder
- DirecTV Stream subscription
- Channels DVR server
- Trusted local network

## Installation

Run these commands as root.

Install curl if needed:

    apt-get update
    apt-get install -y curl

Download the public installer:

    curl -fsSL https://raw.githubusercontent.com/nodonuts/htve-releases/main/install.sh -o htve-install.sh

Verify the download:

    bash htve-install.sh --verify

Start installation:

    bash htve-install.sh --install

The installer verifies the release checksum before installation.

## What gets installed

- Docker Engine and Compose
- FastChannels v5.5.1
- AH4C 2026.09.30
- Automatic AH4C tuning scripts

The guided installer collects server addresses, tuner assignments,
encoder URLs, and protected hardware information.

## After installation

Configure DirecTV authentication in FastChannels.
Run channel discovery and Stream Audit.
Enable Bridge mode, hardware capture, and ah4c Capture.
Authorize your Fire TV devices and update FastChannels Player.
Verify playback before adding feeds to Channels DVR.

## Important limitations

This is prerelease software.
Provider authentication and bridge configuration are interactive.
Automated platform upgrades and full recovery are not yet implemented.
Do not expose application or ADB ports directly to the Internet.
Do not assign devices already controlled by another installation.

Earlier prereleases remain available under GitHub Releases.
