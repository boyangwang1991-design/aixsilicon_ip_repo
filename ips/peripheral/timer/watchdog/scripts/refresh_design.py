"""Re-extract watchdog design inputs with their owning tools; never grant approval."""
from pathlib import Path
import argparse
import json
import os
import subprocess
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = Path(os.environ['UV_PROJECT']).resolve()
SUITE = Path(os.environ.get('SUITE_DIR', WORKFLOW / '.roo/skills/ip-development-suite'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', choices=['lrs', 'hld', 'lld', 'vplan'], required=True)
    args = parser.parse_args()
    commands = {
        'lrs': [
            ['01-lrs-author/scripts/extract_requirements.py', '--lrs-dir', 'docs/lrs', '--output', 'model/requirements.yaml', '--ip-name', 'watchdog'],
            ['19-param-space-verification/scripts/extract_parameters.py', '--lrs-dir', 'docs/lrs', '--output', 'model/parameter_space.yaml', '--ip-name', 'watchdog'],
            ['19-param-space-verification/scripts/config_gen.py', '--config', 'model/parameter_space.yaml', '--output', 'build/reports/quality/param_matrix.md', '--model-output', 'model/parameter_space.yaml'],
        ],
        'hld': [['03-hld-architect/scripts/extract_hld.py', '--hld-dir', 'docs/hld', '--requirements', 'model/requirements.yaml', '--output', 'model', '--ip-name', 'watchdog']],
        'lld': [['05-lld-microdesign/scripts/extract_lld.py', '--lld-dir', 'docs/lld', '--output', 'model/micro_design.yaml', '--ip-name', 'watchdog']],
        'vplan': [['06-verification-plan/scripts/extract_verification.py', '--testplan-dir', 'docs/verification', '--requirements', 'model/requirements.yaml', '--output', 'model/verification.yaml', '--ip-name', 'watchdog']],
    }
    output = ROOT / 'build/reports/design' / args.stage
    output.mkdir(parents=True, exist_ok=True)
    records = []
    for index, command in enumerate(commands[args.stage]):
        argv = [sys.executable, str(SUITE / 'skills' / command[0]), *command[1:]]
        log = output / f'{index}_{Path(command[0]).stem}.log'
        with log.open('w') as stream:
            result = subprocess.run(argv, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT)
        records.append({'command': argv, 'exit_code': result.returncode, 'log': str(log.relative_to(ROOT))})
        (output / 'execution.json').write_text(json.dumps(records, indent=2) + '\n')
        if result.returncode:
            print(log.read_text())
            return result.returncode
    if args.stage == 'vplan':
        micro = yaml.safe_load((ROOT / 'model/micro_design.yaml').read_text())
        modules = {item['id'] for item in micro['modules']}
        links = [{'source_id': ident, 'target_id': 'RTL.FILE.' + item['rtl_file']}
                 for item in micro['rtl_map'] for ident in item['implements'] if ident in modules]
        seed = ROOT / 'build/reports/trace-seeds/lld_to_rtl.yaml'
        seed.parent.mkdir(parents=True, exist_ok=True)
        seed.write_text(yaml.safe_dump({'schema_version': '2.0', 'ip_name': 'watchdog', 'links': links}))
        subprocess.run([sys.executable, str(SUITE / 'skills/16-trace-manager/scripts/build_trace.py'),
                        '--workspace', str(ROOT), '--ip-name', 'watchdog', '--phase', 'precheck'], check=True)
    print(f'{args.stage}: owning extraction completed; approval unchanged')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
