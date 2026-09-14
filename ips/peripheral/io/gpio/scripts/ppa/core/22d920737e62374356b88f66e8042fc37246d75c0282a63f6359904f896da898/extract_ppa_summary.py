#!/usr/bin/env python3
"""Extract one manifest-bound PPA point from explicit Design Compiler reports."""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from pathlib import Path
from typing import Any

import yaml

AREA_PATTERNS = (
    re.compile(r"Total cell area:\s+([\d.]+)"),
    re.compile(r"Total area:\s+([\d.]+)"),
)
SLACK_PATTERN = re.compile(r"slack\s*\((?P<status>[^)]*)\)\s*(?:=\s*)?(?P<value>-?[\d.]+)", re.I)
ARRIVAL_PATTERN = re.compile(r"data arrival time\s+([\d.]+)", re.I)
DYNAMIC_PATTERN = re.compile(r"Total Dynamic Power\s*=\s*([\d.]+)\s*(mW|uW|W)", re.I)
LEAKAGE_PATTERN = re.compile(r"Cell Leakage Power\s*=\s*([\d.]+)\s*(nW|uW|mW|W)", re.I)
CORNER_PATTERN = re.compile(r"Operating Conditions:\s*(\S+)")
LIBRARY_PATTERN = re.compile(r"Operating Conditions:.*?Library:\s*(\S+)")


def _load_mapping(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path}: expected a YAML mapping")
    return data


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _scaled(match: re.Match[str], factors: dict[str, float]) -> float:
    return float(match.group(1)) * factors[match.group(2).lower()]


def extract(
    manifest: dict[str, Any],
    manifest_path: Path,
    area_path: Path,
    timing_path: Path,
    power_path: Path,
    evidence_level: str,
) -> dict[str, Any]:
    if manifest.get("schema") != "ip-ppa-run/1.0":
        raise ValueError("manifest schema must be ip-ppa-run/1.0")
    run_dir = manifest_path.resolve().parent
    declared = manifest.get("raw_reports", {})
    for kind, path in (("area", area_path), ("timing", timing_path), ("power", power_path)):
        expected = run_dir / str(declared.get(kind, ""))
        if path.resolve() != expected.resolve():
            raise ValueError(f"{kind} report must match manifest and stay in its run directory: {expected}")
    evaluator = Path(str(manifest.get("evaluator_script", "")))
    if not evaluator.is_file() or _sha256(evaluator) != manifest.get("evaluator_sha256"):
        raise ValueError("instantiated evaluator script is missing or differs from the manifest hash")

    area_text = area_path.read_text(encoding="utf-8", errors="replace")
    timing_text = timing_path.read_text(encoding="utf-8", errors="replace")
    power_text = power_path.read_text(encoding="utf-8", errors="replace")

    area_match = next((pattern.search(area_text) for pattern in AREA_PATTERNS if pattern.search(area_text)), None)
    slack_match = SLACK_PATTERN.search(timing_text)
    dynamic_match = DYNAMIC_PATTERN.search(power_text)
    leakage_match = LEAKAGE_PATTERN.search(power_text)
    unconstrained = "(Path is unconstrained)" in timing_text or "no constrained paths" in timing_text.lower()
    missing = [
        name
        for name, match in (
            ("area", area_match),
            ("slack", slack_match),
            ("dynamic power", dynamic_match),
            ("leakage power", leakage_match),
        )
        if match is None
    ]
    if evidence_level in {"E2", "E3"} and (missing or unconstrained):
        details = []
        if missing:
            details.append("missing " + ", ".join(missing))
        if unconstrained:
            details.append("timing report contains unconstrained paths")
        raise ValueError(f"{evidence_level} summary rejected: {'; '.join(details)}")

    corner_match = CORNER_PATTERN.search(timing_text) or CORNER_PATTERN.search(power_text)
    library_match = LIBRARY_PATTERN.search(timing_text) or LIBRARY_PATTERN.search(power_text)
    observed_corner = corner_match.group(1) if corner_match else None
    observed_library = library_match.group(1) if library_match else None
    expected_corner = str(manifest.get("corner", ""))
    expected_library = Path(str(manifest.get("target_library", ""))).stem
    if evidence_level in {"E2", "E3"}:
        if observed_corner != expected_corner:
            raise ValueError(f"corner mismatch: manifest={expected_corner}, report={observed_corner}")
        if observed_library != expected_library:
            raise ValueError(f"library mismatch: manifest={expected_library}, report={observed_library}")

    slack = float(slack_match.group("value")) if slack_match else None
    freq = float(manifest["clock_freq_mhz"])
    period_ns = 1000.0 / freq
    critical_delay = period_ns - slack if slack is not None else None
    fmax = 1000.0 / critical_delay if critical_delay and critical_delay > 0 else None
    arrival_match = ARRIVAL_PATTERN.search(timing_text)
    activity = "saif" if re.search(r"\bSAIF\b", power_text, re.I) else "default_probability_estimate"
    return {
        "schema_version": "2.0",
        "schema": "ip-ppa-summary/1.0",
        "run_id": manifest["run_id"],
        "manifest": {"path": str(manifest_path), "sha256": _sha256(manifest_path)},
        "config_id": manifest["config_id"],
        "clock_freq_mhz": freq,
        "params": manifest.get("params", {}),
        "area_um2": float(area_match.group(1)) if area_match else None,
        "slack_ns": slack,
        "critical_delay_ns": critical_delay,
        "data_arrival_ns": float(arrival_match.group(1)) if arrival_match else None,
        "fmax_mhz": fmax,
        "dyn_power_uW": _scaled(dynamic_match, {"w": 1e6, "mw": 1e3, "uw": 1.0}) if dynamic_match else None,
        "leak_power_nW": _scaled(leakage_match, {"w": 1e9, "mw": 1e6, "uw": 1e3, "nw": 1.0}) if leakage_match else None,
        "activity": activity,
        "timing_constrained": not unconstrained and slack_match is not None,
        "evidence_level": evidence_level,
        "comparison_context": {
            key: manifest.get(key)
            for key in (
                "pdk_sha256",
                "target_library",
                "corner",
                "tool",
                "tool_version",
                "constraint_profile",
                "evaluator_sha256",
                "compile_options",
            )
        } | {"activity": activity},
        "raw_reports": {
            "area": {"path": str(area_path), "sha256": _sha256(area_path)},
            "timing": {"path": str(timing_path), "sha256": _sha256(timing_path)},
            "power": {"path": str(power_path), "sha256": _sha256(power_path)},
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--area-report", required=True, type=Path)
    parser.add_argument("--timing-report", required=True, type=Path)
    parser.add_argument("--power-report", required=True, type=Path)
    parser.add_argument("--evidence-level", choices=("E1", "E2", "E3"), default="E2")
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()
    try:
        manifest = _load_mapping(args.manifest)
        summary = extract(
            manifest,
            args.manifest,
            args.area_report,
            args.timing_report,
            args.power_report,
            args.evidence_level,
        )
        freq = f"{float(manifest['clock_freq_mhz']):g}".replace(".", "p")
        output = args.output or Path("reports/ppa") / (
            f"summary_{manifest['config_id']}_{freq}MHz_{manifest['run_id']}.yaml"
        )
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(yaml.safe_dump(summary, allow_unicode=True, sort_keys=False), encoding="utf-8")
    except (KeyError, OSError, ValueError, yaml.YAMLError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote {output} (area={summary['area_um2']}, slack={summary['slack_ns']}, power={summary['dyn_power_uW']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
