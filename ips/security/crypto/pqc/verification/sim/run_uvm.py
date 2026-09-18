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
import hashlib
import json
import os
import re
import signal
import shutil
import subprocess
import time
import tempfile
from pathlib import Path
from xml.etree import ElementTree as ET

IP_ROOT = Path(__file__).resolve().parents[2]
VERIF = IP_ROOT / "verification"
BUILD = IP_ROOT / "build" / "sim" / "uvm"
LIST = VERIF / "verification.list"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot_inputs(entries: list[str]) -> dict[str, str]:
    """Bind source membership as well as contents, including external includes."""
    paths = {LIST, Path(__file__).resolve()}
    for folder in ("rtl", "verification", "docs", "model", "regs", "scripts", "constraints"):
        paths.update(p for p in (IP_ROOT / folder).rglob("*")
                     if p.is_file() and "__pycache__" not in p.parts
                     and p.suffix != ".pyc"
                     and not (p.is_relative_to(IP_ROOT / "docs/learning") and p.suffix == ".md"))
    paths.update(IP_ROOT.glob("*.core"))
    paths.update(IP_ROOT.glob("*.md"))
    paths.update(IP_ROOT.glob("*.yaml"))
    for entry in entries:
        if entry.startswith("+incdir+"):
            for directory in entry[len("+incdir+"):].split("+"):
                root = (IP_ROOT / directory).resolve()
                if not root.is_dir():
                    paths.add(root)
                    continue
                paths.update(p for p in root.rglob("*") if p.is_file()
                             and p.suffix in (".sv", ".svh", ".v", ".vh"))
        elif not entry.startswith(("+", "-")):
            paths.add((IP_ROOT / entry).resolve())
        else:
            raise ValueError(f"unsupported source-list directive: {entry}")
    return {str(p.resolve()): sha256(p) if p.is_file() else "MISSING" for p in sorted(paths)}


def execute(cmd: list[str], cwd: Path, log: Path, timeout: int) -> tuple[int, float]:
    """Terminate the entire tool process group, including compiler children."""
    started = time.monotonic()
    with log.open("w") as output:
        try:
            proc = subprocess.Popen(cmd, cwd=cwd, stdout=output,
                                    stderr=subprocess.STDOUT, start_new_session=True)
        except OSError as exc:
            output.write(f"PQC_EXEC_ERROR: {exc}\n")
            return 127, time.monotonic() - started
        try:
            rc = proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
            output.write(f"\nPQC_RUN_TIMEOUT after {timeout}s\n")
            rc = 124
    return rc, time.monotonic() - started


def verdict(test: str, text: str, rc: int) -> tuple[str, str]:
    """A clean summary alone cannot establish testcase or algorithm completion."""
    if rc:
        return "fail", f"exit={rc}"
    selected = re.findall(r"\[RNTST\]\s+Running test\s+(\w+)\s*\.\.\.", text)
    if selected != [test]:
        return "fail", f"test identity mismatch: {selected!r}"
    if text.count("UVM Report Summary") != 1:
        return "fail", "missing or duplicate UVM report summary"
    for severity in ("ERROR", "FATAL"):
        counts = re.findall(rf"^\s*UVM_{severity}\s*:\s*(\d+)\s*$", text, re.M)
        if counts != ["0"] or re.search(rf"^UVM_{severity}[ \t]+(?!:)\S", text, re.M):
            return "fail", f"UVM_{severity} present or invalid summary"
    if re.search(r"^(?:Error-|Fatal:|Warning-\[STASKW_|PQC_RUN_TIMEOUT|PQC_EXEC_ERROR)", text, re.M):
        return "fail", "tool error or timeout"
    algorithm = {"tc_kem_encaps_main": "ENCAPS", "tc_kem_decaps_main": "DECAPS", "tc_kem_keygen_main": "KEYGEN", "tc_dsa_verify_main": "DSA_VERIFY", "tc_dsa_sign_main": "DSA_SIGN", "tc_dsa_keygen_main": "DSA_KEYGEN"}.get(test)
    if algorithm:
        cases = re.findall(rf"^UVM_INFO .*\[{algorithm}_CASE_PASS\]\s+case=(\d+)\b", text, re.M)
        main = re.findall(rf"^UVM_INFO .*\[{algorithm}_MAIN_PASS\]", text, re.M)
        expected_count = {"DECAPS": 45, "ENCAPS": 6, "KEYGEN": 9, "DSA_VERIFY": 63, "DSA_SIGN": 27, "DSA_KEYGEN": 9}[algorithm]
        if cases != [str(i) for i in range(expected_count)] or len(main) != 1:
            return "fail", "missing, duplicate or out-of-order KAT completion markers"
    return "pass", "test identity, completion and UVM summary checked"


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
        entry = line.replace("$(VIP_ROOT)", str(vip_root))
        if entry.startswith("+incdir+"):
            entry = "+incdir+" + "+".join(str((IP_ROOT / p).resolve())
                                            for p in entry[len("+incdir+"):].split("+"))
        elif not entry.startswith(("+", "-")):
            entry = str((IP_ROOT / entry).resolve())
        entries.append(entry)
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
        *entries,
    ]
    (BUILD / "compile_command.json").write_text(json.dumps(cmd, indent=2))
    # Absolute sources permit all VCS middleware to stay inside build/.
    rc, _ = execute(cmd, BUILD, log, timeout)
    if rc == 0 and (not (BUILD / "simv").is_file() or
                    re.search(r"^(?:Error-|Fatal:)", log.read_text(errors="replace"), re.M)):
        return 1
    return rc


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
        f"+ntb_random_seed={seed}",
        "+ENCAPS_VECTORS=" + str(VERIF / "vectors/encaps"),
        "+DECAPS_VECTORS=" + str(VERIF / "vectors/decaps"),
        "+DSA_KEYGEN_VECTORS=" + str(VERIF / "vectors/dsa"),
        "+DSA_SIGN_VECTORS=" + str(VERIF / "vectors/dsa"),
        "+DSA_VECTORS=" + str(VERIF / "vectors/dsa"),
        "+KEYGEN_VECTORS=" + str(VERIF / "vectors/keygen"),
        "+UVM_VERBOSITY=UVM_LOW",
    ]
    rc, elapsed = execute(cmd, run_dir, log, timeout)
    text = log.read_text(errors="replace")

    # Exact UVM verdicts only; never infer pass from the exit code.
    uvm_err = re.findall(r"UVM_ERROR\s*:\s*(\d+)", text)
    uvm_fat = re.findall(r"UVM_FATAL\s*:\s*(\d+)", text)
    errors = sum(int(x) for x in uvm_err)
    fatals = sum(int(x) for x in uvm_fat)
    status, detail = verdict(test, text, rc)

    return {
        "test": test,
        "seed": seed,
        "status": status,
        "detail": detail,
        "uvm_errors": errors,
        "uvm_fatals": fatals,
        "log": str(log.relative_to(IP_ROOT)),
        "log_sha256": sha256(log),
        "command": cmd,
        "exit_code": rc,
        "elapsed_seconds": elapsed,
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
            "time": str(r.get("elapsed_seconds", 0)),
        })
        if r["status"] != "pass":
            ET.SubElement(tc, "failure", {
                "message": f"{r['detail']} (see {r['log']})",
            })
    ET.ElementTree(suite).write(path, encoding="utf-8", xml_declaration=True)


def main() -> int:
    global BUILD
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

    tests, seeds = args.tests.split(), args.seeds.split()
    if not tests or not seeds or len(set(tests)) != len(tests) or len(set(seeds)) != len(seeds):
        ap.error("tests and seeds must be nonempty lists without duplicates")
    if any(not re.fullmatch(r"tc_\w+", t) for t in tests):
        ap.error("test names must be tc_<identifier>")
    if any(not s.isdecimal() or not 1 <= int(s) <= 2147483647 for s in seeds):
        ap.error("use explicit integer seeds in 1..2147483647")
    if args.compile_timeout <= 0 or args.run_timeout <= 0:
        ap.error("timeouts must be positive")
    outputs = {}
    for name in ("junit", "summary"):
        value = getattr(args, name)
        if value:
            path = (IP_ROOT / value).resolve()
            if not path.is_relative_to((IP_ROOT / "build").resolve()):
                ap.error(f"{name} must be inside the IP build directory")
            if path.exists():
                ap.error(f"refusing to replace existing evidence: {path}")
            outputs[name] = path
    if len(set(outputs.values())) != len(outputs):
        ap.error("JUnit and summary must use different paths")

    vcs = shutil.which("vcs") or "vcs"
    vip_root = find_vip_root()
    entries = expand_list(vip_root)

    BUILD.mkdir(parents=True, exist_ok=True)
    BUILD = Path(tempfile.mkdtemp(prefix="run-", dir=BUILD))
    compile_log = BUILD / "compile.log"
    print(f"[pqc-uvm] VIP_ROOT={vip_root}")
    print(f"[pqc-uvm] compiling {len(entries)} list entries ...")
    # Teaching notes are auxiliary, not normative design/build inputs. Record
    # their drift separately so collaborative documentation cannot relabel a
    # stable compiled design. Every other docs path remains a strict input.
    def learning_docs():
        return {str(p.relative_to(IP_ROOT)): sha256(p)
                for p in sorted((IP_ROOT / "docs/learning").rglob("*.md"))}
    auxiliary_before = learning_docs()
    source_hashes = snapshot_inputs(entries)
    (BUILD / "inputs.before.json").write_text(json.dumps(source_hashes, indent=2))
    version_rc, _ = execute([vcs, "-ID"], BUILD, BUILD / "tool_version.log", 30)
    t0 = time.time()
    rc = compile_design(entries, vcs, compile_log, args.compile_timeout)
    print(f"[pqc-uvm] compile rc={rc} ({time.time()-t0:.1f}s) log={compile_log}")
    after = snapshot_inputs(entries)
    source_stable = after == source_hashes
    binary_hash = sha256(BUILD / "simv") if (BUILD / "simv").is_file() else None
    if rc != 0 or version_rc != 0 or not source_stable:
        tail = compile_log.read_text(errors="replace").splitlines()[-40:]
        print("\n".join(tail))
        results = [{"test": t, "seed": s, "status": "compile_error",
                    "detail": f"compile={rc}; tool_version={version_rc}; inputs_stable={source_stable}",
                    "log": str(compile_log.relative_to(IP_ROOT))}
                   for t in tests for s in seeds]
    else:
        results = []
        if not args.build_only:
            for t in tests:
                for s in seeds:
                    if snapshot_inputs(entries) != source_hashes or sha256(BUILD / "simv") != binary_hash:
                        source_stable = False
                        break
                    results.append(run_one(t, s, vcs, args.run_timeout))
                    if snapshot_inputs(entries) != source_hashes or sha256(BUILD / "simv") != binary_hash:
                        source_stable = False
                        break
                if not source_stable:
                    break

    after = snapshot_inputs(entries)
    source_stable = source_stable and after == source_hashes
    (BUILD / "inputs.after.json").write_text(json.dumps(after, indent=2))
    if not source_stable:
        # Never publish earlier PASS entries from a build whose inputs drifted.
        for result in results:
            result.update(status="fail", detail="build identity changed; results are stale")
        executed = {(r["test"], r["seed"]) for r in results}
        for t in tests:
            for s in seeds:
                if (t, s) not in executed:
                    results.append({"test": t, "seed": s, "status": "fail",
                                    "detail": "not run: build identity changed",
                                    "log": str(compile_log.relative_to(IP_ROOT))})

    for r in results:
        print(f"[pqc-uvm] {r['test']} seed={r['seed']}: {r['status']} ({r['detail']})")

    failed = [r for r in results if r["status"] != "pass"]
    status = "fail" if rc or version_rc or failed or not source_stable else "pass"
    junit = outputs.get("junit", BUILD / "junit.xml")
    if not args.build_only:
        write_junit(results, junit)
        print(f"[pqc-uvm] JUnit -> {junit}")
    sp = outputs.get("summary", BUILD / "summary.json")
    sp.parent.mkdir(parents=True, exist_ok=True)
    sp.write_text(json.dumps({
            "schema": "pqc-uvm-summary/2.0",
            "ip_name": "pqc",
            "status": status,
            "build_only": args.build_only,
            "run_directory": str(BUILD.relative_to(IP_ROOT)),
            "vip_root": str(vip_root),
            "tests": results,
            "source_hashes": source_hashes,
            "inputs_stable": source_stable,
            "auxiliary_learning_docs_before": auxiliary_before,
            "auxiliary_learning_docs_after": learning_docs(),
            "binary_sha256": binary_hash,
            "compile_exit_code": rc,
            "compile_command": json.loads((BUILD / "compile_command.json").read_text()),
            "compile_log": str(compile_log.relative_to(IP_ROOT)),
            "compile_log_sha256": sha256(compile_log),
            "tool_version_exit_code": version_rc,
            "tool_version": (BUILD / "tool_version.log").read_text(errors="replace"),
        }, indent=2))
    print(f"[pqc-uvm] summary -> {sp}")

    print(f"[pqc-uvm] {len(results)-len(failed)}/{len(results)} passed")
    return 1 if status == "fail" else 0


if __name__ == "__main__":
    raise SystemExit(main())
