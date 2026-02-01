 Hardware Inventory

**Last Updated:** 2026-02-01

**Purpose:** Single source of truth for all physical hardware in the homelab. Other documentation should reference this file rather than duplicating hardware details.

---

## Servers

### TrueNAS Storage Server {#truenas}

| Attribute | Value |
|-----------|-------|
| **Hostname** | `truenas` |
| **IP Address** | 192.168.178.10 |
| **Role** | Storage server, application host (pre-migration) |
| **OS** | TrueNAS SCALE (Community Edition) |

**Hardware:**

| Component | Model |
|-----------|-------|
| Type | Custom build |
| CPU | Intel Core i5-9600K |
| RAM | 32 GB DDR4-3200 |
| Motherboard | MSI MPG Z390 Gaming Plus |
| Cooling | be quiet! Dark Rock 4 |
| PSU | be quiet! Pure Power 11 CM 500W |
| Boot Drive | 500 GB SSD |
| Data Drives | 2× 4 TB Seagate IronWolf HDD (ZFS mirror) |

**Documentation:** [Storage Server](servers/storage-server.md)

---

### Proxmox Infrastructure Server {#proxmox}

| Attribute | Value |
|-----------|-------|
| **Hostname** | `pve1` |
| **IP Address** | 192.168.178.11 |
| **Role** | Always-on infrastructure server |
| **OS** | Proxmox VE |

**Hardware:**

| Component | Model |
|-----------|-------|
| Type | Fujitsu ESPRIMO Q958 (mini PC) |
| CPU | Intel i3-9100T |
| RAM | 8 GB |
| Storage | 128 GB SSD |

**Documentation:** [Infrastructure Server](servers/infra-server.md)

---

## Network Equipment

### Router {#router}

| Attribute | Value |
|-----------|-------|
| **Model** | FRITZ!Box 6591 Cable |
| **IP Address** | 192.168.178.1 |
| **Role** | Gateway, DHCP, fallback DNS |

**Home Assistant Integration:** FRITZ!Box (internet connectivity monitoring)

---

### UPS {#ups}

| Attribute | Value |
|-----------|-------|
| **Model** | CyberPower CP900EPFCLCD |
| **Connected to** | TrueNAS (NUT server) |
| **Monitored via** | NUT integration in Home Assistant |

**Monitoring:** [PeaNUT](http://192.168.178.10:30224/) web UI, Home Assistant automations

---

## Smart Home - Hubs & Coordinators

### Zigbee Coordinator (Home Assistant) {#zigbee-coordinator}

| Attribute | Value |
|-----------|-------|
| **Model** | Nabu Casa ZBT-2 |
| **Connection** | USB passthrough to HA VM |
| **Network Channel** | 15 |
| **Role** | Primary Zigbee coordinator for Home Assistant ZHA |

**Connected devices:** Sonoff sensors, Aqara sensors, smart plugs, Zigbee buttons

---

### IKEA Dirigera Hub {#dirigera}

| Attribute | Value |
|-----------|-------|
| **Location** | Bedroom |
| **Protocol** | Matter / Zigbee |
| **Role** | Matter border router; manages IKEA devices via closed Zigbee network |

**Connected devices:** Bedroom lights (Bed1, Bed2, Desk Lamp, Floor lamp)

⚠️ **Note:** IKEA devices use Dirigera's own Zigbee network, not the HA ZHA network. HA controls them via Matter bridge.

---

### Apple HomePod mini {#homepod}

| Attribute | Value |
|-----------|-------|
| **Location** | Office |
| **Protocol** | Matter / Thread |
| **Role** | Matter border router |
