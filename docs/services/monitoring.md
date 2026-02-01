# Monitoring

**Last Updated:** 2026-01-30

## Philosophy

> Monitoring must stay online even if the storage server is down.

- **Uptime Kuma** runs on Proxmox (pve1) - monitors services
- **Healthchecks.io** is external - monitors that our systems are alive
- **Home Assistant** monitors physical infrastructure (UPS, network, devices)

---

## Monitoring Tools

| Tool | Location | Purpose |
|------|----------|---------|
| Uptime Kuma | pve1 (infra100) + TrueNAS | Service availability monitoring |
| Healthchecks.io | External (cloud) | Dead-man switch for backups and heartbeats |
| Home Assistant | TrueNAS (migrating to pve1) | Infrastructure alerts (UPS, network, devices) |

---

## Uptime Kuma

Two instances for redundancy - each can monitor independently if the other server is down.

### Instances

| Instance | URL | Purpose |
|----------|-----|---------|
| pve1 (primary) | http://192.168.178.12:3001 | Main monitoring dashboard |
| TrueNAS | http://192.168.178.10:31050 | Public status page |

**Public Status Page:** http://192.168.178.10:31050/status/homelab

### Monitors (pve1 Instance)

| Group | Monitor | Tags | Purpose |
|-------|---------|------|---------|
| **Network** | FRITZ!Box | network | Router/gateway availability |
| **pve1** | Portainer | docker | Container management UI |
| | Proxmox UI | infra | Hypervisor web interface |
| | VM - Ubuntu Server | infra | Main VM availability |
| **TrueNAS** | TrueNAS Server | storage | Storage server alive |
| | TrueNAS UI | storage | TrueNAS web interface |
| - | UPS | - | UPS status via NUT |

### Status Page Services (TrueNAS Instance)

The public status page monitors user-facing services:

- AdGuard Home
- AdGuard Home DNS
- Home Assistant
- Immich
- Nextcloud
- Scrutiny
- Tailscaled

### Design

- pve1 instance runs on infra100 (Docker container)
- TrueNAS instance runs as TrueNAS app
- Notifications via email/Discord (configure in UI)
- Dashboard for at-a-glance status

---

## Healthchecks.io

External dead-man switch service. Systems ping Healthchecks.io on schedule; if a ping is missed, you get alerted.

### Checks Overview

| Check | Type | Schedule | Grace | Purpose |
|-------|------|----------|-------|---------|
| **pve1-infra100** | Heartbeat | Every minute | 5 min | Proxmox cron alive |
| **Home Assistant Heartbeat** | Heartbeat | Every minute | 2 min | HA alive |
| **TrueNAS Heartbeat** | Heartbeat | Every minute | 2 min | TrueNAS alive |
| **PVE Config Backup** | Backup | Sun 02:00 | 1 hour | Proxmox host backup (DerDanilo) |
| **TrueNAS B2 Backup** | Backup | Daily 01:30 | 8 hours | Backblaze B2 offsite sync |
| **TrueNAS Storj Backup** | Backup | Wed 05:00 | 12 hours | Storj offsite sync |

### Check Types

**Heartbeats:** Ping every minute to confirm system is alive. Alert if no ping within grace period.

**Backup monitors:** Ping at backup start (pre-script) and completion (post-script). Alert if:
- No start ping at expected time
- No completion ping within grace period
- Explicit failure reported

### Implementation

**Proxmox (crontab):**
```bash
# Heartbeat - every minute
*/1 * * * * curl -fsS https://hc-ping.com/<UUID> > /dev/null

# After backup script completes (embedded in script config)
HEALTHCHECKS_URL=https://hc-ping.com/<UUID>
```

**Home Assistant (automation):**
```yaml
# Shell command in configuration.yaml
shell_command:
  hc_ha_heartbeat: "curl -fsS https://hc-ping.com/<UUID>"

# Automation pings every minute
- id: '1768078753076'
  alias: HA Heartbeat
  triggers:
    - minutes: /1
      trigger: time_pattern
  actions:
    - action: shell_command.hc_ha_heartbeat
```

**TrueNAS Cloud Sync (pre/post scripts):**
```bash
# Pre-script: Signal start
curl -fsS https://hc-ping.com/<UUID>/start

# Post-script: Signal completion (or /fail on error)
curl -fsS https://hc-ping.com/<UUID>
```

### Schedule Reference

| Cron | OnCalendar | Description |
|------|------------|-------------|
| `*/1 * * * *` | `minutely` | Every minute |
| `30 1 * * *` | `*-*-* 01:30:00` | Daily 01:30 |
| `0 2 * * 0` | `Sun *-*-* 02:00:00` | Sunday 02:00 |
| `0 5 * * 3` | `Wed *-*-* 05:00:00` | Wednesday 05:00 |

---

## Home Assistant Monitoring

HA monitors physical infrastructure via automations. See [ha_automations.md](home-assistant/ha_automations.md) for full details.

### UPS Monitoring

| Event | Automation | Cooldown |
|-------|------------|----------|
| Power lost (on battery) | UPS - Power lost | 15 min |
| Power restored | UPS - Power restored | 5 min |
| Battery critical | UPS - Battery critically low | 1 hour |
| Forced shutdown | UPS - Forced shutdown imminent | 1 hour |

**Integration:** Network UPS Tools (NUT)

### System Health

| Check | Automation | Trigger |
|-------|------------|---------|
| HA started | HA - Started | HA startup event |
| Disk space low | HA - Low disk space | >85% for 10 min |
| Backup failed | HA - Automatic backup failed | Backup event failed |
| Low battery devices | Low Battery Notifications | Weekly (Saturday) |

### Network Monitoring

| Check | Automation | Trigger |
|-------|------------|---------|
| Internet down | FRITZ!Box - Connection lost | WAN disconnected 2 min |
| Internet restored | FRITZ!Box - Connection restored | WAN connected 1 min |

---

## Alert Destinations

| Source | Destination |
|--------|-------------|
| Uptime Kuma | Email, Discord |
| Healthchecks.io | Email (configure in dashboard) |
| Home Assistant | Mobile push (iOS), Persistent notifications |

---

## Verification

### Daily (automated)
- Healthchecks.io dashboard shows all green
- Uptime Kuma shows services up

### Weekly
- Check Healthchecks.io for any grace period warnings
- Review HA notification history for missed alerts

### Monthly
- Verify all heartbeats still pinging
- Test one alert manually (e.g., stop a service briefly)
- Review and clean up stale checks

---

## Troubleshooting

**Heartbeat not pinging?**
```bash
# Test manually
curl -fsS https://hc-ping.com/<UUID>
# Should return "OK"

# Check cron is running
crontab -l | grep hc-ping
```

**Backup monitor shows late?**
- Check if backup actually ran (logs)
- Check if pre/post scripts are configured
- Verify network connectivity to hc-ping.com

**HA heartbeat stopped?**
- Check HA is running
- Check shell_command is configured in configuration.yaml
- Check automation is enabled

---

## Related Documentation

- [ha_automations.md](home-assistant/ha_automations.md) - HA monitoring automations (Section 7)
- [backup-strategy.md](../recovery/backup-strategy.md) - Backup schedules
- [proxmox-backup-restore.md](../recovery/proxmox-backup-restore.md) - PVE Config Backup details
- [truenas-backup-restore.md](../recovery/truenas-backup-restore.md) - Offsite backup details
