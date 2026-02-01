# Home Assistant – Automations & Logic

## 1. Purpose
This document contains **all behavior, logic, and automation design** for Home Assistant.

It is intentionally separated from [home_assistant.md](home_assistant.md) to ensure:
- Clean recovery after reinstall
- Easier refactoring and debugging
- Clear distinction between *infrastructure* and *behavior*

---

## 2. Design Principles

- **Event-driven over time-driven**
- **Helpers over hard-coded logic**
- **Fail-safe first, escalation later**
- **Notifications before actions**
- **Human-readable messages**
- **Spam protection by default**

---

## 3. Security & Presence Automations

### 3.1 Overview
Security automations monitor doors, manage alarm state, and provide presence-based awareness. All security actions currently focus on **notifications only** to allow safe testing before enabling physical responses (sirens, locks).

### 3.2 Door Monitoring

#### Entrance Door Notifications
**Automation IDs**: `1768424319321`, `1768424390136`

**Purpose**: Notify when entrance door opens or closes for full awareness.

**Triggers**:
- Door contact sensor state change

**Actions**:
- Push notification with door status

```yaml
# Entrance door opened
- id: '1768424319321'
  alias: Entrance door opened - send a notification
  triggers:
  - type: opened
    device_id: <ENTRANCE_DOOR_DEVICE_ID>
    entity_id: <ENTRANCE_DOOR_ENTITY_ID>
    domain: binary_sensor
    trigger: device
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "🚪 Entrance door"
      message: Entrance door was opened
  mode: single

# Entrance door closed
- id: '1768424390136'
  alias: Entrance door closed - send a notification
  triggers:
  - type: not_opened
    device_id: <ENTRANCE_DOOR_DEVICE_ID>
    entity_id: <ENTRANCE_DOOR_ENTITY_ID>
    domain: binary_sensor
    trigger: device
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "🚪 Entrance door"
      message: Entrance door was closed
  mode: single
```

#### Terrace Door Notifications
**Automation IDs**: `1768424485616`, `1768424529252`

**Purpose**: Same as entrance door monitoring.

```yaml
# Terrace door opened
- id: '1768424485616'
  alias: Terrace door opened - send notification
  triggers:
  - type: opened
    device_id: <TERRACE_DOOR_DEVICE_ID>
    entity_id: <TERRACE_DOOR_ENTITY_ID>
    domain: binary_sensor
    trigger: device
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "🚪 Terrace door"
      message: Terrace door was opened
  mode: single

# Terrace door closed
- id: '1768424529252'
  alias: Terrace door closed - send a notification
  triggers:
  - type: not_opened
    device_id: <TERRACE_DOOR_DEVICE_ID>
    entity_id: <TERRACE_DOOR_ENTITY_ID>
    domain: binary_sensor
    trigger: device
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "🚪 Terrace door"
      message: Terrace door was closed
  mode: single
```

### 3.3 Conditional Security Alerts

#### Door Opened When Away
**Automation ID**: `1768654018966`

**Purpose**: Alert when entrance door opens while nobody is home (presence-based).

**Logic**:
- Trigger: Entrance door opens
- Condition: Both persons are not_home
- Action: High-priority notification

```yaml
- id: '1768654018966'
  alias: Security – Entrance door opened (away)
  triggers:
  - entity_id: binary_sensor.entrance_door
    to: 'on'
    trigger: state
  conditions:
  - condition: state
    entity_id: person.user1
    state: 'not_home'
  - condition: state
    entity_id: person.user2
    state: 'not_home'
  actions:
  - data:
      title: "🚪 Entrance door"
      message: Entrance door opened while nobody is home.
    action: notify.mobile_app_user1_phone
  mode: single
```

#### Doors Opened (Night / Armed / Away)
**Automation ID**: `1768654608882`

**Purpose**: Context-aware door monitoring based on time and alarm state.

**Logic**:
1. **Night mode** (22:00-06:00): Always notify
2. **Armed or Away**: Notify if alarm armed OR nobody home
3. Otherwise: No notification (avoid spam during normal use)

**Design Note**: Uses `choose` action for conditional branching.

```yaml
- id: '1768654608882'
  alias: Security – Doors opened (night always, day = armed or away)
  triggers:
  - entity_id:
    - binary_sensor.entry_door_sensor
    - binary_sensor.terrace_door_sensor
    to: 'on'
    trigger: state
  variables:
    door_name: >
      {% if trigger.entity_id == 'binary_sensor.entry_door_sensor' %}
        Entrance door
      {% elif trigger.entity_id == 'binary_sensor.terrace_door_sensor' %}
        Terrace door
      {% else %}
        A door
      {% endif %}
  actions:
  - choose:
    - conditions:
      - condition: time
        after: '22:00:00'
        before: 06:00:00
      sequence:
      - data:
          title: "🌙 Door opened"
          message: '{{ door_name }} opened (night mode).'
        action: notify.mobile_app_user1_phone
    - conditions:
      - condition: or
        conditions:
        - condition: state
          entity_id: input_boolean.alarm_armed
          state: 'on'
        - condition: and
          conditions:
          - condition: state
            entity_id: person.user1
            state: 'not_home'
          - condition: state
            entity_id: person.user2
            state: 'not_home'
      sequence:
      - data:
          title: "🚪 Door opened"
          message: '{{ door_name }} opened (armed or nobody home).'
        action: notify.mobile_app_user1_phone
    default: []
  mode: single
```

### 3.4 Alarm State Management

#### Alarm Armed/Disarmed Notifications
**Automation ID**: `1768655058190`

**Purpose**: Confirm alarm state changes.

**Helper Used**: `input_boolean.alarm_armed`

**Why This Exists**: See [home_assistant.md](home_assistant.md#alarm-state-model) for architecture rationale.

```yaml
- id: '1768655058190'
  alias: Alarm – Armed/Disarmed notification
  triggers:
  - entity_id: input_boolean.alarm_armed
    trigger: state
  actions:
  - data:
      title: "🔔 Alarm status"
      message: >
        {% if is_state('input_boolean.alarm_armed','on') %}
          Alarm ARMED.
        {% else %}
          Alarm DISARMED.
        {% endif %}
    action: notify.mobile_app_user1_phone
  mode: single
```

---

## 4. Lighting Automations

### 4.1 Overview
Lighting automations enhance comfort and energy efficiency by responding to context: time of day, TV usage, and bedtime routines.

### 4.2 TV Backlight Control

#### TV Backlight On
**Automation ID**: `1738003658937`

**Purpose**: Turn on TV backlight when TV powers on (only at night).

**Condition**: Between sunset and sunrise.

**Actions**: Fade in backlight to 25% brightness over 5 seconds.

```yaml
- id: '1738003658937'
  alias: Turn on TV Backlight when TV turns on
  triggers:
  - trigger: state
    entity_id: media_player.lg_tv
    to: 'on'
  conditions:
  - condition: sun
    before: sunrise
    after: sunset
  actions:
  - action: light.turn_on
    data:
      transition: 5
      brightness_pct: 25
    target:
      entity_id: light.essentials_lightstrip
  mode: single
```

#### TV Backlight Off
**Automation ID**: `1738003788392`

**Purpose**: Turn off backlight when TV powers off.

**No Condition**: Works any time of day (safe to turn off).

```yaml
- id: '1738003788392'
  alias: Turn off TV Backlight when TV turns off
  triggers:
  - trigger: state
    entity_id: media_player.lg_tv
    to: 'off'
  actions:
  - action: light.turn_off
    data:
      transition: 5
    target:
      entity_id: light.essentials_lightstrip
  mode: single
```

### 4.3 Bedroom Lighting

#### Bed Light Gentle On
**Automation ID**: `1738006310063`

**Purpose**: When bed light is turned on after 8 PM, force it to dim (15%) to avoid blinding anyone.

**Rationale**: Prevents accidentally turning on full brightness at night.

```yaml
- id: '1738006310063'
  alias: Bed light gently on at night
  triggers:
  - trigger: state
    entity_id: light.bed
    to: 'on'
  conditions:
  - condition: time
    after: '20:00:00'
  actions:
  - action: light.turn_on
    data:
      brightness_pct: 15
    target:
      entity_id: light.bed
  mode: single
```

#### Turn Off All Bedroom Lights When Bed Light Off (Late Night)
**Automation ID**: `1738009469042`

**Purpose**: When bed light is turned off late at night (after 10 PM), turn off all bedroom lights as a convenience.

**Assumption**: Turning off bed light signals "going to sleep".

```yaml
- id: '1738009469042'
  alias: Turn off Bedroom lights when Bed is turned off after 10 PM
  triggers:
  - trigger: state
    entity_id: light.bed
    from: 'on'
    to: 'off'
  conditions:
  - condition: time
    after: '22:00:00'
  - condition: time
    before: 04:00:00
  actions:
  - action: light.turn_off
    target:
      area_id: bedroom
  mode: single
```

### 4.4 Kids Room Controls

#### Child1's Room Lamp Button Control
**Automation ID**: `1769278045351`

**Purpose**: Physical button to toggle Child1's room lamp.

**Trigger**: Zigbee button short press.

```yaml
- id: '1769278045351'
  alias: Switch Child1s Room Lamp with Button
  triggers:
  - device_id: <BUTTON_DEVICE_ID>
    domain: zha
    type: remote_button_short_press
    subtype: button
    trigger: device
  actions:
  - action: switch.toggle
    target:
      entity_id: switch.smart_plug
  mode: single
```

#### Kids Bedtime Routine
**Automation ID**: `1769342498363`

**Purpose**: One-button bedtime routine for kids.

**Actions**:
- Turn on bedside lamps and desk lamps to 50%
- Turn off main ceiling light

**Trigger**: Dashboard button (`input_button.kids_bedtime`).

```yaml
- id: '1769342498363'
  alias: Kids – Bedtime
  description: Dim lights and turn on bedside lamps
  triggers:
  - event_type: input_button.press
    event_data:
      entity_id: input_button.kids_bedtime
    trigger: event
  actions:
  - action: light.turn_on
    target:
      entity_id:
      - light.bed
      - light.desk
      - light.child1s_room_smart_plug
      - light.child2s_lamp
    data:
      brightness_pct: 50
  - action: light.turn_off
    target:
      entity_id: light.h6076
  mode: single
```

---

## 5. Environmental Automations

### 5.1 Humidity Monitoring (Lüften Logic)

**Automation ID**: `1768425042250`

**Purpose**: Notify when any room's humidity exceeds 60% to prompt opening windows ("Lüften" = airing out).

**Sensors Monitored**: 5 temperature/humidity sensors across the house.

**Trigger**: Any sensor > 60% for 5 minutes (debouncing).

**Message**: Includes room name and humidity level.

**Spam Protection**: Mode `queued` with max 10 allows multiple rooms to trigger without blocking.

**Design Note**: Uses `room_map` variable to translate entity IDs to human-readable room names.

```yaml
- id: '1768425042250'
  alias: Lüften! – Hohe Luftfeuchtigkeit (alle Räume)
  description: Notify if any humidity sensor exceeds 60%
  triggers:
  - entity_id:
    - sensor.temperature_humidity_sensor_humidity
    - sensor.temperature_humidity_sensor_humidity_2
    - sensor.temperature_humidity_sensor_humidity_3
    - sensor.temperature_humidity_sensor_humidity_4
    - sensor.temperature_humidity_sensor_humidity_5
    above: 60
    for:
      minutes: 5
    trigger: numeric_state
  variables:
    room_map:
      sensor.temperature_humidity_sensor_humidity: Office
      sensor.temperature_humidity_sensor_humidity_2: Child2s room
      sensor.temperature_humidity_sensor_humidity_3: Child1s room
      sensor.temperature_humidity_sensor_humidity_4: Living room
      sensor.temperature_humidity_sensor_humidity_5: Bedroom
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "💧 Lüften!"
      message: '{{ room_map.get(trigger.entity_id, trigger.to_state.name) }}: {{ trigger.to_state.state | float | round(0) }} % Luftfeuchtigkeit'
  - action: notify.mobile_app_user2_phone
    data:
      title: "💧 Lüften!"
      message: '{{ room_map.get(trigger.entity_id, trigger.to_state.name) }}: {{ trigger.to_state.state | float | round(0) }} % Luftfeuchtigkeit'
  mode: queued
  max: 10
```

---

## 6. Mailbox Automations

### 6.1 Overview
Mailbox monitoring uses an Aqara vibration sensor in tilt detection mode.

**Problem Solved**: Mail delivery causes two tilt events (mailbox opens, then closes). Original approach sent duplicate notifications.

### 6.2 New Mail Notification

**Automation ID**: `1768416530786`

**Purpose**: Notify both family members when mail arrives.

**Trigger**: Postbox tilt event (Zigbee device action).

**Actions**:
1. Send notification to User1 (English)
2. Send notification to User2 (Hungarian)
3. Increment daily mail counter

**Design Note**: Counter allows tracking mail frequency and resetting daily.

```yaml
- id: '1768416530786'
  alias: New Brief Notification
  description: Sends a notification to the phone when the postbox sensor is tilted.
  triggers:
  - device_id: <MAILBOX_SENSOR_DEVICE_ID>
    domain: zha
    type: device_tilted
    subtype: device_tilted
    trigger: device
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "📬 Mail"
      message: Postbox tilted
  - action: notify.mobile_app_user2_phone
    data:
      title: "📬 Posta"
      message: A postaládát kinyitották
  - action: counter.increment
    target:
      entity_id: counter.mailbox_mail_today
  mode: single
```

### 6.3 Alexa Announcement

**Automation ID**: `1768483929417`

**Purpose**: Voice announcement via Alexa when mail arrives.

**Conditions**:
- Respects Do Not Disturb (DND) state
- Includes 1-minute cooldown to prevent spam

**Language**: German (matches household preference).

```yaml
- id: '1768483929417'
  alias: Postbox – Alexa announcement
  description: Alexa sagt Bescheid bei Briefkasten-Bewegung (mit 1 Min Cooldown, respektiert DND)
  triggers:
  - entity_id: binary_sensor.postbox_tilt
    to: 'on'
    trigger: state
  conditions:
  - condition: state
    entity_id: switch.user1_echo_do_not_disturb
    state: 'off'
  actions:
  - data:
      message: Neue Post im Briefkasten.
    action: notify.user1_echo_speak
  - delay: 00:01:00
  mode: single
```

### 6.4 Daily Counter Reset

**Automation ID**: `1769107330971`

**Purpose**: Reset mailbox counter at midnight.

```yaml
- id: '1769107330971'
  alias: Mailbox – Reset daily mail counter
  triggers:
  - trigger: time
    at: 00:00:00
  actions:
  - action: counter.reset
    target:
      entity_id: counter.mailbox_mail_today
  mode: single
```

---

## 7. System & Infrastructure Notifications

### 7.1 UPS Monitoring

#### Overview
UPS monitoring provides early warning of power issues. All UPS automations include **rate limiting** (cooldown) to prevent notification spam during repeated power flickers.

**Integration**: Network UPS Tools (NUT)
**Sensor**: `sensor.ups_status_data`

#### Power Lost (On Battery)
**Automation ID**: `1768077425923`

**Trigger**: UPS status contains "OB" (On Battery).

**Cooldown**: 15 minutes (prevents spam during brownouts).

**Message Includes**:
- Battery charge percentage
- Load percentage
- Input voltage
- Full status string

```yaml
- id: '1768077425923'
  alias: UPS - Power lost (On Battery)
  description: UPS – Power lost (goes on battery / OB)
  triggers:
  - value_template: '{{ ''OB'' in states(''sensor.ups_status_data'') }}'
    trigger: template
  conditions:
  - condition: template
    value_template: '{{ (as_timestamp(now()) - as_timestamp(state_attr(this.entity_id,''last_triggered'') or 0)) > 900 }}'
  actions:
  - data:
      title: ⚡ Power Outage
      message: >
        Mains power lost. UPS is on battery.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        · Input: {{ states('sensor.ups_input_voltage') }}V
        Status: {{ states('sensor.ups_status_data') }}
    action: notify.mobile_app_user1_phone
  - action: notify.persistent_notification
    data:
      message: >
        Mains power lost. UPS is on battery.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        · Input: {{ states('sensor.ups_input_voltage') }}V
        Status: {{ states('sensor.ups_status_data') }}
      title: ⚡ Power Outage
  mode: single
```

#### Power Restored
**Automation ID**: `1768077650509`

**Trigger**: UPS status contains "OL" (Online) and NOT "OB".

**Cooldown**: 5 minutes.

```yaml
- id: '1768077650509'
  alias: UPS - Power restored (Back Online)
  description: UPS – Power restored (OL) Notifications
  triggers:
  - value_template: '{{ ''OL'' in states(''sensor.ups_status_data'') and ''OB'' not in states(''sensor.ups_status_data'') }}'
    trigger: template
  conditions:
  - condition: template
    value_template: '{{ (as_timestamp(now()) - as_timestamp(state_attr(this.entity_id,''last_triggered'') or 0)) > 300 }}'
  actions:
  - data:
      title: "🔌 Power Restored"
      message: >
        Grid power is back. UPS returned online.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        · Input: {{ states('sensor.ups_input_voltage') }}V
        Status: {{ states('sensor.ups_status_data') }}
    action: notify.mobile_app_user1_phone
  - data:
      title: "🔌 Power Restored"
      notification_id: ups_restored
      message: >
        Grid power is back. UPS returned online.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        · Input: {{ states('sensor.ups_input_voltage') }}V
        Status: {{ states('sensor.ups_status_data') }}
    action: persistent_notification.create
  mode: single
```

#### Battery Critically Low
**Automation ID**: `1768077808088`

**Trigger**: UPS status contains "LB" (Low Battery - critical threshold).

**Cooldown**: 1 hour (reduces panic spam).

**Urgency**: High - shutdown may be imminent.

```yaml
- id: '1768077808088'
  alias: UPS - Battery critically low (LB)
  description: UPS – Battery critically low (LB) Notifications
  triggers:
  - value_template: '{{ ''LB'' in states(''sensor.ups_status_data'') }}'
    trigger: template
  conditions:
  - condition: template
    value_template: '{{ (as_timestamp(now()) - as_timestamp(state_attr(this.entity_id,''last_triggered'') or 0)) > 3600 }}'
  actions:
  - data:
      title: "🪫 UPS Battery CRITICAL"
      message: >
        UPS reports LOW BATTERY (critical). Shutdown may happen soon!
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        Status: {{ states('sensor.ups_status_data') }}
    action: notify.mobile_app_user1_phone
  - data:
      title: "🪫 UPS Battery CRITICAL"
      notification_id: ups_critical
      message: >
        UPS reports LOW BATTERY (critical). Shutdown may happen soon!
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        Status: {{ states('sensor.ups_status_data') }}
    action: persistent_notification.create
  mode: single
```

#### Forced Shutdown Imminent
**Automation ID**: `1768077882130`

**Trigger**: UPS status contains "FSD" (Forced Shutdown).

**Cooldown**: 1 hour.

**Meaning**: System-initiated shutdown is happening NOW.

```yaml
- id: '1768077882130'
  alias: UPS - Forced shutdown imminent (FSD)
  description: UPS – Forced shutdown imminent (FSD) Notifications
  triggers:
  - value_template: '{{ ''FSD'' in states(''sensor.ups_status_data'') }}'
    trigger: template
  conditions:
  - condition: template
    value_template: '{{ (as_timestamp(now()) - as_timestamp(state_attr(this.entity_id,''last_triggered'') or 0)) > 3600 }}'
  actions:
  - data:
      title: "🚨 UPS Shutdown Imminent"
      message: >
        UPS reports FSD (forced shutdown). Power cut is imminent.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        Status: {{ states('sensor.ups_status_data') }}
    action: notify.mobile_app_user1_phone
  - data:
      title: "🚨 UPS Shutdown Imminent"
      notification_id: ups_fsd
      message: >
        UPS reports FSD (forced shutdown). Power cut is imminent.
        Battery: {{ states('sensor.ups_battery_charge') }}%
        · Load: {{ states('sensor.ups_load') }}%
        Status: {{ states('sensor.ups_status_data') }}
    action: persistent_notification.create
  mode: single
```

### 7.2 Home Assistant System Health

#### HA Heartbeat
**Automation ID**: `1768078753076`

**Purpose**: Ping [Healthchecks.io](https://healthchecks.io) every minute to confirm HA is alive.

**Why**: External dead-man switch. If HA crashes, the external service will alert.

**Implementation**: Calls `shell_command.hc_ha_heartbeat` (configured in `configuration.yaml`).

```yaml
- id: '1768078753076'
  alias: HA Heartbeat
  description: HA Heartbeat Ping
  triggers:
  - minutes: /1
    trigger: time_pattern
  actions:
  - action: shell_command.hc_ha_heartbeat
  mode: single
```

#### HA Started
**Automation ID**: `1768080268766`

**Purpose**: Notify when Home Assistant starts up.

**Use Cases**:
- Detect unexpected restarts
- Confirm recovery after crash
- Track uptime

```yaml
- id: '1768080268766'
  alias: HA - Started
  description: Home Assistant startup notification
  triggers:
  - event: start
    trigger: homeassistant
  actions:
  - action: notify.mobile_app_user1_phone
    data:
      title: "🟢 Home Assistant started"
      message: Home Assistant has started successfully.
  - action: persistent_notification.create
    data:
      title: Home Assistant
      notification_id: ha_started
      message: 'Home Assistant started at {{ now().strftime(''%Y-%m-%d %H:%M:%S'') }}.'
  mode: single
```

#### Low Disk Space
**Automation ID**: `1768080483782`

**Purpose**: Warn when disk usage exceeds 85%.

**Trigger**: Numeric state above 85% for 10 minutes (debouncing).

**Action**: Dual notification (mobile + persistent).

```yaml
- id: '1768080483782'
  alias: HA - Low disk space
  description: Warn when disk usage is high
  triggers:
  - entity_id: sensor.system_monitor_disk_usage
    above: 85
    for: 00:10:00
    trigger: numeric_state
  actions:
  - data:
      title: ⚠️ Low Disk Space
      message: 'Disk usage is above 85%. Current usage: {{ states(''sensor.system_monitor_disk_usage'') }}%.'
    action: notify.mobile_app_user1_phone
  - data:
      title: ⚠️ Low Disk Space
      notification_id: ha_disk_low
      message: 'Disk usage is above 85%. Current usage: {{ states(''sensor.system_monitor_disk_usage'') }}%. Check storage before Home Assistant becomes unstable.'
    action: persistent_notification.create
  mode: single
```

#### Automatic Backup Failed
**Automation ID**: `1768081797706`

**Purpose**: Alert when automatic HA backup fails.

**Trigger**: Event `backup_automatic_backup` with `event_type: failed`.

**Message Includes**: Failure reason (if available).

```yaml
- id: '1768081797706'
  alias: HA - Automatic backup failed
  description: HA - Automatic backup failed
  triggers:
  - entity_id: event.backup_automatic_backup
    attribute: event_type
    to: failed
    trigger: state
  actions:
  - data:
      title: "💾 Home Assistant backup FAILED"
      message: 'Automatic backup failed. Reason: {{ state_attr(''event.backup_automatic_backup'', ''failed_reason'') or ''unknown'' }}'
    action: notify.mobile_app_user1_phone
  - data:
      title: "💾 Home Assistant backup FAILED"
      notification_id: ha_backup_failed
      message: 'Automatic backup failed. Reason: {{ state_attr(''event.backup_automatic_backup'', ''failed_reason'') or ''unknown'' }}'
    action: persistent_notification.create
  mode: single
```

### 7.3 Device Health

#### Low Battery Notifications
**Automation ID**: `1737909986713`

**Purpose**: Weekly notification of all devices with low battery.

**Implementation**: Uses Blackshome blueprint.

**Schedule**: Saturday at 3:00 AM.

**Channels**:
- Mobile app notification
- Persistent notification

```yaml
- id: '1737909986713'
  alias: Low Battery Notifications & Actions
  use_blueprint:
    path: Blackshome/low-battery-notifications-and-actions.yaml
    input:
      include_time: time_enabled
      time: 03:00:00
      include_easy_notify: enable_easy_okay_notify
      include_persistent_notification: enable_persistent_okay_notification
      notify_device:
      - <NOTIFY_DEVICE_ID>
      weekday_options:
      - sat
```

#### Brother Printer Toner Low
**Automation ID**: `1768076646181`

**Purpose**: Alert when printer toner drops below 20%.

**Integration**: Brother Printer (likely SNMP-based).

**Trigger**: Numeric state 0-20%.

```yaml
- id: '1768076646181'
  alias: Alert when Brother printer toner is low
  triggers:
  - trigger: numeric_state
    entity_id: sensor.hl_l2350dw_black_toner_remaining
    above: 0
    below: 20
  actions:
  - action: notify.persistent_notification
    data:
      message: "🖨️ Brother printer toner is LOW. Consider ordering a replacement cartridge."
      title: "🖨️ Brother printer toner is LOW"
  - action: notify.mobile_app_user1_phone
    data:
      message: "🖨️ Brother printer toner is LOW. Consider ordering a replacement cartridge."
      title: "🖨️ Brother printer toner is LOW"
  mode: single
```

---

## 8. Network Monitoring

### 8.1 FRITZ!Box Internet Connection

#### Connection Lost
**Automation ID**: `1768083862605`

**Purpose**: Alert when WAN connection goes down.

**Trigger**: Connection status changes from "Connected" for 2 minutes.

**Actions**:
1. Store disconnection timestamp in helper (`input_datetime.internet_disconnected_at`)
2. Send notification with previous uptime

**Design Note**: Timestamp stored for calculating downtime duration when restored.

```yaml
- id: '1768083862605'
  alias: FRITZ!Box - Internet connection lost
  description: Notify when FRITZ!Box WAN connection goes down
  triggers:
  - entity_id:
    - binary_sensor.fritz_box_6591_cable_vodafone_connection
    from:
    - Connected
    for:
      hours: 0
      minutes: 2
      seconds: 0
    trigger: state
  actions:
  - target:
      entity_id: input_datetime.internet_disconnected_at
    data:
      datetime: '{{ now().strftime(''%Y-%m-%d %H:%M:%S'') }}'
    action: input_datetime.set_datetime
  - data:
      title: "🌐 Internet connection LOST"
      message: >
        FRITZ!Box connection lost.
        Previous uptime: {{ states('sensor.fritz_box_6591_cable_vodafone_connection_uptime') }}.
        State changed from "{{ trigger.from_state.state }}" to "{{ trigger.to_state.state }}".
    action: notify.mobile_app_user1_phone
  - data:
      title: "🌐 Internet connection LOST"
      notification_id: fritz_internet_down
      message: >
        FRITZ!Box connection lost.
        Previous uptime: {{ states('sensor.fritz_box_6591_cable_vodafone_connection_uptime') }}.
    action: persistent_notification.create
  mode: single
```

#### Connection Restored
**Automation ID**: `1768083919172`

**Purpose**: Alert when WAN connection is restored, including downtime duration.

**Trigger**: Connection status returns to "Connected" for 1 minute (debouncing).

**Actions**:
1. Calculate downtime from stored timestamp
2. Send notification with downtime duration
3. Dismiss persistent notification

```yaml
- id: '1768083919172'
  alias: FRITZ!Box - Internet connection restored
  description: Notify when FRITZ!Box WAN connection is back
  triggers:
  - entity_id: sensor.fritz_box_6591_cable_vodafone_connection
    to: Connected
    for: 00:01:00
    trigger: state
  variables:
    disconnected_at: '{{ states(''input_datetime.internet_disconnected_at'') }}'
    downtime_minutes: >
      {% if disconnected_at not in ['unknown','unavailable','none',''] %}
        {{ ((as_timestamp(now()) - as_timestamp(disconnected_at)) / 60) | round(1) }}
      {% else %}
        unknown
      {% endif %}
  actions:
  - data:
      title: ✅ Internet connection restored
      message: >
        Internet connection restored.
        Downtime: {{ downtime_minutes }} minutes.
        New uptime since: {{ states('sensor.fritz_box_6591_cable_vodafone_connection_uptime') }}.
    action: notify.mobile_app_user1_phone
  - data:
      notification_id: fritz_internet_down
    action: persistent_notification.dismiss
  mode: single
```

---

## 9. Rate Limiting & Anti-Spam Strategy

### 9.1 Patterns Used

| Pattern | Implementation | Example |
|---------|----------------|---------|
| **Debouncing** | `for:` duration | Humidity > 60% for 5 minutes |
| **Cooldown** | Template condition checking `last_triggered` | UPS notifications (15 min cooldown) |
| **Queued Mode** | `mode: queued` with `max:` | Humidity alerts (max 10 queued) |
| **Conditional Logic** | Time/state-based conditions | Door alerts only at night or when armed |

### 9.2 Rationale

> Notifications must remain meaningful or users will ignore them.

**Examples**:
- **Mailbox**: 1-minute cooldown prevents double notifications during mail delivery
- **UPS**: 15-minute cooldown prevents spam during brownouts
- **Humidity**: 5-minute `for:` prevents transient spikes from triggering

---

## 10. Testing Strategy

### 10.1 New Automation Process

1. **Notifications Only**: Start with notifications (no physical actions)
2. **Manual Triggers**: Test via Developer Tools → Services
3. **Observe for False Positives**: Run for 1-2 weeks minimum
4. **Escalate Gradually**: Add physical actions (sirens, locks) only after confidence

### 10.2 Current Status

All automations in this document are **production-active** and tested.

**Future Escalation Planned**:
- Physical siren activation (after long-term alarm logic validation)
- Automated door locking (after presence detection reliability improves)

---

## 11. Future Automation Roadmap

### 11.1 Planned
- Enable siren on confirmed alarm events
- Presence reliability improvements (ensure all devices properly tracked)
- UPS-driven graceful shutdown flows
- Cross-server signaling (small server ↔ big server coordination)
- Wall-mounted tablet dashboards with context-aware displays

### 11.2 Ideas Under Consideration
- Rain detection → auto-close blinds
- Air quality → auto-activate air purifier
- Energy price integration → shift high-consumption tasks to cheap hours
- Vacation mode → randomize lights for security

---

## 12. Helper Entities Used

| Helper | Type | Purpose |
|--------|------|---------|
| `input_boolean.alarm_armed` | Boolean | Alarm state (on = armed) |
| `input_datetime.internet_disconnected_at` | DateTime | Track internet outage start time |
| `counter.mailbox_mail_today` | Counter | Daily mail delivery count |
| `input_button.kids_bedtime` | Button | Trigger bedtime routine |

---

## 13. Related Documentation

- **Architecture**: [home_assistant.md](home_assistant.md)
- **Scripts**: [scripts.md](scripts.md) (when scripts are extracted from automations)
- **Integrations**: [integrations.md](integrations.md)
- **Config Files**: [configs/automations/](configs/automations/) (YAML backups)

---

## 14. Configuration Management

All automations in this document are configured via:
- **HA UI**: For most automations
- **YAML Mode**: For complex logic requiring version control

Backups stored in: [configs/automations/](configs/automations/)

---

**Status**: Fully documented, production-active, incrementally extended

**Last Updated**: 2026-01-31
