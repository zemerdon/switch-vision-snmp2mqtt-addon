# Changelog

## 0.9.12

- Build the Home Assistant app against Switch Vision SNMP2MQTT Core `v0.9.12` at exact merge commit `e9a961f25fd3eb205321d8494c596911fa97fc49`.
- Pin the Node `lts-alpine3.22` builder image to immutable multi-architecture OCI digest `sha256:191c9f0080fcbbc6547a85dc0ff7988072214a355aabdc1d2ec55a7dae5eea8a`.
- Pin the Home Assistant runtime base image to immutable multi-architecture OCI digest `sha256:94ff231402a5e7ad2a82e261ad5fa4ffae7d7bb095c3febb2edbdf309c9b6aca`.
- Prevent future wrapper rebuilds from silently consuming different builder or runtime base images without an explicit source change.
- Preserve reduced writable mounts, generated-YAML import, backup/config handling, Supervisor MQTT integration, Juniper EX3300 live-interface behavior, graceful shutdown handling, and Core runtime behavior unchanged.

## 0.9.11

- Build the Home Assistant app against Switch Vision SNMP2MQTT Core `v0.9.11` at exact merge commit `e25140122506a90a8c47b90d9e6d78ab8448deb6`.
- Remove the unused writable `local_apps` and `all_app_configs` mounts from the app sandbox.
- Retain only the mappings required by the current wrapper workflow: `/config` read/write for imported targets/backups, `/share` read/write for Switch Vision generated YAML handoff, and `/ssl` read-only for TLS material.
- Extend the cutover regression so the removed broad writable mappings cannot accidentally return.
- Preserve generated-YAML import, backup/config paths, Supervisor MQTT discovery, EX3300 handling, and SNMP/MQTT runtime behavior unchanged.

## 0.9.10

- Build and publish the Home Assistant app against Switch Vision SNMP2MQTT Core `v0.9.10`.
- Verify that Core tag `v0.9.10` resolves to merge commit `b5416827a8c53729c61ea842e45c9ec42c96249d` during the container build.
- Inherit Core v0.9.10 graceful `SIGTERM` handling and single-flight shutdown protection without changing existing Home Assistant app stop behaviour.
- Change the Home Assistant `/ssl` mapping from writable to read-only; certificate/key files remain available for MQTT TLS configuration without giving the bridge write access to the SSL store.
- Extend the existing cutover regression to verify the v0.9.10 Core pin and read-only SSL mapping.
- Preserve generated-YAML import, backup/config paths, MQTT service discovery, EX3300 live-interface handling, and existing writable mappings required by the current wrapper workflow.

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
