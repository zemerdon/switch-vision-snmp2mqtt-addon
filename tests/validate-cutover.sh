#!/usr/bin/env sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
RUN="$ROOT/switch-vision-snmp2mqtt/run.sh"
FIXTURE="$ROOT/tests/generated-snmp2mqtt.yaml"
bash -n "$RUN"
grep -q '^# Switch Vision generated SNMP2MQTT YAML' "$FIXTURE"
grep -q '^# Source: Switch Vision Discovery' "$FIXTURE"
grep -q '^# Switch Vision generation ID: 123e4567-e89b-12d3-a456-426614174000$' "$FIXTURE"
fixture_generation_id="$(grep -m1 '^# Switch Vision generation ID:' "$FIXTURE" | sed 's/^# Switch Vision generation ID: //' | tr '[:upper:]' '[:lower:]')"
[ "$fixture_generation_id" = '123e4567-e89b-12d3-a456-426614174000' ]
grep -q '/share/switch_vision/generated-snmp2mqtt.yaml' "$RUN"
grep -q "use_switch_vision_generated_yaml" "$RUN"
grep -q 'use_switch_vision_generated_yaml: true' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q 'Generated targets:' "$RUN"
grep -q 'Generated sensors:' "$RUN"
grep -q 'Generated YAML SHA-256:' "$RUN"
grep -q "bashio::services mqtt 'host'" "$RUN"
grep -q "bashio::services mqtt 'username'" "$RUN"
grep -q "bashio::services mqtt 'password'" "$RUN"
grep -q 'SV_MQTT_HOST' "$RUN"
grep -q 'exec node /app/dist/index.js' "$RUN"
grep -q '^version: 1.0.1$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^schema:$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^  mqtt:$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -Fq '    host: str?' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -Fq '    password: password?' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^  use_switch_vision_generated_yaml: bool$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^  backup_existing_config: bool$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^  backup_existing_config: false$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
[ "$(grep -c '^  homeassistant:$' "$ROOT/switch-vision-snmp2mqtt/config.yaml")" -eq 2 ]
grep -q '^    discovery: true$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^    prefix: homeassistant$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^    discovery: bool$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^    prefix: str$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -Fq '.homeassistant.discovery = true' "$RUN"
grep -Fq '.homeassistant.prefix = "homeassistant"' "$RUN"
grep -Fq 'HOMEASSISTANT_DISCOVERY_REQUESTED' "$RUN"
grep -Fq 'Home Assistant discovery was saved as disabled; Switch Vision requires it' "$RUN"
grep -Fq 'snmp2mqtt-runtime.json' "$RUN"
grep -Fq '"homeassistant_discovery_effective": true' "$RUN"
grep -Fq '"homeassistant_prefix_requested_mode"' "$RUN"
if grep -Fq '"homeassistant_prefix_requested":' "$RUN"; then
  echo 'Raw custom Home Assistant discovery prefix is still written to diagnostics' >&2
  exit 1
fi
grep -q '^ARG CORE_VERSION=v1.0.1$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^ARG CORE_COMMIT=084c0d528dedec5f90767f16a7c03b57fec28e49$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^ARG BUILD_FROM=ghcr.io/home-assistant/base:latest@sha256:94ff231402a5e7ad2a82e261ad5fa4ffae7d7bb095c3febb2edbdf309c9b6aca$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^FROM node:lts-alpine3.22@sha256:191c9f0080fcbbc6547a85dc0ff7988072214a355aabdc1d2ec55a7dae5eea8a AS builder$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q 'CORE_VERSION=v1.0.1' "$ROOT/.github/workflows/build.yml"
grep -q 'CORE_COMMIT=084c0d528dedec5f90767f16a7c03b57fec28e49' "$ROOT/.github/workflows/build.yml"
grep -q 'CORE_VERSION=v1.0.1' "$ROOT/.github/workflows/publish-release.yml"
grep -q 'CORE_COMMIT=084c0d528dedec5f90767f16a7c03b57fec28e49' "$ROOT/.github/workflows/publish-release.yml"
grep -q '^umask 077$' "$RUN"
grep -q 'chmod 700 "${IMPORTED_TARGETS_DIR}"' "$RUN"
grep -q 'chmod 700 "${BACKUP_DIR}"' "$RUN"
grep -q 'chmod 600 "${BACKUP_FILE}"' "$RUN"
grep -q 'chmod 600 "${IMPORTED_TARGETS_PATH}"' "$RUN"
grep -q 'chmod 600 /app/config.yml' "$RUN"

# v0.9.14: Bashio literal-null normalization and safe legacy recovery are
# permanent contracts. Missing/null generated-import state defaults enabled;
# an explicit false remains honored while its manual file exists, and only an
# unusable legacy manual configuration may recover to a valid generated file.
grep -Fq '[ "${TARGET_PATH}" = "null" ] && TARGET_PATH=""' "$RUN"
grep -Fq '[ "${USE_SWITCH_VISION_GENERATED_YAML}" = "null" ] && USE_SWITCH_VISION_GENERATED_YAML=""' "$RUN"
grep -Fq '[ "${SWITCH_VISION_GENERATED_YAML_PATH}" = "null" ] && SWITCH_VISION_GENERATED_YAML_PATH=""' "$RUN"
grep -Fq '[ "${IMPORTED_TARGETS_PATH}" = "null" ] && IMPORTED_TARGETS_PATH=""' "$RUN"
grep -Fq 'USE_SWITCH_VISION_GENERATED_YAML="true"' "$RUN"
grep -Fq 'switch_vision_generated_yaml_is_valid()' "$RUN"
grep -Fq 'if ! bashio::var.true "${USE_SWITCH_VISION_GENERATED_YAML}" && [ ! -f "${TARGET_PATH}" ]; then' "$RUN"
grep -Fq 'recovering to generated-YAML import for this run.' "$RUN"
grep -Fq 'No valid Switch Vision Discovery generated YAML is available for automatic recovery:' "$RUN"
grep -Fq 'if [ ! -f "${SWITCH_VISION_GENERATED_YAML_PATH}" ]; then' "$RUN"
grep -Fq 'No Switch Vision generated SNMP2MQTT YAML is currently published.' "$RUN"
grep -Fq 'SNMP2MQTT will remain stopped until Discovery publishes an SNMP target file.' "$RUN"
grep -Fq 'This is expected on UniFi2MQTT-only installations.' "$RUN"
grep -Fq 'exit 0' "$RUN"
if grep -Fq 'File with Targets config not found:' "$RUN" && ! grep -Fq '[ "${TARGET_PATH}" = "null" ] && TARGET_PATH=""' "$RUN"; then
  echo 'Targets path can still reach file validation as literal null' >&2
  exit 1
fi

if grep -q '^bashio::exit.ok' "$RUN"; then
  echo 'Wrapper still masks the SNMP2MQTT core exit status' >&2
  exit 1
fi
grep -q 'mqtt:need' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
if grep -q '^[[:space:]]*host:[[:space:]]*localhost[[:space:]]*$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"; then
  echo 'Fresh-install localhost MQTT default remains' >&2
  exit 1
fi
grep -q 'sh tests/validate-cutover.sh' "$ROOT/.github/workflows/build.yml"
if grep -q 'local_apps:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"; then
  echo 'Unused local_apps writable mapping remains' >&2
  exit 1
fi
if grep -q 'all_app_configs:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"; then
  echo 'Unused all_app_configs writable mapping remains' >&2
  exit 1
fi
# v0.9.17: Home Assistant OS 18.2 deprecates the legacy `config` map key.
# Use the current mapping name, but pin its container path to /config so every
# established Switch Vision SNMP2MQTT option/path remains compatible.
grep -q '^- type: homeassistant_config$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^  path: /config$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^- type: share$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^- type: ssl$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
if grep -q '^[[:space:]]*-[[:space:]]*config:rw[[:space:]]*$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"; then
  echo 'Deprecated Home Assistant config map remains' >&2
  exit 1
fi
# v1.0.0: `homeassistant` is intentionally a user-visible SNMP2MQTT
# configuration section again. The wrapper still forces Switch Vision's
# required effective discovery=true / prefix=homeassistant contract.
if grep -q 'ssl:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"; then
  echo 'SSL mapping remains writable' >&2
  exit 1
fi
grep -q '/config/app_configs/switch_vision_snmp2mqtt/' "$RUN"
if grep -RiqE 'addons_config|all_addon_configs|^[[:space:]]*-[[:space:]]*addons:rw' "$ROOT/switch-vision-snmp2mqtt" --exclude='CHANGELOG.md' --exclude='*.png'; then
  echo 'Previous Home Assistant path or mapping found' >&2
  exit 1
fi
if grep -RiqE 'Cisco[[:space:]_-]+Vision|cisco[-_]vision' "$ROOT/switch-vision-snmp2mqtt" "$ROOT/README.md" "$ROOT/repository.json" --exclude='*.png'; then
  echo 'Legacy project identifier found' >&2
  exit 1
fi
echo 'Switch Vision SNMP2MQTT cutover self-test: PASS'
