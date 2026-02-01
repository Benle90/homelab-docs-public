# Services Overview

This section documents all services running in the homelab.

## Core Services

### [Home Assistant](services/home-assistant/home_assistant.md)
**Purpose**: Home automation and smart home control

**Status**: Active (Production)

**Location**: Proxmox VM (Home Assistant OS)

**Documentation**:
- [Architecture & Overview](services/home-assistant/home_assistant.md)
- [Automations](services/home-assistant/ha_automations.md)
- [Scripts](services/home-assistant/scripts.md)
- [Integrations](services/home-assistant/integrations.md)
- [Dashboards](services/home-assistant/dashboards.md)
- [Config Files](services/home-assistant/configs/README.md)

---

### [DNS - AdGuard Home](services/dns-adguard.md)
**Purpose**: Network-wide ad blocking and DNS management

**Status**: Active (Production)

**Location**: Currently on TrueNAS (planned migration to Proxmox)

---

### [Monitoring](services/monitoring.md)
**Purpose**: System monitoring and observability

**Status**: Active (Production)

**Components**:
- Uptime Kuma
- Healthchecks.io

---

## Media & Storage Services

### [Immich](services/immich.md)
**Purpose**: Photo and video management (Google Photos alternative)

**Status**: Active (Production)

**Location**: TrueNAS (Docker)

---

### [Nextcloud](services/nextcloud.md)
**Purpose**: File sync and collaboration platform

**Status**: Active (Production)

**Location**: TrueNAS (Docker)

---

## Service Architecture

```
┌─────────────────────────────────────────────────────┐
│ Proxmox (Small Server - Always On)                 │
│  ├─ Home Assistant VM (HA OS)                      │
│  ├─ AdGuard Home (Planned)                         │
│  └─ Infrastructure Services                        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ TrueNAS (Big Server - On-Demand)                   │
│  ├─ Immich (Docker)                                │
│  ├─ Nextcloud (Docker)                             │
│  ├─ AdGuard Home (Current - To Be Migrated)        │
│  └─ Storage Services                               │
└─────────────────────────────────────────────────────┘
```

## Service Status Legend

- **Active (Production)**: Running and actively used
- **Planned**: Not yet deployed
- **Deprecated**: To be removed or replaced
- **Maintenance**: Temporarily offline

---

**Last Updated**: 2026-01-30
