# Home Assistant – Dashboards & UI

## 1. Purpose
This document describes all **dashboards** and UI design decisions in Home Assistant.

Dashboards serve different users and use cases:
- **Daily Use**: Family-friendly, simple controls
- **Admin**: Full visibility, debugging tools
- **Mobile**: Optimized for phone screens

---

## 2. Dashboard Design Principles

- **Intent-Based Controls**: Buttons for "Bedtime" not just "Turn off lights"
- **Context over Detail**: Show what matters now (e.g., open doors, not all doors)
- **Minimal Clutter**: Hide admin features from daily views
- **Responsive Design**: Work well on phone, tablet, desktop
- **Permission-Based**: Show different views per user
- **Reliable Data**: Don't show entities that frequently become unavailable

---

## 3. Dashboard Overview

### 3.1 Default (Home) Dashboard

**Audience**: All family members

**Purpose**: Quick access to common controls and status

**Sections**:
1. **Quick Actions**
   - Bedtime routine button
   - Alarm arm/disarm toggle
   - Scene activations

2. **Room Status**
   - Temperature sensors by room
   - Humidity levels (color-coded)
   - Lights currently on

3. **Security Overview**
   - Door/window status (only show if open)
   - Alarm state
   - Last motion detected

4. **Environment**
   - Weather widget
   - Air quality indicator
   - UV index (during day)

**Design Notes**:
- Cards show/hide based on state (e.g., only show open doors)
- Large touch targets for easy mobile use
- Minimal text, clear icons

---

### 3.2 Admin Dashboard

**Audience**: System administrator only

**Purpose**: Full system visibility and debugging

**Sections**:
1. **System Health**
   - HA uptime
   - CPU/Memory usage
   - Disk space
   - Integrations status

2. **All Entities**
   - Batteries (all devices)
   - Signal strength (all Zigbee)
   - Unavailable entities

3. **Network**
   - Device tracker states
   - Presence detection
   - Network devices

4. **Testing Zone**
   - Manual script triggers
   - Test notification buttons
   - Automation toggles

**Design Notes**:
- Entity list cards for bulk viewing
- History graphs for trends
- Developer tools shortcuts

---

### 3.3 Mobile Dashboard

**Audience**: On-the-go access

**Purpose**: Streamlined for phone screens

**Sections**:
1. **Status at a Glance**
   - Is everything secure?
   - Any alerts?

2. **Critical Controls**
   - Alarm arm/disarm
   - Main lights

3. **Cameras** (if applicable)
   - Live view

**Design Notes**:
- Single column layout
- Larger buttons
- Swipe navigation

---

### 3.4 Wall Tablet Dashboard (Planned)

**Audience**: Fixed tablet in hallway/kitchen

**Purpose**: Always-on control panel

**Ideas**:
- Full-screen kiosk mode
- Time/weather prominent
- Touch-optimized buttons
- Motion-activated display

---

## 4. Card Types & Usage

### 4.1 Entity Cards
Simple status display for single entities.

**Example Use**:
- Current temperature
- Door status

---

### 4.2 Button Cards
Action triggers.

**Example Use**:
- "Bedtime" (runs script)
- "Arm Alarm" (sets helper)

**Styling**:
- Icon + text
- Color indicates state
- Confirmation for critical actions

---

### 4.3 Conditional Cards
Show cards only when relevant.

**Example Use**:
- "Doors Open" warning (only if doors actually open)
- "Battery Low" alert (only if any battery < 20%)

**Benefit**: Reduces clutter, focuses attention

---

### 4.4 Markdown Cards
Custom HTML/text for instructions or status.

**Example Use**:
- "System Maintenance" notices
- Quick help text

---

### 4.5 Graph Cards
Historical data visualization.

**Example Use**:
- Temperature over 24 hours
- Humidity trends

---

### 4.6 Grid/Horizontal Stack
Layout containers for organizing cards.

**Best Practice**: Group related controls together

---

## 5. User-Specific Views

Home Assistant allows different users to see different dashboards.

**Current Setup**:
- Admin user: All dashboards visible
- Family users: Home dashboard only (admin dashboard hidden)

**Configuration**: Set via dashboard settings → "Visible to users"

---

## 6. Theme & Appearance

**Theme**: Default HA theme (or specify if using custom)

**Customizations**:
- Icon colors for different states
- Conditional formatting (e.g., red for open doors)

**Future**: Custom theme matching homelab branding

---

## 7. Mobile App Configuration

The HA Companion App shows dashboards with some differences:

**Mobile-Specific Features**:
- Actionable notifications
- Quick actions widget (iOS/Android)
- Shortcuts integration

**Configuration**:
- Set default dashboard per device
- Enable "Edit from mobile" for quick tweaks

---

## 8. Dashboard Maintenance

### 8.1 Regular Updates
- Remove cards for deprecated entities
- Update card config when automations change
- Test on multiple screen sizes

### 8.2 Backup
Dashboards stored in:
- `.storage/lovelace` (internal HA storage)
- Included in HA backups

**Best Practice**: Export dashboard YAML before major changes

---

## 9. Dashboard YAML vs UI Editor

**UI Editor**:
- Used for most dashboards
- Easier for quick changes
- Stored in `.storage/`

**YAML Mode**:
- For complex layouts
- Version control friendly
- Stored in `ui-lovelace.yaml`

**Current Approach**: UI Editor (can switch to YAML later for version control)

---

## 10. Accessibility Considerations

- High contrast for important states
- Text labels in addition to icons
- Large touch targets (minimum 48x48 px)
- Voice control integration (via Apple Home / Google Assistant)

---

## 11. Examples & Screenshots

### Example Button Card Config
```yaml
type: button
entity: script.bedtime_routine
name: Bedtime
icon: mdi:weather-night
tap_action:
  action: call-service
  service: script.bedtime_routine
  confirmation:
    text: Start bedtime routine?
```

### Example Conditional Card
```yaml
type: conditional
conditions:
  - entity: binary_sensor.entry_door_sensor
    state: "on"
card:
  type: markdown
  content: "⚠️ Entry door is open!"
```

---

## 12. Future Dashboard Improvements

- Wall-mounted tablet with dedicated view
- Energy dashboard integration
- Frigate NVR camera views
- Calendar integration for reminders
- Shopping list widget
- Family member locations map

---

## 13. Related Documentation

- Architecture: [home_assistant.md](home_assistant.md)
- Automations: [ha_automations.md](ha_automations.md)
- Scripts referenced in buttons: [scripts.md](scripts.md)

---

## 14. Tips & Tricks

- **Use badges** for persistent status (top of dashboard)
- **Group by intent** not by device type
- **Test with family** before finalizing
- **Keep it simple** - less is more
- **Update regularly** as usage patterns change

---

**Status**: Template created, ready to document actual dashboards

**Last Updated**: 2026-01-30
