# Nextcloud

**Last Updated:** 2026-02-01
**Status:** Running on TrueNAS (.10)

## Purpose

- File sync (replacement for iCloud Drive)
- Calendar (CalDAV)
- Contacts (CardDAV)
- Occasional file sharing with external users

## Access

| Method | URL | Use Case |
|--------|-----|----------|
| LAN | `http://192.168.178.10:30027` | Primary - home network |
| Tailscale | `http://192.168.178.10:30027` | Primary - remote access via local IP |
| Cloudflare Tunnel | `https://[domain]` | Occasional - external file sharing |

**Note:** Cloudflare Tunnel is behind Zero Trust (email verification required every 24h).

### Client Configuration

- **iPhone/Desktop sync clients:** Use local IP `192.168.178.10:30027` (via Tailscale when remote)
- **CalDAV/CardDAV:** Use app passwords only (not main account password)

## Configuration

### trusted_domains

Must include all valid access points:
```php
'trusted_domains' => array (
  0 => '192.168.178.10:30027',  // LAN + Tailscale
  1 => '[public-domain]',       // Cloudflare Tunnel
),
```

### overwrite Settings

⚠️ **Do NOT set `overwritehost`** for mixed access - it forces redirects and breaks LAN access.
See [LESSONS-LEARNED.md](../LESSONS-LEARNED.md#2025-12-15-nextcloud-overwritehost-causes-forced-redirects) for details.

## Known Issues

| Issue | Status | Reference |
|-------|--------|-----------|
| HTTP headers not set | Open | [#17](https://github.com/Benle90/homelab-docs/issues/17) |
| Collabora not configured | Open | [#18](https://github.com/Benle90/homelab-docs/issues/18) |
| Access config needs review | Open | [#19](https://github.com/Benle90/homelab-docs/issues/19) |
| PostgreSQL 18 warning | Informational | Nextcloud supports up to v17; works but not officially tested |
| HTTPS warning | Expected | Accessing via HTTP locally; acceptable for mixed access pattern |

## Security

- Cloudflare Access protects external access (Zero Trust)
- `/remote.php/dav` excluded from Cloudflare Access (for CalDAV/CardDAV clients)
- App passwords required for sync clients
