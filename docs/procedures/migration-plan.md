# Migration Plan: TrueNAS → Proxmox Services

**Goal:** Move infrastructure services from TrueNAS to Proxmox to achieve proper architecture separation.

**Status:** Pre-migration (planning phase)  
**Owner:** User1  
**Last Updated:** 2026-01-29

---

## 🎯 Migration Objectives

### Current State (Problems)
- ❌ DNS (AdGuard) on TrueNAS → can't power down big server
- ❌ Home Assistant on TrueNAS → can't power down big server
- ❌ Access layer (Tailscale, Cloudflare) on TrueNAS → can't power down big server
- ❌ Monitoring split between servers → confusing
- ❌ Big server must run 24/7 → high power consumption
- ❌ No clear separation of concerns → hard to maintain

### Target State (After Migration)
- ✅ DNS (AdGuard) on Proxmox → always available
- ✅ Home Assistant on Proxmox VM → always available
- ✅ Access layer on Proxmox → always available
- ✅ Monitoring consolidated on Proxmox → single source of truth
- ✅ Big server can be powered down → energy savings
- ✅ Clear separation: infra vs storage → easier to maintain

---

## ⚠️ Prerequisites (Must Complete Before Starting)

### ✅ Completed Prerequisites
1. ✅ Current state documented (`current-state.md`)
2. ✅ NFS share from TrueNAS to Proxmox configured
3. ✅ Proxmox backup system configured
4. ✅ Migration plan documented (this file)

### ⏳ Pending Prerequisites
1. ⏳ **Proxmox backup/restore tested** (CRITICAL - do this first!)
2. ⏳ TrueNAS config backup automated
3. ⏳ All family members informed of planned downtime windows
4. ⏳ Emergency rollback plan ready

---

## 🚨 Critical Considerations

### Downtime Awareness
**Reality check:** Some services WILL be unavailable during migration steps.

**Most affected:**
- DNS filtering (AdGuard) - family will notice slower/ad-filled browsing
- Home Assistant - automations will stop working temporarily
- Remote access - may not be able to access services from outside

**Plan:**
- Do migrations during low-usage times (late evening or weekend morning)
- Inform family: "Internet might be slow for 30 minutes"
- Have mobile data hotspot ready as backup internet
- Keep one device that can access both servers (Tailscale on laptop)

### Point of No Return
**Once you start a migration step, commit to finishing it or rolling back.**

Don't leave services in "half-migrated" state overnight.

---

## 📋 Migration Order (Recommended)

### Phase 0: Validation & Testing ⚠️ DO THIS FIRST
**Status:** Not started  
**Expected time:** 2-3 hours  
**Risk:** Low (only testing)

**Steps:**
1. Create a test VM on Proxmox (Ubuntu Server or Alpine)
2. Take a backup of the test VM
3. Delete the test VM
4. Restore the VM from backup
5. Verify the restored VM boots and works
6. Document the restore process step-by-step
7. Take screenshots of each step

**Success criteria:**
- [ ] Can restore a VM without issues
- [ ] Understand the restore process
- [ ] Confident in backup system

**Blockers if this fails:**
- DO NOT PROCEED with migration until backups work
- Fix backup/restore issues first

---

### Phase 1: Uptime Kuma Consolidation
**Status:** Partially complete (already on Proxmox)  
**Expected time:** 30 minutes  
**Downtime:** None (monitoring only)  
**Risk:** Very low

**Current state:**
- Uptime Kuma on Proxmox VM 100 ✅
- Duplicate Uptime Kuma on TrueNAS ❌

**Steps:**
1. Export monitors from TrueNAS Uptime Kuma
2. Import missing monitors to Proxmox Uptime Kuma
3. Verify all monitors working on Proxmox
4. Update bookmarks/shortcuts to point to Proxmox instance
5. Stop TrueNAS Uptime Kuma instance
6. Monitor for 48 hours
7. Delete TrueNAS Uptime Kuma if no issues

**Rollback:** Restart TrueNAS Uptime Kuma if needed

---

### Phase 2: AdGuard Home Migration
**Status:** Not started  
**Expected time:** 1-2 hours  
**Downtime:** 5-15 minutes (DNS unavailable)  
**Risk:** Medium (affects entire network)

**Current state:**
- AdGuard on TrueNAS
- Primary DNS for all devices

**Preparation:**
1. Verify router fallback DNS configured (Cloudflare 1.1.1.1)
2. Export AdGuard config from TrueNAS
3. Create new VM on Proxmox for AdGuard
   - OS: Debian 12 or Ubuntu Server 24.04
   - RAM: 1 GB
   - CPU: 1 core
   - Disk: 8 GB
4. Install AdGuard Home on new VM
5. Import configuration
6. Test DNS resolution from Proxmox VM
7. Test DNS filtering (visit known ad domain)

**Migration steps:**
1. **[Start timer - downtime begins]**
2. Change router DNS to point to new AdGuard IP
3. Wait 30 seconds for propagation
4. Test DNS from multiple devices
5. Verify filtering working
6. **[Stop timer - downtime ends]**
7. Monitor for 2-3 days
8. If stable, stop TrueNAS AdGuard
9. Wait 1 week before deleting TrueNAS AdGuard

**Rollback plan:**
1. Change router DNS back to TrueNAS AdGuard IP
2. Wait 30 seconds
3. Test DNS working
4. Troubleshoot Proxmox AdGuard offline

**Success criteria:**
- [ ] All devices resolving DNS
- [ ] Ads being blocked
- [ ] No performance issues
- [ ] Family doesn't notice change

---

### Phase 3: Home Assistant Migration
**Status:** Not started  
**Expected time:** 2-3 hours  
**Downtime:** 15-30 minutes (automations stopped)  
**Risk:** High (affects daily life)

**Current state:**
- Home Assistant OS on TrueNAS
- Zigbee coordinator (ZBT-2) USB device on TrueNAS
- Daily automations active
- Family depends on this

**Preparation:**
1. Create full backup of HA on TrueNAS (automatic + manual)
2. Document all USB device IDs
3. Create new VM on Proxmox
   - OS: Home Assistant OS (OVA image)
   - RAM: 4 GB
   - CPU: 2 cores
   - Disk: 32 GB
4. DO NOT START VM YET

**Critical decision point:**
⚠️ **USB Device Strategy:**

**Option A: Physical USB device passthrough**
- Move Zigbee USB from TrueNAS to Proxmox physically
- Pros: Better performance, lower latency
- Cons: Requires physical access, Zigbee offline during move

**Option B: USB/IP over network**
- Keep USB on TrueNAS, connect via network
- Pros: No physical move, can test easily
- Cons: Added latency, complex setup, TrueNAS must stay on

**Recommended: Option A** (physical passthrough)

**Migration steps:**
1. **[Preparation - no downtime]**
   - Inform family: "Automations will stop for 30 min"
   - Best time: Late evening when automations less critical
2. **[Start timer - downtime begins]**
3. Stop Home Assistant on TrueNAS (graceful shutdown)
4. Physically move Zigbee USB to Proxmox host
5. Configure USB passthrough in Proxmox to HA VM
6. Start HA VM on Proxmox
7. Wait for HA to boot (2-3 minutes)
8. Restore backup from TrueNAS
9. Wait for restore (5-10 minutes)
10. Restart HA
11. Wait for boot (2-3 minutes)
12. Verify Zigbee coordinator detected
13. Verify automations loaded
14. Test critical automations manually
15. **[Stop timer - downtime ends]**
16. Monitor for 1-2 weeks
17. If stable, remove HA from TrueNAS

**USB Passthrough Commands (Proxmox):**
```bash
# Find USB device
lsusb

# Add to VM config (example)
qm set <VMID> -usb0 host=<vendorid>:<productid>
```

**Rollback plan:**
1. Stop HA VM on Proxmox
2. Move USB back to TrueNAS physically
3. Start HA on TrueNAS
4. Verify automations working
5. Troubleshoot Proxmox HA offline

**Success criteria:**
- [ ] HA accessible via web UI and app
- [ ] All Zigbee devices responding
- [ ] All automations working
- [ ] No "unavailable" entities
- [ ] Mobile app connected
- [ ] Notifications working
- [ ] Family doesn't notice difference

**Post-migration tasks:**
- Update Tailscale app config (new IP)
- Update mobile app config (new IP)
- Update Uptime Kuma monitor
- Update QUICK-REFERENCE.md with new IP

---

### Phase 4: Access Layer Migration
**Status:** Not started  
**Expected time:** 1-2 hours  
**Downtime:** 10-20 minutes (remote access unavailable)  
**Risk:** Medium (affects remote access)

**Current state:**
- Tailscaled on TrueNAS
- Cloudflared on TrueNAS

**Target:**
- Tailscale on Proxmox (host or VM)
- Cloudflare Tunnel on Proxmox VM

**Preparation:**
1. Decide: Tailscale on Proxmox host or in VM?
   - Recommendation: **Proxmox host** (simpler, more reliable)
2. Generate new Tailscale auth key
3. Prepare Cloudflare Tunnel config export

**Migration steps:**

**Tailscale:**
1. Install Tailscale on Proxmox host
2. Authenticate with auth key
3. Enable subnet routing (if used)
4. Test connectivity from mobile device
5. Verify can access all services
6. Stop Tailscale on TrueNAS
7. Monitor for 1 week

**Cloudflare Tunnel:**
1. Create new VM on Proxmox (or use existing)
2. Install cloudflared
3. Configure tunnel (import config from TrueNAS)
4. Start tunnel
5. Test access from public URLs
6. Stop tunnel on TrueNAS
7. Monitor for 1 week

**Rollback plan:**
- Restart services on TrueNAS
- Update DNS if needed

**Success criteria:**
- [ ] Can access services via Tailscale from mobile
- [ ] Can access services via Cloudflare Tunnel
- [ ] No connection issues
- [ ] No certificate warnings

---

### Phase 5: Final Validation & Cleanup
**Status:** Not started  
**Expected time:** 1 hour  
**Downtime:** None

**Steps:**
1. Verify all services running on Proxmox
2. Power down TrueNAS for 24 hours (test)
3. Verify everything still works without TrueNAS
4. Document any issues found
5. Power up TrueNAS
6. Remove old services from TrueNAS:
   - Stop AdGuard
   - Stop Home Assistant
   - Stop Uptime Kuma
   - Stop Tailscale
   - Stop Cloudflare Tunnel
7. Update `current-state.md` to reflect new reality
8. Update `QUICK-REFERENCE.md` with new IPs
9. Celebrate! 🎉

---

## 📊 Migration Progress Tracker

| Phase | Service | Status | Started | Completed | Issues |
|-------|---------|--------|---------|-----------|--------|
| 0 | Backup Testing | ⏳ Not started | - | - | - |
| 1 | Uptime Kuma | ⏳ Partial | - | - | - |
| 2 | AdGuard Home | ⏳ Not started | - | - | - |
| 3 | Home Assistant | ⏳ Not started | - | - | - |
| 4 | Access Layer | ⏳ Not started | - | - | - |
| 5 | Final Validation | ⏳ Not started | - | - | - |

---

## 🎯 Success Metrics

### Technical Success
- [ ] All services running on Proxmox
- [ ] TrueNAS can be powered down without affecting infrastructure
- [ ] All backups working
- [ ] No performance degradation
- [ ] Documentation updated

### User Success
- [ ] Family doesn't notice changes (except faster/better)
- [ ] All automations still working
- [ ] No complaints about internet speed
- [ ] Remote access still works
- [ ] No increase in "it's broken" reports

---

## 🚨 Emergency Contacts

**If something goes badly wrong:**

1. **Don't panic** - Everything can be rolled back
2. **Check logs** - Usually tells you what's wrong
3. **Rollback to TrueNAS** - If needed, temporary fix
4. **Ask for help** - r/homelab, forums, Claude
5. **Document the issue** - Add to LESSONS-LEARNED.md

**Emergency rollback:**
- Restart services on TrueNAS
- Change router DNS back to TrueNAS (if DNS affected)
- Wait 24 hours to calm down
- Read logs and troubleshoot
- Try again when you understand what went wrong

---

## 📝 Notes & Observations

### During Migration
(Add notes here as you work through migration)

**Date:** ___________  
**Phase:** ___________  
**Note:** ___________

---

## 🎓 Lessons from This Migration

(Fill this out AFTER completing migration)

**What went well:**
- 

**What was harder than expected:**
- 

**What I'd do differently next time:**
- 

**Unexpected issues:**
- 

**Tools that helped:**
- 

**Time estimate accuracy:**
- 

---

**Last Updated:** 2026-01-29  
**Migration Status:** Planning phase  
**Next Action:** Test Proxmox backup/restore (Phase 0)
