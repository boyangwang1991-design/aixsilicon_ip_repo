#!/usr/bin/env python3
"""Validate LLD source/model references and RDL field coverage; no gate approval."""
import argparse
import hashlib
import json
import re
from collections import defaultdict
from pathlib import Path

import yaml
from systemrdl import RDLCompiler
from systemrdl.node import FieldNode


def check(workspace):
    errors, sizes, sources = [], [], {}
    blocks = defaultdict(list)

    def require(ok, message):
        if not ok:
            errors.append(message)

    def bind(path):
        sources[str(path.relative_to(workspace))] = hashlib.sha256(path.read_bytes()).hexdigest()

    def model(name):
        path = workspace / 'model' / (name + '.yaml')
        bind(path)
        return yaml.safe_load(path.read_text())

    lld = model('micro_design')
    hld = model('architecture')
    req = model('requirements')
    params = model('parameter_space')
    external, internal = [model(scope + '_interface')['interfaces'] for scope in ('external', 'internal')]
    domains, crossings = model('clock_domains')['domains'], model('cdc_paths')['paths']
    req_ids = {r['id'] for r in req['requirements']}
    hld_modules = {m['id'] for m in hld['modules']}
    hld_ids = {o['id'] for v in hld.values() if isinstance(v, list) for o in v if isinstance(o, dict) and 'id' in o}
    hld_ids.update(o['id'] for o in external + internal + domains + crossings)
    pages = sorted((workspace / 'docs/lld').glob('*.md'))
    index = (workspace / 'docs/lld/index.md').read_text()
    for path in pages:
        bind(path)
        content = path.read_text()
        matches = re.findall(r'<!-- ((?:LLD_\w+|RTL_MAP))_META\s*\n(.*?)END_\1_META -->', content, re.S)
        for kind, payload in matches:
            blocks[kind].append(yaml.safe_load(payload))
        size = dict(file=path.name, lines=len(content.splitlines()), meta=len(matches))
        sizes.append(size)
        require(size['lines'] <= 450 and size['meta'] <= 20, f'{path.name}: hard split limit exceeded')
        require(size['lines'] < 300 and size['meta'] < 12, f'{path.name}: splitting evaluation required')
        require(path.name == 'index.md' or f'({path.name})' in index, f'index missing {path.name}')
        for target in re.findall(r'\]\(([^)#]+)(?:#[^)]*)?\)', content):
            if '://' not in target:
                require((path.parent / target).exists(), f'{path.name}: missing link {target}')
    require(len(blocks['LLD_DOC']) == 1 and len(blocks['LLD_GATE']) == 1, 'need one document header and one gate')
    require(hld['gates'][0]['status'] == 'pass' and hld['gates'][0]['architecture_freeze'], 'G1 not frozen')
    require(lld['hld_baseline'] == hld['architecture_baseline'], 'HLD baseline mismatch')
    require(lld['lrs_baseline'] == req['requirement_baseline'], 'LRS baseline mismatch')
    for approval in hld['gates'][0].get('approvals', []):
        path = workspace / approval.get('evidence', '')
        require(path.is_file(), 'missing G1 approval evidence')
        if path.is_file():
            bind(path)
    require(bool(hld['gates'][0].get('approvals')), 'G1 approval record absent')
    objects = [o for v in blocks.values() for o in v if 'id' in o]
    lld_ids = {o['id'] for o in objects}
    require(len(lld_ids) == len(objects), 'duplicate LLD IDs')
    module_ids = {m['id'] for m in lld['modules']}
    allocation = defaultdict(list)
    for module in lld['modules']:
        for reference in module['hld_ref']:
            allocation[reference].append(module['id'])
    require(set(allocation) == hld_modules and all(len(v) == 1 for v in allocation.values()), 'HLD modules not uniquely allocated')
    covered = {r for m in lld['modules'] for r in m.get('req_ref', [])}
    require(covered == req_ids, 'LLD module requirement coverage mismatch')
    interface_refs = {r for obj in lld['interfaces'] for r in obj['hld_ref']}
    require(interface_refs == {i['id'] for i in external + internal}, 'HLD interface coverage mismatch')
    refs = {'req_ref': req_ids, 'hld_ref': hld_ids, 'module_ref': module_ids,
            'owner_module': module_ids, 'parent_ref': module_ids | hld_modules,
            'interface_ref': {i['id'] for i in lld['interfaces']}, 'design_ref': lld_ids,
            'protected_objects': lld_ids, 'affected_objects': lld_ids,
            'implements': lld_ids, 'clock_domain': hld_ids, 'reset_domain': hld_ids,
            'source_domain': hld_ids, 'destination_domain': hld_ids}
    for obj in objects:
        for field, valid in refs.items():
            values = obj.get(field, [])
            values = values if isinstance(values, list) else [values]
            for value in values:
                require(value in valid, f'{obj["id"]}.{field}: unknown {value}')
    for fsm in lld['fsms']:
        for field in ('encoding', 'reset_state', 'states', 'transitions', 'illegal_state_handling'):
            require(bool(fsm.get(field)), f'{fsm["id"]}: missing {field}')
    for interface in lld['interfaces']:
        require(bool(interface.get('signals')), f'{interface["id"]}: missing signals')
        for signal in interface.get('signals', []):
            require(all(signal.get(k) for k in ('name', 'width', 'direction', 'stability')), f'{interface["id"]}: incomplete signal')
    mapped = {r for item in lld['rtl_map'] for r in item['implements']}
    design_ids = lld_ids - {r['id'] for r in lld['rtl_map']}
    require(mapped == design_ids, f'RTL mapping missing={sorted(design_ids-mapped)}, unknown={sorted(mapped-design_ids)}')

    rdl_path = workspace / 'regs/watchdog.rdl'
    bind(rdl_path)
    compiler = RDLCompiler()
    compiler.compile_file(str(rdl_path))
    top = compiler.elaborate().top
    fields = {re.sub(r'\[\d*\]', '[]', n.get_path()): n for n in top.descendants(unroll=False) if isinstance(n, FieldNode)}
    reg_refs = [r['register_ref'] for r in lld['registers']]
    require(set(reg_refs) == set(fields), f'RDL behavior coverage missing={sorted(set(fields)-set(reg_refs))}, unknown={sorted(set(reg_refs)-set(fields))}')
    require(len(reg_refs) == len(set(reg_refs)), 'duplicate register behavior assignment')
    for register in lld['registers']:
        for key in ('behavior', 'sw_behavior', 'hw_behavior', 'collision', 'update_timing', 'reset_semantics'):
            require(bool(register.get(key)), f'{register["id"]}: missing {key}')
        field = fields.get(register['register_ref'])
        if field is not None:
            expected = 'RW' if field.is_sw_readable and field.is_sw_writable else 'RO' if field.is_sw_readable else 'WO'
            require(register['sw_behavior'].startswith(expected), f'{register["id"]}: RDL access mismatch')

    projections = {'LLD_MODULE':'modules','LLD_INTERFACE':'interfaces','LLD_TIMING':'timing',
                   'LLD_DATAPATH':'datapaths','LLD_PIPELINE':'pipelines','LLD_BUFFER':'buffers',
                   'LLD_FSM':'fsms','LLD_ARB':'arbiters','LLD_ORDER':'ordering','LLD_REG':'registers',
                   'LLD_RESET':'reset','LLD_CDC':'cdc','LLD_IRQ':'interrupts','LLD_ERROR':'errors',
                   'LLD_SAFETY':'safety','LLD_PPA':'ppa','LLD_DECISION':'decisions',
                   'LLD_VERIFY_HOOK':'verify_hooks','RTL_MAP':'rtl_map','LLD_GATE':'gates'}
    def normalize(obj):
        result = {k:v for k,v in obj.items() if v is not None and v != []}
        if 'parent_ref' in result and isinstance(result['parent_ref'], str):
            result['parent_ref'] = [result['parent_ref']]
        return result
    for kind, key in projections.items():
        order = lambda group: sorted((normalize(o) for o in group), key=lambda o:o.get('id',o.get('gate','')))
        require(order(blocks[kind]) == order(lld[key]), f'{kind}: source/model mismatch')
    bind(workspace / 'scripts/check_lld.py')
    return dict(schema_version='watchdog-lld-author-check/1.0', role='author_check_only',
                passed=not errors, gate='G2 open; no approval inferred', errors=errors,
                counts=dict(requirements=len(req_ids),covered=len(covered & req_ids),modules=len(module_ids),
                            interfaces=len(lld['interfaces']),register_fields=len(fields),fsms=len(lld['fsms']),
                            cdc_paths=len(lld['cdc']),parameters=len(params['parameters']),objects=len(objects)),
                documents=sizes,source_sha256=sources)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path('.'))
    args = parser.parse_args()
    result = check(args.workspace.resolve())
    report = args.workspace / 'reports/quality'
    report.mkdir(parents=True, exist_ok=True)
    (report/'lld_check.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    lines = ['# Watchdog LLD 作者检查','',f'结果：{"PASS" if result["passed"] else "FAIL"}；不是 G2 架构/RTL/DV 评审批复。','',
             '核对六个 HLD 模块、接口、需求、对象引用、RDL 字段行为和访问属性、RTL 映射、分册索引与模型一致性。','',
             '| 项目 | 数量 |','|---|---|']
    lines += [f'| {k} | {v} |' for k,v in result['counts'].items()]
    lines += ['', '本检查不证明 RTL 符合 LLD、周期语义正确、安全覆盖或 PPA 达标；输入身份及完整错误见 lld_check.json。','']
    lines += ['- '+error for error in result['errors']]
    (report/'lld_check.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({k:result[k] for k in ('passed','counts','errors')},ensure_ascii=False))
    return int(not result['passed'])


if __name__ == '__main__':
    raise SystemExit(main())
