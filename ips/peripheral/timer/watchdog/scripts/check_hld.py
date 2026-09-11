#!/usr/bin/env python3
"""Check watchdog HLD references and source/model agreement; not a G1 approval."""
import argparse
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path

import yaml


def check(workspace):
    errors = []
    sources = {}
    blocks = defaultdict(list)

    def require(condition, message):
        if not condition:
            errors.append(message)

    def bind(path):
        sources[str(path.relative_to(workspace))] = hashlib.sha256(path.read_bytes()).hexdigest()

    def read_model(name):
        path = workspace / 'model' / (name + '.yaml')
        bind(path)
        return yaml.safe_load(path.read_text())

    sizes = []
    pages = sorted((workspace / 'docs/hld').glob('*.md'))
    for path in pages:
        bind(path)
        content = path.read_text()
        matches = re.findall(r'<!-- (HLD_\w+)_META\s*\n(.*?)END_\1_META -->', content, re.S)
        for kind, payload in matches:
            blocks[kind].append(yaml.safe_load(payload))
        sizes.append(dict(file=path.name, lines=len(content.splitlines()), meta=len(matches)))
        require(len(content.splitlines()) < 300 and len(matches) < 12, f'{path.name}: split review required')
        for target in re.findall(r'\]\(([^)#]+)(?:#[^)]*)?\)', content):
            if '://' not in target:
                require((path.parent / target).exists(), f'{path.name}: missing link {target}')
    index = (workspace / 'docs/hld/index.md').read_text()
    for path in pages:
        require(path.name == 'index.md' or f'({path.name})' in index, f'index missing {path.name}')

    req = read_model('requirements')
    params = read_model('parameter_space')
    arch = read_model('architecture')
    external = read_model('external_interface')['interfaces']
    internal = read_model('internal_interface')['interfaces']
    domains = read_model('clock_domains')['domains']
    paths = read_model('cdc_paths')['paths']
    ids = {r['id'] for r in req['requirements']}
    modules = {m['id'] for m in arch['modules']}
    interfaces = {i['id'] for i in external + internal}
    domain_ids = {d['id'] for d in domains}
    all_objects = [obj for kind, group in blocks.items() for obj in group if 'id' in obj]
    all_ids = {obj['id'] for obj in all_objects}
    require(len(all_ids) == len(all_objects), 'duplicate HLD IDs')
    require(len(blocks['HLD_DOC']) == 1, 'expected one document header')
    require(len(blocks['HLD_GATE']) == 1, 'expected one G1 record')
    require(arch['lrs_baseline'] == req['requirement_baseline'], 'LRS baseline mismatch')
    require(arch['status'] in ('draft', 'reviewed'), 'author document state invalid')
    gate = blocks['HLD_GATE'][0]
    if gate['status'] == 'pass':
        approvals = gate.get('approvals', [])
        require(gate['architecture_freeze'] is True and bool(approvals), 'G1 pass needs explicit freeze and approval evidence')
        for approval in approvals:
            evidence = workspace / approval.get('evidence', '')
            require(evidence.is_file(), 'missing G1 approval evidence')
            if evidence.is_file():
                bind(evidence)
            require(bool(approval.get('source')) and bool(approval.get('input')), 'incomplete G1 approval record')
    else:
        require(gate['status'] == 'open' and gate['architecture_freeze'] is False and not gate.get('approvals'), 'invalid author G1 state')
    covered = {r for m in arch['modules'] for r in m.get('req_ref', [])}
    require(covered == ids, f'module requirement coverage mismatch: missing={sorted(ids-covered)}, unknown={sorted(covered-ids)}')
    fields = {'req_ref': ids, 'hld_ref': all_ids, 'architecture_ref': all_ids,
              'owner_module': modules, 'source_module': modules, 'target_module': modules,
              'target_modules': modules,
              'participants': modules, 'modules': modules, 'protects': modules,
              'allocated_to': modules, 'affected_objects': all_ids, 'interfaces': interfaces,
              'clock_domain': domain_ids, 'reset_domain': domain_ids, 'power_domain': domain_ids,
              'clock_domains': domain_ids, 'reset_domains': domain_ids,
              'source_domain': domain_ids, 'destination_domain': domain_ids}
    for obj in all_objects:
        for field, valid in fields.items():
            refs = obj.get(field, [])
            refs = refs if isinstance(refs, list) else [refs]
            for ref in refs:
                require(ref in valid, f'{obj["id"]}.{field}: unknown {ref}')
    for kind in ('HLD_MODULE', 'HLD_INTERFACE'):
        for obj in blocks[kind]:
            require(bool(obj.get('req_ref')), f'{obj["id"]}: no requirements')
            require(bool(obj.get('applicability', {}).get('expr')), f'{obj["id"]}: no applicability')
    for scope, group in [('external', external), ('internal', internal)]:
        require(all(i['scope'] == scope for i in group), f'{scope} model scope mismatch')
    for obj in internal:
        endpoints = {obj['source_module'], obj['target_module'], *obj.get('target_modules', [])}
        require(endpoints <= set(obj.get('hld_ref', [])), f'{obj["id"]}: missing endpoint reference')
        for endpoint in endpoints:
            module = next((m for m in arch['modules'] if m['id'] == endpoint), {})
            require(obj['id'] in module.get('interfaces', []), f'{endpoint}: missing interface {obj["id"]}')
    parameter_ids = {p['id'] for p in params['parameters']}
    require({c['config_ref'] for c in arch['config']} == parameter_ids, 'parameter impact coverage mismatch')

    # This checker does not generate canonical models. Compare nonempty source fields
    # against their owner-generated projections, allowing the owner's empty-list removal.
    projections = {'HLD_MODULE': arch['modules'], 'HLD_CONFIG': arch['config'],
                   'HLD_FLOW': arch['flows'], 'HLD_POLICY': arch['policies'],
                   'HLD_PERF': arch['perf'], 'HLD_SAFETY': arch['safety'],
                   'HLD_DECISION': arch['decisions'], 'HLD_VERIFY_HOOK': arch['verify_hooks'],
                   'HLD_CONSTRAINT': arch['constraints'], 'HLD_INTERFACE': external + internal,
                   'HLD_DOMAIN': domains, 'HLD_CDC': paths, 'HLD_GATE': arch['gates']}
    for kind, actual in projections.items():
        normalize = lambda obj: {k: v for k, v in obj.items() if v is not None and v != []}
        ordered = lambda group: sorted((normalize(o) for o in group), key=lambda o: o.get('id', o.get('gate', '')))
        require(ordered(blocks[kind]) == ordered(actual), f'{kind}: source/model mismatch')
    pc_path = workspace / 'reports/quality/param_semantic_check.json'
    bind(pc_path)
    pc = json.loads(pc_path.read_text())
    require(pc['model_sha256'] == sources['model/parameter_space.yaml'], 'stale parameter report')
    require(bool(pc['results']) and all(r['passed'] for r in pc['results']), 'parameter input checks failed')
    bind(workspace / 'scripts/check_hld.py')
    return dict(schema_version='watchdog-hld-author-check/1.0', passed=not errors,
                role='author_check_only', human_gate='G1 ' + gate['status'], errors=errors,
                counts=dict(requirements=len(ids), covered_by_modules=len(covered & ids),
                            modules=len(modules), external_interfaces=len(external),
                            internal_interfaces=len(internal), domains=len(domains),
                            cdc_paths=len(paths), parameters=len(parameter_ids)),
                documents=sizes, source_sha256=sources)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path('.'))
    args = parser.parse_args()
    result = check(args.workspace.resolve())
    report = args.workspace / 'reports/quality'
    report.mkdir(parents=True, exist_ok=True)
    (report / 'hld_check.json').write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    lines = ['# Watchdog HLD 作者检查', '', f'结果：{"PASS" if result["passed"] else "FAIL"}；记录阶段状态为 {result["human_gate"]}，本工具不产生评审批复。', '',
             '检查需求承接、对象引用、参数影响、索引/分册尺寸、META 与五个派生模型一致性以及 PC 证据身份。', '',
             '| 项目 | 数量 |', '|---|---|']
    lines += [f'| {key} | {value} |' for key, value in result['counts'].items()]
    lines += ['', '本检查不证明架构语义正确、RTL 实现一致、CDC 正确或性能达标；详细错误、分册尺寸及输入哈希见 hld_check.json。', '']
    lines += [f'- {error}' for error in result['errors']]
    (report / 'hld_check.md').write_text('\n'.join(lines) + '\n')
    print(json.dumps({k: result[k] for k in ('passed', 'counts', 'errors')}, ensure_ascii=False))
    return int(not result['passed'])


if __name__ == '__main__':
    raise SystemExit(main())
