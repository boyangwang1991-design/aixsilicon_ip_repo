"""Run FuseSoC module targets with immutable inputs and strict VCS result checking."""
import argparse
import hashlib
import json
import re
import subprocess
import time
from pathlib import Path

import yaml


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--test', help='Optional ut_*.sv stem; individual runs do not update full signoff')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    core_path = root / 'aixsilicon_ip_apb_secure_demux.core'
    core = yaml.safe_load(core_path.read_text().split('\n', 1)[1])
    test_sources = sorted((root / 'verification/unit_test').glob('ut_*.sv'))
    targets = {value['toplevel']: key for key, value in core['targets'].items() if key.startswith('ut_')}
    expected = {p.stem for p in test_sources}
    if not expected <= targets.keys():
        raise ValueError('Missing actual FuseSoC target: ' + str(expected - targets.keys()))
    if args.test and args.test not in expected:
        raise ValueError('Unknown test')
    tests = [args.test] if args.test else sorted(expected)
    config = root / 'build/package/fusesoc.conf'
    adapter = root / 'build/package/compat/parity_gen_check.core'
    adapter_data = yaml.safe_load(adapter.read_text().split('\n', 1)[1])
    dependencies = [Path(p) for p in adapter_data['filesets']['rtl_src']['files']]
    source_paths = sorted((root / 'rtl').rglob('*.sv')) + test_sources
    source_paths += sorted((root / 'regs').rglob('*.rdl'))
    source_paths += [root / 'regs/apb_secure_demux.config.json', root / 'rtl/instance/register_bridge.json',
                     root / 'model/parameter_space.yaml', root / 'rtl/filelist.f', core_path,
                     config, adapter, Path(__file__).resolve()] + dependencies
    frozen = [{'path': str(p), 'sha256': sha(p)} for p in source_paths]
    batch = root / 'build/sim/run/ut' / f'batch_{time.time_ns()}'
    batch.mkdir(parents=True)
    identity = batch / 'inputs.json'
    identity.write_text(json.dumps(frozen, indent=2) + '\n')
    checks = {}
    artifacts = []

    def record(path):
        artifacts.append({'path': str(path.relative_to(root)), 'sha256': sha(path)})

    def unchanged():
        if set(p.stem for p in (root / 'verification/unit_test').glob('ut_*.sv')) != expected:
            raise RuntimeError('Module UT source set changed')
        if any(sha(Path(item['path'])) != item['sha256'] for item in frozen):
            raise RuntimeError('Input identity changed; invalidate this batch')

    def execute(command, log, timeout):
        with log.open('w') as output:
            try:
                result = subprocess.run(command, cwd=root, stdout=output, stderr=subprocess.STDOUT,
                                        timeout=timeout, check=False)
                code = result.returncode
            except subprocess.TimeoutExpired:
                code = 124
        record(log)
        return code

    record(identity)
    try:
        for test in tests:
            unchanged()
            build = batch / test
            base = ['fusesoc', '--config', str(config), '--cores-root', str(root), 'run',
                    '--target=' + targets[test], '--build-root', str(build)]
            compile_log = batch / (test + '.compile.log')
            run_log = batch / (test + '.run.log')
            compile_command = base + ['--setup', '--build', core['name']]
            run_command = base + ['--run', core['name']]
            compile_code = execute(compile_command, compile_log, 300)
            unchanged()
            run_code = -1
            if compile_code == 0:
                run_code = execute(run_command, run_log, 120)
            else:
                run_log.write_text('NOT_RUN: compile failed\n')
                record(run_log)
            unchanged()
            run_text = run_log.read_text(errors='replace')
            compile_text = compile_log.read_text(errors='replace')
            marker = test.upper() + ': PASS (errors=0)'
            bad = re.search(r'(?m)^(Error[: -]|Fatal[: -])|failed at [0-9]|FAIL|TIMEOUT', run_text)
            passed = compile_code == 0 and run_code == 0 and not bad and marker in run_text.splitlines()
            if re.search(r'(?m)^Error[: -]', compile_text):
                passed = False
            binaries = [p for p in build.rglob('aixsilicon_ip_apb_secure_demux_1.0.0') if p.is_file()]
            if len(binaries) == 1:
                record(binaries[0])
            elif passed:
                passed = False
            checks[test] = {'status': 'pass' if passed else 'fail', 'compile_exit': compile_code,
                            'run_exit': run_code, 'compile_command': compile_command, 'run_command': run_command,
                            'compile_log': str(compile_log.relative_to(root)), 'run_log': str(run_log.relative_to(root))}
            print(test, checks[test]['status'], flush=True)
        unchanged()
    except (OSError, RuntimeError) as error:
        print(str(error), flush=True)
        for test in tests:
            checks.setdefault(test, {})['status'] = 'fail'
    passed = len(checks) == len(tests) and all(c['status'] == 'pass' for c in checks.values())
    report = {'schema_version': '2.0', 'ip_name': 'apb_secure_demux', 'report_type': 'module_ut',
              'status': 'pass' if passed else 'fail', 'eda_profile': 'commercial-systemverilog',
              'tool': 'vcs', 'tool_version': 'W-2024.09-SP1 (also present in raw logs)',
              'command': 'uv run python scripts/run_module_ut.py' + (' --test ' + args.test if args.test else ''),
              'test_count': len(tests), 'artifacts': artifacts, 'checks': checks}
    text = '# Module UT execution\n\nResults are from this immutable batch only. This is not UVM regression or formal signoff.\n\n<!-- REPORT_META\n'
    text += yaml.safe_dump(report, sort_keys=False) + 'END_REPORT_META -->\n'
    (batch / 'module_ut_summary.md').write_text(text)
    if not args.test:
        (root / 'reports/quality/module_ut_summary.md').write_text(text)
    print(batch / 'module_ut_summary.md', flush=True)
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
