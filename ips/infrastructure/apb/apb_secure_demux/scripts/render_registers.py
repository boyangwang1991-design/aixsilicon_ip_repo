"""Expand the SystemRDL structure template for a validated named configuration.

No RTL behavior is generated here. PeakRDL owns all downstream CSR views.
"""
import argparse
import hashlib
import json
from pathlib import Path

import jinja2
import yaml
from check_configuration import check


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument('--model', type=Path)
    source.add_argument('--config', type=Path)
    parser.add_argument('--configuration')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    input_path = args.model or args.config
    if args.model:
        model = yaml.safe_load(args.model.read_text())
        configs = [c for c in model['support_matrix']['configs'] if c['id'] == args.configuration]
        if len(configs) != 1:
            raise ValueError('configuration must resolve to exactly one entry')
        values = configs[0]['params']
    else:
        values = yaml.safe_load(args.config.read_text())
        args.configuration = args.configuration or args.config.stem
    stage, errors = check(values)
    if errors:
        raise ValueError(f'{stage}: {errors}')
    template_path = Path(__file__).resolve().parents[1] / 'regs/templates/apb_secure_demux.rdl.j2'
    env = jinja2.Environment(undefined=jinja2.StrictUndefined, keep_trailing_newline=True)
    rendered = env.from_string(template_path.read_text()).render(config_id=args.configuration, **values)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(rendered)
    record = {
        'configuration': args.configuration,
        'scope': 'validated explicit specialization; integration qualification is separate',
        'inputs': [{'path': str(p.resolve()), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                   for p in [input_path, template_path, Path(__file__), Path(__file__).with_name('check_configuration.py')]],
        'values': values,
        'rdl_sha256': hashlib.sha256(args.output.read_bytes()).hexdigest(),
    }
    args.output.with_suffix('.config.json').write_text(json.dumps(record, indent=2) + '\n')
    print(f'Rendered {args.configuration}: {args.output}')


if __name__ == '__main__':
    main()
