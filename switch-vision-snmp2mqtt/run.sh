#!/usr/bin/with-contenv bashio

# Credential-bearing generated config and backups are private by default.
umask 077

# ==============================================================================
# Switch Vision SNMP2MQTT
# SNMP2MQTT bridge with optional Switch Vision Discovery generated YAML import.
# ==============================================================================
if bashio::supervisor.ping; then
  bashio::log.blue \
    '-----------------------------------------------------------'
  bashio::log.blue " App: $(bashio::addon.name)"
  bashio::log.blue " $(bashio::addon.description)"
  bashio::log.blue \
    '-----------------------------------------------------------'
  bashio::log.blue " App version: $(bashio::addon.version)"
  if bashio::var.true "$(bashio::addon.update_available)"; then
    bashio::log.magenta ' There is an update available for this app!'
    bashio::log.magenta \
        " Latest app version: $(bashio::addon.version_latest)"
    bashio::log.magenta ' Please consider upgrading as soon as possible.'
  else
    bashio::log.green ' You are running the latest version of this app.'
  fi

  bashio::log.blue " System: $(bashio::info.operating_system)" \
    " ($(bashio::info.arch) / $(bashio::info.machine))"
  bashio::log.blue " Home Assistant Core: $(bashio::info.homeassistant)"
  bashio::log.blue " Home Assistant Supervisor: $(bashio::info.supervisor)"

  bashio::log.blue \
    '-----------------------------------------------------------'
  bashio::log.blue \
    ' Please share the above information when looking for help.'
  bashio::log.blue \
    '-----------------------------------------------------------'
fi

# ==============================================================================
CONFIG_PATH=/data/options.json
TARGET_PATH="$(bashio::config 'targets_path' 2>/dev/null || true)"
USE_SWITCH_VISION_GENERATED_YAML="$(bashio::config 'use_switch_vision_generated_yaml' 2>/dev/null || true)"
SWITCH_VISION_GENERATED_YAML_PATH="$(bashio::config 'switch_vision_generated_yaml_path' 2>/dev/null || true)"
IMPORTED_TARGETS_PATH="$(bashio::config 'imported_targets_path' 2>/dev/null || true)"
BACKUP_EXISTING_CONFIG="$(bashio::config 'backup_existing_config' 2>/dev/null || true)"

# Bashio renders some absent optional values as the literal string "null".
# Normalize all wrapper-owned options before applying defaults so an upgraded
# pre-generated-YAML installation can never try to open a file literally named
# "null".
[ "${TARGET_PATH}" = "null" ] && TARGET_PATH=""
[ "${USE_SWITCH_VISION_GENERATED_YAML}" = "null" ] && USE_SWITCH_VISION_GENERATED_YAML=""
[ "${SWITCH_VISION_GENERATED_YAML_PATH}" = "null" ] && SWITCH_VISION_GENERATED_YAML_PATH=""
[ "${IMPORTED_TARGETS_PATH}" = "null" ] && IMPORTED_TARGETS_PATH=""
[ "${BACKUP_EXISTING_CONFIG}" = "null" ] && BACKUP_EXISTING_CONFIG=""

if [ -z "${TARGET_PATH}" ]; then
  TARGET_PATH="/config/app_configs/switch_vision_snmp2mqtt/targets.yaml"
fi

if [ -z "${USE_SWITCH_VISION_GENERATED_YAML}" ]; then
  USE_SWITCH_VISION_GENERATED_YAML="true"
  bashio::log.notice 'Generated-YAML import option was absent; using the Switch Vision default (enabled).'
fi

if [ -z "${SWITCH_VISION_GENERATED_YAML_PATH}" ]; then
  SWITCH_VISION_GENERATED_YAML_PATH="/share/switch_vision/generated-snmp2mqtt.yaml"
fi

if [ -z "${IMPORTED_TARGETS_PATH}" ]; then
  IMPORTED_TARGETS_PATH="/config/app_configs/switch_vision_snmp2mqtt/imported/generated-snmp2mqtt.yaml"
fi

if [ -z "${BACKUP_EXISTING_CONFIG}" ]; then
  BACKUP_EXISTING_CONFIG="false"
fi

switch_vision_generated_yaml_is_valid() {
  local generated_file="$1"
  [ -f "${generated_file}" ] || return 1
  ! grep -q 'CHANGE_ME' "${generated_file}" || return 1
  grep -q '^# Switch Vision generated SNMP2MQTT YAML' "${generated_file}" || return 1
  grep -q '^# Source: Switch Vision Discovery' "${generated_file}" || return 1
  grep -q '^targets:' "${generated_file}" || return 1
  grep -Eq '^[[:space:]]*-[[:space:]]+host:[[:space:]]+[^[:space:]]+' "${generated_file}" || return 1
  return 0
}

validate_switch_vision_generated_yaml() {
  local generated_file="$1"

  if [ ! -f "${generated_file}" ]; then
    bashio::log.fatal 'Switch Vision generated YAML import is enabled, but file was not found:'
    bashio::log.fatal " ${generated_file}"
    return 1
  fi

  if grep -q 'CHANGE_ME' "${generated_file}"; then
    bashio::log.fatal 'Switch Vision generated YAML rejected: CHANGE_ME placeholder found.'
    return 1
  fi

  if ! grep -q '^# Switch Vision generated SNMP2MQTT YAML' "${generated_file}"; then
    bashio::log.fatal 'Switch Vision generated YAML rejected: generated YAML header missing.'
    return 1
  fi

  if ! grep -q '^# Source: Switch Vision Discovery' "${generated_file}"; then
    bashio::log.fatal 'Switch Vision generated YAML rejected: Switch Vision Discovery source header missing.'
    return 1
  fi

  if ! grep -q '^targets:' "${generated_file}"; then
    bashio::log.fatal 'Switch Vision generated YAML rejected: targets block missing.'
    return 1
  fi

  if ! grep -Eq '^[[:space:]]*-[[:space:]]+host:[[:space:]]+[^[:space:]]+' "${generated_file}"; then
    bashio::log.fatal 'Switch Vision generated YAML rejected: no target host entries found.'
    return 1
  fi

  return 0
}

# v0.9.14 migration safety: v0.9.4 deliberately preserved older saved options,
# so an installation upgraded from the manual-target era can still contain
# use_switch_vision_generated_yaml=false with no usable manual target file. If
# that impossible combination is found and Discovery has supplied a valid
# generated file, recover automatically for this run. A deliberate, functioning
# manual configuration remains untouched.
if ! bashio::var.true "${USE_SWITCH_VISION_GENERATED_YAML}" && [ ! -f "${TARGET_PATH}" ]; then
  if switch_vision_generated_yaml_is_valid "${SWITCH_VISION_GENERATED_YAML_PATH}"; then
    bashio::log.warning 'Legacy manual-target configuration is unusable because its targets file is missing.'
    bashio::log.warning 'A valid Switch Vision Discovery generated YAML is available; recovering to generated-YAML import for this run.'
    USE_SWITCH_VISION_GENERATED_YAML="true"
  else
    bashio::log.fatal
    bashio::log.fatal 'Configuration of this app is incomplete.'
    bashio::log.fatal 'Generated-YAML import is disabled and the manual Targets file does not exist:'
    bashio::log.fatal " ${TARGET_PATH}"
    bashio::log.fatal 'No valid Switch Vision Discovery generated YAML is available for automatic recovery:'
    bashio::log.fatal " ${SWITCH_VISION_GENERATED_YAML_PATH}"
    bashio::log.fatal
    bashio::exit.nok
  fi
fi

if bashio::var.true "${USE_SWITCH_VISION_GENERATED_YAML}"; then
  bashio::log.info 'Switch Vision generated YAML import is enabled.'
  bashio::log.info 'Switch Vision generated YAML path:'
  bashio::log.blue "                  ${SWITCH_VISION_GENERATED_YAML_PATH}"

  if ! validate_switch_vision_generated_yaml "${SWITCH_VISION_GENERATED_YAML_PATH}"; then
    bashio::exit.nok
  fi

  GENERATED_TARGET_COUNT="$(grep -Ec '^[[:space:]]*-[[:space:]]+host:[[:space:]]+[^[:space:]]+' "${SWITCH_VISION_GENERATED_YAML_PATH}" || true)"
  GENERATED_SENSOR_COUNT="$(grep -Ec '^[[:space:]]*-[[:space:]]+oid:[[:space:]]+' "${SWITCH_VISION_GENERATED_YAML_PATH}" || true)"
  GENERATED_SHA256="$(sha256sum "${SWITCH_VISION_GENERATED_YAML_PATH}" | awk '{print $1}')"

  bashio::log.info 'Switch Vision generated YAML validated.'
  bashio::log.info "Generated targets: ${GENERATED_TARGET_COUNT}"
  bashio::log.info "Generated sensors: ${GENERATED_SENSOR_COUNT}"
  bashio::log.info "Generated YAML SHA-256: ${GENERATED_SHA256}"

  IMPORTED_TARGETS_DIR="$(dirname "${IMPORTED_TARGETS_PATH}")"
  mkdir -p "${IMPORTED_TARGETS_DIR}"
  chmod 700 "${IMPORTED_TARGETS_DIR}"

  if bashio::var.true "${BACKUP_EXISTING_CONFIG}" && [ -f "${TARGET_PATH}" ]; then
    BACKUP_DIR="/config/app_configs/switch_vision_snmp2mqtt/backups"
    BACKUP_FILE="${BACKUP_DIR}/targets-$(date -u +%Y%m%dT%H%M%SZ).yaml"
    mkdir -p "${BACKUP_DIR}"
    chmod 700 "${BACKUP_DIR}"
    cp "${TARGET_PATH}" "${BACKUP_FILE}"
    chmod 600 "${BACKUP_FILE}"
    bashio::log.info 'Existing SNMP2MQTT targets config backed up to:'
    bashio::log.blue "                  ${BACKUP_FILE}"
  fi

  cp "${SWITCH_VISION_GENERATED_YAML_PATH}" "${IMPORTED_TARGETS_PATH}"
  chmod 600 "${IMPORTED_TARGETS_PATH}"
  TARGET_PATH="${IMPORTED_TARGETS_PATH}"

  bashio::log.info 'Switch Vision generated YAML validated and imported to:'
  bashio::log.blue "                  ${TARGET_PATH}"
else
  bashio::log.warning 'Switch Vision generated YAML import is disabled; using the manually configured targets file.'
fi

if [ ! -f "${TARGET_PATH}" ]; then
  bashio::log.fatal
  bashio::log.fatal 'Configuration of this app is incomplete.'
  bashio::log.fatal
  bashio::log.fatal 'File with Targets config not found:'
  bashio::log.fatal " ${TARGET_PATH}"
  bashio::log.fatal
  bashio::exit.nok
fi

# Resolve Home Assistant's MQTT service for fresh/default installations.
# Explicit custom broker hosts remain untouched. v0.9.6 installations that
# still contain the old localhost default are migrated at runtime without
# rewriting the user's saved Supervisor options.
MQTT_CONFIG_HOST="$(bashio::config 'mqtt.host' 2>/dev/null || true)"
MQTT_CONFIG_PORT="$(bashio::config 'mqtt.port' 2>/dev/null || true)"
MQTT_CONFIG_USERNAME="$(bashio::config 'mqtt.username' 2>/dev/null || true)"
MQTT_CONFIG_PASSWORD="$(bashio::config 'mqtt.password' 2>/dev/null || true)"

# Bashio may render an absent optional value as the literal string "null".
# Normalize that to empty before deciding whether Supervisor service values
# should be used.
[ "${MQTT_CONFIG_HOST}" = "null" ] && MQTT_CONFIG_HOST=""
[ "${MQTT_CONFIG_PORT}" = "null" ] && MQTT_CONFIG_PORT=""
[ "${MQTT_CONFIG_USERNAME}" = "null" ] && MQTT_CONFIG_USERNAME=""
[ "${MQTT_CONFIG_PASSWORD}" = "null" ] && MQTT_CONFIG_PASSWORD=""

USE_SUPERVISOR_MQTT=false
case "${MQTT_CONFIG_HOST}" in
  ""|localhost|127.0.0.1|core-mosquitto)
    USE_SUPERVISOR_MQTT=true
    ;;
esac

if [ "${USE_SUPERVISOR_MQTT}" = "true" ]; then
  SERVICE_MQTT_HOST="$(bashio::services mqtt 'host' 2>/dev/null || true)"
  SERVICE_MQTT_PORT="$(bashio::services mqtt 'port' 2>/dev/null || true)"
  SERVICE_MQTT_USERNAME="$(bashio::services mqtt 'username' 2>/dev/null || true)"
  SERVICE_MQTT_PASSWORD="$(bashio::services mqtt 'password' 2>/dev/null || true)"

  if [ -z "${SERVICE_MQTT_HOST}" ]; then
    bashio::log.fatal 'Home Assistant MQTT service is required but no MQTT service host was returned by Supervisor.'
    bashio::exit.nok
  fi

  SV_MQTT_HOST="${SERVICE_MQTT_HOST}"
  SV_MQTT_PORT="${SERVICE_MQTT_PORT:-1883}"
  SV_MQTT_USERNAME="${SERVICE_MQTT_USERNAME}"
  SV_MQTT_PASSWORD="${SERVICE_MQTT_PASSWORD}"
  bashio::log.info 'Using Home Assistant Supervisor MQTT service.'
else
  SV_MQTT_HOST="${MQTT_CONFIG_HOST}"
  SV_MQTT_PORT="${MQTT_CONFIG_PORT:-1883}"
  SV_MQTT_USERNAME="${MQTT_CONFIG_USERNAME}"
  SV_MQTT_PASSWORD="${MQTT_CONFIG_PASSWORD}"
  bashio::log.info 'Using explicitly configured MQTT broker.'
fi

export SV_MQTT_HOST SV_MQTT_PORT SV_MQTT_USERNAME SV_MQTT_PASSWORD

bashio::log.info 'SNMP2MQTT Starting...'

bashio::log.info 'Prepare config...'
yq -p json -o yaml \
  'del(.targets_path, .use_switch_vision_generated_yaml, .switch_vision_generated_yaml_path, .imported_targets_path, .backup_existing_config)
   | .mqtt.host = strenv(SV_MQTT_HOST)
   | .mqtt.port = (strenv(SV_MQTT_PORT) | tonumber)
   | .mqtt.username = strenv(SV_MQTT_USERNAME)
   | .mqtt.password = strenv(SV_MQTT_PASSWORD)' \
  "${CONFIG_PATH}" > /app/config.yml
cat "${TARGET_PATH}" >> /app/config.yml
chmod 600 /app/config.yml

bashio::log.info
bashio::log.info 'Configuration - Targets from:'
bashio::log.blue "                  ${TARGET_PATH}"
bashio::log.info 'Configuration - MQTT Host:'
bashio::log.blue "                  $(bashio::config 'mqtt.host')"
bashio::log.info 'SNMP2MQTT Start'
bashio::log.info

# ==============================================================================
bashio::color.blue
# Replace the wrapper process so Supervisor receives the core's exact exit
# status and stop signals are delivered directly to SNMP2MQTT.
exec node /app/dist/index.js
