# Quick Reference Guide

**Last Updated:** 2026-01-31

Quick access to frequently needed information. Keep this file updated as things change.

---

## 🌐 Network Information

### LAN Configuration
- **Subnet:** 192.168.178.0/24
- **Gateway:** 192.168.178.1
- **DNS Primary:** AdGuard Home (currently on TrueNAS)
- **DNS Secondary:** Router fallback (Cloudflare)

### IP Addresses

| Device/Service | IP Address | Notes |
|----------------|------------|-------|
| Router/Gateway | 192.168.178.1 | |
| TrueNAS (Big Server) | 192.168.178.10 | Storage server |
| Proxmox (Small Server) | 192.168.178.11 | Infrastructure server |
| infra100 (VM) | 192.168.178.12 | Ubuntu Server on Proxmox |
| AdGuard Home | 192.168.178.10 | Currently on TrueNAS (to be migrated) |
| Home Assistant | 192.168.178.10 | Currently on TrueNAS (to be migrated) |
| Uptime Kuma | 192.168.178.12 | On Proxmox (VM 100 - infra100) |

**Note:** After migration, update IPs for services moving to Proxmox.

---

## 🔐 Access Methods

### Web Interfaces

#### Infrastructure Management
| Service | URL | Location | Access Method |
|---------|-----|----------|---------------|
| Proxmox VE | https://192.168.178.11:8006 | pve1 | LAN or Tailscale |
| TrueNAS | https://192.168.178.10/ui/signin | truenas | LAN or Tailscale |
| Portainer | http://192.168.178.12:9000 | pve1 (infra100) | LAN or Tailscale |

#### Monitoring & Network Services
| Service | URL | Location | Access Method |
|---------|-----|----------|---------------|
| Uptime Kuma | http://192.168.178.12:3001/dashboard | pve1 (infra100) | LAN or Tailscale |
| Uptime Kuma | http://192.168.178.10:31050 | truenas (duplicate) | LAN or Tailscale |
| AdGuard Home | http://192.168.178.10:30004/ | truenas | LAN only |

#### Core Applications
| Service | URL | Location | Access Method |
|---------|-----|----------|---------------|
| Home Assistant | http://homeassistant.local:8123/ | truenas | Tailscale, LAN |
| Nextcloud | http://192.168.178.10:30027/ | truenas | Cloudflare Tunnel, Tailscale, LAN |
| Immich | http://192.168.178.10:30041/ | truenas | Cloudflare Tunnel, Tailscale, LAN |
| Jellyfin | (port not specified) | truenas | LAN or Tailscale |

#### Utility Services
| Service | URL | Location | Access Method |
|---------|-----|----------|---------------|
| Crafty 4 | https://192.168.178.10:8443/ | truenas | LAN or Tailscale |
| PeaNUT | http://192.168.178.10:30224/ | truenas | LAN only |
| Scrutiny | http://192.168.178.10:31054/ | truenas | LAN only |

### Remote Access

**Tailscale:**
- Primary remote access method
- Subnet: 100.x.x.x (check Tailscale admin console for your devices)
- All admin access goes through Tailscale
- Mobile apps (Home Assistant, Nextcloud) configured to use Tailscale IPs

**Cloudflare Tunnel:**
- Browser access only
- Protected by Cloudflare Zero Trust (requires 2FA)
- Used selectively (Nextcloud, Immich)
- Daily re-authentication required (friction point)

**Security Rules:**
- ✅ No port forwarding on router
- ✅ No public SSH access
- ✅ Admin access only via Tailscale
- ✅ NFS restricted to specific IPs only

---

## 🖥️ Hardware Quick Reference

### Big Server (TrueNAS)
- **CPU:** Intel Core i5-9600K
- **RAM:** 32 GB DDR4-3200
- **Storage:** 500 GB SSD + 2×4 TB Seagate IronWolf (ZFS mirror)
- **Power:** Can be powered down when not needed
- **Purpose:** Storage and stateful applications

### Small Server (Proxmox)
- **Model:** Fujitsu ESPRIMO Q958
- **CPU:** Intel i3-9100T
- **RAM:** 8 GB
- **Storage:** 128 GB SSD
- **Power:** Always-on (low power consumption)
- **Purpose:** Infrastructure services

---

## 📦 Critical Services (Can't Live Without)

| Service | Current Location | Priority | Daily Use? |
|---------|-----------------|----------|------------|
| AdGuard Home | TrueNAS | Critical | Yes |
| Home Assistant | TrueNAS | Critical | Yes |
| Nextcloud | TrueNAS | High | Yes |
| Immich | TrueNAS | High | Yes |
| Uptime Kuma | Proxmox | Medium | No |
| Tailscale | TrueNAS | Critical | Yes |
| Cloudflare Tunnel | TrueNAS | Medium | Occasionally |

---

## 💾 Backup Locations

### Proxmox Backups
- **Storage:** NFS on TrueNAS (see [storage-server.md](servers/storage-server.md#network-shares) for share details)
- **Schedule:** Daily at 21:00
- **Retention:** 14 backups
- **Quota:** 150 GiB

### Home Assistant Backups
- **Storage:** SMB share on TrueNAS (see [storage-server.md](servers/storage-server.md#smb-shares))
- **Schedule:** Daily

### Application Data
- **ZFS Snapshots:** On TrueNAS
- **Offsite:** Planned (Backblaze B2) - not yet configured

---

## 🔧 Common Commands

### Proxmox (via SSH or Shell)
```bash
# List all VMs
qm list

# Start a VM
qm start <VMID>

# Stop a VM
qm stop <VMID>

# List backups
vzdump --list

# Check NFS mount
df -h | grep truenas
```

### TrueNAS (via SSH or Shell)
```bash
# Check ZFS pool status
zpool status

# List snapshots
zfs list -t snapshot

# Check available space
zfs list
```

### Docker (on Proxmox VM 100)
```bash
# List running containers
docker ps

# Check logs
docker logs <container_name>

# Restart a container
docker restart <container_name>
```

### Storage & Disk Health
```bash
# Check S.M.A.R.T. status (TrueNAS/Proxmox)
smartctl -A /dev/sda              # Full S.M.A.R.T. attributes
smartctl -H /dev/sda              # Quick health check (PASSED/FAILED)

# ZFS pool health
zpool status                      # Pool status and errors
zpool list                        # Pool capacity overview
zfs list -o name,used,avail,refer # Dataset usage

# Disk usage
df -h                             # Filesystem usage
du -sh /path/*                    # Directory sizes
lsblk                             # Block device tree
```

### Networking
```bash
# Interface and IP info
ip a                              # All interfaces and IPs
ip r                              # Routing table

# Active connections and listening ports
ss -tulpn                         # TCP/UDP listeners with process names

# Connectivity tests
ping -c 4 192.168.178.1           # Test gateway
ping -c 4 1.1.1.1                 # Test internet
nslookup google.com               # Test DNS resolution

# Check NFS mounts
showmount -e 192.168.178.10       # List NFS exports from TrueNAS
mount | grep nfs                  # Currently mounted NFS shares
```

### Services & Logs
```bash
# Systemd service management
systemctl status <service>        # Service status
systemctl restart <service>       # Restart service
systemctl enable <service>        # Enable on boot

# Log viewing
journalctl -u <service> -f        # Follow service logs
journalctl -u <service> --since "1 hour ago"
dmesg -T | tail -50               # Recent kernel messages (with timestamps)

# Docker logs (with options)
docker logs -f <container>        # Follow logs
docker logs --tail 100 <container> # Last 100 lines
```

### Proxmox Specific
```bash
# Cluster and node info
pvesh get /nodes                  # List nodes
pvecm status                      # Cluster status (if clustered)

# Task and backup info
pveam list local                  # Available templates
pvesm status                      # Storage status

# VM disk info
qm config <VMID>                  # VM configuration
```

---

## 🚨 Emergency Contacts & Resources

### When Things Break

**Priority Order:**
1. Check this documentation first
2. Check service logs
3. Check Uptime Kuma for status
4. Restart the service
5. Check backup availability
6. Ask for help (forums, Claude, etc.)

### Useful Resources
- **Proxmox Docs:** https://pve.proxmox.com/wiki/Main_Page
- **TrueNAS Docs:** https://www.truenas.com/docs/
- **Home Assistant Docs:** https://www.home-assistant.io/docs/
- **Your Homelab Docs:** (This repository!)

### Support Communities
- r/homelab
- r/selfhosted
- Proxmox Forums
- TrueNAS Forums
- Home Assistant Community

---

## 📝 Quick Decision Tree

### "Should I restart the server?"

**Big Server (TrueNAS):**
- ⚠️ Check: Is anyone using Nextcloud/Immich right now?
- ⚠️ Check: Are automations running (Home Assistant)?
- ⚠️ Check: Is DNS working from another source?
- ✅ If all clear: OK to restart
- 🕐 Expected downtime: 5-10 minutes

**Small Server (Proxmox):**
- ⚠️ Check: Is DNS working? (AdGuard - after migration)
- ⚠️ Check: Are any VMs critical right now?
- ✅ Probably safe to restart
- 🕐 Expected downtime: 3-5 minutes

### "Can I shut down the big server overnight?"

**Current State:** ❌ No
- DNS (AdGuard) would stop
- Home Assistant would stop
- Automations would fail
- Access layer would fail

**After Migration:** ✅ Yes
- DNS will be on Proxmox
- Home Assistant will be on Proxmox
- Only storage would be offline

---

## 🔑 Passwords & Secrets

**⚠️ DO NOT store passwords in this file!**

Use a password manager (Bitwarden, 1Password, KeePass, etc.)

Store:
- Proxmox root password
- TrueNAS admin password
- Home Assistant admin password
- Service API keys
- Tailscale auth keys
- Cloudflare API tokens
- Backblaze B2 credentials

---

**Remember:** Update this file whenever you change IPs, add services, or complete migrations!

**Last Verified:** 2026-01-31
