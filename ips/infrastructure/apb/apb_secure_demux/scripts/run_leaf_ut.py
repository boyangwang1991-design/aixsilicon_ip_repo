#!/usr/bin/env python3
"""Run one self-checking leaf UT; never emits full-IP Module UT signoff."""
import argparse
import hashlib
import json
import re
import subprocess
import time
from pathlib import Path


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('module', choices=['decode', 'access', 'irq', 'events', 'dfx'])
    parser.add_argument('--depth', type=int, choices=range(33), default=3)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    top = 'ut_apb_secure_demux_' + args.module
    run_dir = root / 'build/sim/run/ut' / f'{top}_{time.time_ns()}'
    run_dir.mkdir(parents=True)
    inputs = [root / f'rtl/apb_secure_demux_{args.module}.sv',
              root / f'verification/unit_test/{top}.sv', Path(__file__).resolve()]
    frozen = [{'path': str(p.relative_to(root)), 'sha256': digest(p)} for p in inputs]
    manifest = {'scope': 'single leaf only; not full Module UT/G3 signoff', 'inputs': frozen,
                'module': args.module, 'depth': args.depth if args.module == 'events' else None,
                'commands': [], 'passed': False}

    def unchanged():
        if any(digest(root / item['path']) != item['sha256'] for item in frozen):
            raise RuntimeError('Inputs changed during compile/run; invalidate this batch')

    def run(command, name, timeout):
        unchanged()
        log = run_dir / (name + '.log')
        with log.open('w') as output:
            try:
                proc = subprocess.run(command, cwd=run_dir, stdout=output,
                                      stderr=subprocess.STDOUT, timeout=timeout, check=False)
                code = proc.returncode
            except subprocess.TimeoutExpired:
                code = 124
        unchanged()
        manifest['commands'].append({'command': command, 'exit_code': code,
                                     'log': str(log.relative_to(root)), 'log_sha256': digest(log)})
        return code, log.read_text(errors='replace')

    command = ['vcs', '-full64', '-sverilog', '-timescale=1ns/1ps',
               str(inputs[0]), str(inputs[1]), '-top', top, '-o', str(run_dir / 'simv')]
    if args.module == 'events':
        command.append(f'-pvalue+{top}.DEPTH={args.depth}')
    try:
        code, output = run(command, 'compile', 180)
        if code == 0:
            manifest['binary_sha256'] = digest(run_dir / 'simv')
            code, output = run([str(run_dir / 'simv')], 'run', 60)
            marker = f'UT_APB_SECURE_DEMUX_{args.module.upper()}: PASS (errors=0'
            manifest['passed'] = code == 0 and marker in output and not re.search(r'(?m)^(Error:|Fatal:)|failed at [0-9]', output)
        print(output[-1500:])
    finally:
        (run_dir / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        print(run_dir / 'manifest.json')
    return 0 if manifest['passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
