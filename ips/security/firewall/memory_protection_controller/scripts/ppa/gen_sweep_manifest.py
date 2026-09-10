#!/usr/bin/env python3
"""Create a content-addressed manifest for one isolated PPA sweep point."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path
from typing import Any

import yaml


def load_pdk(path: Path) -> dict[str, Any]:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"{path}: expected a YAML mapping")
    if data.get("status") != "PDK_READY":
        raise ValueError(f"{path}: PDK_READY is required for an E2/E3 sweep")
    target = Path(str(data.get("target_library", "")))
    if target.suffix != ".db" or not target.is_file():
        raise ValueError(f"{path}: invalid target_library: {target}")
    if not data.get("link_libraries") or not data.get("corner"):
        raise ValueError(f"{path}: link_libraries and corner are required")
    return data


def hash_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def hash_rtl(rtl_dir: Path) -> str:
    digest = hashlib.sha256()
    paths = sorted((*rtl_dir.rglob("*.sv"), *rtl_dir.rglob("*.v")))
    if not paths:
        raise ValueError(f"no Verilog/SystemVerilog sources below {rtl_dir}")
    for path in paths:
        digest.update(path.relative_to(rtl_dir).as_posix().encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
    return digest.hexdigest()


def parse_params(raw: str) -> dict[str, str]:
    params: dict[str, str] = {}
    for part in raw.split(","):
        part = part.strip()
        if not part:
            continue
        if "=" not in part:
            raise ValueError(f"invalid param segment: {part!r} (expected NAME=VALUE)")
        key, value = part.split("=", 1)
        if not key.strip() or key.strip() in params:
            raise ValueError(f"empty or duplicate parameter: {key!r}")
        params[key.strip()] = value.strip()
    return dict(sorted(params.items()))


def build_manifest(
    pdk: dict[str, Any],
    pdk_sha256: str,
    ip_name: str,
    config_id: str,
    freq_mhz: float,
    params: dict[str, str],
    rtl_sha256: str,
    constraints_sha256: str,
    constraints_path: str,
    constraint_profile: str,
    evaluator_script: str,
    evaluator_sha256: str,
    tool_version: str,
    compile_options: list[str],
) -> dict[str, Any]:
    context = {
        "ip_name": ip_name,
        "config_id": config_id,
        "clock_freq_mhz": freq_mhz,
        "params": params,
        "rtl_sha256": rtl_sha256,
        "constraints_sha256": constraints_sha256,
        "constraint_profile": constraint_profile,
        "evaluator_sha256": evaluator_sha256,
        "pdk_sha256": pdk_sha256,
        "target_library": pdk["target_library"],
        "link_libraries": pdk["link_libraries"],
        "corner": pdk["corner"],
        "tool": "dc_shell",
        "tool_version": tool_version,
        "compile_options": compile_options,
    }
    encoded = json.dumps(context, sort_keys=True, separators=(",", ":")).encode("utf-8")
    run_id = hashlib.sha256(encoded).hexdigest()[:16]
    return {
        "schema_version": "2.0",
        "schema": "ip-ppa-run/1.0",
        "run_id": run_id,
        **context,
        "constraints_path": constraints_path,
        "evaluator_script": evaluator_script,
        "raw_reports": {
            "area": "area.rpt",
            "timing": "timing.rpt",
            "power": "power.rpt",
        },
        "status": "planned",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pdk", required=True, type=Path)
    parser.add_argument("--ip-name", required=True)
    parser.add_argument("--config-id", required=True)
    parser.add_argument("--freq-mhz", required=True, type=float)
    parser.add_argument("--params", default="")
    parser.add_argument("--rtl-dir", required=True, type=Path)
    parser.add_argument("--constraints", required=True, type=Path)
    parser.add_argument(
        "--constraint-profile",
        required=True,
        help="stable LRS/LLD constraint-policy ID shared by comparable sweep points",
    )
    parser.add_argument("--evaluator-script", required=True, type=Path)
    parser.add_argument("--tool-version", required=True)
    parser.add_argument("--compile-option", action="append", default=[])
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()

    try:
        pdk = load_pdk(args.pdk)
        manifest = build_manifest(
            pdk=pdk,
            pdk_sha256=hash_file(args.pdk),
            ip_name=args.ip_name,
            config_id=args.config_id,
            freq_mhz=args.freq_mhz,
            params=parse_params(args.params),
            rtl_sha256=hash_rtl(args.rtl_dir),
            constraints_sha256=hash_file(args.constraints),
            constraints_path=str(args.constraints),
            constraint_profile=args.constraint_profile,
            evaluator_script=str(args.evaluator_script),
            evaluator_sha256=hash_file(args.evaluator_script),
            tool_version=args.tool_version,
            compile_options=args.compile_option,
        )
        output = args.output or Path("evidence/ppa") / manifest["run_id"] / "manifest.yaml"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(yaml.safe_dump(manifest, allow_unicode=True, sort_keys=False), encoding="utf-8")
    except (OSError, ValueError, yaml.YAMLError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote {output} (run_id={manifest['run_id']}, pdk_status=PDK_READY)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
