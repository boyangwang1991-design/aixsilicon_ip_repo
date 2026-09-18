"""Negative fixtures for the evidence runner; these are not DUT/UVM results."""
import importlib.util
import json
import sys
from pathlib import Path

import pytest


@pytest.fixture
def runner():
    spec = importlib.util.spec_from_file_location("pqc_runner", Path(__file__).with_name("run_uvm.py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def log_for(test="tc_cmd_smoke", algorithm=None):
    text = f"UVM_INFO @ 0: reporter [RNTST] Running test {test}...\n"
    if algorithm:
        text += "".join(f"UVM_INFO test.sv(1) @ 10: test [{algorithm}_CASE_PASS] case={i} pset={i//2+1}\n"
                        for i in range({"DECAPS": 45, "ENCAPS": 6, "KEYGEN": 9, "DSA_KEYGEN": 9, "DSA_VERIFY": 63, "DSA_SIGN": 27}[algorithm]))
        text += f"UVM_INFO test.sv(2) @ 20: test [{algorithm}_MAIN_PASS] checked\n"
    return text + "--- UVM Report Summary ---\nUVM_ERROR : 0\nUVM_FATAL : 0\n"


@pytest.mark.parametrize("algorithm", ["ENCAPS", "DECAPS", "KEYGEN", "DSA_KEYGEN", "DSA_VERIFY", "DSA_SIGN"])
def test_kat_completion_required(runner, algorithm):
    name = f"tc_{algorithm.lower()}_main" if algorithm.startswith("DSA_") else f"tc_kem_{algorithm.lower()}_main"
    good = log_for(name, algorithm)
    assert runner.verdict(name, good, 0)[0] == "pass"
    assert runner.verdict(name, log_for(name), 0)[0] == "fail"
    assert runner.verdict(name, good.replace("case=5", "case=4"), 0)[0] == "fail"
    assert runner.verdict(name, good.replace(f"[{algorithm}_MAIN_PASS]", "[INCOMPLETE]"), 0)[0] == "fail"


@pytest.mark.parametrize("change", [
    lambda s: s.replace("Running test tc_cmd_smoke", "Running test tc_other"),
    lambda s: s.replace("[RNTST]", "[OTHER]"),
    lambda s: s + s,
    lambda s: s.replace("UVM_ERROR : 0", "UVM_ERROR : 1"),
    lambda s: s.replace("UVM_FATAL : 0", ""),
    lambda s: "UVM_ERROR test.sv(1) @ 0: test [BUG] failed\n" + s,
    lambda s: "Error-[TEST] tool failure\n" + s,
    lambda s: s + "\nPQC_RUN_TIMEOUT after 1s\n",
    lambda s: s + "\nWarning-[STASKW_RMCOF] Cannot open file\n",
])
def test_false_pass_rejected(runner, change):
    assert runner.verdict("tc_cmd_smoke", change(log_for()), 0)[0] == "fail"


def test_exit_code_and_valid_smoke(runner):
    assert runner.verdict("tc_cmd_smoke", log_for(), 0)[0] == "pass"
    assert runner.verdict("tc_cmd_smoke", log_for(), 1)[0] == "fail"


def test_external_include_and_membership(runner, tmp_path, monkeypatch):
    root = tmp_path / "ip"
    (root / "rtl").mkdir(parents=True)
    manifest = root / "verification.list"
    manifest.write_text("")
    external = tmp_path / "vip"
    external.mkdir()
    header = external / "config.svh"
    header.write_text("old")
    monkeypatch.setattr(runner, "IP_ROOT", root)
    monkeypatch.setattr(runner, "LIST", manifest)
    entries = [f"+incdir+{external}"]
    before = runner.snapshot_inputs(entries)
    header.write_text("new")
    assert before != runner.snapshot_inputs(entries)
    header.write_text("old")
    extra = root / "rtl" / "new.sv"
    extra.write_text("module new_module; endmodule")
    assert before != runner.snapshot_inputs(entries)
    extra.unlink()
    assert before == runner.snapshot_inputs(entries)
    contract = root / "pqc_contract.md"
    contract.write_text("new contract")
    assert before != runner.snapshot_inputs(entries)
    contract.unlink()
    header.unlink()
    assert before != runner.snapshot_inputs(entries)


def test_subprocess_timeout_and_missing_tool(runner, tmp_path):
    log = tmp_path / "tool.log"
    rc, elapsed = runner.execute([sys.executable, "-c", "import time; time.sleep(30)"],
                                 tmp_path, log, 1)
    assert rc == 124 and elapsed < 10
    assert "PQC_RUN_TIMEOUT" in log.read_text()
    assert runner.execute([str(tmp_path / "missing")], tmp_path, log, 1)[0] == 127


@pytest.mark.parametrize("args", [
    ["--tests", ""], ["--seeds", ""], ["--seeds", "random"],
    ["--tests", "tc_a tc_a"], ["--seeds", "1 1"],
    ["--tests", "../../escape"], ["--run-timeout", "0"],
    ["--junit", "reports/incorrect.xml"],
    ["--junit", "build/same", "--summary", "build/same"],
])
def test_invalid_requests_fail_before_build(runner, monkeypatch, args):
    monkeypatch.setattr(sys, "argv", ["runner", *args])
    with pytest.raises(SystemExit) as exc:
        runner.main()
    assert exc.value.code == 2


def test_compile_failure_emits_failing_evidence(runner, tmp_path, monkeypatch):
    root = tmp_path / "ip"
    root.mkdir()
    manifest = root / "verification.list"
    manifest.write_text("")
    monkeypatch.setattr(runner, "IP_ROOT", root)
    monkeypatch.setattr(runner, "LIST", manifest)
    monkeypatch.setattr(runner, "BUILD", root / "build" / "sim" / "uvm")
    monkeypatch.setattr(runner, "find_vip_root", lambda: tmp_path)
    monkeypatch.setattr(runner.shutil, "which", lambda _: str(tmp_path / "no_vcs"))
    monkeypatch.setattr(sys, "argv", ["runner"])
    assert runner.main() == 1
    summary = next((root / "build").rglob("summary.json"))
    data = json.loads(summary.read_text())
    assert data["status"] == "fail"
    assert data["tests"][0]["status"] == "compile_error"
    assert "<failure" in summary.with_name("junit.xml").read_text()


@pytest.mark.parametrize("mutation", [None, "add", "delete", "vip", "binary"])
def test_run_identity_is_rechecked(runner, tmp_path, monkeypatch, mutation):
    root = tmp_path / "ip"
    (root / "rtl").mkdir(parents=True)
    source = root / "rtl" / "top.sv"
    source.write_text("module top; endmodule")
    vip = tmp_path / "vip"
    vip.mkdir()
    header = vip / "config.svh"
    header.write_text("original")
    manifest = root / "verification.list"
    manifest.write_text(f"+incdir+{vip}\nrtl/top.sv\n")
    monkeypatch.setattr(runner, "IP_ROOT", root)
    monkeypatch.setattr(runner, "LIST", manifest)
    monkeypatch.setattr(runner, "BUILD", root / "build" / "sim" / "uvm")
    monkeypatch.setattr(runner, "find_vip_root", lambda: vip)

    def execute(cmd, cwd, log, timeout):
        if "-ID" in cmd:
            log.write_text("fixture compiler; not EDA evidence\n")
        elif "-o" in cmd:
            Path(cmd[cmd.index("-o") + 1]).write_text("fixture binary")
            log.write_text("fixture compile\n")
        else:
            log.write_text(log_for())
            if mutation == "add":
                (source.parent / "extra.sv").write_text("new input")
            elif mutation == "delete":
                source.unlink()
            elif mutation == "vip":
                header.write_text("changed")
            elif mutation == "binary":
                (runner.BUILD / "simv").write_text("changed binary")
        return 0, 0.01

    monkeypatch.setattr(runner, "execute", execute)
    monkeypatch.setattr(sys, "argv", ["runner", "--seeds", "1 2"])
    assert runner.main() == (1 if mutation else 0)
    summary = json.loads((runner.BUILD / "summary.json").read_text())
    assert len(summary["tests"]) == 2
    assert summary["status"] == ("fail" if mutation else "pass")
    if mutation:
        assert all(r["status"] == "fail" for r in summary["tests"])
    else:
        assert all(r["log_sha256"] for r in summary["tests"])


def test_teaching_notes_are_auxiliary_but_design_docs_are_inputs(runner, tmp_path, monkeypatch):
    root = tmp_path / "ip"
    learning = root / "docs/learning"
    learning.mkdir(parents=True)
    design = root / "docs/lld"
    design.mkdir()
    manifest = root / "verification.list"
    manifest.write_text("")
    monkeypatch.setattr(runner, "IP_ROOT", root)
    monkeypatch.setattr(runner, "LIST", manifest)
    before = runner.snapshot_inputs([])
    (learning / "lesson.md").write_text("teaching notes")
    assert runner.snapshot_inputs([]) == before
    (design / "contract.md").write_text("changed design contract")
    assert runner.snapshot_inputs([]) != before


def test_fault_stimulus_completion_required(runner):
    name = "tc_illegal_state_shutdown"
    empty = log_for(name)
    marker = "UVM_INFO fault.sv(1) @ 10: test [FAULT_IDLE_PASS] checked\n"
    assert runner.verdict(name, empty, 0)[0] == "fail"
    assert runner.verdict(name, marker + empty, 0)[0] == "pass"
    assert runner.verdict(name, marker + marker + empty, 0)[0] == "fail"
