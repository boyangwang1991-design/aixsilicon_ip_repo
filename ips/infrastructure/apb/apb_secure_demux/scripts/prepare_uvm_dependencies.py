"""Adapt candidate VIP packaging metadata without modifying or vendoring sources."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

import yaml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cbb-root', type=Path, required=True)
    parser.add_argument('--vip-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    subprocess.run([sys.executable, str(root / 'scripts/prepare_dependencies.py'),
                    '--cbb-root', str(args.cbb_root), '--output', str(output)], check=True)
    vip = args.vip_root.resolve() / 'vip/amba/apb'
    original = vip / 'aixsilicon_vip_apb_1.0.0.core'
    data = yaml.safe_load(original.read_text().split('\n', 1)[1])
    if data['name'] != 'aixsilicon:vip:apb:1.0.0':
        raise ValueError('Unexpected VIP identity')
    sources = sorted((vip / 'src').rglob('*.sv'))
    inputs = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in [original, *sources]}
    units = [vip / 'src' / name for name in ('apb_types_pkg.sv', 'apb_if.sv', 'apb_pkg.sv')]
    files = [str(p) for p in units]
    files += [{str(p): {'is_include_file': True, 'include_path': str(vip / 'src')}}
              for p in sources if p not in units]
    adapter = {'name': data['name'], 'description': 'Local candidate VIP metadata adapter; qualification pending',
               'filesets': {'src': {'files': files, 'file_type': 'systemVerilogSource'}},
               'targets': {'default': {'filesets': ['src']}}}
    (output / 'compat/apb.core').write_text('CAPI=2:\n' + yaml.safe_dump(adapter, sort_keys=False))
    (output / 'vip_dependency_manifest.json').write_text(json.dumps({
        'scope': 'Preintegration only; external source unchanged; include-only metadata repaired',
        'inputs': inputs}, indent=2) + '\n')
    if any(hashlib.sha256(Path(p).read_bytes()).hexdigest() != h for p, h in inputs.items()):
        raise RuntimeError('VIP changed during metadata preparation')


if __name__ == '__main__':
    main()
