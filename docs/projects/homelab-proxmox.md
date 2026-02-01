# Homelab – Proxmox Project

## Purpose
Dedicated project focused on virtualization, learning, and infrastructure separation.

## Goals
- Learn Proxmox VE deeply
- Separate infra from storage
- Run services in VMs or Docker hosts
- Make everything modular and replaceable

## Design Decisions

### Why Proxmox
- Clear separation between host and workloads
- Easy VM backup/restore
- Flexible networking
- Future clustering support

## Current Layout
- Proxmox host on Infrastructure Server
- One or more VMs:
  - Docker host
  - Home Assistant
  - Monitoring stack

## Philosophy
Proxmox is infrastructure, not a service host.
VMs are disposable.
Configuration lives in documentation.

