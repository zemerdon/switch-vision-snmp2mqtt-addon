# Changelog

## 0.9.9

- Build and publish the Home Assistant app against Switch Vision SNMP2MQTT core `v0.9.9`.
- Verify that core tag `v0.9.9` resolves to merge commit `9b8cfcf481bbb4139a0a3c0564a0e33264b3317a` during the container build.
- Add runtime live IF-MIB interface-name resolution for dynamic ifIndex changes and Juniper EX3300 SFP/SFP+ hot-plug handling.
- Support alternate `xe-...` / `ge-...` interface candidates without requiring regenerated YAML when the active uplink mode changes.
- Preserve existing MQTT, generated-YAML import, private runtime-file, and Supervisor integration behavior.

## 0.9.8

- Build and publish the Home Assistant app against hardened Switch Vision SNMP2MQTT core `v0.9.8`.
- Verify that core tag `v0.9.8` resolves to audited core commit `0cdbbfe843c47cd596bd02401cab07dc11827b63` during the container build.
- Inherit core v0.9.8 restricted transforms, strict SNMP version handling, SNMPv3 semantic validation, duplicate explicit Home Assistant `object_id` rejection, and overlapping-poll protection.
- Set `umask 077` in the runtime wrapper and enforce owner-only modes on imported generated YAML, local backups, and the generated runtime configuration.
- Extend the repository cutover regression gate to verify the v0.9.8 core pin and private runtime-file contract.

## 0.9.7

- Resolve the Home Assistant Supervisor MQTT service automatically for fresh installs and migrated `localhost` defaults.
- Preserve explicit custom MQTT broker hosts and credentials.
- Pass Supervisor MQTT host, port, username and password into the generated runtime configuration without logging secrets.
- Replace the shell wrapper with the Node process so fatal core exits and stop signals propagate correctly to Supervisor.
- Pin the container build to Switch Vision SNMP2MQTT core tag `v0.9.7`.
- Run the repository cutover/runtime regression script before publishing the multi-architecture image.

## 0.9.6

- Pin the container build to Switch Vision SNMP2MQTT core tag `v0.9.6`.
- Add Juniper EX VLAN and trunk discovery support from the updated core.
- Use `local_apps` and `all_app_configs` Home Assistant OS mappings.
- Move app configuration paths to `/config/app_configs/switch_vision_snmp2mqtt/`.
- Remove active legacy add-on mappings and legacy configuration-path fallbacks.
- Preserve the Switch Vision Discovery generated-YAML import workflow.

## 0.9.5

- Enable Home Assistant MQTT Discovery by default for fresh installations.
- Keep existing saved add-on options unchanged during upgrades.
- Derive the GHCR image tag and build metadata from `config.yaml` instead of hard-coding the version.
- Force each image build to fetch the current Switch Vision SNMP2MQTT core source.

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
