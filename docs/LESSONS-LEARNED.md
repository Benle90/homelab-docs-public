# Lessons Learned

**Purpose:** Document mistakes, discoveries, and "things I wish I knew earlier."

**Why this matters:** You're new to Linux and self-hosting. Future-you will thank current-you for writing this down.

---

## 🎯 How to Use This Document

After solving a problem or learning something valuable:
1. Add an entry with the date
2. Describe what went wrong (or what you discovered)
3. Explain the solution
4. Write down what you learned
5. Note if documentation needs updating

---

## 2026-02-01: Cron Jobs Need Full Paths

### What Happened
S.M.A.R.T long test cron job on TrueNAS failed with `smartctl: not found` error, even though `smartctl` works fine in the terminal.

### The Problem
- Cron jobs run with a minimal PATH environment variable
- Commands like `smartctl` that are in `/usr/sbin/` aren't found
- The same command works in an interactive shell but fails in cron

### The Solution
Use absolute paths in cron commands:
```bash
# Wrong
smartctl -t short /dev/disk/by-id/...

# Correct
/usr/sbin/smartctl -t short /dev/disk/by-id/...
```

Find the full path with: `which smartctl`

### Lesson Learned
**Always use absolute paths in cron jobs.**
- Cron's PATH is typically just `/usr/bin:/bin`
- Don't assume commands will be found just because they work in terminal
- This applies to any scheduled task system, not just cron

### Related Documentation
- Updated [storage-server.md](servers/storage-server.md#scheduled-tasks) with correct commands
- GitHub Issue #15 tracks related email notification problem

---

## 2025-12-15: Nextcloud overwritehost Causes Forced Redirects

### What Happened
While trying to configure Collabora Online for Nextcloud, followed a guide that set `overwritehost` in config.php. After that, Nextcloud redirected ALL requests to the public domain (Cloudflare Zero Trust), even when accessing via local IP. This completely broke internal LAN and Tailscale access.

### The Problem
- `overwritehost` tells Nextcloud to redirect ALL requests to that hostname
- Even accessing via `http://192.168.178.10:30027` redirected to `https://cloud.domain.com`
- Reinstalling the Nextcloud app didn't help (config persists in app data)
- Removing the setting via TrueNAS app UI didn't fully remove it from config.php

### The Solution
Had to manually delete the config values using `occ`:
```bash
occ config:system:delete overwritehost
occ config:system:delete overwriteprotocol
occ config:system:delete overwrite.cli.url
```

After removing these, local IP access worked again without redirects.

### Lesson Learned
**Understand the difference between Nextcloud's overwrite settings:**

| Setting | Effect | Use Case |
|---------|--------|----------|
| `overwritehost` | **Redirects ALL requests** to this host | Single access method only (NOT for mixed LAN + domain) |
| `overwriteprotocol` | Changes protocol in generated links | Behind HTTPS proxy |
| `overwrite.cli.url` | Default URL for CLI/cron/background jobs | Share links, email notifications |

**For mixed access (LAN + external domain):**
- Do NOT set `overwritehost` - it forces redirects
- Only set `overwrite.cli.url` to control generated links (share URLs, etc.)
- Accept that share links will use one "canonical" URL

**TrueNAS app settings don't always sync with config.php:**
- Changes in UI may not fully apply
- Always verify with `occ config:system:get <key>` or read config.php directly
- Use `occ config:system:delete` to fully remove settings

### Related Documentation
- Reddit post: [r/NextCloud thread](https://www.reddit.com/r/NextCloud/comments/1pnd0hq/help_nextcloud_local_access_always_redirects_to/)
- GitHub Issue #19: Nextcloud access configuration review

---

## 2026-01-29: NFS Security with Tailscale Subnet Routing

### What Happened
When setting up Proxmox backups to TrueNAS via NFS, discovered that Tailscale subnet routing exposes NFS shares to all Tailscale users, not just the local network.

### The Problem
- TrueNAS NFS shares are meant for LAN-only access
- Tailscale subnet routing (100.x.x.x subnet) allowed access from any Tailscale-connected device
- Default NFS security is based on IP ranges
- Could accidentally expose sensitive data

### The Solution
- Restricted NFS share access to specific IP: `192.168.178.11/32` (Proxmox only)
- Used TrueNAS allowed hosts/networks feature
- Result: Only Proxmox can mount the NFS share, even with Tailscale routing enabled

### Lesson Learned
**When using VPN subnet routing, always verify what becomes accessible.**
- VPN routing changes the security model
- Test with `showmount -e <truenas-ip>` from different devices
- Use the most restrictive permissions possible
- Document security decisions in your architecture docs

### Related Documentation
- Updated `backup-strategy.md` with NFS security notes
- Added to `CHANGELOG.md`

---

## 2026-01-XX: Minecraft Server Performance on HDD

### What Happened
Tried to run Minecraft server (crafty-4) on TrueNAS with game files on spinning HDDs (Seagate IronWolf).

### The Problem
- HDDs too slow for real-time game server operations
- High latency, player lag
- Frequent timeouts
- Poor gaming experience

### The Solution
- Need to move game server to SSD storage
- Options:
  1. Run on Proxmox VM with local SSD
  2. Create SSD-backed dataset on TrueNAS
  3. Accept that games need fast storage

### Lesson Learned
**Different workloads have different I/O requirements:**
- **HDDs are fine for:** Bulk storage, photos, media streaming, backups
- **SSDs are necessary for:** Databases, game servers, VMs, anything with random I/O
- Don't assume "it's just files" means HDD is acceptable
- Test performance before committing to a storage location

### Status
- Crafty-4 currently not actively used due to performance issues
- Will revisit when SSD storage strategy is clear

---

## YYYY-MM-DD: Template for Future Entries

### What Happened
Brief description of the situation or problem.

### The Problem
- What went wrong
- Why it was a problem
- What you expected vs what happened

### The Solution
- What you did to fix it
- Steps taken
- Tools used

### Lesson Learned
**Key takeaway in bold.**
- Specific learning points
- How to avoid this in the future
- General principles discovered

### Related Documentation
- Links to updated docs
- Where this is now documented

---

## 💡 General Wisdom

### Things I Wish I Knew Earlier

**Documentation:**
- Document while you work, not after (you'll forget details)
- Screenshots are worth 1000 words (especially for UI configurations)
- Note WHY you did something, not just WHAT you did

**Linux & Self-Hosting:**
- Read logs first, Google second, ask for help third
- Most problems have been solved before (forums are your friend)
- `systemctl status <service>` is your first debugging step
- Permissions issues are almost always the problem (especially with Docker)

**Homelab Specific:**
- Start small, add complexity gradually
- Backups don't count unless you've tested restoring
- Document your network (IPs, VLANs, firewall rules) - you will forget
- Label everything physically (cables, drives, ports)

**Proxmox:**
- VMs are easier to backup/restore than LXC containers
- Give VMs more resources than you think they need
- Always enable QEMU guest agent
- Snapshots are not backups

**TrueNAS:**
- ZFS is amazing but unforgiving (don't mess with pools unless you know what you're doing)
- Apps (TrueCharts) are convenient but can be fragile during updates
- Always export config before major changes
- Monitor drive health with Scrutiny

**Home Assistant:**
- Start with notifications, not actions (test your logic first)
- Helpers (input_boolean, etc.) make automations more maintainable
- Separate infrastructure from behavior (why ha_automations.md exists)
- Backup before updating

**Networking:**
- Tailscale is easier than VPN (and more secure)
- Cloudflare Tunnel + Zero Trust = no port forwarding needed
- Local DNS (AdGuard) improves everything
- Document your firewall rules

---

## 🚫 Common Mistakes (Don't Do These)

### Docker / Containers
- ❌ Running containers as root unnecessarily
- ❌ Not using volumes for persistent data
- ❌ Not specifying versions (using `:latest` tag)
- ❌ Forgetting to expose ports in docker-compose

### Backups
- ❌ Assuming backup = tested backup
- ❌ Storing backups only on same server
- ❌ Not documenting restore procedures
- ❌ Forgetting to backup configuration files

### System Administration
- ❌ Updating everything at once (recipe for disaster)
- ❌ Not reading release notes before updating
- ❌ Changing multiple things at once (can't debug)
- ❌ Not having a rollback plan

### Security
- ❌ Exposing admin panels to internet
- ❌ Using default passwords
- ❌ Not understanding what VPN/tunnel exposes
- ❌ Giving too many permissions "just to make it work"

---

## 🎓 Resources That Helped

### Communities
- **r/homelab** - General homelab help and inspiration
- **r/selfhosted** - Self-hosted service recommendations
- **Proxmox Forum** - Proxmox-specific issues
- **TrueNAS Forum** - TrueNAS and ZFS help
- **Home Assistant Community** - HA automations and integrations

### Documentation
- **Proxmox Wiki** - https://pve.proxmox.com/wiki/
- **TrueNAS Docs** - https://www.truenas.com/docs/
- **Home Assistant Docs** - https://www.home-assistant.io/docs/
- **Tailscale Docs** - https://tailscale.com/kb/

### YouTube Channels
- Techno Tim - Homelab tutorials
- Awesome Open Source - Self-hosted services
- Jeff Geerling - Raspberry Pi and homelab

---

## 📈 Progress Tracking

### Skills Acquired
- [ ] Basic Linux command line
- [ ] Docker basics
- [ ] ZFS fundamentals
- [ ] Proxmox VM management
- [ ] Home Assistant automation
- [ ] Network troubleshooting
- [ ] Backup/restore procedures
- [ ] Git for documentation

### Next Skills to Learn
- [ ] Advanced networking (VLANs, firewall rules)
- [ ] Infrastructure as Code (Terraform, Ansible)
- [ ] Monitoring and alerting
- [ ] Advanced ZFS (replication, send/receive)
- [ ] Kubernetes (maybe, someday)

---

## 🎯 Project Milestones

### Completed
- ✅ Basic homelab setup (TrueNAS + Proxmox)
- ✅ Core services running (Nextcloud, Immich, HA)
- ✅ Remote access working (Tailscale + Cloudflare)
- ✅ Proxmox backups automated
- ✅ Documentation started

### In Progress
- ⏳ Migration to proper architecture (infra on Proxmox)
- ⏳ Backup strategy fully implemented
- ⏳ Testing and validation procedures

### Planned
- 📅 Offsite backups (Backblaze B2)
- 📅 Monitoring and alerting
- 📅 UPS-aware shutdown automation
- 📅 Advanced Home Assistant automations

---

**Last Updated:** 2026-02-01

**Remember:** Every mistake is a learning opportunity. Document them so you don't repeat them!
