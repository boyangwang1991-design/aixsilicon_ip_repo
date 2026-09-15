"""Run canonical UVM tests through FuseSoC with immutable execution inputs."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import subprocess
import sys
import time

import yaml


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suite', type=Path, required=True)
    parser.add_argument('--cbb-root', type=Path, required=True)
    parser.add_argument('--vip-root', type=Path, required=True)
    parser.add_argument('--mode', choices=['compile', 'smoke', 'regress'], default='smoke')
    parser.add_argument('--test')
    parser.add_argument('--seed', type=int, default=42)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    suite = args.suite.resolve()
    sys.path.insert(0, str(suite / 'scripts'))
    from parse_uvm_log import parse_uvm_log
    model = yaml.safe_load((root / 'model/verification.yaml').read_text())
    planned = {tc['id']: tc for f in model['features'] for tc in f['testcases']}
    regression = yaml.safe_load((root / 'verification/sim/regression_list.yaml').read_text())
    listed = {tc['test']: dict(tc, tier=tier) for tier, group in regression.items() for tc in group}
    if set(listed) != set(planned) or any(
        any(listed[k][field] != planned[k][field] for field in ('name', 'implementation', 'tier'))
        for k in listed
    ):
        parser.error('Regression list is stale; run the owning gen_regression_list.py')
    selected = [planned[k] for k, tc in listed.items() if args.mode == 'regress' or tc['tier'] == 'smoke']
    if args.test:
        selected = [tc for tc in planned.values() if tc['name'] == args.test]
        if len(selected) != 1:
            parser.error('Test must identify exactly one canonical testcase')
    batch = root / 'build/sim/run/uvm' / f'batch_{time.time_ns()}'
    batch.mkdir(parents=True)
    dep = batch / 'dependencies'
    subprocess.run([sys.executable, str(root / 'scripts/prepare_uvm_dependencies.py'),
                    '--cbb-root', str(args.cbb_root.resolve()), '--vip-root', str(args.vip_root.resolve()),
                    '--output', str(dep)], check=True)
    def snapshot():
        paths = {p for name in ('rtl', 'regs', 'scripts', 'verification', 'docs', 'model', 'configs', 'constraints')
                 for p in (root / name).rglob('*') if p.is_file() and '__pycache__' not in p.parts
                 and p.name != 'quality.yaml'} | set(root.glob('*.core'))
        for manifest in ('dependency_manifest.json', 'vip_dependency_manifest.json'):
            paths |= {Path(p) for p in json.loads((dep / manifest).read_text())['inputs']}
        paths |= {p for p in dep.rglob('*') if p.is_file()}
        return {str(p): sha(p) for p in sorted(paths)}
    before = snapshot()
    (batch / 'inputs.json').write_text(json.dumps(before, indent=2) + '\n')
    def unchanged():
        if snapshot() != before:
            raise RuntimeError('Source/dependency identity changed: invalidate the entire batch')
    def execute(command, log, cwd, timeout):
        with log.open('w') as stream:
            try:
                result = subprocess.run(command, cwd=cwd, stdout=stream, stderr=subprocess.STDOUT,
                                        timeout=timeout, check=False)
                return result.returncode
            except subprocess.TimeoutExpired:
                return 124
    command = ['fusesoc', '--verbose', '--config', str(dep / 'fusesoc.conf'), '--cores-root', str(root),
               'run', '--target=uvm', '--build-root', str(batch / 'fusesoc'), '--setup', '--build',
               'aixsilicon:ip:apb_secure_demux:1.0.0']
    compile_log = batch / 'compile.log'
    compile_exit = execute(command, compile_log, root, 1200)
    unchanged()
    result = {'compile_command': command, 'compile_exit': compile_exit,
              'compile_log': {'path': str(compile_log.relative_to(root)), 'sha256': sha(compile_log)},
              'input_manifest': {'path': str((batch / 'inputs.json').relative_to(root)),
                                 'sha256': sha(batch / 'inputs.json')}, 'executions': []}
    passed = compile_exit == 0
    if passed and args.mode != 'compile':
        binaries = [p for p in (batch / 'fusesoc').rglob('aixsilicon_ip_apb_secure_demux_1.0.0') if p.is_file()]
        if len(binaries) != 1:
            raise RuntimeError('Missing or ambiguous simulation binary')
        binary = binaries[0]
        result['binary_sha256'] = sha(binary)
        for tc in selected:
            unchanged()
            run_dir = batch / tc['name']
            run_dir.mkdir()
            log = run_dir / 'run.log'
            implementation = root / tc['implementation']
            if not implementation.is_file() or implementation.suffix != '.sv':
                log.write_text('NOT_RUN: implementation is absent or requires its static runner\n')
                code = 2
                run_command = []
            else:
                run_command = [str(binary), '+UVM_TESTNAME=' + tc['name'],
                               '+ntb_random_seed=' + str(args.seed), '-cm', 'line+cond+fsm+tgl+branch',
                               '-cm_dir', str(run_dir / 'coverage.vdb')]
                code = execute(run_command, log, run_dir, 1200)
            unchanged()
            parsed = parse_uvm_log(log.read_text(errors='replace'))
            # Immediate/SVA $error diagnostics are outside UVM severity counts.
            raw_failures = re.findall(r'(?m)^\s*(?:Error:|Fatal:).*|^.*failed at [0-9].*',
                                      log.read_text(errors='replace'))
            parsed['simulator_failures'] = raw_failures
            ok = code == 0 and parsed['result'] == 'PASSED' and not raw_failures
            passed &= ok
            result['executions'].append({'id': tc['id'], 'implementation': tc['implementation'],
                                         'command': run_command, 'exit_code': code, 'seed': args.seed,
                                         'log': str(log.relative_to(root)), 'log_sha256': sha(log),
                                         'status': 'pass' if ok else 'fail', 'parsed': parsed})
            print(tc['id'], 'pass' if ok else 'fail', flush=True)
    unchanged()
    result['status'] = 'pass' if passed else 'fail'
    (batch / 'execution.json').write_text(json.dumps(result, indent=2) + '\n')
    print(batch / 'execution.json', flush=True)
    return 0 if passed else 2


if __name__ == '__main__':
    raise SystemExit(main())
