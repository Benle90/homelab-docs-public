# Storage Server

**Hostname:** `truenas`  
**IP Address:** 192.168.178.10  
**Hardware:** Custom build  
**CPU:** Intel Core i5-9600K  
**RAM:** 32 GB DDR4-3200  
**Motherboard:** MSI MPG Z390 Gaming Plus  
**Cooling:** be quiet! Dark Rock 4  
**PSU:** be quiet! Pure Power 11 CM 500W  

## Storage
- 500 GB SSD (OS + apps)
- 2×4 TB Seagate IronWolf HDDs
- ZFS mirror for data

## OS
TrueNAS SCALE (Community Edition)

## Responsibilities
- ZFS storage (primary data store)
- Nextcloud (file sync, calendar, contacts)
- Immich (photo library)
- Application backups
- Network shares (NFS and SMB)

## Network Shares

### NFS Shares

| Name | Path | Purpose | Allowed Hosts |
|------|------|---------|---------------|
| Proxmox Backups | `/mnt/storage/backups/proxmox` | Proxmox VM and host backups | `192.168.178.11/32` (pve1 only) |

**Security note:** NFS restricted to specific IP to prevent exposure via Tailscale subnet routing. See [LESSONS-LEARNED.md](../LESSONS-LEARNED.md#2026-01-29-nfs-security-with-tailscale-subnet-routing).

### SMB Shares

| Name | Path | Purpose |
|------|------|---------|
| `ha-backup` | `/mnt/storage/ha-backup` | Home Assistant automated backups |
| `storage-smb` | `/mnt/storage/storage-smb` | General file sharing, Ubuntu PC Deja Dup backups |
| `time-machine` | `/mnt/storage/timemachine` | macOS Time Machine backups |

**Mount example (Linux):**
```bash
# Mount storage-smb share
sudo mount -t cifs //192.168.178.10/storage-smb /mnt/storage -o username=<user>
```

**Why SMB for desktop shares:** Cross-platform compatibility (Windows, macOS, Linux). NFS is used only for server-to-server communication where both ends are Linux.

## Services & Access URLs

### Infrastructure Services (to be migrated)
- **AdGuard Home:** http://192.168.178.10:30004/
  - DNS filtering and ad blocking
  - *Should be migrated to pve1*
- **Uptime Kuma:** http://192.168.178.10:31050
  - Monitoring and uptime tracking
  - *Duplicate of infra100 instance*
- **Cloudflared:** (no web interface)
  - Cloudflare Tunnel for secure remote access
  - *Should be migrated to pve1*
- **Tailscaled:** (no web interface)
  - Tailscale VPN daemon
  - *Should be migrated to pve1*

### Core Applications
- **TrueNAS Web UI:** https://192.168.178.10/ui/signin
  - Main management interface
- **Nextcloud:** http://192.168.178.10:30027/
  - File sync, calendar, contacts
- **Immich:** http://192.168.178.10:30041/
  - Photo library and management
- **Home Assistant:** http://homeassistant.local:8123/
  - Home automation platform
  - *Should be migrated to pve1 as dedicated VM*
- **Jellyfin:** (port not specified)
  - Media server

### Utility Services
- **Crafty 4:** https://192.168.178.10:8443/
  - Minecraft server management
  - *Performance issues due to slow HDD*
- **PeaNUT:** http://192.168.178.10:30224/
  - UPS monitoring
- **Scrutiny:** http://192.168.178.10:31054/
  - Drive health monitoring

### Not Configured
- **Collabora:** (not yet configured)
  - Document editing for Nextcloud

## Scheduled Tasks

### S.M.A.R.T Tests (Cron Jobs)

TrueNAS SCALE discontinued built-in S.M.A.R.T test scheduling. These are configured as manual cron jobs under **System → Advanced → Cron Jobs**.

**Important:** Use full paths in cron commands (`/usr/sbin/smartctl`) as cron runs with minimal PATH.

| Test | Schedule | Time |
|------|----------|------|
| Short | Daily | 00:15 |
| Long | 1st of month (except Tuesdays) | 02:30 |

**Short test command:**
```bash
/usr/sbin/smartctl -t short /dev/disk/by-id/ata-ST4000VN006-3CW104_<SERIAL1> && /usr/sbin/smartctl -t short /dev/disk/by-id/ata-ST4000VN006-3CW104_<SERIAL2>
```

**Long test command:**
```bash
[ "$(date +%u)" -ne 2 ] && /usr/sbin/smartctl -t long /dev/disk/by-id/ata-ST4000VN006-3CW104_<SERIAL1> && /usr/sbin/smartctl -t long /dev/disk/by-id/ata-ST4000VN006-3CW104_<SERIAL2>
```

The long test skips Tuesdays to avoid overlap with ZFS scrub.

### ZFS Scrub

Configured under **Storage → Storage Health → Configure**.

| Setting | Value |
|---------|-------|
| Schedule | Tuesdays 02:10 |
| Threshold | 35 days |

## Availability
- Not necessarily 24/7
- Can be powered down to save energy
- Scheduled maintenance tasks run overnight (00:15-02:30)

## Design Notes
- All critical infrastructure should NOT depend on this server
- Infrastructure services (DNS, monitoring) run on pve1 instead
- This server can be shut down without breaking core network services
