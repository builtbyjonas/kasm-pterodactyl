# Kasm Workspaces for Pterodactyl

[![License](https://img.shields.io/github/license/builtbyjonas/kasm-pterodactyl.svg)](https://github.com/builtbyjonas/kasm-pterodactyl/blob/main/LICENSE)
[![GitHub Container Registry](https://img.shields.io/badge/ghcr.io-builtbyjonas%2Fkasm--pterodactyl-blue)](https://github.com/builtbyjonas/kasm-pterodactyl/pkgs/container/kasm-pterodactyl)

Run Kasm Workspaces inside Pterodactyl Panel. This repository contains the Dockerfile and the Pterodactyl Egg configuration required to deploy Kasm Workspaces as a server.

## Overview

Kasm Workspaces is a container streaming platform that allows you to deliver browser-based access to desktops, applications, and web services. By integrating it with Pterodactyl Panel, you can manage Kasm Workspaces deployments using Pterodactyl's familiar interface.

### Key Features
- **Dynamic Port Forwarding**: Automatically routes the dynamic TCP port allocated by Pterodactyl to Kasm's internal listeners. Zero configuration needed!
- **Auto-Password Synchronization**: Scans Pterodactyl's read-only startup variables and injects the Administrator and User credentials directly into Kasm's inner PostgreSQL layer upon initialization.
- **LinuxServer.io Foundations**: Wraps cleanly on top of `linuxserver/kasm` base images by hooking transparently into the `s6-overlay` lifecycle.

## Prerequisites

- A working Pterodactyl Panel (Wings and Panel)
- A node capable of running Docker containers

## Quick Start

1. Download the `egg.json` from the repository.
2. Go to your Pterodactyl admin area -> Nests.
3. Import the `egg.json`.
4. Create a new server using the newly imported egg.

For detailed instructions, refer to the documentation:

## Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration](docs/CONFIGURATION.md)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the terms found in the [LICENSE](LICENSE.md) file.
