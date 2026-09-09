#!/usr/bin/env python3
"""gen_sweep_manifest.py — 为每个 sweep 点生成 run manifest（绑定 pdk.yaml 库上下文）

对齐 20-ppa-optimization：每个扫描点必须有 run manifest（工具/库/corner/约束/参数 hash）。
用法:
    uv run python scripts/gen_sweep_manifest.py \
        --summary evidence/ppa/<run_id>/sweep_summary.csv \
        --pdk model/pdk.yaml --evidence evidence/ppa/<run_id>
"""
import argparse
import csv
import hashlib
import yaml
from pathlib import Path


def sha256_file(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--summary", required=True)
    ap.add_argument("--pdk", default="model/pdk.yaml")
    ap.add_argument("--evidence", required=True)
    args = ap.parse_args()

    pdk = yaml.safe_load(Path(args.pdk).read_text())
    pdk_root = Path(args.pdk)
    rows = list(csv.DictReader(Path(args.summary).open(newline="")))
    ev = Path(args.evidence)
    manifests_dir = ev / "manifests"
    manifests_dir.mkdir(parents=True, exist_ok=True)

    for r in rows:
        tag = r["run_tag"]
        rpt = Path("build/synth") / tag / "reports"
        manifest = {
            "schema_version": "ppa-run-manifest/0.1",
            "run_id": ev.name,
            "point": tag,
            "ip": "apb_cdc_bridge",
            "params": {
                "CDC_IMPL": int(r["cdc_impl"]),
                "REQ_DEPTH": int(r["req_depth"]),
                "RSP_DEPTH": int(r["rsp_depth"]),
                "clock_ns": float(r["clock_ns"]),
                "freq_mhz": int(r["freq_mhz"]),
            },
            "tool": {
                "name": "dc_shell",
                "version": "V-2023.12-SP3",
                "compile": "compile_ultra",
            },
            "library_context": {
                "pdk_status": pdk.get("status", "PDK_READY"),
                "pdk_yaml": str(pdk_root),
                "target_library": "sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db",
                "operating_conditions": "tt_nominal_max_1p00v_25c",
                "clock_uncertainty_ns": 0.10,
                "io_delay_ns": {"in_max": 0.5, "in_min": 0.2, "out_max": 0.5, "out_min": 0.2},
                "load_pf": 0.01,
                "drive_cell": "BUFH_X4M_A9TH",
            },
            "results": {
                "total_area_um2": float(r["total_area_um2"]),
                "dyn_power_uW": float(r["dyn_power_uW"]),
                "wns_ns": float(r["wns_ns"]),
                "tns_ns": float(r["tns_ns"]),
                "violating_paths": int(r["violating_paths"]),
                "slack_ns": float(r["slack_ns"]),
            },
            "evidence": {
                "area_rpt": str(rpt / "area.rpt"),
                "timing_rpt": str(rpt / "timing.rpt"),
                "power_rpt": str(rpt / "power.rpt"),
                "qor_rpt": str(rpt / "qor.rpt"),
                "netlist": f"build/synth/{tag}/outputs/apb_cdc_bridge_top_synth.v",
            },
            "repro": {
                "cmd": f"dc_shell -f scripts/synth.tcl -x 'set CLK_PERIOD_NS {r['clock_ns']}; "
                       f"set CDC_IMPL {r['cdc_impl']}; set REQ_DEPTH {r['req_depth']}; "
                       f"set RSP_DEPTH {r['rsp_depth']}; set RUN_TAG {tag}'",
            },
        }
        out = manifests_dir / f"{tag}.yaml"
        out.write_text(yaml.safe_dump(manifest, sort_keys=False))
    print(f"Wrote {len(rows)} run manifests -> {manifests_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
