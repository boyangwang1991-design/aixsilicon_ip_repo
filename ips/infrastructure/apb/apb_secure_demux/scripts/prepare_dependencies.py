"""Prepare local FuseSoC dependency metadata without copying dependency RTL."""

import argparse
import hashlib
import json
from pathlib import Path

import yaml


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cbb-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True, help='Fresh local build directory')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output.resolve()
    if not output.is_relative_to(root / 'build'):
        parser.error('Dependency metadata with local paths must stay under this IP build directory')
    if output.exists():
        parser.error('Output exists; use a fresh directory to preserve active build inputs')
    component = args.cbb_root.resolve() / 'components/coding_integrity/parity_gen_check'
    source = component / 'rtl/parity_gen_check.sv'
    original = component / 'fusesoc/aixsilicon_cbb_parity_gen_check.core'
    data = yaml.safe_load(original.read_text().split('\n', 1)[1])
    if data['name'] != 'aixsilicon:cbb:parity_gen_check:0.1.0':
        parser.error('Unexpected CBB VLNV; review the dependency before adapting metadata')
    frozen = {str(p): sha(p) for p in [source, original]}
    data.pop('provider', None)
    data['filesets'] = {'rtl_src': {'files': [str(source)], 'file_type': 'systemVerilogSource'}}
    data['targets'] = {'default': {'filesets': ['rtl_src']}}
    for parameter in data.get('parameters', {}).values():
        parameter.setdefault('paramtype', 'vlogparam')
    compat = output / 'compat'
    compat.mkdir(parents=True)
    adapter = compat / 'parity_gen_check.core'
    adapter.write_text('CAPI=2:\n' + yaml.safe_dump(data, sort_keys=False))
    config = output / 'fusesoc.conf'
    config.write_text(f'[main]\nignored_dirs = {root / "build"}\n\n'
                      f'[library.cbb_compat]\nlocation = {compat}\n')
    if any(sha(Path(path)) != value for path, value in frozen.items()):
        raise RuntimeError('Dependency changed during preparation')
    manifest = {'scope': 'Local metadata adapter; external RTL unchanged; no release qualification',
                'inputs': frozen, 'adapter_sha256': sha(adapter), 'config_sha256': sha(config),
                'generator_sha256': sha(Path(__file__))}
    (output / 'dependency_manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(config)


if __name__ == '__main__':
    main()
