"""Materialize an isolated, validated CSR/RTL instance; copies SV behavior unchanged."""
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
from pathlib import Path


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--configuration', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    if output.exists():
        raise ValueError('Output already exists; use a fresh isolated directory')
    output.mkdir(parents=True)
    inputs = sorted((root / 'rtl').glob('*.sv'))
    inputs += sorted((root / 'verification/unit_test').glob('*.sv'))
    inputs += sorted((root / 'constraints').glob('*.sdc'))
    inputs += [root / 'aixsilicon_ip_apb_secure_demux.core', root / 'regs/templates/apb_secure_demux.rdl.j2']
    inputs += [root / 'scripts' / name for name in ['check_configuration.py', 'render_registers.py',
               'generate_register_bridge.py', 'spyglass_lint.sh', 'synth.tcl']]
    frozen = [{'path': str(p.relative_to(root)), 'sha256': sha(p)} for p in inputs]
    for item, source in zip(frozen, inputs):
        destination = output / item['path']
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
    (output / 'rtl/generated').mkdir(parents=True)
    rdl = output / 'regs/apb_secure_demux.rdl'
    commands = [[sys.executable, str(output / 'scripts/render_registers.py'), '--model',
                 str(root / 'model/parameter_space.yaml'), '--configuration', args.configuration, '--output', str(rdl)],
                [sys.executable, '-m', 'peakrdl', 'regblock', str(rdl), '-o', str(output / 'rtl/generated'),
                 '--cpuif', 'apb4-flat', '--module-name', 'apb_secure_demux_csr_regblock',
                 '--package-name', 'apb_secure_demux_csr_pkg', '--default-reset', 'arst_n',
                 '--err-if-bad-addr', '--err-if-bad-rw'],
                [sys.executable, str(output / 'scripts/generate_register_bridge.py'), '--rdl', str(rdl),
                 '--config-manifest', str(rdl.with_suffix('.config.json')), '--output', str(output / 'rtl/instance')]]
    results = []
    for index, command in enumerate(commands):
        result = subprocess.run(command, capture_output=True, text=True, timeout=240, check=False)
        log = output / f'generate_{index}.log'
        log.write_text(result.stdout + result.stderr)
        results.append({'command': command, 'exit_code': result.returncode, 'log_sha256': sha(log)})
        if result.returncode:
            raise RuntimeError(log.read_text())
    for item, source in zip(frozen, inputs):
        if sha(source) != item['sha256'] or sha(output / item['path']) != item['sha256']:
            raise RuntimeError('Source or copied behavior changed during materialization')
    manifest = {'configuration': args.configuration, 'scope': 'isolated validated instance, not parameter execution signoff',
                'inputs': frozen, 'parameter_model_sha256': sha(root / 'model/parameter_space.yaml'),
                'materializer_sha256': sha(Path(__file__)), 'commands': results}
    (output / 'materialization.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('MATERIALIZED', args.configuration, output)


if __name__ == '__main__':
    main()
