"""Run watchdog FuseSoC targets with local logs and current dependency binding."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = Path(os.environ['UV_PROJECT']).resolve()
SUITE = Path(os.environ.get('SUITE_DIR', WORKFLOW / '.roo/skills/ip-development-suite'))
sys.path.insert(0, str(SUITE))
from scripts.run_rtl_check import run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', choices=['lint', 'elab', 'synth', 'cdc', 'rdc', 'formal'])
    parser.add_argument('--synth-mode', choices=['ultra', 'classic'], default='ultra')
    args = parser.parse_args()
    os.environ['WATCHDOG_IP_ROOT'] = str(ROOT)
    subprocess.run([sys.executable, str(ROOT / 'scripts/prepare_dependencies.py')], check=True, cwd=ROOT)
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%f')
    output = ROOT / 'build/reports/rtl' / stamp
    output.mkdir(parents=True)
    binding = ROOT / 'build/reports/full_flow/dependency_binding.json'
    before = binding.read_bytes()
    cmd = ['fusesoc', '--verbose', '--cores-root', '.', '--cores-root', 'build/dependency_adapter', 'run',
           '--target', args.target, '--build-root', str(ROOT / 'build/rtl' / stamp),
           'aixsilicon:ip:watchdog:1.0.0']
    if args.target == 'elab':
        cmd.insert(cmd.index('--target'), '--setup')
        cmd.insert(cmd.index('--target'), '--build')
    if args.target == 'synth':
        cmd = ['env', f'WATCHDOG_SYNTH_MODE={args.synth_mode}', *cmd]
    if args.target in {'lint', 'elab', 'synth'}:
        tool, version = {'lint': ('spyglass', 'X-2025.06'), 'elab': ('vcs', 'W-2024.09-SP1_Full64'),
                         'synth': ('dc_shell', 'V-2023.12-SP3')}[args.target]
        os.environ['WATCHDOG_SYNTH_OUT'] = str(ROOT / 'build/rtl' / stamp / 'mapped')
        extra = [str(binding.relative_to(ROOT))]
        if args.target == 'synth':
            extra += ['model/pdk.yaml', 'build/rtl/pdk_setup.tcl']
        data = run(ROOT, args.target, tool, version, str((output / 'execution.json').relative_to(ROOT)),
                   ['timeout', '--kill-after=10s', '1800s', *cmd], extra, timeout=1820)
    else:
        log = output / 'execution.log'
        with log.open('w') as stream:
            try:
                result = subprocess.run(cmd, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT, timeout=1000)
                code = result.returncode
            except subprocess.TimeoutExpired:
                code = 124
        data = {'schema': 'watchdog-special-attempt/1.0', 'target': args.target,
                'command': cmd, 'exit_code': code, 'status': 'unverified' if code == 0 else 'fail',
                'log': {'path': str(log.relative_to(ROOT)), 'sha256': hashlib.sha256(log.read_bytes()).hexdigest()}}
    subprocess.run([sys.executable, str(ROOT / 'scripts/prepare_dependencies.py')], check=True, cwd=ROOT)
    if binding.read_bytes() != before:
        data['status'] = 'fail'
        data['dependency_error'] = 'external dependency source changed during execution'
    (output / 'execution.json').write_text(json.dumps(data, indent=2) + '\n')
    print(json.dumps({'target': args.target, 'status': data['status'], 'manifest': str(output.relative_to(ROOT)) + '/execution.json'}))
    return 0 if data['status'] == 'pass' else 2


if __name__ == '__main__':
    raise SystemExit(main())
