"""Rebuild design projections and native CSR evidence with the selected suite."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

import yaml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suite', required=True, type=Path)
    args = parser.parse_args()
    suite = args.suite.resolve()
    root = Path(__file__).resolve().parents[1]
    batch = root / 'build/design' / f'rebuild_{time.time_ns()}'
    batch.mkdir(parents=True)
    quality = root / 'build/reports/quality'
    quality.mkdir(parents=True, exist_ok=True)
    calls = []

    def run(script, *options, local=False):
        path = root / script if local else suite / script
        command = [sys.executable, str(path), *map(str, options)]
        result = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=600)
        log = batch / f'{len(calls):02}_{path.stem}.log'
        log.write_text(result.stdout + result.stderr)
        calls.append({'command': command, 'exit_code': result.returncode,
                      'log': str(log.relative_to(root)),
                      'sha256': hashlib.sha256(log.read_bytes()).hexdigest()})
        (batch / 'execution.json').write_text(json.dumps(calls, indent=2) + '\n')
        print(path.stem, result.returncode, flush=True)
        if result.returncode:
            print(result.stderr[-2000:])
            raise SystemExit(result.returncode)

    run('skills/01-lrs-author/scripts/extract_requirements.py', '--lrs-dir', 'docs/lrs',
        '--output', 'model/requirements.yaml', '--ip-name', 'apb_secure_demux')
    pc = 'skills/19-param-space-verification/scripts/'
    run(pc + 'extract_parameters.py', '--lrs-dir', 'docs/lrs', '--output', 'model/parameter_space.yaml',
        '--ip-name', 'apb_secure_demux')
    run(pc + 'config_gen.py', '--config', 'model/parameter_space.yaml',
        '--model-output', 'model/parameter_space.yaml', '--output', quality / 'param_matrix.md', '--seed', 42)
    run(pc + 'validate_params.py', '--config', 'model/parameter_space.yaml', '--output', quality / 'param_check.md')
    run('skills/03-hld-architect/scripts/extract_hld.py', '--hld-dir', 'docs/hld', '--output', 'model',
        '--requirements', 'model/requirements.yaml', '--ip-name', 'apb_secure_demux')
    run('skills/05-lld-microdesign/scripts/extract_lld.py', '--lld-dir', 'docs/lld',
        '--output', 'model/micro_design.yaml', '--ip-name', 'apb_secure_demux')
    run('scripts/check_register_structure.py', '--rdl', 'regs/apb_secure_demux.rdl',
        '--config-manifest', 'regs/apb_secure_demux.config.json', '--micro-design', 'model/micro_design.yaml',
        '--output', batch / 'register_structure.json', local=True)
    run('skills/02-reg-model/scripts/publish_csr.py', '--rdl-source', 'regs/apb_secure_demux.rdl',
        '--generated', 'rtl/generated/apb_secure_demux_csr_pkg.sv',
        '--generated', 'rtl/generated/apb_secure_demux_csr_regblock.sv',
        '--lint-command', 'vlogan -full64 -sverilog {files}',
        '--manifest', 'rtl/generated/apb_secure_demux_csr.manifest.yaml',
        '--report', quality / 'register_check.md', '--lint-log', batch / 'native_compile.log',
        '--work-dir', batch / 'native_compile', '--ip-name', 'apb_secure_demux',
        '--tool-version', 'VCS W-2024.09-SP1')
    run('skills/06-verification-plan/scripts/extract_verification.py', '--testplan-dir', 'docs/verification',
        '--requirements', 'model/requirements.yaml', '--output', 'model/verification.yaml', '--ip-name', 'apb_secure_demux')
    micro = yaml.safe_load((root / 'model/micro_design.yaml').read_text())
    links = []
    for mapping in micro['rtl_map']:
        target = root / mapping['rtl_file']
        if not target.is_file() or not target.resolve().is_relative_to(root / 'rtl'):
            raise ValueError('RTL mapping does not name a current local RTL source')
        for source in mapping['implements']:
            links.append({'source_id': source, 'target_id': 'RTL.FILE.' + mapping['rtl_file']})
    seed = root / 'build/reports/trace-seeds/lld_to_rtl.yaml'
    seed.parent.mkdir(parents=True, exist_ok=True)
    seed.write_text(yaml.safe_dump({'schema_version': '2.0', 'ip_name': 'apb_secure_demux', 'links': links}, sort_keys=False))
    run('skills/16-trace-manager/scripts/build_trace.py', '--workspace', root,
        '--ip-name', 'apb_secure_demux', '--phase', 'precheck')
    print(batch)


if __name__ == '__main__':
    main()
