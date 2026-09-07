#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_ip_registry.py — AIXSILICON IP registry.yaml 生成 / 校验 / 规范化

职责（对齐 cbb_repo 框架）：
1. 生成 registry.yaml（SSOT）：消费 scripts/data/*.py 清单 + 已交付覆盖，
   自动分配 ID（按 domain 顶层前缀 + 序号）并计算 path（ips/<domain>/<subdomain>/<name>）。
2. 校验（--check）：复用 ip_lib.validate 做一致性检查。
3. 规范化重写（--write）：稳定排序 + 更新 updated 时间戳。

用法:
  python3 scripts/build_ip_registry.py --generate   # 依据 data/*.py 生成 registry.yaml（默认）
  python3 scripts/build_ip_registry.py --check      # 只读校验 registry.yaml
  python3 scripts/build_ip_registry.py --write      # 校验通过后规范化重写 registry.yaml

退出码：0=通过/已生成；10=校验失败；20=用法错误；3=缺少 pyyaml。
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ip_lib import (ROOT, REGISTRY_PATH, ID_PREFIX, REQUIRED_FIELDS, validate)

try:
    from data import all_ip_entries
except ImportError as exc:  # pragma: no cover
    print("错误: 无法导入 scripts/data 清单数据：%s" % exc)
    raise SystemExit(20)


def _assign_ids(entries):
    """按 domain 顶层前缀 + 序号分配稳定 ID。"""
    counters = {}
    for e in entries:
        top = e["domain"].split("/")[0]
        prefix = ID_PREFIX.get(top, "IP")
        counters[prefix] = counters.get(prefix, 0) + 1
        e["id"] = "%s-%03d" % (prefix, counters[prefix])
    return entries


def _assign_paths(entries):
    """派生 path：已交付条目用真实 path；规划条目用 ips/<domain>/<subdomain>/<name>。"""
    for e in entries:
        if e.get("path"):
            continue
        e["path"] = "ips/%s/%s/%s" % (e["domain"], e["subdomain"], e["name"])
    return entries


def build_registry_dict():
    entries = all_ip_entries()
    entries = _assign_ids(entries)
    entries = _assign_paths(entries)
    entries.sort(key=lambda e: (e.get("priority", ""), e.get("id", "")))
    return {"schema_version": "2.0", "vendor": "aixsilicon", "library": "ip",
            "ips": entries}


def write_registry(reg):
    import yaml
    from datetime import datetime, timezone
    reg["updated"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    lines = []
    lines.append('schema_version: "%s"' % reg.get("schema_version", "2.0"))
    lines.append('updated: "%s"' % reg["updated"])
    lines.append("# 本文件是 AIXSILICON IP 目录唯一 SSOT（由 scripts/build_ip_registry.py 治理）。")
    lines.append("# 字段: id/name/domain/subdomain/type/priority/status/maturity/version/interfaces/description/path")
    lines.append("# 修改入口: 编辑 scripts/data/*.py 清单后运行 'python3 scripts/build_ip_registry.py --generate' 重新生成。")
    lines.append("# status=implemented/released 表示物理目录存在且已交付；planned 条目仅为规划候选。")
    lines.append("vendor: aixsilicon")
    lines.append("library: ip")
    lines.append("")
    lines.append("ips:")
    for e in reg["ips"]:
        lines.append("  - id: %s" % e["id"])
        lines.append("    name: %s" % e["name"])
        lines.append("    domain: %s" % e["domain"])
        lines.append("    subdomain: %s" % e["subdomain"])
        lines.append("    type: %s" % e["type"])
        lines.append("    priority: %s" % e["priority"])
        lines.append("    status: %s" % e["status"])
        lines.append("    maturity: %s" % e["maturity"])
        lines.append('    version: "%s"' % e["version"])
        ifs = e.get("interfaces") or []
        if ifs:
            lines.append("    interfaces: [%s]" % ", ".join(ifs))
        lines.append("    description: '%s'" % str(e["description"]).replace("'", "''"))
        lines.append("    path: %s" % e["path"])
        if e.get("vendor") and e["vendor"] != "aixsilicon":
            lines.append("    vendor: %s" % e["vendor"])
        if e.get("core"):
            lines.append("    core: %s" % e["core"])
    with open(REGISTRY_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser(description="AIXSILICON IP registry.yaml 生成/校验/规范化工具")
    ap.add_argument("--generate", action="store_true",
                    help="依据 scripts/data/*.py 生成 registry.yaml（默认行为）")
    ap.add_argument("--check", action="store_true", help="只读校验 registry.yaml")
    ap.add_argument("--write", action="store_true", help="校验通过后规范化重写 registry.yaml")
    args = ap.parse_args()

    import yaml  # noqa: F401  (确保依赖存在)

    if args.check or args.write:
        with open(REGISTRY_PATH, encoding="utf-8") as f:
            reg = yaml.safe_load(f)
        errors, warnings = validate(reg)
        ips = reg.get("ips", [])
        implemented = sum(1 for e in ips if e.get("status") in ("implemented", "released"))
        print("registry.yaml: 共 %d 条（implemented/released=%d）" % (len(ips), implemented))
        for w in warnings:
            print("  WARN: %s" % w)
        for e in errors:
            print("  ERROR: %s" % e)
        if errors:
            print("==> 校验失败（%d 个错误）。不做任何写入。" % len(errors))
            raise SystemExit(10)
        if args.write:
            write_registry(reg)
            print("==> registry.yaml 已规范化重写")
        else:
            print("==> 校验通过（只读，未写入）。")
        return

    # 默认：生成
    reg = build_registry_dict()
    write_registry(reg)
    total = len(reg["ips"])
    impl = sum(1 for e in reg["ips"] if e.get("status") in ("implemented", "released"))
    print("==> registry.yaml 已生成：共 %d 条（implemented/released=%d）" % (total, impl))


if __name__ == "__main__":
    main()
