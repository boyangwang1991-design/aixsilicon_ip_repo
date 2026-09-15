"""Extract measured DUT coverage; keep unimplemented VPLAN closure explicitly open."""
import argparse
import json
from pathlib import Path
import re
import yaml
from run_uvm import P, digest, inputs


def ratios(line, names):
    """Read URG -show ratios columns, retaining absent denominators as None."""
    tokens = line.split()
    if len(tokens) < 1 + 2 * len(names):
        raise ValueError('incomplete URG coverage row')
    result = {}
    for index, name in enumerate(names):
        percentage, fraction = tokens[1+2*index:3+2*index]
        if percentage == '--' and fraction == '--':
            result[name] = None
            continue
        match = re.fullmatch(r'(\d+)/(\d+)', fraction)
        if not match:
            raise ValueError(f'invalid URG fraction: {fraction}')
        covered, total = map(int, match.groups())
        if not 0 <= covered <= total or total <= 0:
            raise ValueError('invalid coverage denominator')
        if abs(float(percentage) - 100*covered/total) > 0.011:
            raise ValueError('URG percentage and fraction disagree')
        result[name] = dict(covered=covered, total=total, achieved=100*covered/total)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--coverage-manifest', type=Path, required=True)
    args = parser.parse_args()
    source = args.coverage_manifest.resolve()
    data = json.loads(source.read_text())
    before = inputs()
    if data['inputs'] != before or data['inputs_after'] != before:
        raise ValueError('coverage inputs are stale')
    regression = P/data['regression']['path']
    if digest(regression) != data['regression']['sha256']:
        raise ValueError('regression manifest changed')
    artifacts = {str(source.relative_to(P)): digest(source),
                 str(regression.relative_to(P)): digest(regression),
                 str(Path(__file__).resolve().relative_to(P)): digest(Path(__file__))}
    measurements = []; failures = []
    for group in data['groups']:
        for entry in group['reports']:
            if digest(P/entry['path']) != entry['sha256']:
                raise ValueError('raw coverage report changed')
            artifacts[entry['path']] = entry['sha256']
        if group['status'] != 'reported':
            failures.append(f"{group['config_id']}: URG execution failed")
            continue
        hierarchy = next(x['path'] for x in group['reports'] if x['path'].endswith('/hierarchy.txt'))
        rows = [line for line in (P/hierarchy).read_text().splitlines() if line.split()[-1:] == ['dut']]
        if len(rows) != 1:
            raise ValueError('expected exactly one watchdog_harness.dut row')
        values = ratios(rows[0], ['line', 'condition', 'toggle', 'fsm', 'branch', 'assertion'])
        for name, value in values.items():
            if name == 'assertion':
                continue  # Harness assertion coverage is reported separately; not DUT code coverage.
            measurements.append(dict(config_id=group['config_id'], metric=name,
                scope=f"{group['config_id']}:watchdog_harness.dut", report=hierarchy,
                target=95, **(value or {'covered': None, 'total': None, 'achieved': None})))
            if value is None or value['achieved'] < 95:
                failures.append(f"{group['config_id']}/{name}: {'unmeasured' if value is None else str(round(value['achieved'], 2))+'%'}; target 95%")
    # The implemented generic coverpoints do not map the mandatory bins/crosses in VPLAN.
    # Reporting their score as mandatory functional coverage would overstate verification.
    failures.append('WDT-COV-001: VPLAN mandatory bins/cross mapping and assertion closure are incomplete')
    dependency = P/'build/reports/regression/regression_summary.md'
    artifacts[str(dependency.relative_to(P))] = digest(dependency)
    out = P/'build/reports/coverage/coverage_summary.md'
    meta = dict(schema_version='2.0', ip_name='watchdog', report_type='coverage', status='fail',
        eda_profile='commercial-systemverilog', tool='URG', tool_version=data['tool'],
        command='python scripts/summarize_coverage.py --coverage-manifest '+str(source.relative_to(P)),
        artifacts=[dict(path=p, sha256=h) for p,h in sorted(artifacts.items())],
        dependencies=[dict(path=str(dependency.relative_to(P)), sha256=digest(dependency))],
        code_metrics=measurements, functional_closure='incomplete', assertion_closure='incomplete',
        exclusions=[], waivers=[], threshold_changes=[], failures=failures)
    if inputs() != before:
        raise ValueError('inputs changed during coverage extraction')
    out.write_text('# Coverage extraction\n\nFAIL: measured DUT ratios and remaining closure gaps.\n\n'
                   '<!-- REPORT_META\n'+yaml.safe_dump(meta, allow_unicode=True, sort_keys=False)+'END_REPORT_META -->\n')
    print(json.dumps(dict(status='fail', measurements=len(measurements), report=str(out.relative_to(P)))))
    return 1


if __name__ == '__main__':
    raise SystemExit(main())
