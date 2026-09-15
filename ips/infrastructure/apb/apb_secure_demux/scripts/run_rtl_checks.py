"""Run the IP FuseSoC targets and retain input-bound G3 evidence locally."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

import yaml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('check', choices=['lint', 'elab', 'synth'])
    parser.add_argument('--suite', type=Path)
    parser.add_argument('--execute', type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    if args.execute:
        batch = args.execute.resolve()
        if not batch.is_relative_to(root / 'build/rtl'):
            parser.error('execution directory must be local build/rtl')
        command = ['fusesoc', '--verbose', '--config', str(batch / 'dependencies/fusesoc.conf'),
                   '--cores-root', str(root), 'run', '--target=' + args.check,
                   '--build-root', str(batch / 'fusesoc'),
                   '--setup', '--build', 'aixsilicon:ip:apb_secure_demux:1.0.0']
        env = dict(os.environ, ASD_PDK_SETUP=str(root / 'build/rtl/pdk_setup.tcl'))
        if args.check == 'lint':
            env['ASD_REAL_SG_SHELL'] = shutil.which('sg_shell') or ''
            if not env['ASD_REAL_SG_SHELL']:
                raise RuntimeError('sg_shell is unavailable')
            env['PATH'] = str(root / 'scripts/tool_adapters') + os.pathsep + env['PATH']
        result = subprocess.run(command, cwd=root, env=env, check=False)
        # DC redirects reports; include actual tool output in the execution log.
        if args.check == 'synth':
            for name in ['synth.log', 'area.rpt', 'check_design.rpt', 'check_timing.rpt']:
                paths = list((batch / 'fusesoc').rglob('reports/' + name))
                if len(paths) != 1:
                    print('Missing/ambiguous DC report: ' + name, flush=True)
                    return 2
                with paths[0].open(errors='replace') as stream:
                    shutil.copyfileobj(stream, sys.stdout)
        return result.returncode
    if not args.suite:
        parser.error('--suite is required for the local evidence adapter; plain FuseSoC targets remain standalone')
    suite = args.suite.resolve()
    sys.path.insert(0, str(suite))
    from scripts.run_rtl_check import run
    batch = root / 'build/rtl' / f'{args.check}_{time.time_ns()}'
    batch.mkdir(parents=True)
    old = root / 'build/package'
    local = batch / 'dependencies'
    (local / 'compat').mkdir(parents=True)
    data = yaml.safe_load((old / 'compat/parity_gen_check.core').read_text().split('\n', 1)[1])
    sources = []
    for index, name in enumerate(data['filesets']['rtl_src']['files']):
        source = Path(name)
        destination = local / f'{index}_{source.name}'
        shutil.copyfile(source, destination)
        if source.read_bytes() != destination.read_bytes():
            raise RuntimeError('CBB source changed during snapshot')
        sources.append(str(destination))
    data['filesets']['rtl_src']['files'] = sources
    (local / 'compat/parity_gen_check.core').write_text('CAPI=2:\n' + yaml.safe_dump(data, sort_keys=False))
    (local / 'fusesoc.conf').write_text(
        f'[main]\nignored_dirs = {root / "build"}\n\n[library.cbb_compat]\nlocation = {local / "compat"}\n')
    inputs = [str(p.relative_to(root)) for p in local.rglob('*') if p.is_file()]
    if args.check == 'synth':
        inputs += ['model/pdk.yaml', 'build/rtl/pdk_setup.tcl']
    tool, version = {'lint': ('spyglass', 'X-2025.06'),
                     'elab': ('vcs', 'W-2024.09-SP1'),
                     'synth': ('dc_shell', 'V-2023.12-SP3')}[args.check]
    output = batch / 'execution.json'
    result = run(root, args.check, tool, version, str(output.relative_to(root)),
                 [sys.executable, str(Path(__file__).resolve()), args.check,
                  '--execute', str(batch)], inputs, timeout=3600)
    print(json.dumps({k: result[k] for k in ['check', 'status', 'exit_code', 'detail']}))
    print(output)
    return 0 if result['status'] == 'pass' else 2


if __name__ == '__main__':
    raise SystemExit(main())
