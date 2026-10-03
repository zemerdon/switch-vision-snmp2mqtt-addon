#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools/sv_release_check.py"
SPEC = importlib.util.spec_from_file_location(
    "sv_snmp_family_release_check_test",
    MODULE_PATH,
)
assert SPEC and SPEC.loader
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)


class SNMPFamilyReleaseCheckTests(unittest.TestCase):
    def test_current_app_version_is_1_0_5(self):
        self.assertEqual(release.resolve_addon_version(ROOT), "1.0.5")

    def test_engine_pin_is_exact_public_engine(self):
        version, commit = release.addon_engine_pin(ROOT)
        self.assertEqual(version, "1.0.3")
        self.assertEqual(
            commit,
            "a65a8d3af41eb1e5bb9014c2e0db3d4c0f01a350",
        )

    def test_release_dependency_set_is_intentionally_empty(self):
        lines = [
            line.strip()
            for line in (
                ROOT / "tools/sv_release_check.requirements.txt"
            ).read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]
        self.assertEqual(lines, [])

    def test_release_check_is_local_and_non_publishing(self):
        source = MODULE_PATH.read_text(encoding="utf-8")
        self.assertIn("SV_RELEASE_CHECK_PASS", source)
        self.assertIn("PYTHONDONTWRITEBYTECODE", source)
        self.assertIn("--engine-source-root", source)
        self.assertIn("--engine-source-sha", source)
        for forbidden in (
            "gh release",
            "docker push",
            "git push",
            "workflow_dispatch",
        ):
            self.assertNotIn(forbidden, source)

    def test_dockerfile_contract_requires_digest_and_engine_pin(self):
        release.validate_dockerfile_contract(ROOT)


if __name__ == "__main__":
    unittest.main(verbosity=2)
