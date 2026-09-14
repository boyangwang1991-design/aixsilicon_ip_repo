#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build_ip_registry.py — AIXSILICON IP registry.yaml 生成 / 校验 / 规范化

职责（对齐 cbb_repo 框架）：
1. registry.yaml 是唯一编辑入口；旧 Python 清单已归档。默认只读校验。
2. 校验（--check）：复用 ip_lib.validate 做一致性检查。
3. 规范化重写（--write）：稳定排序 + 更新 updated 时间戳。

用法:
  python3 scripts/build_ip_registry.py --generate   # 兼容旧入口：仅规范化当前索引，不恢复旧清单
  python3 scripts/build_ip_registry.py --check      # 只读校验 registry.yaml
  python3 scripts/build_ip_registry.py --write      # 校验通过后规范化重写 registry.yaml

退出码：0=通过/已生成；10=校验失败；20=用法错误；3=缺少 pyyaml。
"""
import argparse
import os
import sys
import json
import re
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ip_lib import (ROOT, REGISTRY_PATH, ID_PREFIX, REQUIRED_FIELDS, validate)

ID_MAP_PATH = Path(__file__).parent / "data/ip_ids.json"


def _assign_ids(entries, id_map=None):
    """保留历史编号（含已移除名称），仅为新名称分配编号。"""
    if id_map is None:
        id_map = json.loads(ID_MAP_PATH.read_text(encoding="utf-8"))
    if len(set(id_map.values())) != len(id_map):
        raise ValueError("ip_ids.json 存在重复 ID")
    if any(not re.fullmatch(r"(?:MIG-IP-)?[A-Z]+-\d{3,}", v) for v in id_map.values()):
        raise ValueError("ip_ids.json 存在非法 ID")
    used = set(id_map.values())
    for e in entries:
        top = e["domain"].split("/")[0]
        prefix = ID_PREFIX.get(top, "IP")
        if e["name"] not in id_map:
            number = max([int(v.split("-")[1]) for v in used if v.startswith(prefix + "-")] or [0]) + 1
            id_map[e["name"]] = "%s-%03d" % (prefix, number)
            used.add(id_map[e["name"]])
        e["id"] = id_map[e["name"]]
    return entries


def _assign_paths(entries):
    """派生 path：已交付条目用真实 path；规划条目用 ips/<domain>/<subdomain>/<name>。"""
    for e in entries:
        if e.get("path"):
            continue
        e["path"] = "ips/%s/%s/%s" % (e["domain"], e["subdomain"], e["name"])
    return entries


def build_registry_dict():
    """读取当前索引，包括扩展字段；历史规划不能作为生成输入。"""
    import yaml
    return yaml.safe_load(Path(REGISTRY_PATH).read_text(encoding="utf-8"))


def write_registry(reg):
    """规范化唯一事实源；保留所有扩展字段。"""
    import yaml
    from datetime import datetime, timezone
    reg["updated"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    reg["ips"].sort(key=lambda e: (e.get("priority", ""), e["id"]))
    Path(REGISTRY_PATH).write_text(yaml.safe_dump(reg, allow_unicode=True, sort_keys=False), encoding="utf-8")


def main():
    ap = argparse.ArgumentParser(description="AIXSILICON IP registry.yaml 校验/规范化工具")
    modes = ap.add_mutually_exclusive_group()
    modes.add_argument("--generate", action="store_true",
                    help="兼容入口：规范化当前 registry，不再从旧 Python 清单生成")
    modes.add_argument("--check", action="store_true", help="只读校验 registry.yaml")
    modes.add_argument("--check-source", action="store_true", help="兼容入口：只读校验 registry 与历史编号")
    modes.add_argument("--write", action="store_true", help="校验通过后规范化重写 registry.yaml")
    args = ap.parse_args()

    import yaml  # noqa: F401  (确保依赖存在)

    if not args.generate:
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

    # --generate 兼容旧调用：仅规范化当前 registry，不恢复已移出条目。
    reg = build_registry_dict()
    errors, _ = validate(reg)
    if errors:
        print("\n".join(errors))
        raise SystemExit(10)
    id_map = json.loads(ID_MAP_PATH.read_text(encoding="utf-8"))
    id_map.update({e["name"]: e["id"] for e in reg["ips"]})
    ID_MAP_PATH.write_text(json.dumps(id_map, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    write_registry(reg)
    total = len(reg["ips"])
    impl = sum(1 for e in reg["ips"] if e.get("status") in ("implemented", "released"))
    print("==> registry.yaml 已生成：共 %d 条（implemented/released=%d）" % (total, impl))


if __name__ == "__main__":
    main()
