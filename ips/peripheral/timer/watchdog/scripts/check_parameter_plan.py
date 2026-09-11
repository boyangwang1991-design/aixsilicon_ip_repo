#!/usr/bin/env python3
"""Check resolved watchdog PC inputs against LRS configuration semantics.

This checks configuration data, not RTL execution or parameter-space coverage.
Run from the IP directory using the workflow root uv environment.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import jsonschema
import yaml


def validate(values, parameters):
    errors = []
    for p in parameters:
        name = p['name']
        if name not in values:
            errors.append(f'{name}: missing')
            continue
        value, domain = values[name], p['domain']
        if p['type'] == 'int':
            if type(value) is not int:
                errors.append(f'{name}: expected integer')
            elif isinstance(domain, list) and value not in domain:
                errors.append(f'{name}: outside enum')
            elif isinstance(domain, dict) and 'max' in domain and not domain['min'] <= value <= domain['max']:
                errors.append(f'{name}: outside bounds')
        elif p['type'] == 'array':
            try:
                jsonschema.validate(value, p['schema'])
            except jsonschema.ValidationError as exc:
                errors.append(f'{name}: {exc.message}')
    if errors:
        return errors
    channels, clients = values['NUM_CHANNELS'], values['NUM_CLIENTS']
    width, pw, sw = values['COUNTER_WIDTH'], values['PRESCALE_WIDTH'], values['SOURCE_WIDTH']
    for name in ('AUTO_START_MASK', 'NO_STOP_MASK', 'HARD_CFG_LOCK_MASK'):
        if not 0 <= values[name] < (1 << channels):
            errors.append(f'{name}: references unimplemented channel')
    if len(values['DEFAULT_CFG']) != channels:
        errors.append('DEFAULT_CFG: array length differs from NUM_CHANNELS')
    for ch, cfg in enumerate(values['DEFAULT_CFG']):
        def reject(condition, message):
            if condition:
                errors.append(f'DEFAULT_CFG[{ch}]: {message}')
        reject(cfg['SERVICE_MODE'] >= 2 and not values['SUPPORT_TOKEN_QA'], 'unsupported token/QA')
        reject(cfg['SUP_MODE'] != 0 and not values['SUPPORT_SUPERVISION'], 'unsupported supervision')
        reject(cfg['SERVICE_PATH'] and not values['SUPPORT_HW_EVENT'], 'unsupported hardware path')
        for name in ('WIN_MIN', 'TIMEOUT', 'PRETIMEOUT', 'BOOT_TIMEOUT'):
            reject(cfg[name] >= 1 << width, f'{name} exceeds counter width')
        reject(cfg['PRESCALE'] >= 1 << pw, 'PRESCALE exceeds width')
        reject(cfg['TIMEOUT'] == 0 or cfg['SEQ_LIMIT'] == 0, 'zero timeout/sequence limit')
        reject(not 0 < cfg['REQUIRE_MASK'] < 1 << clients, 'invalid client mask')
        reject(cfg['WIN_MIN'] >= cfg['TIMEOUT'] if cfg['WIN_EN'] else cfg['WIN_MIN'] != 0, 'invalid window')
        reject(not cfg['WIN_MIN'] <= cfg['PRETIMEOUT'] < cfg['TIMEOUT'] if cfg['PREWARN_EN'] else cfg['PRETIMEOUT'] != 0, 'invalid pretimeout')
        reject(cfg['BOOT_TIMEOUT'] == 0 if cfg['BOOT_EN'] else cfg['BOOT_TIMEOUT'] != 0, 'invalid boot timeout')
        reject(cfg['SUP_MODE'] == 0 and cfg['REQUIRE_MASK'] != 1, 'SINGLE mask must be 1')
        reject(cfg['SUP_MODE'] == 2 and cfg['WIN_EN'], 'ALIVE cannot enable window')
        reject(cfg['SUP_MODE'] == 3 and cfg['SERVICE_MODE'] != 0, 'FLOW requires service encoding 0')
        required = 0x3c2 | (0x1c if values['SAFETY_EN'] else 0)
        reject(cfg['FAULT_POLICY'] & required != required or cfg['FAULT_POLICY'] & ~0x7fe != 0, 'invalid mandatory fault policy')
        reject(cfg['RECOVERY_LIMIT'] > 255, 'recovery limit exceeds 255')
        if cfg['RESPONSE_MODE'] == 0:
            reject(any(cfg[k] for k in ('LOCAL_DELAY', 'FINAL_DELAY', 'ALLOW_LOCAL_RECOVERY', 'RECOVERY_LIMIT')), 'direct response has local recovery settings')
        else:
            reject(cfg['FINAL_DELAY'] <= cfg['LOCAL_DELAY'], 'final delay must exceed local delay')
            reject(cfg['RECOVERY_LIMIT'] == 0 if cfg['ALLOW_LOCAL_RECOVERY'] else cfg['RECOVERY_LIMIT'] != 0, 'inconsistent recovery enable/limit')
        overrides = {}
        for entry in cfg['CLIENT_OVERRIDES']:
            idx = entry['client']
            reject(idx in overrides or idx >= clients, 'duplicate/unimplemented client override')
            overrides[idx] = entry['values']
        for idx in range(clients):
            if not (cfg['REQUIRE_MASK'] >> idx) & 1:
                continue
            client = overrides.get(idx, cfg['CLIENT_DEFAULT'])
            reject(client['OWNER_SOURCE'] >= 1 << sw, 'source id exceeds width')
            if cfg['SUP_MODE'] == 2:
                reject(not 1 <= client['MIN_ALIVE'] <= client['MAX_ALIVE'] <= 65535, 'invalid ALIVE limits')
            if cfg['SUP_MODE'] == 3:
                reject(not 1 <= client['LAST_STEP'] <= 255, 'invalid last checkpoint')
                reject(not 0 <= client['DEADLINE_MIN'] < client['DEADLINE_MAX'] < 1 << width, 'invalid deadline')
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', type=Path, default=Path('.'))
    args = parser.parse_args()
    workspace = args.workspace.resolve()
    source = workspace / 'model/parameter_space.yaml'
    data = yaml.safe_load(source.read_text())
    results = []
    for case in data['support_matrix']['configs']:
        errors = validate(case['params'], data['parameters'])
        expected = case.get('expect_fail', {})
        passed = bool(errors) if expected.get('stage') == 'Schema' else not errors
        if expected and expected.get('stage') != 'Schema':
            passed = False  # An elaboration negative needs the actual EDA stage.
        results.append(dict(id=case['id'], passed=passed, rejected=bool(errors), expected=expected, diagnostics=errors))
    report = workspace / 'reports/quality'
    report.mkdir(parents=True, exist_ok=True)
    identity = {'model_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
    (report / 'param_semantic_check.json').write_text(json.dumps(dict(schema_version='watchdog-pc-check/1.0', **identity, results=results), ensure_ascii=False, indent=2)+'\n')
    count = sum(r['passed'] for r in results)
    lines = ['# Watchdog 参数合同语义校验', '', f'{count}/{len(results)} 项符合预期。仅证明输入合同/Schema，不证明 RTL 或多配置执行通过。', '', f'模型 SHA-256：`{identity["model_sha256"]}`', '', '| config_id | 输入处理 | 计划预期 | 结果 |', '|---|---|---|---|']
    for r in results:
        lines.append(f'| {r["id"]} | {"拒绝" if r["rejected"] else "接受"} | {r["expected"].get("stage", "合法配置")} | {"PASS" if r["passed"] else "FAIL"} |')
    lines += ['', '逐项诊断和工具源码哈希见 param_semantic_check.json。逻辑字段规则来自冻结 LRS §配置/寄存器/服务/监督；项目校验独立于 RTL validate_config 实现。', '']
    (report / 'param_semantic_check.md').write_text('\n'.join(lines))
    print(f'PC semantic checks: {count}/{len(results)} match expected result')
    return int(count != len(results))


if __name__ == '__main__':
    raise SystemExit(main())
