# Switch Vision SNMP2MQTT

Home Assistant app wrapper for the Switch Vision SNMP2MQTT polling backend.

## Core version

This app is pinned to Switch Vision SNMP2MQTT core `v0.9.7`.

Core v0.9.7 retains Juniper EX VLAN/trunk discovery and adds validated `object_id` support. No local Juniper MIB installation is required at runtime.

## MQTT service resolution

Fresh installations use Home Assistant's declared MQTT service automatically.
The app reads the Supervisor-provided MQTT host, port, username, and password
through Bashio. Existing v0.9.6 options that still contain the old `localhost`
default are treated as the automatic Supervisor mode.

Setting a different MQTT host explicitly keeps that broker configuration and
does not replace its credentials with Supervisor service credentials.

## Switch Vision Discovery import

Switch Vision Discovery generates:

```text
/share/switch_vision/generated-snmp2mqtt.yaml
```

Fresh installations use this generated file by default:

```yaml
use_switch_vision_generated_yaml: true
switch_vision_generated_yaml_path: /share/switch_vision/generated-snmp2mqtt.yaml
imported_targets_path: /config/app_configs/switch_vision_snmp2mqtt/imported/generated-snmp2mqtt.yaml
```

At startup, the app validates and imports that file, then logs the source path, target count, sensor count, and SHA-256. The app requires these generated-file markers:

```yaml
# Switch Vision generated SNMP2MQTT YAML
# Source: Switch Vision Discovery v0.9.0
```

It also rejects missing files, `CHANGE_ME` placeholders, missing `targets:` blocks, and files without target host entries.

## Manual targets file

Generated import can be disabled and the manual targets path used instead:

```text
/config/app_configs/switch_vision_snmp2mqtt/targets.yaml
```

## Juniper EX VLAN and trunk support

Core v0.9.6 can correlate standard bridge tables with Juniper EX VLAN tables to derive:

- access or trunk mode
- native/PVID VLAN
- member VLANs
- tagged VLANs
- untagged VLANs

The implementation uses numeric OIDs so the app does not depend on locally installed MIB files.

## Current HAOS paths

This version uses only current Home Assistant OS app mappings and paths:

```yaml
map:
  - local_apps:rw
  - all_app_configs:rw
```

```text
/config/app_configs/switch_vision_snmp2mqtt/
```

Previous mapping names and configuration paths are not supported.
