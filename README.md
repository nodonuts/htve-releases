# HTVE Releases

Public, versioned **upstream-only** installer packages for HTVE Platform.

> **Status:** Pre-release testing. No public installation package has been published yet. Do not use this repository as an installation source until a verified release and its checksum are available.

## What the installer targets

- Debian 13 (amd64)
- Official FastChannels and AH4C container images
- DirecTV Stream with an account provided by the installer operator
- An operator-supplied Fire TV / Android TV tuner, ADB connection, and HDMI encoder stream
- Optional integration with an existing Channels DVR server, configured during setup

The installer asks for host addresses, ports, and hardware assignments. No private network addresses or credentials are bundled. It requires explicit tuner-hardware authorization.

## Planned distribution

Each pre-release or release will include a versioned `.tar.gz` installer archive and published SHA-256 checksum. A small bootstrap script will fetch and verify the pinned archive before starting the interactive installer.

Downloading a public release will **not require a GitHub account**.

## Important limitations

Provider authentication, channel approval, and initial FastChannels bridge setup still require web UI interaction. Automated upgrades, full rollback, and recovery of partially created containers are not yet implemented.

Keep FastChannels and AH4C ports on trusted networks; **do not expose them directly to the public internet**. Never assign a tuner already controlled by another server.

This repository holds **distribution artifacts only**; it is not a mirror of the private development repository or its JDG-specific overlays.
