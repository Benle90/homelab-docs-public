# System Verification Checklist

**Purpose:** Regular verification that all critical systems are working correctly.

**Schedule:** Run this checklist monthly (or after major changes).

**Last Verification:** 2026-01-29 (initial creation)

---

## 🎯 How to Use This Checklist

1. Copy this file or print it
2. Go through each section systematically
3. Check `[ ]` items as you verify them
4. Note any issues in the "Issues Found" section
5. Update "Last Verification" date when complete
6. Fix any issues found before next verification

---

## 📋 Core Infrastructure

### DNS (AdGuard Home)
- [ ] AdGuard Home accessible via web interface
- [ ] DNS filtering working (test: visit blocked ad domain)
- [ ] Query logs showing activity
- [ ] All devices using AdGuard as primary DNS
- [ ] Fallback DNS configured on router
- [ ] No unusual CPU/memory usage

**Last Verified:** ___________  
**Notes:** ___________

---

### Network Connectivity
- [ ] LAN access working
- [ ] Router accessible (192.168.178.1)
- [ ] Internet connectivity from all devices
- [ ] No IP conflicts
- [ ] DHCP leases look reasonable

**Last Verified:** ___________  
**Notes:** ___________

---

### Proxmox (Small Server)
- [ ] Proxmox web UI accessible (https://192.168.178.11:8006)
- [ ] All VMs showing as "running"
- [ ] CPU usage reasonable (<50% idle)
- [ ] Memory usage reasonable
- [ ] Storage space available (>20% free)
- [ ] System updates available? (check but don't auto-update)
- [ ] No alerts or warnings in dashboard

**VMs Status:**
- [ ] VM 100 (Ubuntu Server): Running
- [ ] VM ___ (___): ___ (add as you create more)

**Last Verified:** ___________  
**Notes:** ___________

---

### TrueNAS (Big Server)
- [ ] TrueNAS web UI accessible (https://192.168.178.10)
- [ ] All pools healthy (check zpool status)
- [ ] No degraded disks
- [ ] Storage space available (>20% free on critical pools)
- [ ] No ZFS errors in logs
- [ ] System updates available? (check but don't auto-update)
- [ ] Temperature normal (<60°C)
- [ ] All apps/services running

**Last Verified:** ___________  
**Notes:** ___________

---

## 🏠 Home Automation

### Home Assistant
- [ ] Home Assistant accessible (web UI and mobile app)
- [ ] All automations enabled
- [ ] No "unavailable" entities (or document expected ones)
- [ ] Zigbee coordinator connected (ZBT-2)
- [ ] All critical sensors reporting
- [ ] Recent automation activity in logbook
- [ ] Mobile app notifications working (send test)
- [ ] Last backup date reasonable (<7 days)

**Critical Sensors:**
- [ ] Entry door sensor: Working
- [ ] Terrace door sensor: Working
- [ ] Mailbox sensor: Working
- [ ] Humidity sensors: Working
- [ ] Air quality sensor: Working
- [ ] Presence detection: Working (if enabled)

**Last Verified:** ___________  
**Notes:** ___________

---

## 💾 Storage & Applications

### Nextcloud
- [ ] Nextcloud accessible via browser
- [ ] Mobile/desktop sync working
- [ ] Calendar sync working (CalDAV)
- [ ] Contacts sync working (CardDAV)
- [ ] Can upload/download files
- [ ] No "broken" or "conflicted" files
- [ ] Background jobs running (check admin panel)
- [ ] Storage space available

**Last Verified:** ___________  
**Notes:** ___________

---

### Immich
- [ ] Immich accessible via browser/mobile app
- [ ] Photo upload working
- [ ] Photos displaying correctly
- [ ] Facial recognition working (if enabled)
- [ ] Storage space available
- [ ] Background jobs running

**Last Verified:** ___________  
**Notes:** ___________

---

### Jellyfin (if actively used)
- [ ] Jellyfin accessible
- [ ] Media playback working
- [ ] Library scanning working
- [ ] No errors in dashboard

**Last Verified:** ___________  
**Notes:** ___________

---

## 🔐 Access & Security

### Tailscale
- [ ] Tailscale accessible from mobile device
- [ ] All devices showing "online" in admin console
- [ ] Can access internal services via Tailscale
- [ ] Subnet routing working (if enabled)
- [ ] No unexpected devices in network

**Last Verified:** ___________  
**Notes:** ___________

---

### Cloudflare Tunnel
- [ ] Cloudflare Tunnel active (check cloudflared logs)
- [ ] Can access services via public URLs
- [ ] Zero Trust authentication working
- [ ] No expired certificates
- [ ] No unusual traffic patterns

**Last Verified:** ___________  
**Notes:** ___________

---

## 📊 Monitoring

### Uptime Kuma
- [ ] Uptime Kuma accessible
- [ ] All monitors showing "Up" (or document expected down)
- [ ] Recent uptime data showing
- [ ] Notifications configured and working (send test)
- [ ] No monitors in "Down" state unexpectedly

**Critical Monitors:**
- [ ] Proxmox: Up
- [ ] TrueNAS: Up
- [ ] Home Assistant: Up
- [ ] Nextcloud: Up
- [ ] Immich: Up
- [ ] Internet connectivity: Up

**Last Verified:** ___________  
**Notes:** ___________

---

### Healthchecks.io (when configured)
- [ ] Healthchecks.io account accessible
- [ ] All checks showing "Up"
- [ ] Backup job checks receiving pings
- [ ] Notifications configured

**Last Verified:** ___________  
**Notes:** ___________

---

## 💾 Backups

### Proxmox Backups
- [ ] Automated backup job configured
- [ ] Last backup successful (<24 hours old)
- [ ] Backup files present on TrueNAS NFS share
- [ ] Backup size reasonable (not growing excessively)
- [ ] Storage space available for backups
- [ ] Retention policy working (old backups deleted)

**Backup details:**
- Last backup: ___________
- Backup size: ___________
- Backups kept: ___/14

**Last Verified:** ___________  
**Notes:** ___________

---

### Home Assistant Backups
- [ ] HA backups configured
- [ ] Last backup successful (<7 days old)
- [ ] Backup size reasonable
- [ ] Can access backup files

**Last Verified:** ___________  
**Notes:** ___________

---

### TrueNAS Config Backup (when automated)
- [ ] Config backup job configured
- [ ] Last config export successful
- [ ] Config files accessible

**Last Verified:** ___________  
**Notes:** ___________

---

### Offsite Backups (when configured)
- [ ] Backblaze B2 accessible
- [ ] Recent sync successful
- [ ] Critical data present in B2
- [ ] Storage usage reasonable

**Last Verified:** ___________  
**Notes:** ___________

---

## 🔋 Power & UPS

### UPS Status
- [ ] UPS showing "Online" status
- [ ] Battery charge >80%
- [ ] Last self-test successful
- [ ] Estimated runtime reasonable
- [ ] PeaNUT/NUT monitoring working
- [ ] Shutdown automation configured (if planned)

**UPS details:**
- Model: ___________
- Battery charge: ___%
- Estimated runtime: ___ minutes

**Last Verified:** ___________  
**Notes:** ___________

---

### Scrutiny (Drive Health)
- [ ] Scrutiny accessible
- [ ] All drives showing "Healthy"
- [ ] No SMART errors
- [ ] No drives with high temperature
- [ ] Recent SMART data available

**Last Verified:** ___________  
**Notes:** ___________

---

## 🧪 Testing (Quarterly)

### Backup Restore Test
- [ ] VM restore tested (last quarter)
- [ ] Application backup restore tested
- [ ] Recovery procedures documented
- [ ] Recovery time acceptable

**Last Tested:** ___________  
**Notes:** ___________

---

### Disaster Recovery Drill
- [ ] Documentation reviewed
- [ ] Recovery procedures validated
- [ ] Missing information documented
- [ ] Backup access confirmed

**Last Tested:** ___________  
**Notes:** ___________

---

## 📝 Issues Found During This Check

| Date | Issue | Severity | Status | Notes |
|------|-------|----------|--------|-------|
| | | High/Med/Low | Open/Fixed | |
| | | | | |
| | | | | |

---

## ✅ Sign-Off

**Verification completed by:** Owner  
**Date:** ___________  
**Overall system health:** Healthy / Needs Attention / Critical Issues  
**Action items created:** Yes / No  
**Next verification due:** ___________

---

## 📅 Verification History

| Date | Completed By | Issues Found | Notes |
|------|--------------|--------------|-------|
| 2026-01-29 | Owner | 0 | Initial checklist creation |
| | | | |
| | | | |
| | | | |

---

## 💡 Tips

- **Don't rush:** Take your time with each check
- **Document everything:** If something seems off, note it
- **Fix critical issues immediately:** Don't wait until next check
- **Update this checklist:** Add/remove items as your setup changes
- **Be honest:** It's better to find issues during planned maintenance than during an emergency

---

**Remember:** This checklist is only useful if you actually run it regularly!

Set a recurring calendar reminder: "Monthly Homelab Verification"
