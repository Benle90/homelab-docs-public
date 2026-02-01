# Home Assistant – Scripts

## 1. Purpose
This document describes all **reusable scripts** in Home Assistant. Scripts are sequences of actions that can be called from automations, dashboards, or other scripts.

Scripts differ from automations:
- **Scripts**: Action sequences without triggers (called manually or by automations)
- **Automations**: Include triggers, conditions, and actions

---

## 2. Design Principles

- **Single Responsibility**: Each script does one thing well
- **Parameterized**: Accept variables for flexibility
- **Idempotent**: Safe to run multiple times
- **Documented**: Clear description and usage examples
- **Fail-Safe**: Handle edge cases gracefully

---

## 3. Script Categories

### 3.1 Lighting Scripts
Scripts for common lighting scenarios and routines.

#### Example: Bedtime Routine
**Script ID**: `script.bedtime_routine`

**Purpose**: Dims lights and prepares the house for sleep

**Parameters**:
- `room`: Target room (optional, defaults to all)
- `dim_level`: Brightness percentage (default: 10%)

**Triggered By**:
- Dashboard button
- Voice command
- Scheduled automation

**Actions**:
1. Dim main lights to specified level
2. Turn on nightlights
3. Lock doors (if enabled)

**Configuration**:
```yaml
# See: configs/scripts/lighting.yaml
```

---

### 3.2 Security Scripts
Scripts related to alarm management and security routines.

#### Example: Arm Alarm System
**Script ID**: `script.arm_alarm`

**Purpose**: Arms the alarm system with pre-checks

**Actions**:
1. Check all doors/windows closed
2. Send notification if any open
3. Set alarm helper to armed state
4. Flash lights as confirmation

---

### 3.3 Notification Scripts
Reusable notification patterns with consistent formatting.

#### Example: Send Family Notification
**Script ID**: `script.notify_family`

**Purpose**: Send notification to all family members

**Parameters**:
- `title`: Notification title
- `message`: Notification body
- `priority`: high/normal/low

---

### 3.4 System Scripts
Scripts for maintenance and system management.

#### Example: Restart Services
**Script ID**: `script.restart_services`

**Purpose**: Graceful restart of integrations

---

## 4. Script Development Workflow

1. **Define Use Case**: What problem does this script solve?
2. **Identify Inputs**: What parameters are needed?
3. **Draft Actions**: List the sequence of operations
4. **Test Manually**: Trigger from Developer Tools
5. **Add to Dashboard**: Create button for easy access
6. **Document Here**: Add to this file with examples
7. **Commit Config**: Save YAML to `configs/scripts/`

---

## 5. Testing & Validation

- All scripts tested via Developer Tools before production use
- Edge cases considered (what if device unavailable?)
- Logging enabled for debugging
- Notification sent on script failure (for critical scripts)

---

## 6. Script Inventory

| Script ID | Purpose | Used By | Status |
|-----------|---------|---------|--------|
| `script.bedtime_routine` | Dim lights for sleep | Dashboard, automation | Active |
| `script.arm_alarm` | Arm security system | Dashboard | Active |
| `script.notify_family` | Family notifications | Multiple automations | Active |

---

## 7. Future Scripts

Ideas for future implementation:
- Morning routine (gradual light increase)
- Guest mode (disable certain automations)
- Vacation mode (randomize lights, notifications)
- Energy saving mode (reduce standby consumption)

---

## 8. Related Documentation

- Architecture: [home_assistant.md](home_assistant.md)
- Automations: [ha_automations.md](ha_automations.md)
- Actual YAML configs: [configs/scripts/](configs/scripts/)

---

**Status**: Template created, ready for population with actual scripts

**Last Updated**: 2026-01-30
