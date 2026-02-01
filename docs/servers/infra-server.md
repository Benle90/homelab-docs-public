# Infrastructure Server

**Hostname:** `pve1`  
**IP Address:** 192.168.178.11  
**Hardware:** Fujitsu ESPRIMO Q958  
**CPU:** Intel i3-9100T  
**RAM:** 8 GB  
**Storage:** 128 GB SSD  

## OS
Proxmox VE

## Role
Always-on infrastructure server providing core services for the homelab.

## Responsibilities
- Virtualization platform (Proxmox VE)
- DNS (planned: AdGuard Home VM)
- Monitoring (planned: consolidated Uptime Kuma)
- Home automation (planned: Home Assistant OS VM)
- Access coordination (planned: Tailscale, Cloudflare Tunnel)

## Current VMs

### infra100 (VM ID: 100)
- **IP Address:** 192.168.178.12
- **OS:** Ubuntu Server
- **Purpose:** General Docker host for lightweight services

**Services:**
- **Docker:** Container runtime
- **Portainer:** http://192.168.178.12:9000
  - Docker management UI
- **Uptime Kuma:** http://192.168.178.12:3001/dashboard
  - Monitoring (duplicate - to be consolidated)

## Future VMs (Planned)
- **infra101:** AdGuard Home (DNS filtering)
- **infra102:** Home Assistant OS (home automation)
- **infra103:** Uptime Kuma (consolidated monitoring)

## Design Principle
No critical data stored locally.
Server must be rebuildable in under 1 hour.
All VMs follow `infraXXX` naming convention matching VM IDs.
