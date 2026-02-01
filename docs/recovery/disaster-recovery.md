# Disaster Recovery Plan

**Last Updated:** 2026-01-30
**Purpose:** High-level recovery planning and scenario overview

---

## Recovery Principles

1. **Stay calm** - Panic leads to mistakes
2. **Assess first** - Understand what's actually broken
3. **Check backups** - Verify backups exist before proceeding
4. **Document everything** - Take notes as you recover
5. **One thing at a time** - Don't change multiple things simultaneously

---

## Disaster Scenarios

| Scenario | Impact | Recovery Doc |
|----------|--------|--------------|
| Proxmox failure | All VMs down | [proxmox-backup-restore.md](proxmox-backup-restore.md) |
| TrueNAS failure | All data unavailable | [truenas-backup-restore.md](truenas-backup-restore.md) |
| Both servers | Complete homelab loss | See below |
| Accidental VM deletion | Single service down | [proxmox-backup-restore.md](proxmox-backup-restore.md) |
| Service misconfiguration | Single service broken | Restore from app backup |

---

## Pre-Disaster Checklist

**Do these NOW, before you need them:**

### Critical (Must Have)
- [ ] This documentation accessible from multiple locations
- [ ] Backup verification performed in last 30 days
- [ ] Recovery procedures tested at least once
- [ ] Emergency credentials stored securely (password manager)
- [ ] Restore scripts saved offline (USB, cloud storage)

### Important (Should Have)
- [ ] Tailscale account recovery methods set up
- [ ] Cloudflare account recovery methods set up
- [ ] Offsite backup tested (B2/Storj)
- [ ] Proxmox ISO on bootable USB

---

## Catastrophic Loss (Both Servers)

**Scenario:** Fire, flood, theft - both servers destroyed

**This will take days. Accept it. Don't rush.**

### Phase 1: Get Infrastructure Running (Day 1)
1. Obtain replacement hardware
2. Install Proxmox → [proxmox-backup-restore.md](proxmox-backup-restore.md)
3. Install TrueNAS → [truenas-backup-restore.md](truenas-backup-restore.md)
4. Basic network configuration

### Phase 2: Restore Critical Services (Day 1-2)
Priority order:
1. **TrueNAS storage** - Need this for everything
2. **DNS (AdGuard)** - Network functionality
3. **Access layer** - Remote work capability
4. **Monitoring** - Visibility

### Phase 3: Restore Data (Day 2+)
1. Pull data from B2/Storj (takes days for large datasets)
2. Prioritize: Photos > Documents > Media
3. Let it run in background

### Phase 4: Applications (Day 3+)
1. Reinstall apps once data is restored
2. Restore configurations
3. Test functionality

### Prerequisites
Without these, recovery is impossible:
- [ ] Offsite backups accessible (B2/Storj)
- [ ] This documentation accessible
- [ ] Account credentials accessible
- [ ] Replacement hardware available

---

## Recovery Service Priorities

When recovering multiple services, restore in this order:

1. **DNS (AdGuard)** - Network needs name resolution
2. **Home Assistant** - Home automation, safety
3. **Monitoring** - Need visibility into health
4. **Remote access (Tailscale)** - Work remotely
5. **Everything else** - Docker hosts, media, etc.

---

## Testing Schedule

### Monthly
- [ ] Verify Proxmox backups running
- [ ] Verify offsite sync completing (B2/Storj)
- [ ] Check storage space usage

### Quarterly
- [ ] Test VM restore from backup
- [ ] Test file restore from B2
- [ ] Test file restore from Storj
- [ ] Verify documentation is current

### Annually
- [ ] Full disaster recovery simulation
- [ ] Update all documentation

---

## Recovery Log Template

Use this when performing actual recovery:

```
Date: ___________
Scenario: ___________
Cause: ___________

Timeline:
- Event discovered: ___________
- Recovery started: ___________
- Services restored: ___________
- Full recovery: ___________

What Worked:
-

What Didn't Work:
-

Lessons Learned:
-

Documentation Updates Needed:
-
```

---

## Recovery Complete Checklist

Recovery is NOT done until:
- [ ] All critical services operational
- [ ] Data integrity verified
- [ ] Backups resuming automatically
- [ ] Monitoring operational
- [ ] Documentation updated with lessons learned

---

## Related Documentation

- [proxmox-backup-restore.md](proxmox-backup-restore.md) - Proxmox host and VM recovery
- [truenas-backup-restore.md](truenas-backup-restore.md) - TrueNAS and data recovery
- [backup-strategy.md](backup-strategy.md) - Overall backup philosophy

---

## Emergency Contacts

- Proxmox Community: https://forum.proxmox.com
- TrueNAS Community: https://forums.truenas.com
- r/homelab: https://reddit.com/r/homelab
