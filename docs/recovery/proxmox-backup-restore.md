# Proxmox Backup & Restore

**Last Updated:** 2026-01-30
**Status:** Implemented and tested

---

## Emergency Quick Reference

**Print this section and keep it accessible.**

### Critical Info

| Item | Value |
|------|-------|
| Proxmox Host | pve1 (192.168.178.11) |
| TrueNAS Server | 192.168.178.10 |
| Backup Location | `/mnt/truenas-backups/proxmox-host-configs/` |
| Backup Script | `/usr/local/bin/prox_config_backup.sh` |
| Schedule | Sundays at 2:00 AM |

### Restore Commands

**Option 1: Existing Proxmox (config corrupted)**
```bash
ssh root@192.168.178.11
mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups
wget https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_restore.sh
chmod +x prox_config_restore.sh
ls -lt /mnt/truenas-backups/proxmox-host-configs/ | head -3
./prox_config_restore.sh /mnt/truenas-backups/proxmox-host-configs/pve_pve1_YYYY-MM-DD.HH.MM.SS.tar.gz
# Select Mode 1 (Default restore) - System reboots automatically
```

**Option 2: Fresh Proxmox install**
```bash
# After installing Proxmox with hostname=pve1, IP=192.168.178.11
ssh root@192.168.178.11
mkdir -p /mnt/truenas-backups
mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups
wget https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_restore.sh
chmod +x prox_config_restore.sh
./prox_config_restore.sh /mnt/truenas-backups/proxmox-host-configs/pve_pve1_YYYY-MM-DD.HH.MM.SS.tar.gz
# Select Mode 2 (Experimental for fresh install) - System reboots automatically
# After reboot: check /etc/fstab vs /etc/fstab_RESTORED, merge NFS mounts if needed
```

**Access backups when Proxmox is down:**
```bash
# From any Linux PC
sudo mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/temp
ls -lh /mnt/temp/proxmox-host-configs/

# Or SSH to TrueNAS directly
ssh root@192.168.178.10
ls -lh /mnt/storage/backups/proxmox/host-configs/
```

**Important links:**

- Restore script: https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_restore.sh
- Proxmox ISO: https://www.proxmox.com/en/downloads

---

## Understanding Host Backups

**Host backups are NOT the same as VM backups:**

| Type | What it saves | Purpose |
|------|---------------|---------|
| VM backups (vzdump) | Guest VMs and containers | Restore individual VMs |
| Host backups (this doc) | Proxmox configuration | Restore Proxmox itself |

Without host backups, you must reconfigure Proxmox from scratch after reinstall.

---

## What Gets Backed Up

DerDanilo's script backs up:

- `/etc/` - System configuration
- `/etc/pve/` - Proxmox configuration (storage, VMs, users, firewall)
- `/var/lib/pve-cluster/` - Cluster database
- `/root/` - Root home (SSH keys, scripts)
- `/var/spool/cron/` - Cron jobs
- `/usr/local/bin/` - Custom scripts
- APT package list
- Proxmox system report

**Typical backup size:** 500 KB - 1 MB

---

## Current Configuration

### Backup Script

**Location:** `/usr/local/bin/prox_config_backup.sh`

**Settings:**
```bash
DEFAULT_BACK_DIR="/mnt/truenas-backups/proxmox-host-configs"
MAX_BACKUPS=10
BACKUP_OPT_FOLDER=false
HEALTHCHECKS=1
HEALTHCHECKS_URL=https://hc-ping.com/<YOUR-HEALTHCHECKS-UUID>
```

### Cron Schedule

```bash
# View with: crontab -l
*/1 * * * * curl -fsS https://hc-ping.com/<YOUR-HEARTBEAT-UUID> > /dev/null
0 2 * * 0 /usr/local/bin/prox_config_backup.sh
```

| Entry | Schedule | Purpose |
|-------|----------|---------|
| `*/1 * * * *` | Every minute | Healthchecks.io heartbeat (system alive) |
| `0 2 * * 0` | Sundays 2 AM | Host config backup |

### Monitoring

Two Healthchecks.io monitors:

| Check | Cron | OnCalendar | Purpose |
|-------|------|------------|---------|
| pve1-infra100 | `*/1 * * * *` | `minutely` | System heartbeat |
| PVE Config Backup | `0 2 * * 0` | `Sun *-*-* 02:00:00` | Backup success |

---

## Restore Procedures

### Scenario A: Config Corrupted (Proxmox Still Running)

1. Mount backups if not mounted:
   ```bash
   mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups
   ```

2. Download restore script:
   ```bash
   wget https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_restore.sh
   chmod +x prox_config_restore.sh
   ```

3. List and select backup:
   ```bash
   ls -lt /mnt/truenas-backups/proxmox-host-configs/ | head -5
   ```

4. Restore (select Mode 1):
   ```bash
   ./prox_config_restore.sh /mnt/truenas-backups/proxmox-host-configs/pve_pve1_YYYY-MM-DD.HH.MM.SS.tar.gz
   ```

5. System reboots automatically. Verify via web UI at `https://192.168.178.11:8006`

### Scenario B: Fresh Proxmox Install

**Step 1: Install Proxmox**

Boot from ISO and install with exact settings:
- Hostname: `pve1`
- IP: `192.168.178.11/24`
- Gateway: `192.168.178.1`
- DNS: `192.168.178.1`

**Step 2: Get backup**
```bash
ssh root@192.168.178.11
mkdir -p /mnt/truenas-backups
mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups
ls -lh /mnt/truenas-backups/proxmox-host-configs/
```

**Step 3: Restore (select Mode 2)**
```bash
wget https://raw.githubusercontent.com/DerDanilo/proxmox-stuff/master/prox_config_restore.sh
chmod +x prox_config_restore.sh
./prox_config_restore.sh /mnt/truenas-backups/proxmox-host-configs/pve_pve1_YYYY-MM-DD.HH.MM.SS.tar.gz
```

**Step 4: After reboot**
```bash
# Check fstab - script saves restored version separately
diff /etc/fstab /etc/fstab_RESTORED

# Add NFS mount if needed
echo "192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups nfs defaults 0 0" >> /etc/fstab
mount -a
```

**Step 5: Restore VMs**

After host config is restored, restore VMs from vzdump backups:
1. Web UI → Storage → truenas-backups → Backups
2. Select VM backup → Restore
3. Repeat for each VM

---

## Manual Operations

### Run Backup Now
```bash
/usr/local/bin/prox_config_backup.sh
```

### Check Backup Status
```bash
ls -lh /mnt/truenas-backups/proxmox-host-configs/
```

### Test Healthchecks.io
```bash
curl -fsS https://hc-ping.com/<YOUR-HEALTHCHECKS-UUID>
# Returns "OK" if successful
```

---

## Verification

### Monthly (5 min)
```bash
# Check recent backup exists
ls -lt /mnt/truenas-backups/proxmox-host-configs/ | head -3

# Verify backup size (should be 500KB-5MB)
du -h /mnt/truenas-backups/proxmox-host-configs/*.tar.gz | tail -1

# Check retention (max 10 backups)
ls -1 /mnt/truenas-backups/proxmox-host-configs/*.tar.gz | wc -l
```

### Quarterly (15 min)
```bash
# Extract and verify contents
cd /tmp
tar -xzf /mnt/truenas-backups/proxmox-host-configs/pve_pve1_*.tar.gz

# Check critical files exist
ls -la etc/pve/storage.cfg etc/network/interfaces etc/pve/qemu-server/ root/.ssh/

# Cleanup
rm -rf etc var root proxmox*
```

---

## Troubleshooting

**Backup not running?**
```bash
crontab -l | grep prox_config_backup
df -h | grep truenas
/usr/local/bin/prox_config_backup.sh  # Run manually to see errors
```

**NFS mount missing?**
```bash
mount -t nfs 192.168.178.10:/mnt/storage/backups/proxmox /mnt/truenas-backups
```

**Network config warning:** Restoring network config can break remote access. Have physical/IPMI access ready, or review `etc/network/interfaces` in backup before restoring.

---

## Network Flow

```
┌──────────────────┐
│   Proxmox pve1   │  Sundays 2 AM
│  192.168.178.11  │  └─> prox_config_backup.sh
└────────┬─────────┘
         │ NFS
         ▼
┌──────────────────┐
│     TrueNAS      │  /mnt/storage/backups/proxmox/
│  192.168.178.10  │  host-configs/
└──────────────────┘
         │
    Backups survive
    if pve1 dies
```

---

## External Resources

- [DerDanilo's proxmox-stuff](https://github.com/DerDanilo/proxmox-stuff) - Backup/restore scripts
- [Proxmox Backup Docs](https://pve.proxmox.com/wiki/Backup_and_Restore) - Official documentation
