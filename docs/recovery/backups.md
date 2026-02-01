# Backup Overview

## Philosophy

> If it's not documented, it does not exist.
> If it's not backed up, it will be lost.
> If it's not tested, it won't work when you need it.

## Backup Layers

| Layer | Purpose | Details |
|-------|---------|---------|
| ZFS snapshots | Local protection | TrueNAS native |
| VM backups | Proxmox VMs | vzdump to TrueNAS |
| Host backups | Proxmox config | DerDanilo scripts |
| Offsite | Disaster protection | B2 (daily), Storj (weekly) |
| Documentation | Rebuild knowledge | This repository |

## Documents

| Document | Purpose |
|----------|---------|
| [backup-strategy.md](backup-strategy.md) | Complete backup strategy and schedules |
| [proxmox-backup-restore.md](proxmox-backup-restore.md) | Proxmox host + VM backup/restore |
| [truenas-backup-restore.md](truenas-backup-restore.md) | TrueNAS and offsite backup/restore |
| [disaster-recovery.md](disaster-recovery.md) | High-level disaster planning |
