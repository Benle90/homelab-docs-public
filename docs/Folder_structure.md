homelab-docs/
├── README.md                           # Entry point, quick overview
├── CHANGELOG.md                        # Track all major changes (NEW)
├── QUICK-REFERENCE.md                  # Fast access to IPs, URLs, commands (NEW)
├── VERIFICATION-CHECKLIST.md           # Monthly system health checks (NEW)
├── LESSONS-LEARNED.md                  # Mistakes, discoveries, wisdom (NEW)
│
├── current-state.md                    # What is running RIGHT NOW
├── architecture.md                     # Target/goal architecture
├── network.md                          # Network topology, IPs, VLANs
│
├── servers/
│   ├── infra-server.md                 # Small server (Proxmox)
│   └── storage-server.md               # Big server (TrueNAS)
│
├── services/
│   ├── dns-adguard.md                  # DNS filtering
│   ├── home-assistant/
│   │   ├── home_assistant.md           # HA infrastructure (RENAMED/MOVED)
│   │   └── ha_automations.md           # HA logic and automations (RENAMED/MOVED)
│   ├── nextcloud.md                    # File sync, calendar, contacts
│   ├── immich.md                       # Photo library
│   ├── monitoring.md                   # Uptime Kuma
│   └── jellyfin.md                     # Media server (OPTIONAL - create if needed)
│
├── recovery/
│   ├── backup-strategy.md              # Complete backup documentation
│   ├── disaster-recovery.md            # Recovery procedures (NEW)
│   └── backups.md                      # (DEPRECATED - info moved to backup-strategy.md)
│
├── procedures/
│   ├── migration-plan.md               # TrueNAS → Proxmox migration (NEW)
│   └── runbooks/                       # Step-by-step procedures (OPTIONAL)
│       ├── restore-vm.md               # How to restore a VM
│       ├── restore-truenas.md          # How to restore TrueNAS
│       └── add-new-service.md          # Adding new services
│
├── templates/                          # Reusable templates
│   └── lesson-learned.md               # Template for LESSONS-LEARNED entries
│
└── projects/
    ├── homelab-proxmox.md              # Proxmox learning notes
    └── future-ideas.md                 # Future project ideas (OPTIONAL)

---

## File Status Legend

- (NEW) = Created in this update
- (RENAMED/MOVED) = Existing file that should be reorganized
- (DEPRECATED) = Old file, content merged elsewhere
- (OPTIONAL) = Create when needed, not immediately required

---

## Recommended Next Steps

### Immediate (Do Now)
1. Add the 6 new files to your repository root:
   - CHANGELOG.md
   - QUICK-REFERENCE.md
   - VERIFICATION-CHECKLIST.md
   - LESSONS-LEARNED.md

2. Create `procedures/` folder and add:
   - migration-plan.md

3. Update `recovery/` folder:
   - Add disaster-recovery.md

### Soon (This Week)
1. Create `services/home-assistant/` subfolder
2. Move `home_assistant.md` → `services/home-assistant/home_assistant.md`
3. Move `ha_automations.md` → `services/home-assistant/ha_automations.md`

### Later (As Needed)
1. Create `procedures/runbooks/` when you have tested procedures
2. Create `projects/future-ideas.md` for brainstorming
3. Mark `backups.md` as deprecated (content is in backup-strategy.md)

---

## Alternative: Flat Structure (If You Prefer Simple)

If folders feel like overkill, you can keep everything flat at the root:

homelab-docs/
├── README.md
├── CHANGELOG.md                    # NEW
├── QUICK-REFERENCE.md              # NEW
├── VERIFICATION-CHECKLIST.md       # NEW
├── LESSONS-LEARNED.md              # NEW
├── current-state.md
├── architecture.md
├── network.md
├── infra-server.md
├── storage-server.md
├── dns-adguard.md
├── home_assistant.md
├── ha_automations.md
├── nextcloud.md
├── immich.md
├── monitoring.md
├── backup-strategy.md
├── disaster-recovery.md            # NEW
├── migration-plan.md               # NEW
└── homelab-proxmox.md

Both work fine - choose based on your preference!
- Folders = More organized, scales better
- Flat = Simpler, easier to navigate initially

---

## Migration Guide: How to Reorganize

### Option 1: Keep It Flat (Easiest)
```bash
# Just add the new files to your root directory
# No reorganization needed
```

### Option 2: Organize Into Folders (Recommended)
```bash
# Create new directories
mkdir -p services/home-assistant
mkdir -p procedures/runbooks
mkdir -p recovery
mkdir -p servers
mkdir -p projects

# Move existing files
mv home_assistant.md services/home-assistant/
mv ha_automations.md services/home-assistant/
mv infra-server.md servers/
mv storage-server.md servers/
mv dns-adguard.md services/
mv nextcloud.md services/
mv immich.md services/
mv monitoring.md services/
mv backup-strategy.md recovery/
mv backups.md recovery/
mv homelab-proxmox.md projects/

# Add new files
mv CHANGELOG.md .
mv QUICK-REFERENCE.md .
mv VERIFICATION-CHECKLIST.md .
mv LESSONS-LEARNED.md .
mv disaster-recovery.md recovery/
mv migration-plan.md procedures/

# Update README.md to reference new structure
```

### Option 3: Gradual Migration (Safest)
1. Add new files to root first
2. Use them for a week
3. Then reorganize into folders when comfortable
4. Update internal links as you go

---

## Notes

- **Choose one structure and stick with it**
- Folders are better long-term but flat is fine for small setups
- All internal links (like in README.md) will need updating if you reorganize
- Git makes reorganization safe (you can always revert)
- Your current setup works - don't feel pressured to reorganize immediately

**Recommendation for you:** Start with flat structure (just add new files to root), then organize into folders after your migration is complete.
