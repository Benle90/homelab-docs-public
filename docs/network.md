# Network Configuration

## LAN
Subnet: 192.168.178.0/24  
Gateway: 192.168.178.1  

## DNS
Primary: AdGuard Home  
Secondary: Router (fallback)

## Remote Access
- Tailscale: private/admin access
- Cloudflare Tunnel: browser access
- Cloudflare Zero Trust: identity-based protection

## Security Rules
- No port forwarding
- No public SSH
- Admin access only via Tailscale

## Proxmox Firewall

Proxmox firewall is hierarchical: Datacenter → Node → VM. Each level must have firewall enabled for rules to apply.

### Datacenter Level

Default policy for all nodes and VMs.

| # | Dir | Action | Protocol | Source | D.Port | Comment |
|---|-----|--------|----------|--------|--------|---------|
| 0 | out | ACCEPT | - | - | - | Allow outbound |
| 1 | in | DROP | - | - | - | Drop all other |

### Node: pve1 (192.168.178.11)

| # | Dir | Action | Protocol | Source | D.Port | Comment |
|---|-----|--------|----------|--------|--------|---------|
| 0 | in | ACCEPT | - | 100.64.0.0/10 | - | Tailscale |
| 1 | in | ACCEPT | icmp | - | - | Ping |
| 2 | in | ACCEPT | tcp | 192.168.178.0/24 | 22 | SSH |
| 3 | in | ACCEPT | tcp | 192.168.178.0/24 | 8006 | Proxmox Web UI |
| 4 | out | ACCEPT | - | - | - | Allow outbound |
| 5 | in | DROP | - | - | - | Drop all other |

### VM: infra100 (192.168.178.12)

| # | Dir | Action | Protocol | Source | D.Port | Comment |
|---|-----|--------|----------|--------|--------|---------|
| 0 | in | ACCEPT | icmp | - | - | Ping |
| 1 | in | ACCEPT | tcp | 192.168.178.0/24 | 22 | SSH |
| 2 | in | ACCEPT | - | 100.64.0.0/10 | - | Tailscale |
| 3 | in | ACCEPT | tcp | 192.168.178.0/24 | 9000 | Portainer |
| 4 | in | ACCEPT | tcp | 192.168.178.0/24 | 3001 | Uptime Kuma |
| 5 | in | DROP | - | - | - | Drop all other |

### Key Principles

- **Rule order matters:** Rules are processed top-to-bottom; DROP must be last
- **100.64.0.0/10:** Tailscale CGNAT range for remote access
- **192.168.178.0/24:** Local LAN only
- **Default deny:** Explicit DROP at end of each ruleset

