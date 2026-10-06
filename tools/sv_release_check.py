#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SHA_RE = re.compile(r"^[0-9a-f]{40}$")
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
GENERATED_ROOTS = ("switch-vision-snmp2mqtt", "tests", "tools")


def release_env() -> dict[str, str]:
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return env


def run(
    args: list[str],
    cwd: Path,
    *,
    timeout: int = 900,
) -> subprocess.CompletedProcess[str]:
    proc = subprocess.run(
        args,
        cwd=cwd,
        env=release_env(),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
        timeout=timeout,
    )
    if proc.stdout:
        print(proc.stdout, end="" if proc.stdout.endswith("\n") else "\n")
    if proc.returncode:
        raise SystemExit(
            f"SNMP2MQTT family release check command failed "
            f"({proc.returncode}): {' '.join(args)}"
        )
    return proc


def git_capture(repo: Path, *args: str) -> str:
    proc = subprocess.run(
        [
            "git",
            "-c",
            f"safe.directory={repo}",
            "-C",
            str(repo),
            *args,
        ],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if proc.returncode:
        raise SystemExit(
            "SNMP2MQTT git command failed: "
            + (proc.stderr or proc.stdout or "").strip()
        )
    return (proc.stdout or "").strip()


def git_status(repo: Path) -> str:
    return git_capture(
        repo,
        "status",
        "--porcelain=v1",
        "--untracked-files=all",
    )


def resolve_addon_version(root: Path) -> str:
    text = (
        root / "switch-vision-snmp2mqtt/config.yaml"
    ).read_text(encoding="utf-8")
    match = re.search(
        r"^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\s*$",
        text,
        flags=re.MULTILINE,
    )
    version = match.group(1) if match else ""
    if not SEMVER_RE.fullmatch(version):
        raise SystemExit(
            f"SNMP2MQTT app version is not exact semantic version: {version!r}"
        )
    return version


def engine_identity(engine_root: Path) -> tuple[str, str]:
    package = json.loads(
        (engine_root / "package.json").read_text(encoding="utf-8")
    )
    version = str(package.get("version") or "").strip()
    if not SEMVER_RE.fullmatch(version):
        raise SystemExit(
            f"SNMP2MQTT engine package version is invalid: {version!r}"
        )
    head = git_capture(engine_root, "rev-parse", "HEAD")
    if not SHA_RE.fullmatch(head):
        raise SystemExit("SNMP2MQTT engine HEAD identity is invalid")
    return version, head


def addon_engine_pin(root: Path) -> tuple[str, str]:
    dockerfile = (
        root / "switch-vision-snmp2mqtt/Dockerfile"
    ).read_text(encoding="utf-8")
    version_match = re.search(
        r"^ARG CORE_VERSION=v([0-9]+\.[0-9]+\.[0-9]+)\s*$",
        dockerfile,
        flags=re.MULTILINE,
    )
    commit_match = re.search(
        r"^ARG CORE_COMMIT=([0-9a-f]{40})\s*$",
        dockerfile,
        flags=re.MULTILINE,
    )
    if version_match is None or commit_match is None:
        raise SystemExit(
            "SNMP2MQTT app Docker engine pin is incomplete"
        )
    return version_match.group(1), commit_match.group(1)


def validate_engine_coordination(
    root: Path,
    engine_root: Path,
    engine_source_sha: str,
) -> tuple[str, str]:
    if not SHA_RE.fullmatch(engine_source_sha):
        raise SystemExit("coordinated engine source SHA is invalid")

    engine_version, engine_head = engine_identity(engine_root)
    if engine_head != engine_source_sha:
        raise SystemExit(
            "coordinated engine source tree does not match supplied SHA"
        )

    pinned_version, pinned_commit = addon_engine_pin(root)
    if pinned_version != engine_version:
        raise SystemExit(
            "SNMP2MQTT app engine version pin does not match local engine"
        )

    if pinned_commit != engine_source_sha:
        raise SystemExit(
            "SNMP2MQTT app engine commit pin does not match the exact "
            "coordinated engine source SHA"
        )

    workflow = (
        root / ".github/workflows/publish-release.yml"
    ).read_text(encoding="utf-8")
    for marker in (
        f"CORE_VERSION=v{pinned_version}",
        f"CORE_COMMIT={pinned_commit}",
    ):
        if marker not in workflow:
            raise SystemExit(
                "SNMP2MQTT public publisher engine pin drift: " + marker
            )

    changelog = (
        engine_root / "CHANGELOG.md"
    ).read_text(encoding="utf-8")
    if f"## v{engine_version}" not in changelog:
        raise SystemExit(
            "SNMP2MQTT engine changelog lacks current engine version"
        )

    readme = (
        root / "switch-vision-snmp2mqtt/README.md"
    ).read_text(encoding="utf-8")
    readme_marker = (
        f"engine `v{engine_version}` at reviewed commit "
        f"`{pinned_commit}`"
    )
    if readme_marker not in readme:
        raise SystemExit(
            "SNMP2MQTT app README engine pin does not match release contract"
        )

    print(
        "SNMP2MQTT coordinated engine contract: PASS "
        f"(v{engine_version}, local={engine_source_sha}, "
        f"pinned={pinned_commit}, exact-sha)"
    )
    return engine_version, pinned_commit


def validate_addon_version(root: Path, version: str) -> None:
    changelog = (
        root / "switch-vision-snmp2mqtt/CHANGELOG.md"
    ).read_text(encoding="utf-8")
    headings = re.findall(
        r"^##\s+([0-9]+\.[0-9]+\.[0-9]+)\s*$",
        changelog,
        flags=re.MULTILINE,
    )
    if not headings or headings[0] != version:
        raise SystemExit(
            "SNMP2MQTT app changelog first release heading "
            "does not match current version"
        )
    print(f"SNMP2MQTT app {version} version metadata contract: PASS")


def generated_junk(root: Path) -> list[Path]:
    problems: list[Path] = []
    for relative in GENERATED_ROOTS:
        base = root / relative
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_dir() and path.name == "__pycache__":
                problems.append(path)
            elif path.is_file() and (
                path.suffix in {".pyc", ".pyo"}
                or path.name == ".DS_Store"
            ):
                problems.append(path)
    return problems


def reject_generated_junk(root: Path) -> None:
    problems = generated_junk(root)
    if problems:
        shown = ", ".join(
            str(path.relative_to(root)) for path in problems[:20]
        )
        raise SystemExit(
            "SNMP2MQTT app generated cache/junk material present: " + shown
        )
    print("SNMP2MQTT app source hygiene: PASS")


def validate_dockerfile_contract(root: Path) -> None:
    text = (
        root / "switch-vision-snmp2mqtt/Dockerfile"
    ).read_text(encoding="utf-8")
    required = (
        "ARG BUILD_FROM=ghcr.io/home-assistant/base:latest@sha256:",
        "FROM node:lts-alpine3.22@sha256:",
        "ARG CORE_VERSION=",
        "ARG CORE_COMMIT=",
        "git init /tmp/snmp2mqtt",
        'git -C /tmp/snmp2mqtt fetch --depth 1 origin "${CORE_COMMIT}"',
        "git -C /tmp/snmp2mqtt checkout --detach FETCH_HEAD",
        'test "${actual_commit}" = "${CORE_COMMIT}"',
        'test "${actual_version}" = "${CORE_VERSION}"',
        'CMD [ "/run.sh" ]',
    )
    missing = [token for token in required if token not in text]
    if missing:
        raise SystemExit(
            "SNMP2MQTT app Dockerfile release contract missing: "
            + ", ".join(missing)
        )
    if 'git clone --branch "${CORE_VERSION}"' in text:
        raise SystemExit(
            "SNMP2MQTT app Dockerfile must fetch the exact CORE_COMMIT, "
            "not use CORE_VERSION as a Git selector"
        )
    print("SNMP2MQTT app Dockerfile release contract: PASS")


def run_engine_regressions(engine_root: Path) -> None:
    baseline_status = git_status(engine_root)
    run(
        [
            "yarn",
            "install",
            "--frozen-lockfile",
            "--non-interactive",
        ],
        engine_root,
        timeout=900,
    )
    run(
        ["yarn", "test:regression"],
        engine_root,
        timeout=1200,
    )
    final_status = git_status(engine_root)
    if final_status != baseline_status:
        raise SystemExit(
            "SNMP2MQTT engine regression changed tracked repository state"
        )
    print("SNMP2MQTT engine permanent regression suite: PASS")


def run_addon_regressions(root: Path) -> None:
    run(["sh", "tests/validate-cutover.sh"], root)
    run([sys.executable, "tools/test_sv_release_check.py"], root)
    print("SNMP2MQTT app permanent regression suite: PASS (2 checks)")


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Run the coordinated product-owned Switch Vision SNMP2MQTT "
            "engine + Home Assistant app release validation."
        )
    )
    parser.add_argument("--mode", choices=("release",), required=True)
    parser.add_argument("--engine-source-root", type=Path, required=True)
    parser.add_argument("--engine-source-sha", required=True)
    args = parser.parse_args()
    if args.mode != "release":
        raise SystemExit("unsupported release-check mode")

    root = ROOT
    engine_root = args.engine_source_root.resolve()
    if not (engine_root / "package.json").is_file():
        raise SystemExit("coordinated engine source root is unavailable")

    baseline_status = git_status(root)
    addon_version = resolve_addon_version(root)

    reject_generated_junk(root)
    validate_addon_version(root, addon_version)
    validate_dockerfile_contract(root)
    run(["bash", "-n", "switch-vision-snmp2mqtt/run.sh"], root)
    validate_engine_coordination(
        root,
        engine_root,
        args.engine_source_sha,
    )
    run_engine_regressions(engine_root)
    run_addon_regressions(root)
    reject_generated_junk(root)
    validate_addon_version(root, addon_version)

    final_status = git_status(root)
    if final_status != baseline_status:
        print(
            "SNMP2MQTT app release check changed repository state.",
            file=sys.stderr,
        )
        return 1

    print(
        f"SNMP2MQTT family app {addon_version} deterministic "
        "release validation: PASS"
    )
    print("SV_RELEASE_CHECK_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
