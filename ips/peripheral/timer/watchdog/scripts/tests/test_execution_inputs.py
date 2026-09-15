"""A changed executable dependency invalidates reuse; a report writer does not."""
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import run_uvm


def test_actual_dependencies_and_membership_are_bound(tmp_path,monkeypatch):
    root=tmp_path/'ip';root.mkdir()
    monkeypatch.setattr(run_uvm,'P',root)
    monkeypatch.setattr(run_uvm,'R',tmp_path)
    suite=tmp_path/'suite';(suite/'scripts').mkdir(parents=True)
    (suite/'scripts/parse_uvm_log.py').write_text('fixture parser\n')
    monkeypatch.setattr(run_uvm,'SUITE',suite)
    names=['aixsilicon_ip_watchdog.core','watchdog_contract.md','rtl/top.sv',
           *['scripts/'+name for name in run_uvm.BUILD_SCRIPTS]]
    for name in names:
        file=root/name;file.parent.mkdir(parents=True,exist_ok=True);file.write_text('initial\n')
    (tmp_path/'uv.lock').write_text('fixture\n')
    dependency=tmp_path/'repos/aixsilicon_cbb_repo/components/arbitration_scheduling/round_robin_arbiter/rtl/round_robin_arbiter.sv'
    dependency.parent.mkdir(parents=True);dependency.write_text('fixture\n')
    before=run_uvm.inputs()
    (root/'scripts/collect_coverage.py').write_text('postprocessing change\n')
    assert run_uvm.inputs()==before
    (root/'rtl/new.sv').write_text('new compile input\n')
    assert run_uvm.inputs()!=before
    (root/'rtl/new.sv').unlink()
    (root/'scripts/run_uvm.py').write_text('changed build runner\n')
    assert run_uvm.inputs()!=before
    extra=root/'scripts/parameter_checker.py';extra.write_text('parameter-specific dependency\n')
    pv_before=run_uvm.inputs([extra])
    extra.write_text('changed parameter checker\n')
    assert run_uvm.inputs([extra])!=pv_before


def test_runtime_model_mutation_changes_identity(tmp_path,monkeypatch):
    monkeypatch.setattr(run_uvm,'P',tmp_path)
    binary=tmp_path/'simv';binary.write_bytes(b'launcher')
    directory=tmp_path/'simv.daidir';directory.mkdir()
    model=directory/'model.so';model.write_bytes(b'compiled model')
    before=run_uvm.runtime_inventory(binary)
    model.write_bytes(b'changed compiled model')
    assert run_uvm.runtime_inventory(binary)!=before
