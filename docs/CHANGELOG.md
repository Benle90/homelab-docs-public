# Homelab Changelog

**Purpose:** Track all significant changes, migrations, and decisions in the homelab.

**Instructions:** Add entries after completing any major work. Date format: YYYY-MM-DD.

---

## 2026-02-01

### Documentation
- **nextcloud.md:** Rewrote service documentation to reflect actual access patterns
  - Clarified primary access is LAN/Tailscale, Cloudflare Tunnel is occasional
  - Added Known Issues section linking to GitHub issues #17, #18, #19
  - Added warning about `overwritehost` with link to lessons learned
  - Added client configuration details
- **LESSONS-LEARNED.md:** Added lesson about Nextcloud `overwritehost` causing forced redirects
  - Documents root cause of previous incident where LAN access was broken
  - Explains difference between `overwritehost`, `overwriteprotocol`, and `overwrite.cli.url`
  - Guidance for mixed access patterns (LAN + external domain)
  - See [LESSONS-LEARNED.md](LESSONS-LEARNED.md)
- **storage-server.md:** Added Scheduled Tasks section documenting S.M.A.R.T test cron jobs and ZFS scrub configuration
  - TrueNAS SCALE discontinued built-in S.M.A.R.T scheduling; now manual cron jobs
  - Documented exact commands with full paths (`/usr/sbin/smartctl`)
  - Documented scrub task location (Storage → Storage Health → Configure)
  - See [storage-server.md](servers/storage-server.md#scheduled-tasks)
- **LESSONS-LEARNED.md:** Added lesson about cron jobs needing full paths
- **backup-strategy.md:** Added cross-reference to storage-server.md for S.M.A.R.T cron job details

## 2026-01-31

### Refactored
- **Home Assistant security automations:** Simplified alarm logic with single source of truth
  - **Removed:** `Security – Entrance door opened (away)` (broken, used non-existent entity)
  - **Removed:** `Security – Doors opened (night always, day = armed or away)` (complex conditional logic)
  - **Removed:** `Alarm – Armed/Disarmed notification` (noisy, not needed - only care about security events)
  - **Added:** Alarm state management automations:
    - `Alarm – Auto-arm at night` (22:00)
    - `Alarm – Auto-disarm in morning` (06:00, only if someone home - vacation-safe)
    - `Alarm – Auto-arm when everyone leaves`
    - `Alarm – Auto-disarm on arrival`
  - **Added:** `Security – Door opened while armed` (simple: alarm armed → notify)
  - **Benefit:** `input_boolean.alarm_armed` is now the single source of truth; door response logic is trivial; adding siren later is one line
  - **Added:** `Presence – Notify when someone arrives or leaves` (cross-notify: each person notified about the other)
  - Updated [security.yaml](services/home-assistant/configs/automations/security.yaml)

### Added
- **CLAUDE.md:** Created project instructions file for Claude Code AI assistant
  - Documents project overview and current state context
  - Defines conventions (file naming, status indicators, cross-references)
  - Specifies what to check before making changes
  - Links to key reference documents
  - **Learning from mistakes:** Added instructions to check LESSONS-LEARNED.md before working on risky topics (NFS, storage, backups, Docker, VPN)
  - Proactive lesson documentation: Claude will suggest adding entries when problems occur
  - **Proactive improvements:** Added instructions to watch for and suggest fixes for duplicates, outdated info, inconsistencies, missing cross-references, stale dates, and broken links
  - **Meta self-improvement:** Added instructions for Claude to evaluate and suggest improvements to CLAUDE.md itself - detecting gaps, missing conventions, and new patterns that should be documented
  - **GitHub Issues integration:** Added workflow for checking, creating, and updating issues; commit linking with `Fixes #123`; guidelines for when to create vs skip issues
- **Templates directory:** Created `docs/templates/` with reusable templates
  - Extracted lesson-learned template from LESSONS-LEARNED.md

### Configuration
- **Claude Code permissions:** Updated `.claude/settings.json` with additional allowed commands
  - Added `git status`, `git diff`, `git log` for repository inspection
  - Added `mkdocs serve`, `mkdocs build` for documentation preview

### Documentation
- **Folder structure:** Added templates directory to documentation organization

### Rationale
- **CLAUDE.md file:** Provides persistent context to Claude Code across sessions, ensuring consistent behavior and adherence to project conventions without manual instruction each time

### Configuration
- **Proxmox Firewall:** Enabled firewall on infra100 VM
  - Configured hierarchical firewall (Datacenter → pve1 → infra100)
  - Default deny policy with explicit allow rules
  - LAN access (192.168.178.0/24) for SSH, Portainer, Uptime Kuma
  - Tailscale access (100.64.0.0/10) for remote management

### Documentation
- **Network:** Added comprehensive Proxmox firewall documentation
  - Datacenter, node, and VM-level rules
  - Rule ordering principles (DROP must be last)
- **Network Shares:** Documented all TrueNAS shares in [storage-server.md](servers/storage-server.md)
  - NFS: Proxmox backups share with security notes
  - SMB: ha-backup, storage-smb, time-machine shares
  - Consolidated share info as single source of truth
- **QUICK-REFERENCE.md:** Removed duplicated NFS path, now references storage-server.md
- **CLAUDE.md:** Added documentation placement principles
  - Single source of truth guidance
  - Clarified QUICK-REFERENCE.md scope (operational lookups, not detailed config)
  - Added "Server-provided resources" to placement table

---

## 2026-01-30

### Documentation
- **Uptime Kuma:** Updated monitoring documentation with dual-instance setup
  - Documented pve1 instance (primary) at 192.168.178.12:3001
  - Documented TrueNAS instance at 192.168.178.10:31050
  - Added public status page URL: `/status/homelab`
  - Listed all monitors by group (Network, pve1, TrueNAS) with tags
  - Listed status page services (AdGuard, Home Assistant, Immich, Nextcloud, Scrutiny, Tailscaled)

### Added
- **Proxmox Host Backup System:** Implemented automated weekly backups using DerDanilo's battle-tested scripts
  - Script: `/usr/local/bin/prox_config_backup.sh` from [DerDanilo/proxmox-stuff](https://github.com/DerDanilo/proxmox-stuff)
  - Storage: TrueNAS NFS share at `192.168.178.10:/mnt/storage/backups/proxmox`
  - Schedule: Weekly on Sundays at 02:00 CET (cron: `0 2 * * 0`)
  - Retention: Last 10 backups (auto-cleanup of older backups)
  - Size: ~700 KB per backup (compressed)
  - Backup contents: `/etc/pve/`, network config, cluster data, SSH keys, cron jobs, package lists
  - **Critical**: Backups stored on TrueNAS, not Proxmox (survives host failure)

### Monitoring
- **Proxmox Backup Monitoring:** Configured dual Healthchecks.io monitors
  - **pve1-infra100:** Cron heartbeat (every minute) - confirms system alive
  - **PVE Config Backup:** Weekly backup success check (OnCalendar: `Sun *-*-* 02:00:00`)
  - Period: 7 days, Grace: 1 hour, Timezone: Europe/Brussels
  - Automatic alerts on backup failure or missed schedule

### Documentation
- **Proxmox Host Backup & Restore Guide:** Comprehensive documentation created
  - Step-by-step installation and configuration
  - Two restore scenarios: existing Proxmox + fresh reinstall
  - Backup access methods when Proxmox is down (TrueNAS SSH, web UI, NFS mount)
  - Monthly/quarterly testing procedures
  - Troubleshooting guide
  - OnCalendar/Cron reference table
- **Emergency Restore Quick Reference:** Created printable one-page guide for disaster recovery
- Added Healthchecks.io monitoring overview with configuration details

### Rationale
- **Weekly schedule:** Host config changes infrequently, weekly is sufficient
- **DerDanilo's scripts:** Battle-tested (1.3k+ GitHub stars), comprehensive, reliable
- **Retention (10 backups):** ~2.5 months of history, balances storage vs. recovery options
- **NFS storage on TrueNAS:** Survives Proxmox host failure, accessible from any machine
- **Dual monitoring:** Heartbeat detects system failure, backup check confirms successful completion

### Documentation
- **Home Assistant:** Complete documentation restructure
  - Restructured `ha_automations.md` with all 30 automations categorized by domain
  - Created separate YAML config files by category (security, lighting, environmental, mailbox, system, network, devices)
  - Added comprehensive `integrations.md` documenting all 10+ active integrations
  - Created template files for `scripts.md` and `dashboards.md`
  - Added `configs/README.md` with security guidelines for config management
  - Updated `mkdocs.yml` with Home Assistant navigation section
  - All automations now documented with purpose, YAML, and design rationale

### Added
- **Offsite Backup Monitoring:** Configured Healthchecks.io monitors for both cloud backup tasks
  - **Backblaze B2:** Daily at 01:30 CET with 8-hour grace period
  - **Storj:** Weekly (Wednesday) at 05:00 CET with 12-hour grace period
  - Both use pre/post-scripts for start and completion pings
  - Immediate alerts on missing start ping or exceeded grace period
- **Home Assistant Config Backup:** All automation YAML files now version controlled
  - 7 category-based config files for easy management and recovery

### Documentation (Backup)
- Updated `backup-strategy.md` with complete offsite backup configuration
- Documented both Backblaze B2 (daily) and Storj (weekly) backup schedules
- Added OnCalendar and Cron expressions for both Healthchecks.io monitors
- Clarified backup destination purposes and data priorities
- Updated TrueNAS scheduled tasks table with both cloud sync tasks
- Documented monitoring configuration with pre/post-script pings

### Rationale
- **B2 daily backup:** Minimal RPO (24 hours), critical data protection
- **Storj weekly backup:** Cost-effective for large datasets (photos, media)
- **Dual provider:** Redundancy and cost optimization
- **Healthchecks.io:** Proactive failure detection for all backup tasks

---

## 2026-01-29

### Added
- **Proxmox Backup System:** Configured automated daily backups to TrueNAS NFS share
  - Storage: `192.168.178.10:/mnt/storage/backups/proxmox`
  - Schedule: Daily at 21:00
  - Retention: Keep last 14 backups
  - Compression: ZSTD
  - Currently backing up: VM 100 (Ubuntu Server)

### Security
- **NFS Access Restriction:** Limited NFS share to Proxmox IP only (192.168.178.11/32)
  - Reason: Tailscale subnet routing could expose NFS to all Tailscale users
  - Solution: Granular IP-based access control on TrueNAS

### Documentation
- Created comprehensive `backup-strategy.md`
- Updated `current-state.md` with backup status
- Documented NFS security considerations

### Testing Status
- ⏳ Proxmox backup/restore procedure: Not yet tested
- ⏳ Healthchecks.io monitoring: Not yet configured

---

## Planned (Next Steps)

### This Week
- [ ] Test Proxmox VM restore procedure
- [ ] Verify backup file created on TrueNAS (after 21:00 today)
- [ ] Verify B2 and Storj sync logs and data integrity
- [ ] Document actual backup sizes

### This Month
- [ ] Automate TrueNAS config backups
- [ ] Test Storj/B2 restore procedure
- [ ] Begin migration: Move AdGuard Home from TrueNAS to Proxmox
- [ ] Begin migration: Move Home Assistant from TrueNAS to Proxmox VM

---

## Template for Future Entries

```markdown
## YYYY-MM-DD

### Added
- What was added and why

### Changed
- What was modified and why

### Removed
- What was deleted and why

### Fixed
- What was broken and how it was resolved

### Security
- Any security-related changes

### Migration
- Migration steps completed

### Lessons Learned
- What you discovered or learned
```

---

## Historical Context (Pre-Documentation)

### Dec 2025
- Initial homelab setup
- TrueNAS SCALE installed on big server
- Proxmox VE installed on small server
- Most services running on TrueNAS (not aligned with target architecture)
- Manual backup procedures only

### Current Pain Points
- DNS (AdGuard) on wrong server (TrueNAS instead of Proxmox)
- Home Assistant on wrong server (TrueNAS instead of Proxmox)
- Can't power down TrueNAS without losing critical infrastructure
- No automated backups for Proxmox (✅ now fixed)
- No automated TrueNAS config backups
- Offsite backups configured (✅ B2 daily, ✅ Storj weekly, both monitored)

### Goal Architecture
- Proxmox (small server): Always-on infrastructure (DNS, monitoring, automation, access)
- TrueNAS (big server): On-demand storage and stateful applications
- Separation enables energy savings and better maintainability

---

**Last Updated:** 2026-02-01
