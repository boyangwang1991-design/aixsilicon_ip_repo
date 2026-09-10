#!/usr/bin/env python3
"""AXI MPU PPA sweep runner（IP 内版本，自套件参考脚本适配）。

对每个 sweep 点（PIPELINE × REGION_NUM × 时钟频率）：
  1. 生成内容寻址 manifest（gen_sweep_manifest 参考实现的本地适配，含 PIPELINE 参数）；
  2. 渲染 DC TCL（库上下文取 model/pdk.yaml，时钟周期取该点 freq）；
  3. 运行 dc_shell，原始 area/timing/power.rpt 落 evidence/ppa/<run-id>/；
  4. 调用 extract_ppa_summary.py 生成 reports/ppa/summary_*.yaml。

用法：uv run python scripts/ppa/run_sweep.py [--points default|fast]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

import yaml

IP = Path(__file__).resolve().parents[2]
WS = IP
PDK = WS / "model/pdk.yaml"
DC_SHELL = "dc_shell"

# Sweep 矩阵：PIPELINE(0/1) × REGION_NUM(4/16) × 频率(200/400/500 MHz 中取 3 点)
DEFAULT_POINTS = [
    # (config_id,        params,                          freq_mhz)
    ("CFG_R16_P0_200M", "REGION_NUM=16,PIPELINE=0", 200.0),
    ("CFG_R16_P0_400M", "REGION_NUM=16,PIPELINE=0", 400.0),
    ("CFG_R16_P0_500M", "REGION_NUM=16,PIPELINE=0", 500.0),
    ("CFG_R16_P1_200M", "REGION_NUM=16,PIPELINE=1", 200.0),
    ("CFG_R16_P1_400M", "REGION_NUM=16,PIPELINE=1", 400.0),
    ("CFG_R16_P1_500M", "REGION_NUM=16,PIPELINE=1", 500.0),
    ("CFG_R4_P0_400M", "REGION_NUM=4,PIPELINE=0", 400.0),
]

TCL_TEMPLATE = """# Auto-generated for PPA sweep point {config_id}; library context from model/pdk.yaml
set_app_var search_path [list . {search_path}]
set_app_var target_library {target_base}
set_app_var link_library [list * {target_base}]

set rtl_dir {ip}/rtl
set rtl_files [list \\
    $rtl_dir/generated/axi_mpu_csr_pkg.sv \\
    $rtl_dir/generated/axi_mpu_csr.sv \\
    $rtl_dir/axi_mpu_permission.sv \\
    $rtl_dir/axi_mpu_read.sv \\
    $rtl_dir/axi_mpu_write.sv \\
    $rtl_dir/axi_mpu.sv ]

define_design_lib WORK -path ./{run_id}_work
analyze -format sverilog $rtl_files
elaborate axi_mpu -parameters "REGION_NUM={region_num},PIPELINE={pipeline}"
current_design axi_mpu
link

set_operating_conditions {corner}

create_clock -name clk -period {period_ns} [get_ports clk]
set_input_delay 0.4 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.4 -clock clk [all_outputs]
set_load 0.010 [all_outputs]

compile -map_effort medium

report_area  > {run_dir}/area.rpt
report_timing > {run_dir}/timing.rpt
report_power  > {run_dir}/power.rpt
report_qor    > {run_dir}/qor.rpt
exit
"""


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rtl_digest(rtl_dir: Path) -> str:
    digest = hashlib.sha256()
    for path in sorted((*rtl_dir.rglob("*.sv"), *rtl_dir.rglob("*.svh"))):
        digest.update(path.relative_to(rtl_dir).as_posix().encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
    return digest.hexdigest()


def run_one(config_id: str, params: str, freq_mhz: float) -> Path:
    pdk = yaml.safe_load(PDK.read_text())
    kv = dict(item.split("=") for item in params.split(","))
    region_num = int(kv["REGION_NUM"])
    pipeline = int(kv["PIPELINE"])
    period_ns = round(1000.0 / freq_mhz, 4)

    run_id = f"{config_id}_{int(freq_mhz)}MHz_{hashlib.sha1(params.encode()).hexdigest()[:8]}"
    run_dir = WS / "evidence/ppa" / run_id
    run_dir.mkdir(parents=True, exist_ok=True)

    # manifest（对齐 ip-ppa-run/1.0 契约；evaluator 绑定 IP 内脚本）
    evaluator = WS / "scripts/ppa/extract_ppa_summary.py"
    manifest = {
        "schema": "ip-ppa-run/1.0",
        "run_id": run_id,
        "ip_name": "axi_mpu",
        "config_id": config_id,
        "corner": pdk["corner"],
        "node": pdk["node"],
        "library": pdk["library"],
        "target_library": pdk["target_library"],
        "params": kv,
        "clock_freq_mhz": freq_mhz,
        "clock_period_ns": period_ns,
        "pdk": {
            "status": pdk["status"],
            "node": pdk["node"],
            "library": pdk["library"],
            "corner": pdk["corner"],
            "target_library": pdk["target_library"],
            "link_libraries": pdk["link_libraries"],
        },
        "tool": "dc_shell",
        "tool_version": "V-2023.12-SP3",
        "rtl_dir_hash": rtl_digest(WS / "rtl"),
        "sdc": "constraints/timing.sdc",
        "sdc_sha256": sha256(WS / "constraints/timing.sdc"),
        "constraint_profile": "lrs-axi_mpu-ppa-sweep-v1",
        "compile_options": "compile -map_effort medium",
        "activity_method": "default-probability-propagation (no SAIF)",
        "evaluator_script": str(evaluator),
        "evaluator_sha256": sha256(evaluator),
        "raw_reports": {"area": "area.rpt", "timing": "timing.rpt", "power": "power.rpt"},
    }
    (run_dir / "manifest.yaml").write_text(
        yaml.safe_dump(manifest, allow_unicode=True, sort_keys=False), encoding="utf-8"
    )

    # TCL
    target = Path(pdk["target_library"])
    # include 路径（axi_mpu_defs.svh）必须进 search_path
    search_path = " ".join([
        str(Path(pdk["target_library"]).parent),
        str(WS / "rtl"),
        str(WS / "rtl/include"),
        str(WS / "rtl/generated"),
    ])
    tcl = TCL_TEMPLATE.format(
        config_id=config_id,
        search_path=search_path,
        target_base=target.name,
        ip=str(IP),
        run_id=run_id,
        run_dir=str(run_dir),
        region_num=region_num,
        pipeline=pipeline,
        period_ns=period_ns,
        corner=pdk['corner'],
    )
    tcl_path = run_dir / "synth.tcl"
    tcl_path.write_text(tcl, encoding="utf-8")

    log = run_dir / "dc_shell.log"
    r = subprocess.run([DC_SHELL, "-f", str(tcl_path)], cwd=str(run_dir),
                       capture_output=True, text=True, timeout=1800)
    log.write_text((r.stdout or "") + (r.stderr or ""), encoding="utf-8")
    if r.returncode != 0:
        print(f"FAIL {config_id}: dc_shell rc={r.returncode}", file=sys.stderr)
        raise SystemExit(2)
    for kind in ("area.rpt", "timing.rpt", "power.rpt"):
        if not (run_dir / kind).is_file():
            print(f"FAIL {config_id}: missing {kind}", file=sys.stderr)
            raise SystemExit(2)

    # summary 提取
    summary_out = WS / "reports/ppa" / f"summary_{config_id}_{int(freq_mhz)}MHz.yaml"
    r2 = subprocess.run([
        sys.executable, str(evaluator),
        "--manifest", str(run_dir / "manifest.yaml"),
        "--area-report", str(run_dir / "area.rpt"),
        "--timing-report", str(run_dir / "timing.rpt"),
        "--power-report", str(run_dir / "power.rpt"),
        "--output", str(summary_out),
    ], capture_output=True, text=True)
    if r2.returncode != 0:
        print(f"FAIL extract {config_id}: {r2.stderr[-500:]}", file=sys.stderr)
        raise SystemExit(3)
    print(f"OK {config_id} @ {freq_mhz}MHz -> {run_id}")
    return run_dir


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--points", default="default", choices=("default",))
    args = parser.parse_args()
    (WS / "reports/ppa").mkdir(parents=True, exist_ok=True)
    for config_id, params, freq in DEFAULT_POINTS:
        run_one(config_id, params, freq)
    return 0


if __name__ == "__main__":
    sys.exit(main())
