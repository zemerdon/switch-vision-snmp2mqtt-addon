#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

changelog_path = ROOT / 'switch-vision-snmp2mqtt/CHANGELOG.md'
changelog = changelog_path.read_text(encoding='utf-8')
entry = '''## 0.9.15

- Restore the Home Assistant app `schema:` for the existing MQTT, manual-target, generated-YAML import, imported-target and backup options so Supervisor renders the Configuration/Options controls again.
- Add explicit defaults for optional MQTT host/username/password and `backup_existing_config` while preserving automatic Supervisor MQTT resolution when the host is blank.
- Keep Switch Vision SNMP2MQTT Core pinned to `v0.9.13` at `bc8bd1a057b21bc7f779325222a971130da3839e`; runtime polling and generated-YAML recovery behavior are unchanged from 0.9.14.
- Add permanent cutover checks requiring the Options schema and visible wrapper-owned fields.

'''
if changelog.startswith('# Changelog\n\n'):
    changelog = '# Changelog\n\n' + entry + changelog[len('# Changelog\n\n'):]
else:
    raise SystemExit('ERROR: unexpected Add-on changelog header')
changelog_path.write_text(changelog, encoding='utf-8', newline='\n')

test_path = ROOT / 'tests/validate-cutover.sh'
test = test_path.read_text(encoding='utf-8')
old = "grep -q '^version: 0.9.14$' \"$ROOT/switch-vision-snmp2mqtt/config.yaml\""
new = "grep -q '^version: 0.9.15$' \"$ROOT/switch-vision-snmp2mqtt/config.yaml\""
if old not in test:
    raise SystemExit('ERROR: expected 0.9.14 cutover version assertion not found')
test = test.replace(old, new, 1)
marker = new + '\n'
schema_checks = '''grep -q '^schema:$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -q '^  mqtt:$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -Fq '    host: str?' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -Fq '    password: password?' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -q '^  use_switch_vision_generated_yaml: bool$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -q '^  backup_existing_config: bool$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\ngrep -q '^  backup_existing_config: false$' "$ROOT/switch-vision-snmp2mqtt/config.yaml"\n'''
if 'backup_existing_config: bool' not in test:
    test = test.replace(marker, marker + schema_checks, 1)
test_path.write_text(test, encoding='utf-8', newline='\n')
print('Prepared SNMP2MQTT Add-on v0.9.15 Options schema hotfix')
