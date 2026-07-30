# Changelog

## 0.9.4

- Make Switch Vision Discovery generated YAML the fresh-install default.
- Load `/share/switch_vision/generated-snmp2mqtt.yaml` automatically when the add-on starts.
- Log the imported generated-YAML path, target count, sensor count, and SHA-256.
- Preserve existing user options during add-on upgrades; the new default applies to fresh installs or reset options.
- Improve the warning shown when generated import is deliberately disabled.

## 0.9.0

- Rename the add-on to Switch Vision SNMP2MQTT.
- Change slug to `switch_vision_snmp2mqtt`.
- Change configuration paths to `/config/addons_config/switch_vision_snmp2mqtt/`.
- Change Discovery input path to `/share/switch_vision/generated-snmp2mqtt.yaml`.
- Rename generated-import options to `use_switch_vision_generated_yaml` and `switch_vision_generated_yaml_path`.
- Validate Switch Vision-only generated YAML headers.
- Rename GHCR image and GitHub repository references.
- Remove previous-name compatibility aliases for clean-install testing.
