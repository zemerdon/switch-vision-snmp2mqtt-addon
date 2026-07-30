# Switch Vision SNMP2MQTT

Home Assistant add-on wrapper for the Switch Vision SNMP2MQTT polling backend.

## Switch Vision Discovery import

Switch Vision Discovery generates:

```text
/share/switch_vision/generated-snmp2mqtt.yaml
```

Fresh installations use this generated file by default:

```yaml
use_switch_vision_generated_yaml: true
switch_vision_generated_yaml_path: /share/switch_vision/generated-snmp2mqtt.yaml
imported_targets_path: /config/addons_config/switch_vision_snmp2mqtt/imported/generated-snmp2mqtt.yaml
```

At startup, the add-on validates and imports that file, then logs the source path, target count, sensor count, and SHA-256. The add-on requires these generated-file markers:

```yaml
# Switch Vision generated SNMP2MQTT YAML
# Source: Switch Vision Discovery v0.9.0
```

It also rejects missing files, `CHANGE_ME` placeholders, missing `targets:` blocks, and files without target host entries.

## Manual targets file

Existing users can disable generated import and use the manual targets path:

```text
/config/addons_config/switch_vision_snmp2mqtt/targets.yaml
```

## Clean-install release

v0.9.0 is a breaking clean-install cutover. Previous project option names, paths, slug, image names, and header aliases are not retained.
