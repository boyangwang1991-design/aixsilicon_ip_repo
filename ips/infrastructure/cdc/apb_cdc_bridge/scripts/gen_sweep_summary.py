#!/usr/bin/env python3
"""gen_sweep_summary.py — 从 build/synth/<run_tag>/reports 提取 PPA 指标生成 sweep_summary.csv

对齐 20-ppa-optimization：每个 sweep 点提取 (area, slack/fmax, dyn_power, leak_power)。
注意 DC power.rpt 的 Total Dynamic Power 单位可能是 uW 或 mW，统一换算为 uW。
用法:
    uv run python scripts/gen_sweep_summary.py --evidence evidence/ppa/<run_id>
"""
import argparse
import csv
import re
from pathlib import Path

REPORT_DIRS = {
    "hs_50ns":      dict(clock_ns=5.0,   cdc_impl=0, req=1, rsp=1),
    "hs_25ns":      dict(clock_ns=2.5,   cdc_impl=0, req=1, rsp=1),
    "hs_1667ns":    dict(clock_ns=1.667, cdc_impl=0, req=1, rsp=1),
    "fifo_d1_50ns": dict(clock_ns=5.0,   cdc_impl=1, req=1, rsp=1),
    "fifo_d1_25ns": dict(clock_ns=2.5,   cdc_impl=1, req=1, rsp=1),
    "fifo_d1_1667ns": dict(clock_ns=1.667, cdc_impl=1, req=1, rsp=1),
    "fifo_d2_50ns": dict(clock_ns=5.0,   cdc_impl=1, req=2, rsp=2),
    "fifo_d2_25ns": dict(clock_ns=2.5,   cdc_impl=1, req=2, rsp=2),
    "fifo_d2_1667ns": dict(clock_ns=1.667, cdc_impl=1, req=2, rsp=2),
}


def get_value(path: Path, pattern: str, field: int, default: str = "") -> str:
    if not path.is_file():
        return default
    m = re.search(pattern, path.read_text(), re.M)
    if not m:
        return default
    return m.group(field) if field <= m.re.groups else m.group(0).split()[field - 1]


def dyn_power_uW(power_rpt: Path) -> float:
    """Total Dynamic Power 单位统一换算为 uW（DC 可能输出 uW 或 mW）。"""
    if not power_rpt.is_file():
        return 0.0
    txt = power_rpt.read_text()
    m = re.search(r"Total Dynamic Power\s+=\s+([\d.]+)\s+(\w+)", txt)
    if not m:
        return 0.0
    val, unit = float(m.group(1)), m.group(2).lower()
    if unit == "mw":
        return val * 1000.0
    if unit == "w":
        return val * 1e6
    return val  # uW


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--evidence", required=True, help="evidence/ppa/<run_id> 目录")
    ap.add_argument("--synth-root", default="build/synth", help="综合输出根")
    args = ap.parse_args()

    ev = Path(args.evidence)
    ev.mkdir(parents=True, exist_ok=True)
    out = ev / "sweep_summary.csv"

    rows = []
    for tag, meta in REPORT_DIRS.items():
        rpt = Path(args.synth_root) / tag / "reports"
        if not (rpt / "area.rpt").is_file():
            print(f"[skip] {tag}: no reports")
            continue
        area = get_value(rpt / "area.rpt", r"Total cell area:\s+([\d.]+)", 1)
        dynp = dyn_power_uW(rpt / "power.rpt")
        wns = get_value(rpt / "qor.rpt", r"Design\s+WNS:\s+([\d.-]+)\s+TNS:\s+([\d.-]+)\s+Number of Violating Paths:\s+(\d+)", 1)
        tns = get_value(rpt / "qor.rpt", r"Design\s+WNS:\s+([\d.-]+)\s+TNS:\s+([\d.-]+)\s+Number of Violating Paths:\s+(\d+)", 2)
        viol = get_value(rpt / "qor.rpt", r"Design\s+WNS:\s+([\d.-]+)\s+TNS:\s+([\d.-]+)\s+Number of Violating Paths:\s+(\d+)", 3)
        slack = get_value(rpt / "qor.rpt", r"Critical Path Slack:\s+([\d.-]+)", 1)
        freq = round(1000 / meta["clock_ns"])
        rows.append({
            "run_tag": tag, "clock_ns": meta["clock_ns"], "freq_mhz": freq,
            "cdc_impl": meta["cdc_impl"], "req_depth": meta["req"], "rsp_depth": meta["rsp"],
            "total_area_um2": area, "dyn_power_uW": f"{dynp:.4f}", "wns_ns": wns,
            "tns_ns": tns, "violating_paths": viol, "slack_ns": slack,
        })

    with out.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"Wrote {out} ({len(rows)} points)")
    for r in rows:
        print(f"  {r['run_tag']:14s} f={r['freq_mhz']:4d}MHz  "
              f"area={float(r['total_area_um2']):10.3f}  "
              f"dyn={float(r['dyn_power_uW']):8.2f}uW  "
              f"WNS={r['wns_ns']:>5}  slack={r['slack_ns']:>5}ns")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
