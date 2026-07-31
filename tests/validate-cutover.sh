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
