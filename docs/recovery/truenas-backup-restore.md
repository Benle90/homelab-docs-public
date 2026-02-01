# TrueNAS Backup & Restore

**Last Updated:** 2026-01-30
**Status:** Configured and operational

---

## Overview

TrueNAS (192.168.178.10) stores all critical data and serves as the backup destination for Proxmox. This document covers:

1. What data lives on TrueNAS
2. How it's protected (local + offsite)
3. Recovery procedures

---

## Data on TrueNAS

| Dataset | Purpose | Backup Priority |
|---------|---------|-----------------|
| `/mnt/storage/backups/proxmox/` | Proxmox VM + host backups | Critical |
| Photo library (Immich) | Family photos | Critical |
| Nextcloud data | User files | High |
| Application configs | Service configurations | High |
| Media library | Movies, TV shows | Low (re-obtainable) |

---

## Backup Layers

### Layer 1: ZFS Snapshots (Local)

**Purpose:** Protect against accidental deletion, file corruption

**Note:** Not a backup - still on same hardware

### Layer 2: Offsite Cloud Storage

#### Backblaze B2 (Daily)

| Setting | Value |
|---------|-------|
| Schedule | Daily at 01:30 CET |
| Cron | `30 1 * * *` |
| Grace period | 8 hours |
| Monitoring | Healthchecks.io (pre/post-scripts) |

**What syncs:** Critical application data, configs, databases

#### Storj (Weekly)

| Setting | Value |
|---------|-------|
| Schedule | Wednesdays at 05:00 CET |
| Cron | `0 5 * * 3` |
| Grace period | 12 hours |
| Monitoring | Healthchecks.io (pre/post-scripts) |

**What syncs:** Immich photos, Nextcloud data, large datasets

**Why two providers:**
- Daily B2 for fast RPO on critical data
- Weekly Storj for cost-effective large dataset backup
- Storj has free egress (cheaper restores)

---

## TrueNAS Scheduled Tasks

| Task | Schedule | Purpose |
|------|----------|---------|
| SMART Short | Daily 00:15 | Drive health check |
| SMART Long | 1st of month 02:30 | Deep drive health |
| ZFS Scrub | Every 35 days (Tuesdays) 02:10 | Data integrity |
| Backblaze B2 sync | Daily 01:30 | Offsite backup |
| Storj sync | Wed 05:00 | Offsite backup |
| Immich DB dump | Daily 00:30 | Database backup |

---

## Recovery Procedures

### Scenario: TrueNAS Total Loss

**Severity:** Critical - all data at risk

#### Step 1: Assess Damage

**If ZFS drives intact:**
- Import existing pool (best case)
- May recover all data without restore

**If drives damaged:**
- Restore from offsite backup (B2/Storj)
- Data loss = everything since last sync

#### Step 2: Reinstall TrueNAS

1. Boot from TrueNAS SCALE ISO
2. Install on separate drive (NOT data drives)
3. Configure:
   - IP: `192.168.178.10`
   - Gateway: `192.168.178.1`
   - DNS: `192.168.178.11` (AdGuard on Proxmox)

#### Step 3A: Import Existing Pool (Drives OK)

```
Storage → Import Pool → Select pool → Import
```

Verify:
- All datasets present
- Permissions intact
- Data accessible

#### Step 3B: Restore from Cloud (Drives Failed)

1. Create new ZFS pool (mirror recommended)
2. Create datasets matching original structure
3. Configure Cloud Sync to pull from B2/Storj
4. Wait for restore (may take days for large datasets)
5. Verify data integrity

**Restore priority:**
1. Photos (Immich) - irreplaceable
2. Documents (Nextcloud) - important
3. Proxmox backups - needed to restore VMs
4. Media - lowest priority (re-obtainable)

#### Step 4: Reconfigure Services

1. **NFS shares:**
   - Recreate: `/mnt/storage/backups/proxmox`
   - Set permissions: `192.168.178.11/32`

2. **Apps (Nextcloud, Immich, etc.):**
   - Reinstall apps
   - Point to restored data directories
   - Restore database dumps

#### Step 5: Verify

- [ ] ZFS pool healthy (`zpool status`)
- [ ] All datasets accessible
- [ ] Apps responding
- [ ] Proxmox can access NFS share
- [ ] Offsite sync resumed

---

## TrueNAS Config Backup

**Current status:** Manual (before major changes)

**To backup config:**
1. System → General → Manage Configuration
2. Download System Configuration
3. Store securely (not on TrueNAS!)

**Recommended:** Export config before any system changes

---

## Verification

### Monthly
- [ ] Check B2 sync completing (Healthchecks.io)
- [ ] Check Storj sync completing (Healthchecks.io)
- [ ] Verify ZFS pool health: `zpool status`
- [ ] Check SMART results in TrueNAS UI

### Quarterly
- [ ] Test restore of small file from B2
- [ ] Test restore of small file from Storj
- [ ] Verify ZFS scrub completing
- [ ] Review cloud storage costs

---

## Quick Reference

### Check ZFS Health
```bash
ssh root@192.168.178.10
zpool status
zpool list
```

### Check Cloud Sync Status
Check Healthchecks.io dashboard or TrueNAS → Data Protection → Cloud Sync Tasks

### Manual Cloud Sync
TrueNAS UI → Data Protection → Cloud Sync Tasks → Run Now

---

## External Resources

- [TrueNAS SCALE Docs](https://www.truenas.com/docs/scale/)
- [ZFS Administration](https://openzfs.github.io/openzfs-docs/)
- [Backblaze B2 Docs](https://www.backblaze.com/b2/docs/)
- [Storj Docs](https://docs.storj.io/)
