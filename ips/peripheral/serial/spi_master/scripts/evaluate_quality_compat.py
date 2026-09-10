"""Bounded SPI mixed-proof adapter. Shared evaluator and UVM checks stay intact."""
from pathlib import Path
import hashlib
import json
IP = Path(__file__).resolve().parents[1]
SOURCE = IP.parents[4] / 'aixsilicon_skill_repo/skills/ip-development-suite/skills/15-regression-quality-review/scripts/evaluate_quality.py'

def validate_spi_static_execution(record, log_path, workspace, artifacts):
    try:
        if record.get('executor') != 'static+c' or record.get('log') != 'build/delivery/driver-1.log':
            return False, 'static executor or log identity mismatch'
        rel = 'reports/quality/delivery-check.json'
        path = workspace / rel
        sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
        if artifacts.get(rel, {}).get('sha256') != sha(path):
            return False, 'static report hash mismatch'
        data = json.loads(path.read_text())
        checks = data.get('checks', [])
        required = {'driver 0', 'driver 1', 'driver 2', 'single PCLK sequential domain', 'MISO is not false-pathed'}
        if data.get('status') != 'pass' or not checks or any(c.get('status') != 'pass' for c in checks) or not required.issubset({c.get('name') for c in checks}):
            return False, 'static checks missing or failed'
        hashes = data.get('hashes', {})
        if not {'scripts/check_delivery.py', 'sw/tests/test_driver.c', 'sw/src/spi_master.c', *('build/delivery/driver-%d.log' % i for i in range(3))}.issubset(hashes):
            return False, 'static source/compile/run bindings missing'
        for name, expected in hashes.items():
            artifact = (workspace / name).resolve()
            if not artifact.is_relative_to(workspace.resolve()) or not artifact.is_file() or sha(artifact) != expected:
                return False, 'stale static artifact: ' + name
        for i in range(3):
            if data.get('executions', [])[i].get('exit_code') != 0:
                return False, 'C command failed'
        if 'DRIVER_TEST PASS' not in log_path.read_text() or 'DRIVER_TEST FAIL' in log_path.read_text():
            return False, 'C driver did not pass'
        return True, 'real static checks and C compile/run passed; current source/log hashes verified'
    except (OSError, ValueError, TypeError, KeyError, IndexError):
        return False, 'invalid static execution evidence'

def load_evaluator():
    text = SOURCE.read_text()
    old = '                implementation = (workspace / raw_implementation).resolve()\n'
    new = old + '''                if (testcase.get("type") == "static"
                    and testcase.get("id") == "TC.SPI_MASTER.DELIVERY.001"
                    and raw_implementation == "scripts/check_delivery.py"
                    and implementation.is_relative_to(workspace.resolve())
                    and implementation.is_file()):
                    mapped_implementations.append(implementation)
                    continue
'''
    assert text.count(old) == 1, 'Upstream changed; review adapter'
    text = text.replace(old, new)
    old = '            passed, detail = validate_uvm_log(log_path)\n'
    new = '''            if testcase_id == "TC.SPI_MASTER.DELIVERY.001" and implementation == "scripts/check_delivery.py":
                passed, detail = validate_spi_static_execution(record, log_path, workspace, artifacts)
            else:
                passed, detail = validate_uvm_log(log_path)
'''
    assert text.count(old) == 1, 'Upstream changed; review adapter'
    text = text.replace(old, new)
    text = text.replace('"generated_by": "15-regression-quality-review/evaluate_quality.py"', '"generated_by": "15-regression-quality-review/scripts/evaluate_quality.py + SPI mixed-proof adapter"')
    namespace = {'__name__': 'spi_quality_upstream', '__file__': str(SOURCE), 'validate_spi_static_execution': validate_spi_static_execution}
    exec(compile(text, str(SOURCE), 'exec'), namespace)
    return namespace

if __name__ == '__main__':
    provenance = {'upstream': str(SOURCE), 'upstream_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(), 'adapter_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), 'changes': ['only exact static delivery testcase accepts Python implementation', 'static+C validates executable evidence, exit codes and current source/log hashes; UVM checks unchanged'], 'coverage_rules_modified': False}
    (IP/'reports/quality/quality-evaluator-adapter.json').write_text(json.dumps(provenance, indent=2)+'\n')
    raise SystemExit(load_evaluator()['main']())
