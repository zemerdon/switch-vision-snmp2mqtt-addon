#!/usr/bin/env sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
RUN="$ROOT/switch-vision-snmp2mqtt/run.sh"
FIXTURE="$ROOT/tests/generated-snmp2mqtt.yaml"
grep -q '^# Switch Vision generated SNMP2MQTT YAML' "$FIXTURE"
grep -q '^# Source: Switch Vision Discovery' "$FIXTURE"
grep -q '/share/switch_vision/generated-snmp2mqtt.yaml' "$RUN"
grep -q "use_switch_vision_generated_yaml" "$RUN"
if grep -RiqE 'Cisco[[:space:]_-]+Vision|cisco[-_]vision' "$ROOT/switch-vision-snmp2mqtt" "$ROOT/README.md" "$ROOT/repository.json" --exclude='*.png'; then
  echo 'Legacy project identifier found' >&2
  exit 1
fi
echo 'Switch Vision SNMP2MQTT cutover self-test: PASS'
