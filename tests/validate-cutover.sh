#!/usr/bin/env sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
RUN="$ROOT/switch-vision-snmp2mqtt/run.sh"
FIXTURE="$ROOT/tests/generated-snmp2mqtt.yaml"
grep -q '^# Switch Vision generated SNMP2MQTT YAML' "$FIXTURE"
grep -q '^# Source: Switch Vision Discovery' "$FIXTURE"
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
grep -q '^version: 0.9.14$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^ARG CORE_VERSION=v0.9.13$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^ARG CORE_COMMIT=bc8bd1a057b21bc7f779325222a971130da3839e$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^ARG BUILD_FROM=ghcr.io/home-assistant/base:latest@sha256:94ff231402a5e7ad2a82e261ad5fa4ffae7d7bb095c3febb2edbdf309c9b6aca$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^FROM node:lts-alpine3.22@sha256:191c9f0080fcbbc6547a85dc0ff7988072214a355aabdc1d2ec55a7dae5eea8a AS builder$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q 'CORE_VERSION=v0.9.13' "$ROOT/.github/workflows/build.yml"
grep -q 'CORE_COMMIT=bc8bd1a057b21bc7f779325222a971130da3839e' "$ROOT/.github/workflows/build.yml"
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
grep -q 'config:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q 'share:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q 'ssl:ro' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
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
