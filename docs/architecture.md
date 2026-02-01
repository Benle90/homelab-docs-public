# Architecture Overview

## Design Goals
- Separation of infrastructure and data
- Minimal power usage
- No inbound ports exposed
- Secure remote access
- Easy recovery and migration

## Server Roles

### Infrastructure Server (Always-On)
- Proxmox VE
- DNS
- Monitoring
- Automation
- Access layer

### Storage Server (On-Demand)
- TrueNAS SCALE
- ZFS storage
- Stateful applications (Immich, Nextcloud)

## Logical Architecture

- Infrastructure server is the control plane
- Storage server holds all persistent data
- Infrastructure server can operate independently
- Storage server can be shut down without breaking core services

