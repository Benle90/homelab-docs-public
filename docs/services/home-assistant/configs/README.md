# Home Assistant Configuration Files

## Overview
This directory contains sanitized versions of Home Assistant configuration files for documentation and version control purposes.

## Important Security Notes

- **Never commit actual secrets** (API keys, tokens, passwords)
- Use `!secret` references for sensitive data
- Example: `api_key: !secret openweather_key`
- Keep your actual `secrets.yaml` file outside this repository

## Directory Structure

```
configs/
├── automations/          # Automation YAML files organized by domain
│   ├── security.yaml     # Alarm, door sensors, presence
│   ├── lighting.yaml     # Light controls, scenes, routines
│   └── notifications.yaml # System notifications, alerts
├── scripts/              # Reusable scripts
├── helpers.yaml          # Input booleans, numbers, text, datetime helpers
└── README.md            # This file
```

## How to Use These Files

### 1. Reference in Documentation
Link to these configs from your markdown documentation to show actual implementation.

### 2. Recovery Reference
During disaster recovery, use these files as templates to rebuild your configuration.

### 3. Testing Changes
Before applying changes to production HA:
1. Update the YAML file here
2. Test in a development environment
3. Document the change in the corresponding `.md` file
4. Apply to production HA

## Syncing with Production

These files should be kept in sync with your actual Home Assistant installation:

```bash
# Example: Copy from HA to docs (sanitize secrets first!)
# Adjust paths based on your HA installation location
cp /path/to/ha/config/automations.yaml configs/automations/
# Then manually replace secrets with !secret references
```

## Configuration Management Tips

1. **Modular Approach**: Split automations by domain rather than one large file
2. **Comments**: Add YAML comments to explain complex logic
3. **Naming Conventions**: Use clear, descriptive entity IDs
4. **Version Control**: Commit after each significant change with clear messages

## Related Documentation

- Architecture: [home_assistant.md](../home_assistant.md)
- Automation Logic: [ha_automations.md](../ha_automations.md)
- Scripts: [scripts.md](../scripts.md)
- Integrations: [integrations.md](../integrations.md)
- Dashboards: [dashboards.md](../dashboards.md)

---

**Last Updated**: 2026-01-30
