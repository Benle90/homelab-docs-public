## 🆕✨ NEW! I've created a template version with AI-assisted setup wizard: https://github.com/Benle90/homelab-docs-public-template/


# Homelab Documentation

**Location**: Home
**Purpose**: Recovery, rebuild, long-term maintainability

This repository documents my entire homelab setup with the assumption that **everything may need to be rebuilt from scratch**.

---

## Quick Navigation

### 📊 Current State & Planning
- [Current State](current-state.md) - What's deployed right now
- [Quick Reference](QUICK-REFERENCE.md) - IPs, credentials, key commands
- [Hardware Inventory](inventory.md) - All physical hardware
- [Architecture](architecture.md) - Design goals and server roles
- [Changelog](CHANGELOG.md) - All significant changes and decisions
- [Lessons Learned](LESSONS-LEARNED.md) - What worked, what didn't

### 🖥️ Servers
- [Infrastructure Server (Small)](servers/infra-server.md) - Proxmox, always-on services
- [Storage Server (Big)](servers/storage-server.md) - TrueNAS, storage & apps

### 🌐 Network
- [Network Architecture](network.md) - Topology, VLANs, routing

### 🔧 Services
- **[Services Overview](services.md)** - All running services
- [Home Assistant](services/home-assistant/home_assistant.md) - Smart home automation
  - [Automations (30 total)](services/home-assistant/ha_automations.md)
  - [Integrations](services/home-assistant/integrations.md)
  - [Scripts](services/home-assistant/scripts.md)
  - [Dashboards](services/home-assistant/dashboards.md)
  - [Config Files](services/home-assistant/configs/README.md)
- [DNS - AdGuard Home](services/dns-adguard.md)
- [Monitoring](services/monitoring.md) - Uptime Kuma, Healthchecks.io
- [Immich](services/immich.md) - Photo management
- [Nextcloud](services/nextcloud.md) - File sync

### 📋 Procedures
- [Migration Plan](procedures/migration-plan.md) - TrueNAS → Proxmox migration

### 🔄 Recovery
- [Recovery Overview](recovery/backups.md) - Backup layers at a glance
- [Backup Strategy](recovery/backup-strategy.md) - Proxmox, TrueNAS, offsite backups
- [Disaster Recovery](recovery/disaster-recovery.md) - Full rebuild procedures
- [Proxmox Backup & Restore](recovery/proxmox-backup-restore.md)
- [TrueNAS Backup & Restore](recovery/truenas-backup-restore.md)

---

## Documentation Goals

- **Recovery-grade**: Sufficient to rebuild everything from scratch
- **Decision tracking**: Why things are done this way
- **Living document**: Updated as the homelab evolves
- **Version controlled**: All changes tracked in git

---

## Goal Architecture

> ⚠️ **Note:** This shows the target state. See [current-state.md](current-state.md) for what's actually running today.

```
┌─────────────────────────────────┐
│ Proxmox (Small - Always On)    │
│  ├─ Home Assistant VM           │
│  ├─ DNS (AdGuard)              │
│  └─ Core Infrastructure         │
└─────────────────────────────────┘
                ↕
┌─────────────────────────────────┐
│ TrueNAS (Big - On-Demand)       │
│  ├─ Storage (ZFS)               │
│  ├─ Immich, Nextcloud           │
│  └─ Backups                     │
└─────────────────────────────────┘
```

---

