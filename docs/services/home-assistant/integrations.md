# Home Assistant – Integrations

## 1. Purpose
This document describes all **integrations** configured in Home Assistant, including setup instructions, credentials management, and troubleshooting steps.

Use this document for:
- Recovery after reinstall
- Adding new instances
- Troubleshooting connectivity issues
- Documenting API keys and tokens needed (without exposing actual values)

---

## 2. Integration Principles

- **Minimal Cloud Dependencies**: Prefer local integrations
- **Secure Credentials**: Use `secrets.yaml` for all sensitive data
- **Documentation First**: Document before configuring
- **Testing**: Verify each integration after setup

---

## 3. Device Integrations

### 3.1 Zigbee (ZHA - Zigbee Home Automation)

**Purpose**: Connect Zigbee devices (sensors, lights, switches)

**Hardware**:
- Coordinator: Nabu Casa ZBT-2 (USB)
- Connected to: HA VM via USB passthrough

**Setup Steps**:
1. Pass USB device through Proxmox to HA VM
2. Navigate to Settings → Devices & Services → Add Integration
3. Search for "ZHA"
4. Select USB device path (usually `/dev/ttyUSB0` or `/dev/ttyACM0`)
5. Wait for coordinator initialization

**Connected Devices** (Active in automations):
- Aqara door/window sensors (entrance & terrace doors)
- Aqara vibration sensor (mailbox tilt detection)
- Zigbee buttons (Child1's room lamp control)
- Smart plugs (kids room lamps)
- Temperature/humidity sensors (5x rooms)

**Troubleshooting**:
- If devices not responding: Power cycle router devices first (mesh rebuilds)
- If coordinator not found: Check USB passthrough in Proxmox
- Weak signal: Add more powered router devices to mesh

**Network Channel**: 15 (avoid Wi-Fi interference)

---

### 3.2 Matter

**Purpose**: Connect Matter-certified devices

**Setup**:
- Enable Matter Server add-on
- Add devices via Settings → Integrations → Matter

**Connected Devices**:
- IKEA Matter devices
- (Expanding as more devices become available)

**Design Note**:
- HA is the Matter controller
- Apple Home consumes from HA (not the other way around)

---

### 3.3 Apple Home (HomeKit Bridge)

**Purpose**: Expose HA entities to Apple Home ecosystem

**Setup**:
1. Add HomeKit Bridge integration
2. Select entities to expose
3. Scan QR code with iPhone/iPad

**Exposed Entities**:
- Critical lights
- Alarm status (read-only)
- Temperature sensors

**Not Exposed**:
- Scripts (to prevent bypassing HA logic)
- System entities

---

## 4. Service Integrations

### 4.1 Mobile App (HA Companion)

**Purpose**:
- Remote access
- Push notifications
- Device tracking
- Actionable notifications

**Setup per Device**:
1. Install HA Companion App from App Store
2. Configure connection URL (use Tailscale IP, not public)
3. Enable location permissions (for presence detection)
4. Configure notification settings

**Important**:
- Use **internal/Tailscale IP** to avoid cloud dependency
- Disable battery optimization on Android

**Configured Devices**:
- `notify.mobile_app_user1_phone` - Primary notification target
- `notify.mobile_app_user2_phone` - Family member notifications (humidity, mailbox)

**Used By**:
- Security alerts (door monitoring, alarm status)
- System notifications (HA startup, UPS status, backups)
- Environmental alerts (humidity warnings)
- Device health (low battery, printer toner)
- Network alerts (internet connectivity)

---

### 4.2 Weather Integration

**Provider**: OpenWeather (or specify your choice)

**Purpose**: Weather data for automations and dashboards

**Setup**:
1. Obtain API key from [openweathermap.org](https://openweathermap.org/api)
2. Add to `secrets.yaml`: `openweather_key: YOUR_KEY_HERE`
3. Add Weather integration via UI
4. Configure location coordinates

**Used For**:
- Dashboard weather widget
- Future: Rain-based automation (e.g., close blinds)

**Credentials Required**:
- API key (stored in `!secret openweather_key`)

---

### 4.3 Uptime Kuma

**Purpose**: Monitor HA availability from external system

**Setup**:
1. Create HTTP(S) monitor in Uptime Kuma
2. Point to HA URL (via Tailscale)
3. Set check interval (e.g., 5 minutes)

**Benefit**: Detect HA crashes/restarts from outside HA

---

### 4.4 Network UPS Tools (NUT)

**Purpose**: Monitor UPS status for power management

**Setup**:
1. NUT server runs on TrueNAS (or separate system)
2. Add NUT integration in HA
3. Configure NUT server IP and credentials

**Exposed Entities** (Active):
- `sensor.ups_battery_charge` - Battery percentage
- `sensor.ups_status_data` - Status string (OL, OB, LB, FSD)
- `sensor.ups_load` - Load percentage
- `sensor.ups_input_voltage` - Input voltage

**Automations Using NUT**:
- UPS Power lost (On Battery) - 15min cooldown
- UPS Power restored
- UPS Battery critically low (LB)
- UPS Forced shutdown imminent (FSD)

**Status Codes**:
- **OL** = Online (normal)
- **OB** = On Battery (power outage)
- **LB** = Low Battery (critical)
- **FSD** = Forced Shutdown (imminent)

**Credentials Required**:
- NUT server IP
- Username/password (if configured)

---

## 5. Local Network Integrations

### 5.1 Network Scanning

**Purpose**: Device presence detection via network

**Types**:
- **Ping**: Simple ICMP checks
- **NMAP**: Device discovery
- **Router integration**: Direct device list from router

**Configuration**: Via `configuration.yaml` or UI

---

### 5.2 AdGuard Home

**Purpose**: DNS statistics and blocking controls

**Setup**:
1. Add AdGuard Home integration
2. Provide AdGuard IP and API key
3. Entities created for blocked queries, top domains, etc.

**Used For**:
- Dashboard statistics
- Future: Dynamic blocking based on presence

---

### 5.3 FRITZ!Box

**Purpose**: Router integration for internet connectivity monitoring

**Integration**: AVM FRITZ!SmartHome

**Setup**:
1. Add FRITZ!Box integration via UI
2. Enter FRITZ!Box IP address
3. Provide admin credentials
4. Select entities to monitor

**Exposed Entities** (Active):
- `binary_sensor.fritz_box_6591_cable_vodafone_connection` - Connection status
- `sensor.fritz_box_6591_cable_vodafone_connection_uptime` - Uptime tracking

**Automations Using FRITZ!Box**:
- Internet connection lost (2min debounce)
- Internet connection restored (1min debounce, calculates downtime)

**Helper Used**:
- `input_datetime.internet_disconnected_at` - Stores timestamp for downtime calculation

---

### 5.4 Brother Printer

**Purpose**: Monitor printer status and consumables

**Integration**: Brother Printer (SNMP)

**Setup**:
1. Add Brother Printer integration via UI
2. Enter printer IP address
3. Wait for auto-discovery of entities

**Exposed Entities** (Active):
- `sensor.hl_l2350dw_black_toner_remaining` - Toner level percentage

**Automations**:
- Alert when toner drops below 20%

---

### 5.5 LG webOS TV

**Purpose**: Control and monitor LG TV

**Integration**: LG webOS Smart TV

**Setup**:
1. Add LG webOS TV integration
2. Enter TV IP address
3. Accept pairing request on TV

**Exposed Entities** (Active):
- `media_player.lg_tv` - TV power state and control

**Automations Using LG TV**:
- Turn on TV backlight when TV powers on (sunset to sunrise only)
- Turn off TV backlight when TV powers off

**Connected Devices**:
- `light.essentials_lightstrip` - TV backlight (controlled based on TV state)

---

### 5.6 Alexa Media Player

**Purpose**: Voice announcements and TTS

**Integration**: Alexa Media Player (custom component)

**Setup**:
1. Install via HACS
2. Configure with Amazon account credentials
3. Select Alexa devices to integrate

**Exposed Entities** (Active):
- `notify.user1_echo_speak` - TTS notification service
- `switch.user1_echo_do_not_disturb` - DND status

**Automations Using Alexa**:
- Postbox announcement (respects DND, 1-minute cooldown)

**Language**: German (household preference)

---

## 6. System Integrations

### 6.1 System Monitor

**Purpose**: Monitor HA host system resources

**Integration**: System Monitor (built-in)

**Setup**:
1. Add System Monitor integration via UI
2. Select resources to monitor

**Exposed Entities** (Active):
- `sensor.system_monitor_disk_usage` - Disk usage percentage

**Automations**:
- Low disk space alert (>85% for 10 minutes)

---

### 6.2 Shell Command

**Purpose**: Execute shell commands for external integrations

**Configuration**: Added to `configuration.yaml`

```yaml
shell_command:
  hc_ha_heartbeat: 'curl -fsS -m 10 --retry 5 https://hc-ping.com/YOUR_UUID_HERE'
```

**Used By**:
- HA Heartbeat automation (pings every minute)

**Purpose**: Dead-man switch via Healthchecks.io

---

## 7. Helper Entities

**Purpose**: Store state and enable complex automations

**Configured Helpers**:

| Helper | Type | Purpose |
|--------|------|---------|
| `input_boolean.alarm_armed` | Boolean | Alarm armed/disarmed state |
| `input_datetime.internet_disconnected_at` | DateTime | Track internet outage start time |
| `counter.mailbox_mail_today` | Counter | Daily mail delivery count |
| `input_button.kids_bedtime` | Button | Trigger bedtime routine |

---

## 8. Third-Party Services

### 8.1 Healthchecks.io

**Purpose**: Dead-man switch for HA availability monitoring

**Setup**:
1. Create check at [healthchecks.io](https://healthchecks.io)
2. Get unique ping URL
3. Add to `configuration.yaml` as shell command (see Section 6.2)
4. Create automation to ping every minute

**Implementation**:
- Shell command: `shell_command.hc_ha_heartbeat`
- Automation: HA Heartbeat (runs every minute)

**Benefit**: External service alerts if HA stops responding

---

### 8.2 Discord Webhook (Optional - Not Currently Active)

**Purpose**: Alternative notification channel

**Setup**:
1. Create webhook in Discord server
2. Add to `secrets.yaml`
3. Use RESTful command to send notifications

---

## 9. Add-ons vs Integrations

**Add-ons** (run inside HA Supervisor):
- File Editor
- SSH & Web Terminal
- Matter Server

**Integrations** (external services):
- All items listed above

---

## 10. Credentials Management

All sensitive data stored in `secrets.yaml`:

```yaml
# Example structure (not real values!)
openweather_key: abc123...
adguard_api_key: def456...
nut_password: ghi789...
discord_webhook: https://discord.com/api/webhooks/...
```

**Never commit** `secrets.yaml` to git!

---

## 11. Integration Health Check

Regular maintenance:
- Check for integration errors in Settings → System → Logs
- Update integrations when new versions available
- Test after HA updates
- Verify API keys haven't expired

---

## 12. Recovery Checklist

After fresh HA install, configure integrations in this order:

1. **ZHA (Zigbee)** - Critical for door sensors, buttons, environmental sensors
2. **Mobile App** - For all notifications (security, system, environmental)
3. **NUT** - For UPS monitoring and power alerts
4. **FRITZ!Box** - For internet connectivity monitoring
5. **Brother Printer** - For toner level alerts
6. **LG webOS TV** - For TV backlight automation
7. **Alexa Media Player** - For voice announcements (via HACS)
8. **System Monitor** - For disk space monitoring
9. **Shell Command** - Add healthchecks.io heartbeat to configuration.yaml
10. **Helper Entities** - Create all input_boolean, input_datetime, counter, input_button entities

---

## 13. Related Documentation

- Architecture: [home_assistant.md](home_assistant.md)
- Automations using these integrations: [ha_automations.md](ha_automations.md)
- Scripts: [scripts.md](scripts.md)

---

**Status**: Fully documented with all active integrations from current automations

**Last Updated**: 2026-01-30
