# Current State Documentation

**Last Updated:** 2026-01-29  
**Status:** Pre-migration baseline

This document describes what is **actually running today**, before any migration to the goal architecture described in the other documentation files.

---

## Infrastructure Overview

### Storage Server (truenas)
**Status:** Running almost everything (not aligned with goal state)

**Hostname:** `truenas`  
**IP Address:** 192.168.178.10  

**Hardware:**
- CPU: Intel Core i5-9600K
- RAM: 32 GB DDR4-3200
- Storage: 500 GB SSD + 2×4 TB Seagate IronWolf (ZFS mirror)
- OS: TrueNAS SCALE Community Edition

**Services Currently Running:**
- **AdGuard Home** - Primary DNS for network
  - URL: http://192.168.178.10:30004/
- **Home Assistant OS** - Daily use, automations active
  - URL: http://homeassistant.local:8123/
- **Immich** - Photo library
  - URL: http://192.168.178.10:30041/
- **Nextcloud** - File sync, calendar, contacts
  - URL: http://192.168.178.10:30027/
- **Uptime Kuma** - Monitoring (duplicate)
  - URL: http://192.168.178.10:31050
- **Cloudflared** - Cloudflare Tunnel (no web interface)
- **Tailscaled** - Tailscale VPN (no web interface)
- **Jellyfin** - Media server (port not specified)
- **Collabora** - Document editing (not yet configured)
- **Crafty 4** - Minecraft server (HDD too slow, performance issues)
  - URL: https://192.168.178.10:8443/
- **PeaNUT** - UPS monitoring
  - URL: http://192.168.178.10:30224/
- **Scrutiny** - Drive health monitoring
  - URL: http://192.168.178.10:31054/

---

### Infrastructure Server (pve1)
**Status:** Mostly idle (not aligned with goal state)

**Hostname:** `pve1`  
**IP Address:** 192.168.178.11  

**Hardware:**
- Model: Fujitsu ESPRIMO Q958
- CPU: Intel i3-9100T
- RAM: 8 GB
- Storage: 128 GB SSD
- OS: Proxmox VE

**Current VMs:**
1. **infra100** (VM ID: 100) - Ubuntu Server (IP: 192.168.178.12)
   - **Docker** - Container runtime
   - **Portainer** - Docker management UI
     - URL: http://192.168.178.12:9000
   - **Uptime Kuma** - Monitoring (duplicate of TrueNAS instance)
     - URL: http://192.168.178.12:3001/dashboard

**Notes:**
- Very underutilized
- Should be the always-on infrastructure server
- Currently not fulfilling its intended role

---

## Network Configuration

**LAN:** 192.168.178.0/24  
**Gateway:** 192.168.178.1

**Server IP Addresses:**
- **pve1** (Proxmox infrastructure): 192.168.178.11
- **truenas** (Storage server): 192.168.178.10
- **infra100** (VM on pve1): 192.168.178.12

**DNS Setup:**
- **Current Primary:** AdGuard Home (on truenas - storage server)
- **Router Fallback:** Cloudflare DNS

**Access Methods:**
- **Tailscale:** Primary remote access
- **Cloudflare Tunnel:** Browser access (selective services)
- **LAN:** Direct access when home

**Security:**
- No port forwarding
- No public SSH
- Admin access via Tailscale

---

## Critical Gaps vs Goal State

### 1. DNS on Wrong Server
**Current:** AdGuard on storage server (truenas)  
**Goal:** AdGuard on infrastructure server (pve1)  
**Risk:** If truenas is off, no DNS filtering

### 2. Home Assistant on Wrong Server
**Current:** HA OS running on truenas  
**Goal:** HA OS as dedicated VM on pve1 (likely infra102)  
**Impact:** Can't shut down truenas without losing daily automations

### 3. Monitoring Split
**Current:** Uptime Kuma running on both servers (truenas + infra100)  
**Goal:** Single Uptime Kuma on pve1, monitoring everything  
**Issue:** Confusing, redundant

### 4. Access Layer on Wrong Server
**Current:** Cloudflared + Tailscaled on truenas  
**Goal:** Access coordination on pve1  
**Impact:** Can't access anything if truenas is down

### 5. No Separation of Concerns
**Current:** truenas must run 24/7 for infrastructure services  
**Goal:** truenas on-demand, pve1 always-on  
**Result:** Higher power consumption, can't achieve energy savings goal

---

## Backup Status

### Proxmox
- **Status:** ✅ Backup storage configured and automated
- **Storage:** NFS share on TrueNAS (`192.168.178.10:/mnt/storage/backups/proxmox`)
- **Security:** NFS restricted to Proxmox IP only (192.168.178.11/32)
- **Quota:** 150 GiB on TrueNAS dataset
- **Schedule:** Daily at 21:00
- **Retention:** Keep last 14 backups
- **Compression:** ZSTD
- **Mode:** Snapshot
- **VMs included:** VM 100 (Ubuntu Server)
- **Next steps:** 
  - Test backup/restore procedure
  - Set up Healthchecks.io monitoring
  - Configure offsite backup to Backblaze B2

### TrueNAS Config
- **Status:** ⚠️ Manual backups only
- **Frequency:** Irregular (before major changes)
- **Need:** Automated daily config exports

### Home Assistant
- **Status:** ✅ Automated backups configured
- **Location:** Within HA OS on TrueNAS

### Application Data
- **ZFS Snapshots:** Likely configured (verify)
- **Offsite:** Backblaze B2 (verify configuration)

---

## Migration Blockers

Before migration can begin, we need:

1. ✅ **Current state documented** (this file)
2. ✅ **NFS share from TrueNAS to Proxmox** (configured and secured)
3. ✅ **Proxmox backup system configured and tested** (automated daily backups)
4. ❌ **VM backup/restore procedure validated** (manual test needed)
5. ❌ **TrueNAS config automated backup**
6. ❌ **Migration order plan**

---

## Notes

- Owner is new to Linux and self-hosting
- Approach: Careful, step-by-step, verify everything
- Priority: Don't break daily-use services (HA, Nextcloud, Immich)
- Philosophy: If not documented, it doesn't exist

---

**Next Steps:**
1. Test Proxmox VM backup/restore
2. Set up automated backups
3. Document migration order
4. Execute migration phase by phase
