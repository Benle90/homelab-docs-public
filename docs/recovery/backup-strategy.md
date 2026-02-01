# Backup Strategy - Complete Documentation

**Last Updated:** 2026-01-30  
**Status:** Configured and operational

This document describes the complete backup strategy for the homelab, including all configurations, procedures, and recovery steps.

---

## Philosophy

> If it's not documented, it does not exist.  
> If it's not backed up, it will be lost.  
> If it's not tested, it won't work when you need it.

---

## Backup Layers

### Layer 1: Local Snapshots
- **ZFS snapshots** on TrueNAS
- Protects against: accidental deletion, file corruption
- **Not a backup:** Still on same hardware

### Layer 2: VM/Application Backups
- **Proxmox VM backups** to TrueNAS via NFS
- **Home Assistant** automated backups
- **Application exports** (Nextcloud, Immich configs)
- Protects against: VM corruption, misconfiguration, service failure

### Layer 3: Offsite Storage
- **Storj/Backblaze B2** object storage
- Protects against: hardware failure, fire, theft, natural disaster
- **Status:** Configured and monitored

### Layer 4: Documentation
- **This repository** (markdown files)
- Recovery procedures
- Configuration details
- **Critical:** Without docs, you can't rebuild

---

## Proxmox Backup Configuration

### Storage Setup

**NFS Share on TrueNAS:**
- **Server:** truenas (192.168.178.10)
- **Export path:** `/mnt/storage/backups/proxmox`
- **Dataset quota:** 150 GiB
- **Compression:** LZ4 (on TrueNAS dataset)

**Security:**
- NFS access restricted to: `192.168.178.11/32` (pve1 only)
- Reason: Tailscale subnet routing enabled, prevents unauthorized access

**Proxmox storage ID:** `truenas-backups`

### Backup Schedule

**Job configuration:**
- **Schedule:** Daily at 21:00
- **Reason for timing:** truenas likely powered on during evening hours
- **VMs included:** 
  - infra100 (VM ID: 100) - Ubuntu Server with Docker, Portainer, Uptime Kuma
  - *(More VMs will be added as they're created: infra101, infra102, etc.)*

**Retention:**
- **Keep last:** 14 backups
- **Reasoning:** 2 weeks of history, enough to recover from delayed issue discovery
- **Auto-cleanup:** Proxmox automatically deletes backups older than 14

**Backup mode:**
- **Mode:** Snapshot
- **Compression:** ZSTD
- **Benefits:** Minimal downtime, good compression ratio

### Expected Backup Sizes

**Current estimates:**
- infra100 (Ubuntu Server): ~10-30 GB compressed
- 14 backups: ~140-420 GB total
- Well within 150 GiB quota

**Action required:** Verify actual size after first backup completes

---

## TrueNAS Configuration Backup

### Current Status
- **Status:** ⚠️ Manual backups only
- **Frequency:** Irregular (before major changes)
- **Location:** Manual downloads to local machine

### TrueNAS Scheduled Tasks

**Current automated tasks running on TrueNAS:**

| Task | Frequency | Time |
|------|-----------|------|
| SMART Short | Daily | 00:15 |
| SMART Long | Day 1 of each month (except Tuesdays) | 02:30 |
| ZFS Scrub | Every 35 days on Tuesdays | 02:10 |
| Backblaze B2 sync | Daily | 01:30 |
| Storj sync | Weekly (Wednesday) | 05:00 |
| Immich DB dump | Daily | 00:30 |
| Immich Nightly tasks | Daily | 01:05 |

**Notes:**
- All times are local time (CET)
- Tasks are staggered to avoid conflicts
- SMART tests are manual cron jobs (TrueNAS discontinued built-in scheduling) - see [storage-server.md](../servers/storage-server.md#scheduled-tasks) for commands
- ZFS scrub verifies data integrity
- Both cloud backup tasks include Healthchecks.io pre/post-scripts
- Immich tasks maintain photo library database

### Planned Automation
**Goal:** Daily automated config exports

**Options being considered:**
1. TrueNAS built-in cloud sync to B2
2. Cron job exporting config to dataset
3. External script pulling via API

**Decision pending:** Will be implemented after Proxmox backup testing is complete

---

## Offsite Backup Configuration

**Status:** ✅ Configured and monitored

### Backup Destinations

The homelab uses two offsite backup destinations for redundancy and cost optimization:

#### 1. Backblaze B2 (Daily Backups)

**Purpose:** Primary offsite backup with daily sync

**Schedule:**
- **Frequency:** Daily
- **Start time:** 01:30 CET
- **Runs:** Every night during TrueNAS maintenance window
- **Grace period:** 8 hours (until 09:30 CET)

**Monitoring:**
- Healthchecks.io monitor configured
- Pre-script: Pings at backup start
- Post-script: Pings at backup completion
- Alert if no completion ping within 8 hours

**What is synced:**
1. Critical application data
2. Application configs/databases
3. TrueNAS configurations
4. Selected datasets requiring daily protection

**Cost:**
- Storage: ~$6/TB/month
- Download: ~$10/TB (only when restoring)

#### 2. Storj (Weekly Backups)

**Purpose:** Secondary offsite backup, cost-effective for large datasets

**Schedule:**
- **Frequency:** Weekly (every Wednesday)
- **Start time:** 05:00 CET
- **Reason:** Weekly sufficient for large datasets, more cost-effective
- **Grace period:** 12 hours (until 17:00 CET)

**Monitoring:**
- Healthchecks.io monitor configured
- Pre-script: Pings at backup start
- Post-script: Pings at backup completion
- Alert if no completion ping within 12 hours

**What is synced:**
1. **Priority 1:** Immich photo library (complete)
2. **Priority 2:** Nextcloud data (user files)
3. **Priority 3:** Media library (if space allows)
4. **Priority 4:** Selected Proxmox VM backups

**Cost:**
- Storage: ~$4-6/TB/month
- Download: Free egress (significant advantage)
- Expected cost: $5-10/month depending on data size

**Rationale:**
- Wednesday chosen to avoid weekend/Monday maintenance windows
- 12-hour grace allows for very large dataset sync times
- Early morning start (5 AM) utilizes off-peak hours
- Weekly frequency reduces costs while maintaining reasonable RPO

### Sync Method

**Implementation:**
- TrueNAS Cloud Sync Tasks
- Encrypted at rest on both destinations
- Scheduled during low-traffic hours
- Pre/post-scripts ping Healthchecks.io for monitoring

### Alert Behavior

**Backblaze B2 (Daily):**
- Start ping expected: 01:30 CET
- Completion ping expected: Before 09:30 CET
- Alert if: No start ping, no completion within 8 hours, or explicit failure

**Storj (Weekly):**
- Start ping expected: Wednesday 05:00 CET  
- Completion ping expected: Before Wednesday 17:00 CET
- Alert if: No start ping, no completion within 12 hours, or explicit failure

---

## Home Assistant Backup

**Status:** ✅ Configured

**Configuration:**
- HA OS running as VM on TrueNAS
- Daily automated backups to SMB share `ha-backup` (see [storage-server.md](../servers/storage-server.md#smb-shares))
- **Note:** After migration to pve1, backup destination will need reconfiguration

---

## Application Data Backups

### Nextcloud
- **Data location:** ZFS on TrueNAS
- **Protection:** ZFS snapshots
- **Offsite:** Synced to Storj/B2
- **Config:** Manual export before major changes

### Immich
- **Data location:** ZFS on TrueNAS (photo library)
- **Protection:** ZFS snapshots
- **Offsite:** Critical - photo library synced to Storj/B2
- **Config:** Database dumps automated (daily at 00:30)

### Other Services
- **Jellyfin:** Media can be re-obtained, low priority
- **AdGuard Home:** Config exported manually, should automate
- **Uptime Kuma:** Low criticality, config export available

---

## Monitoring

All backup tasks are monitored via Healthchecks.io with pre/post-script pings.

See **[monitoring.md](../services/monitoring.md)** for complete monitoring documentation including:
- Healthchecks.io check configuration
- Alert behavior and grace periods
- Home Assistant infrastructure monitoring
- Uptime Kuma service monitoring

---

## Recovery Procedures

Detailed recovery procedures are documented separately:

- **[proxmox-backup-restore.md](proxmox-backup-restore.md)** - Proxmox host config + VM recovery (using DerDanilo scripts)
- **[truenas-backup-restore.md](truenas-backup-restore.md)** - TrueNAS and data recovery
- **[disaster-recovery.md](disaster-recovery.md)** - High-level disaster planning

### Quick Reference

| Scenario | Document |
|----------|----------|
| VM corruption | [proxmox-backup-restore.md](proxmox-backup-restore.md) |
| Proxmox host failure | [proxmox-backup-restore.md](proxmox-backup-restore.md) |
| TrueNAS failure | [truenas-backup-restore.md](truenas-backup-restore.md) |
| Both servers lost | [disaster-recovery.md](disaster-recovery.md) |

---

## Testing Schedule

### What Must Be Tested Regularly

**Monthly:**
- ✅ Verify Proxmox backups are running
- ✅ Check backup storage space usage
- ✅ Verify Backblaze B2 sync completing successfully (daily checks)
- ✅ Verify Storj sync completing successfully (Wednesday checks)
- ❌ Test VM restore (quarterly minimum)

**Quarterly:**
- ❌ Full VM restore test
- ❌ Test B2 data retrieval and restore
- ❌ Test Storj data retrieval and restore
- ❌ Test config restore procedures
- ❌ Verify data integrity across all backup layers

**Annually:**
- ❌ Full disaster recovery simulation
- ❌ Update and verify all documentation
- ❌ Review and adjust retention policies
- ❌ Review offsite backup costs and optimize if needed

---

## Next Steps (Priority Order)

1. **Immediate:**
   - ✅ Proxmox backup configured
   - ✅ Backblaze B2 daily backup configured and monitored
   - ✅ Storj weekly backup configured and monitored
   - ❌ Verify backup file created on TrueNAS
   - ❌ Document actual backup size

2. **This Week:**
   - ❌ Test VM restore procedure
   - ❌ Verify B2 sync logs and data integrity
   - ❌ Verify Storj sync logs and data integrity
   - ❌ Automate TrueNAS config backups

3. **This Month:**
   - ❌ Test B2 restore procedure (small file test)
   - ❌ Test Storj restore procedure (small file test)
   - ❌ Configure Proxmox backup monitoring
   - ❌ Begin migration planning

4. **Ongoing:**
   - Keep this documentation updated
   - Regular backup verification (daily B2, weekly Storj)
   - Quarterly restore testing
   - Monitor backup storage costs

---

## Important Notes

- **Power management concern:** truenas may be powered down overnight. Backups scheduled for appropriate windows:
  - Proxmox: 21:00 (evening, server likely running)
  - B2 sync: 01:30 daily (during nightly maintenance, server running)
  - Storj sync: 05:00 Wednesday (early morning, off-peak, server likely running)
- **Network security:** NFS restricted to pve1 IP only (192.168.178.11/32) due to Tailscale subnet routing exposure.
- **Storage quota:** 150 GiB limit prevents runaway disk usage.
- **Task coordination:** 
  - Proxmox backup (21:00) scheduled to avoid truenas maintenance windows
  - TrueNAS tasks run between 00:15 - 02:30
  - B2 sync (01:30) runs during maintenance window
  - Storj sync (05:00 Wed) runs after all nightly maintenance
- **Monitoring:** All cloud backup tasks ping Healthchecks.io (pre/post-scripts) for automatic failure detection
- **Redundancy:** Two offsite providers (B2 daily, Storj weekly) provide backup redundancy and cost optimization
- **Philosophy:** Better to have backups we don't need than need backups we don't have.

---

**Last manual backup verification:** 2026-01-29 (Proxmox configured)  
**Last restore test:** Never (needs to be done)  
**Last disaster recovery drill:** Never (needs to be done)
