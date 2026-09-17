#!/usr/bin/env python3
"""PQC UVM compile/run entry point (verification/sim/run_uvm.py).

Single deterministic entry for the UVM smoke/regression flow:

    uv run --locked --no-sync python verification/sim/run_uvm.py \
        --tests tc_cmd_smoke --seeds 1

Responsibilities:
  * resolve VIP_ROOT (the aixsilicon_vip_repo checkout) so the protocol VIP
    sources can be referenced read-only (docs/reuse_plan.md §4.2.3);
  * compile verification.list with VCS (UVM 1.2) into <ip>/build/sim/uvm;
  * run each requested testcase, capturing raw logs and a JUnit xml.

All run middleware goes to build/ (git ignored). Success is decided by the exact
UVM summary of the run, never by the exit code alone.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path
from xml.etree import ElementTree as ET

IP_ROOT = Path(__file__).resolve().parents[2]
VERIF = IP_ROOT / "verification"
BUILD = IP_ROOT / "build" / "sim" / "uvm"
LIST = VERIF / "verification.list"


def find_vip_root() -> Path:
    """Locate the VIP repo checkout without hard-coding an absolute path."""
    env = os.environ.get("VIP_ROOT")
    if env:
        p = Path(env)
        if (p / "vip" / "amba" / "apb" / "src" / "apb_pkg.sv").is_file():
            return p
        raise SystemExit(f"VIP_ROOT={env} does not contain the APB VIP sources")

    # Walk up from the IP workspace to the workspace root, then look for the repo.
    for parent in [IP_ROOT, *IP_ROOT.parents]:
        cand = parent / "aixsilicon_vip_repo"
        if (cand / "vip" / "amba" / "apb" / "src" / "apb_pkg.sv").is_file():
            return cand
    raise SystemExit(
        "could not locate aixsilicon_vip_repo; set VIP_ROOT to its path"
    )


def expand_list(vip_root: Path) -> list[str]:
    """Return the filelist with $(VIP_ROOT) substituted, comments removed."""
    if not LIST.is_file():
        raise SystemExit(f"missing {LIST}")
    entries: list[str] = []
    for raw in LIST.read_text().splitlines():
        line = raw.split("//", 1)[0].strip()
        if not line:
            continue
        entries.append(line.replace("$(VIP_ROOT)", str(vip_root)))
    return entries


def compile_design(entries: list[str], vcs: str, log: Path, timeout: int) -> int:
    BUILD.mkdir(parents=True, exist_ok=True)
    cmd = [
        vcs,
        "-full64",
        "-sverilog",
        "-timescale=1ns/1ps",
        "-ntb_opts",
        "uvm-1.2",
        "-top",
        "harness",
        "-o",
        str(BUILD / "simv"),
        "-Mdir=" + str(BUILD / "csrc"),
        "-l",
        str(log),
        *entries,
    ]
    # VCS is invoked from the IP root so the relative list entries resolve.
    with open(log, "w") as fh:
        try:
            proc = subprocess.run(cmd, cwd=IP_ROOT, stdout=fh,
                                  stderr=subprocess.STDOUT, timeout=timeout)
            return proc.returncode
        except subprocess.TimeoutExpired:
            # A hung compile must never block the flow indefinitely.
            print(f"[pqc-uvm] COMPILE TIMEOUT after {timeout}s", file=sys.stderr)
            return 124


def run_one(test: str, seed: str, vcs: str, timeout: int) -> dict:
    run_dir = BUILD / "run" / f"{test}_{seed}"
    run_dir.mkdir(parents=True, exist_ok=True)
    log = run_dir / "run.log"
    simv = BUILD / "simv"
    if not simv.is_file():
        return {"test": test, "seed": seed, "status": "compile_error",
                "log": str(log.relative_to(IP_ROOT)), "detail": "simv missing"}

    cmd = [
        str(simv),
        f"+UVM_TESTNAME={test}",
        f"+UVM_SEED={seed}",
        "+UVM_VERBOSITY=UVM_MEDIUM",
        "-l",
        str(log),
    ]
    timed_out = False
    with open(log, "w") as fh:
        try:
            proc = subprocess.run(cmd, cwd=run_dir, stdout=fh,
                                  stderr=subprocess.STDOUT, timeout=timeout)
            rc = proc.returncode
        except subprocess.TimeoutExpired:
            # Hard watchdog: report a timeout instead of hanging the flow.
            timed_out = True
            rc = 124
            fh.write(f"\nPQC_RUN_TIMEOUT after {timeout}s\n")
    text = log.read_text(errors="replace")

    # Exact UVM verdicts only; never infer pass from the exit code.
    uvm_err = re.findall(r"UVM_ERROR\s*:\s*(\d+)", text)
    uvm_fat = re.findall(r"UVM_FATAL\s*:\s*(\d+)", text)
    errors = sum(int(x) for x in uvm_err)
    fatals = sum(int(x) for x in uvm_fat)
    finished = "UVM Report Summary" in text or "UVM_FATAL" in text

    status = "pass"
    detail = "uvm clean"
    if timed_out:
        status, detail = "fail", f"TIMEOUT after {timeout}s"
    elif rc != 0:
        status, detail = "fail", f"exit={rc}"
    elif fatals:
        status, detail = "fail", f"UVM_FATAL={fatals}"
    elif errors:
        status, detail = "fail", f"UVM_ERROR={errors}"
    elif not finished:
        status, detail = "fail", "no UVM report summary (run did not complete)"

    return {
        "test": test,
        "seed": seed,
        "status": status,
        "detail": detail,
        "uvm_errors": errors,
        "uvm_fatals": fatals,
        "log": str(log.relative_to(IP_ROOT)),
    }


def write_junit(results: list[dict], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    suite = ET.Element("testsuite", {
        "name": "pqc_uvm",
        "tests": str(len(results)),
        "failures": str(sum(1 for r in results if r["status"] != "pass")),
    })
    for r in results:
        tc = ET.SubElement(suite, "testcase", {
            "classname": "pqc_uvm",
            "name": f"{r['test']}_{r['seed']}",
            "time": "0",
        })
        if r["status"] != "pass":
            ET.SubElement(tc, "failure", {
                "message": f"{r['detail']} (see {r['log']})",
            })
    ET.ElementTree(suite).write(path, encoding="utf-8", xml_declaration=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--tests", default="tc_cmd_smoke",
                    help="space-separated testcase names")
    ap.add_argument("--seeds", default="1", help="space-separated seeds")
    ap.add_argument("--build-only", action="store_true")
    ap.add_argument("--compile-timeout", type=int, default=900,
                    help="hard timeout (s) for the VCS compile")
    ap.add_argument("--run-timeout", type=int, default=600,
                    help="hard timeout (s) per simulation; prevents hangs")
    ap.add_argument("--junit", default=None, help="JUnit xml output path")
    ap.add_argument("--summary", default=None, help="JSON summary output path")
    args = ap.parse_args()

    vcs = shutil.which("vcs") or "vcs"
    vip_root = find_vip_root()
    entries = expand_list(vip_root)

    BUILD.mkdir(parents=True, exist_ok=True)
    compile_log = BUILD / "compile.log"
    print(f"[pqc-uvm] VIP_ROOT={vip_root}")
    print(f"[pqc-uvm] compiling {len(entries)} list entries ...")
    t0 = time.time()
    rc = compile_design(entries, vcs, compile_log, args.compile_timeout)
    print(f"[pqc-uvm] compile rc={rc} ({time.time()-t0:.1f}s) log={compile_log}")
    if rc != 0:
        tail = compile_log.read_text(errors="replace").splitlines()[-40:]
        print("\n".join(tail))
        return 1
    if args.build_only:
        return 0

    tests = args.tests.split()
    seeds = args.seeds.split()
    results = [run_one(t, s, vcs, args.run_timeout) for t in tests for s in seeds]

    for r in results:
        print(f"[pqc-uvm] {r['test']} seed={r['seed']}: {r['status']} ({r['detail']})")

    if args.junit:
        write_junit(results, IP_ROOT / args.junit)
        print(f"[pqc-uvm] JUnit -> {args.junit}")
    if args.summary:
        sp = IP_ROOT / args.summary
        sp.parent.mkdir(parents=True, exist_ok=True)
        sp.write_text(json.dumps({
            "schema": "pqc-uvm-summary/1.0",
            "ip_name": "pqc",
            "vip_root": str(vip_root),
            "tests": results,
        }, indent=2))
        print(f"[pqc-uvm] summary -> {args.summary}")

    failed = [r for r in results if r["status"] != "pass"]
    print(f"[pqc-uvm] {len(results)-len(failed)}/{len(results)} passed")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())