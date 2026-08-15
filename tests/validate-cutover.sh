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
grep -q '^version: 0.9.9$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q '^ARG CORE_VERSION=v0.9.9$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q '^ARG CORE_COMMIT=9b8cfcf481bbb4139a0a3c0564a0e33264b3317a$' "$ROOT/switch-vision-snmp2mqtt/Dockerfile"
grep -q 'CORE_VERSION=v0.9.9' "$ROOT/.github/workflows/build.yml"
grep -q 'CORE_COMMIT=9b8cfcf481bbb4139a0a3c0564a0e33264b3317a' "$ROOT/.github/workflows/build.yml"
grep -q '^umask 077$' "$RUN"
grep -q 'chmod 700 "${IMPORTED_TARGETS_DIR}"' "$RUN"
grep -q 'chmod 700 "${BACKUP_DIR}"' "$RUN"
grep -q 'chmod 600 "${BACKUP_FILE}"' "$RUN"
grep -q 'chmod 600 "${IMPORTED_TARGETS_PATH}"' "$RUN"
grep -q 'chmod 600 /app/config.yml' "$RUN"
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
grep -q 'local_apps:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
grep -q 'all_app_configs:rw' "$ROOT/switch-vision-snmp2mqtt/config.yaml"
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
