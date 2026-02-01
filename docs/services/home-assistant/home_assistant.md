# Home Assistant – Architecture & Project Documentation

## 1. Overview
This document describes the **Home Assistant (HA)** setup as part of the wider homelab environment. It is intended as **recovery‑grade documentation**: after a reinstall, hardware failure, or migration, this file should be sufficient to rebuild the system with the same architecture, logic, and design decisions.

The guiding principles of this project are:
- **Local‑first & self‑hosted** (no cloud dependency for core automations)
- **High reliability** (UPS‑aware, monitored, observable)
- **Security by design** (segmented access, minimal exposure)
- **Recoverability** (clear separation of infra vs services)
- **Family‑friendly automation** (lights, notifications, presence, safety)

---

## 2. Runtime Environment

### 2.1 Host Platform
- **Hypervisor**: Proxmox VE
- **HA Deployment**: Home Assistant OS (dedicated VM)
- **Rationale**:
  - Full HA Supervisor support
  - Snapshots at VM level
  - Clean separation from other services (AdGuard, Uptime Kuma, Docker, etc.)
  - Easy restore / migration to new hardware

### 2.2 VM Characteristics (Logical)
- Single‑purpose VM: **only Home Assistant**
- No additional services or containers inside HA VM
- Networking via Proxmox bridge (LAN)

---

## 3. Network & Access Model

### 3.1 Access Paths
Home Assistant is **not directly exposed to the public internet**.

**Access methods**:
1. **LAN access**
   - Used inside the home network
2. **Tailscale**
   - Primary remote access method
   - Used by mobile devices and admin access
   - HA Companion App configured to always use internal/Tailscale IP
3. **Cloudflare Tunnel (limited use)**
   - Optional browser access
   - Protected by Cloudflare Zero Trust (2FA)
   - Used sparingly due to daily re‑authentication friction

### 3.2 DNS & Naming
- Internal DNS handled by **AdGuard Home**
- Local hostname resolution (e.g. `homeassistant.lan`)
- Router fallback DNS remains enabled

---

## 4. Radio & Device Integration

### 4.1 Zigbee / Thread
- **Coordinator**: Nabu Casa ZBT‑2 (USB)
- Connected to HA VM host
- Used for:
  - Aqara sensors (motion, vibration, door/window)
  - IKEA Tradfri bulbs
  - Misc Zigbee end devices

Design notes:
- Zigbee mesh powered by always‑on mains devices
- Battery sensors kept simple and event‑based

### 4.2 Matter / Apple Home
- Some IKEA devices operate via Matter
- Home Assistant acts as the **single source of truth**
- Apple Home is treated as a *consumer UI*, not a controller

---

## 5. Scope Boundary

This document intentionally **does not contain detailed automation logic**.

All concrete automations (triggers, conditions, helpers, YAML patterns, and design decisions) are documented separately in:

➡ **`automations.md`**

This separation keeps infrastructure/architecture concerns cleanly isolated from behavior and logic.

---

## 6. Dashboards & UI

### 6.1 Dashboards
- Multiple dashboards
- Visibility controlled per HA user
- Family-friendly views for daily use
- Admin dashboards for debugging and testing

### 6.2 Controls
- Buttons for:
  - Alarm arm/disarm
  - Bedtime routines
- Sensors grouped logically (rooms, functions)

---

## 7. Infrastructure Awareness

### 7.1 UPS Integration
- UPS monitored outside HA (TrueNAS / NUT)
- HA receives status via sensors

Used for:
- Notifications only (currently)
- Future:
  - Coordinated shutdown logic
  - Cross-server awareness (small vs big server)

---

## 8. Observability & Reliability

- HA startup notifications enabled
- Integration with wider monitoring stack:
  - Uptime Kuma
  - Healthchecks.io (via infra VMs)

HA itself is treated as a **core dependency**, not just a convenience service.

---

## 9. Backup & Recovery Strategy

- VM-level snapshots via Proxmox
- HA internal backups
- External backup handled by homelab backup strategy (ZFS + offsite)

Recovery assumption:
> If Proxmox is restored, HA can be fully recovered from VM backup without re-pairing devices.

---

## 10. Design Decisions Summary

| Area | Decision | Reason |
|-----|---------|--------|
| Deployment | HA OS in VM | Stability, snapshots, supervisor |
| Access | Tailscale-first | Secure, friction-free |
| Cloud | Optional only | Avoid dependency |
| Automations | Separated | Clarity, recovery, maintainability |
| Security | Helper-based alarm | Safe iteration |
| UI | Intent buttons | Family usability |

---

## 11. Future Improvements

- Activate physical siren once logic is fully validated
- Improve presence accuracy (ensure all family devices registered)
- Deeper UPS-driven automation (graceful shutdowns)
- More Matter-native devices
- Shared family dashboards on wall tablets

---

**Status**: Actively evolving, production-used daily
