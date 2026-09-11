"""Check GPIO configuration semantics against the extracted LRS contract.

Run from the IP root using the workflow Python environment. This is Schema
validation, not RTL parameter-space execution evidence.
"""
import hashlib
import json
from pathlib import Path

import yaml


def violations(values):
    errors = []
    ranges = {'N_GPIO': (1, 128), 'SYNC_STAGES': (2, 4), 'N_IRQ_GROUPS': (1, 4)}
    for key, (lower, upper) in ranges.items():
        if type(values.get(key)) is not int or not lower <= values[key] <= upper:
            errors.append(key + ': invalid integer range')
    for key in ('OUT_INV_EN', 'AON_WAKE_EN', 'SNAPSHOT_EN', 'STRAP_EN', 'DIAG_EN',
                'ACCESS_CTRL_EN', 'CFG_PARITY_EN', 'BOOT_SECURE_ONLY', 'BOOT_PRIV_ONLY'):
        if type(values.get(key)) is not int or values[key] not in (0, 1):
            errors.append(key + ': expected 0 or 1')
    if type(values.get('EVENT_FIFO_DEPTH')) is not int or values['EVENT_FIFO_DEPTH'] not in (0, 4, 8, 16, 32, 64):
        errors.append('EVENT_FIFO_DEPTH: illegal depth')
    width = values.get('N_GPIO')
    if type(width) is int and 1 <= width <= 128:
        for key in ('INPUT_CAP_MASK', 'OUTPUT_CAP_MASK', 'RESET_OUT', 'RESET_OE',
                    'RESET_IN_EN', 'HW_SAFE_OUT', 'HW_SAFE_OE'):
            if type(values.get(key)) is not int or not 0 <= values[key] < (1 << width):
                errors.append(key + ': mask width')
    for enabled, capability in (('RESET_OE', 'OUTPUT_CAP_MASK'), ('HW_SAFE_OE', 'OUTPUT_CAP_MASK'), ('RESET_IN_EN', 'INPUT_CAP_MASK')):
        if type(values.get(enabled)) is int and type(values.get(capability)) is int:
            if values[enabled] & ~values[capability]:
                errors.append(enabled + ': exceeds capability')
    return errors


def main():
    model_path = Path('model/parameter_space.yaml')
    model = yaml.safe_load(model_path.read_text())
    results = []
    for config in model['support_matrix']['configs']:
        errors = violations(config['params'])
        expected = config.get('expect_fail', {})
        passed = (bool(errors) and expected.get('stage') == 'Schema') if expected else not errors
        results.append({'id': config['id'], 'expected_failure': expected, 'errors': errors, 'pass': passed})
    passed = bool(results) and all(result['pass'] for result in results)
    output = {'scope': 'GPIO Schema only; PV not run', 'pass': passed,
              'model_sha256': hashlib.sha256(model_path.read_bytes()).hexdigest(),
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), 'results': results}
    Path('reports/quality/parameter_semantics.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
    print(f'GPIO PARAMETER SCHEMA {"PASS" if passed else "FAIL"}: {len(results)} cases')
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
