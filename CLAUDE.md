# Claude Code Instructions for Homelab Documentation

This file provides context and instructions for Claude Code when working with this repository.

## Project Overview

This is a **recovery-grade documentation** repository for a homelab setup. The core philosophy is: "If it's not documented, it doesn't exist. If it's not backed up, it will be lost."

**Current state:** Pre-migration phase with services split between TrueNAS (.10) and Proxmox (.11).
**Goal state:** Core services on always-on Proxmox, storage services on TrueNAS.

## Before Making Any Changes

1. Read [docs/README.md](docs/README.md) to understand the documentation structure
2. Check [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) for current IPs, services, and status
3. Review [docs/current-state.md](docs/current-state.md) to understand what's running NOW vs goal state
4. Check [docs/Folder_structure.md](docs/Folder_structure.md) for where different types of documentation belong
5. **Check [docs/LESSONS-LEARNED.md](docs/LESSONS-LEARNED.md)** for relevant past mistakes on the topic
6. **Check [docs/CHANGELOG.md](docs/CHANGELOG.md)** for recent changes to related files

**When giving advice on risky operations:**
- Reference relevant past lessons from LESSONS-LEARNED.md
- Suggest testing procedures before committing to changes

## After Completing Any Task

**Before saying "done", always check:**

1. **LESSONS-LEARNED.md** - Does this warrant a new entry? (mistakes, discoveries, gotchas)
2. **Documentation** - Are there inconsistencies to fix? (duplicated info, outdated content, missing cross-references)
3. **CHANGELOG.md** - Does it need updating?
4. **Commit and push** - Don't wait to be asked

**Proactively mention improvements** - don't wait for the user to ask.

**When something goes wrong:**
1. Fix the immediate problem
2. **Proactively suggest** adding an entry to LESSONS-LEARNED.md
3. Use the template at [docs/templates/lesson-learned.md](docs/templates/lesson-learned.md)
4. Include: what happened, why it was a problem, how it was fixed, and the lesson learned

## Proactive Documentation Improvements

**While working, watch for and suggest fixes for:**

| Issue | Action |
|-------|--------|
| **Duplicated information** | Suggest consolidating to single source of truth, link from other locations |
| **Outdated information** | Flag it, suggest updates or removal |
| **Inconsistent data** | IPs, URLs, service names that don't match across files - suggest corrections |
| **Missing cross-references** | Related docs that should link to each other |
| **Stale "Last Updated" dates** | Files with old dates but recent content changes |
| **Deprecated files** | Files marked deprecated that could be removed or have lingering references |
| **Missing metadata** | Files lacking Purpose, Status, or Last Updated headers |
| **Broken internal links** | Links to moved or renamed files |

**When you notice improvements:**
1. Mention them at the end of completing the user's request
2. Group related suggestions together
3. Offer to implement them if the user agrees
4. Don't interrupt urgent tasks - note improvements for after

**Periodic review suggestions:**
- When reading multiple docs, note inconsistencies for later
- Suggest a "documentation health check" if many issues accumulate
- Prioritize: broken/incorrect info > missing info > style improvements

## When Making Documentation Changes

### Always Update the Changelog

After any documentation change, update [docs/CHANGELOG.md](docs/CHANGELOG.md) with:
- Date in `YYYY-MM-DD` format
- Change type: `Documentation`, `Configuration`, `Added`, `Removed`, `Monitoring`, `Rationale`
- Brief description with links to related files
- Reference GitHub issues if applicable

### Always Commit and Push Changes

After completing documentation work, always commit and push the changes. Don't wait to be asked.

### Follow Existing Patterns

- **Heading hierarchy:** H1 for page title, H2 for major sections, H3 for subsections
- **Metadata at top of files:** Include `Last Updated`, `Status`, and `Purpose` where appropriate
- **Cross-references:** Link to related documentation using relative markdown links
- **Decision documentation:** Document WHY, not just WHAT

### Status Indicators

Use consistent emoji markers:
- ✅ Working/configured/complete
- ❌ Not working/needed/missing
- ⚠️ Caution/in progress/warning
- 🕐 Time-related information

## File Naming Conventions

- **Regular documentation:** lowercase with hyphens (`backup-strategy.md`, `disaster-recovery.md`)
- **Meta/reference files:** ALL-CAPS (`README.md`, `CHANGELOG.md`, `QUICK-REFERENCE.md`)
- **Directories:** lowercase (`services/`, `recovery/`, `procedures/`)

## Where to Document What

| Content Type | Location |
|-------------|----------|
| Server hardware/config | `docs/servers/` |
| Server-provided resources (shares, exports) | `docs/servers/` (on the server that provides them) |
| Service documentation | `docs/services/` |
| Backup/recovery procedures | `docs/recovery/` |
| Migration/one-time procedures | `docs/procedures/` |
| Operational quick-lookups (schedules, retention, common commands) | `docs/QUICK-REFERENCE.md` |
| Architecture decisions | `docs/architecture.md` |
| Current running state | `docs/current-state.md` |

### Documentation Placement Principles

**Before adding new information:**
1. Check if an existing file is the natural home (e.g., server config → server docs)
2. Don't default to QUICK-REFERENCE.md - it's for operational lookups, not detailed configuration

**Single source of truth:**
- Configuration details live in ONE place (usually the most specific location)
- Other files reference it with links, don't duplicate
- Example: NFS share config in `storage-server.md`, backup schedule in `QUICK-REFERENCE.md` references it

**QUICK-REFERENCE.md is for:**
- Frequently-needed operational data (schedules, retention policies, common commands)
- Quick IP/URL lookups for daily use
- NOT for detailed configuration that changes rarely

## Network Context

- **Subnet:** 192.168.178.0/24
- **TrueNAS:** 192.168.178.10
- **Proxmox (pve1):** 192.168.178.11
- **VMs:** 192.168.178.12 and higher
- **VM naming:** `infraXXX` where XXX matches VM ID (e.g., infra100, infra101)

## MkDocs Site

This repository uses MkDocs with Material theme. When adding new pages:
1. Create the markdown file in the appropriate `docs/` subdirectory
2. Update `mkdocs.yml` navigation section to include the new page
3. Test locally with `mkdocs serve` if needed

## Templates

Reusable templates are available in [docs/templates/](docs/templates/):
- `lesson-learned.md` - For documenting mistakes and discoveries

## GitHub Issues Integration

Issues provide persistence across sessions - use them to track work that spans multiple conversations.

### When User Reports a Problem

1. **Immediately check** `gh issue list` for existing related issues
2. **If found:** Show the issue and ask if it's the same problem; update status if needed
3. **If not found:** Ask "Should I create an issue to track this?"
4. **Never create issues without asking** - always get user confirmation first

### When to Check for Existing Issues

| Situation | Action |
|-----------|--------|
| Starting work on a feature/migration | Check for related open issues |
| User mentions something "for later" | Check if issue exists, suggest creating one if not |
| Beginning a new session | Optionally review open issues for context |

### When to Create Issues

**Good candidates for issues:**
- Multi-session projects (migrations, large features)
- Problems discovered but not fixing immediately
- Documentation improvements to do later
- Ideas or enhancements for future consideration
- Bugs or issues that need investigation

**Skip creating issues for:**
- Quick fixes completed in same session
- Trivial changes (typos, small updates)
- Work that's already done

### Issue Workflow

1. **Before starting work:** `gh issue list` - check for related open issues
2. **When creating:** Ask user first, then use `gh issue create`
3. **In commits:** Reference issues with `Fixes #123` or `Relates to #123`
4. **After completing work:** Close issue with summary using `gh issue close`
5. **Discovering future work:** Suggest creating issue to track it

### Keeping Issues Updated

- If working on something tracked by an issue, update it with progress
- If an issue is stale or no longer relevant, suggest closing it
- When completing partial work, comment on the issue with what was done

### Issue Labels (if configured)

Use labels to categorize:
- `documentation` - Doc improvements
- `bug` - Something broken
- `enhancement` - New features or improvements
- `migration` - Migration-related tasks
- `infrastructure` - Server/network changes

---

## Meta: Improving These Instructions

**This section tells Claude to evaluate and improve CLAUDE.md itself.**

### When to Evaluate These Instructions

- **At session start:** Briefly check if instructions cover the task at hand
- **After completing work:** Reflect on what was missing or unclear
- **When asking clarifying questions:** Note if a default preference could be documented
- **When user corrects behavior:** Consider if the correction should become a rule

### Signs That Instructions Need Updating

| Observation | Potential Addition |
|-------------|-------------------|
| User repeatedly specifies the same preference | Add as default behavior |
| New service/VM added to homelab | Update Network Context section |
| New convention established during work | Add to relevant conventions section |
| Recurring question about "where does X go?" | Add to "Where to Document What" table |
| New category of mistakes discovered | Add to "Learning From Past Mistakes" table |
| User says "always do X" or "never do Y" | Add as explicit instruction |
| Workflow established that should persist | Document the workflow |

### How to Suggest Instruction Updates

1. **Don't silently update** - always propose changes to the user first
2. **Be specific** - show the exact addition or change
3. **Explain why** - reference the situation that revealed the gap
4. **Group related changes** - batch small updates together
5. **Prioritize** - essential rules > helpful defaults > nice-to-haves

### Example Triggers

- "You keep forgetting to..." → Add to instructions
- "Whenever we do X, also do Y" → Add as linked behavior
- New VM created (e.g., infra101) → Update Network Context
- New service deployed → Consider if it needs special handling
- Migration milestone reached → Update "Current state" in Project Overview
- New lesson learned added → Check if pitfalls table needs updating

### What NOT to Add

- One-time preferences (ask again next time)
- Highly context-dependent decisions
- Obvious or universal best practices
- Temporary states that will change soon
