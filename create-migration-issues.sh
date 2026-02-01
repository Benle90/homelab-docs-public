#!/bin/bash
# Script to create GitHub issues from migration-plan.md
# Run this after installing and authenticating with GitHub CLI

set -e

echo "Creating labels..."

# Create labels if they don't exist
gh label create "migration" --description "Service migration tasks" --color "0366d6" 2>/dev/null || echo "  - Label 'migration' already exists"
gh label create "critical" --description "Critical priority tasks" --color "d73a4a" 2>/dev/null || echo "  - Label 'critical' already exists"
gh label create "testing" --description "Testing related tasks" --color "d4c5f9" 2>/dev/null || echo "  - Label 'testing' already exists"
gh label create "monitoring" --description "Monitoring related tasks" --color "c5def5" 2>/dev/null || echo "  - Label 'monitoring' already exists"
gh label create "dns" --description "DNS related tasks" --color "fbca04" 2>/dev/null || echo "  - Label 'dns' already exists"
gh label create "medium-risk" --description "Medium risk changes" --color "f9d0c4" 2>/dev/null || echo "  - Label 'medium-risk' already exists"
gh label create "high-risk" --description "High risk changes" --color "d93f0b" 2>/dev/null || echo "  - Label 'high-risk' already exists"
gh label create "home-assistant" --description "Home Assistant related" --color "0e8a16" 2>/dev/null || echo "  - Label 'home-assistant' already exists"
gh label create "networking" --description "Networking related tasks" --color "5319e7" 2>/dev/null || echo "  - Label 'networking' already exists"
gh label create "documentation" --description "Documentation tasks" --color "0075ca" 2>/dev/null || echo "  - Label 'documentation' already exists"

echo ""
echo "Creating migration GitHub issues..."

# Phase 0: Backup Testing
gh issue create --title "Phase 0: Validate Proxmox Backup/Restore System" --body "$(cat <<'EOF'
## Priority: CRITICAL - Must complete before any migration

Test the backup and restore process to ensure we can recover VMs if something goes wrong.

### Steps:
1. Create a test VM on Proxmox (Ubuntu Server or Alpine)
2. Take a backup of the test VM
3. Delete the test VM
4. Restore the VM from backup
5. Verify the restored VM boots and works
6. Document the restore process step-by-step
7. Take screenshots of each step

### Success Criteria:
- [ ] Can restore a VM without issues
- [ ] Understand the restore process
- [ ] Confident in backup system

### Estimated Time: 2-3 hours
### Risk: Low (only testing)
### Downtime: None

**BLOCKER:** Do NOT proceed with any migration phases until this is complete and successful.

Related file: `procedures/migration-plan.md` (Phase 0)
EOF
)" --label "critical,migration,testing"

echo "✅ Created Phase 0 issue"

# Phase 1: Uptime Kuma
gh issue create --title "Phase 1: Consolidate Uptime Kuma Monitoring" --body "$(cat <<'EOF'
## Migration Phase 1: Uptime Kuma

Consolidate monitoring by migrating all monitors to the Proxmox instance and removing the duplicate TrueNAS instance.

### Current State:
- ✅ Uptime Kuma running on Proxmox VM 100 (http://192.168.178.12:3001/dashboard)
- ❌ Duplicate Uptime Kuma on TrueNAS (http://192.168.178.10:31050)

### Steps:
1. Export monitors from TrueNAS Uptime Kuma
2. Import missing monitors to Proxmox Uptime Kuma
3. Verify all monitors working on Proxmox
4. Update bookmarks/shortcuts to point to Proxmox instance
5. Stop TrueNAS Uptime Kuma instance
6. Monitor for 48 hours
7. Delete TrueNAS Uptime Kuma if no issues

### Rollback Plan:
- Restart TrueNAS Uptime Kuma if needed

### Success Criteria:
- [ ] All monitors consolidated on Proxmox
- [ ] No monitoring gaps
- [ ] Bookmarks updated

### Estimated Time: 30 minutes
### Risk: Very Low
### Downtime: None (monitoring only)

**Depends on:** Phase 0 (backup testing)

Related file: `procedures/migration-plan.md` (Phase 1)
EOF
)" --label "migration,monitoring"

echo "✅ Created Phase 1 issue"

# Phase 2: AdGuard Home
gh issue create --title "Phase 2: Migrate AdGuard Home (DNS)" --body "$(cat <<'EOF'
## Migration Phase 2: AdGuard Home

Move DNS filtering from TrueNAS to Proxmox to enable powering down TrueNAS.

### Current State:
- AdGuard on TrueNAS (http://192.168.178.10:30004/)
- Primary DNS for all devices on network

### Preparation Steps:
1. Verify router fallback DNS configured (Cloudflare 1.1.1.1)
2. Export AdGuard config from TrueNAS
3. Create new VM on Proxmox for AdGuard
   - OS: Debian 12 or Ubuntu Server 24.04
   - RAM: 1 GB, CPU: 1 core, Disk: 8 GB
4. Install AdGuard Home on new VM
5. Import configuration
6. Test DNS resolution from Proxmox VM
7. Test DNS filtering (visit known ad domain)

### Migration Steps:
1. **[Start timer - downtime begins]**
2. Change router DNS to point to new AdGuard IP
3. Wait 30 seconds for propagation
4. Test DNS from multiple devices
5. Verify filtering working
6. **[Stop timer - downtime ends]**
7. Monitor for 2-3 days
8. If stable, stop TrueNAS AdGuard
9. Wait 1 week before deleting TrueNAS AdGuard

### Rollback Plan:
1. Change router DNS back to TrueNAS AdGuard IP (192.168.178.10)
2. Wait 30 seconds
3. Test DNS working
4. Troubleshoot Proxmox AdGuard offline

### Success Criteria:
- [ ] All devices resolving DNS
- [ ] Ads being blocked
- [ ] No performance issues
- [ ] Family doesn't notice change

### Estimated Time: 1-2 hours
### Risk: Medium (affects entire network)
### Downtime: 5-15 minutes (DNS unavailable)

**Best time:** Late evening or weekend morning (low usage time)
**Inform family:** "Internet might be slow for 30 minutes"

**Depends on:** Phase 0, Phase 1 (optional)

Related file: `procedures/migration-plan.md` (Phase 2)
EOF
)" --label "migration,dns,medium-risk"

echo "✅ Created Phase 2 issue"

# Phase 3: Home Assistant
gh issue create --title "Phase 3: Migrate Home Assistant" --body "$(cat <<'EOF'
## Migration Phase 3: Home Assistant

Move Home Assistant from TrueNAS to Proxmox VM with USB Zigbee coordinator passthrough.

### Current State:
- Home Assistant OS on TrueNAS (http://homeassistant.local:8123/)
- Zigbee coordinator (ZBT-2) USB device on TrueNAS
- Daily automations active
- **Family depends on this service**

### Preparation Steps:
1. Create full backup of HA on TrueNAS (automatic + manual)
2. Document all USB device IDs
3. Create new VM on Proxmox
   - OS: Home Assistant OS (OVA image)
   - RAM: 4 GB, CPU: 2 cores, Disk: 32 GB
4. DO NOT START VM YET

### USB Device Strategy:
**Physical USB passthrough** (recommended)
- Move Zigbee USB from TrueNAS to Proxmox physically
- Better performance, lower latency

### Migration Steps:
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

### USB Passthrough Commands:
\`\`\`bash
# Find USB device
lsusb

# Add to VM config
qm set <VMID> -usb0 host=<vendorid>:<productid>
\`\`\`

### Rollback Plan:
1. Stop HA VM on Proxmox
2. Move USB back to TrueNAS physically
3. Start HA on TrueNAS
4. Verify automations working
5. Troubleshoot Proxmox HA offline

### Success Criteria:
- [ ] HA accessible via web UI and app
- [ ] All Zigbee devices responding
- [ ] All automations working
- [ ] No "unavailable" entities
- [ ] Mobile app connected
- [ ] Notifications working
- [ ] Family doesn't notice difference

### Post-Migration Tasks:
- Update Tailscale app config (new IP)
- Update mobile app config (new IP)
- Update Uptime Kuma monitor
- Update QUICK-REFERENCE.md with new IP

### Estimated Time: 2-3 hours
### Risk: High (affects daily life)
### Downtime: 15-30 minutes (automations stopped)

**Best time:** Late evening or weekend morning
**Inform family beforehand!**

**Depends on:** Phase 0, Phase 2 (optional but recommended)

Related file: `procedures/migration-plan.md` (Phase 3)
EOF
)" --label "migration,home-assistant,high-risk"

echo "✅ Created Phase 3 issue"

# Phase 4: Access Layer
gh issue create --title "Phase 4: Migrate Access Layer (Tailscale + Cloudflare Tunnel)" --body "$(cat <<'EOF'
## Migration Phase 4: Access Layer

Move remote access services (Tailscale and Cloudflare Tunnel) from TrueNAS to Proxmox.

### Current State:
- Tailscaled on TrueNAS
- Cloudflared on TrueNAS

### Target:
- Tailscale on Proxmox host (recommended)
- Cloudflare Tunnel on Proxmox VM

### Preparation Steps:
1. Decide: Tailscale on Proxmox host or in VM?
   - **Recommendation:** Proxmox host (simpler, more reliable)
2. Generate new Tailscale auth key
3. Prepare Cloudflare Tunnel config export

### Migration Steps - Tailscale:
1. Install Tailscale on Proxmox host
2. Authenticate with auth key
3. Enable subnet routing (if used)
4. Test connectivity from mobile device
5. Verify can access all services
6. Stop Tailscale on TrueNAS
7. Monitor for 1 week

### Migration Steps - Cloudflare Tunnel:
1. Create new VM on Proxmox (or use existing)
2. Install cloudflared
3. Configure tunnel (import config from TrueNAS)
4. Start tunnel
5. Test access from public URLs
6. Stop tunnel on TrueNAS
7. Monitor for 1 week

### Rollback Plan:
- Restart services on TrueNAS
- Update DNS if needed

### Success Criteria:
- [ ] Can access services via Tailscale from mobile
- [ ] Can access services via Cloudflare Tunnel
- [ ] No connection issues
- [ ] No certificate warnings

### Estimated Time: 1-2 hours
### Risk: Medium (affects remote access)
### Downtime: 10-20 minutes (remote access unavailable)

**Best time:** When home on LAN (in case remote access breaks)

**Depends on:** Phase 0, Phase 3 (recommended)

Related file: `procedures/migration-plan.md` (Phase 4)
EOF
)" --label "migration,networking,medium-risk"

echo "✅ Created Phase 4 issue"

# Phase 5: Final Validation
gh issue create --title "Phase 5: Final Validation & Cleanup" --body "$(cat <<'EOF'
## Migration Phase 5: Final Validation

Final testing and cleanup after all services have been migrated.

### Steps:
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
7. Update \`current-state.md\` to reflect new reality
8. Update \`QUICK-REFERENCE.md\` with new IPs and services
9. Update \`servers/storage-server.md\` to remove migrated services
10. Celebrate! 🎉

### Success Criteria - Technical:
- [ ] All services running on Proxmox
- [ ] TrueNAS can be powered down without affecting infrastructure
- [ ] All backups working
- [ ] No performance degradation
- [ ] Documentation updated

### Success Criteria - User:
- [ ] Family doesn't notice changes (except faster/better)
- [ ] All automations still working
- [ ] No complaints about internet speed
- [ ] Remote access still works
- [ ] No increase in "it's broken" reports

### Estimated Time: 1 hour
### Risk: Low
### Downtime: None

**Depends on:** All previous phases (0-4)

Related file: `procedures/migration-plan.md` (Phase 5)
EOF
)" --label "migration,documentation"

echo "✅ Created Phase 5 issue"

echo ""
echo "🎉 All migration issues created successfully!"
echo ""
echo "View your issues: gh issue list --label migration"
