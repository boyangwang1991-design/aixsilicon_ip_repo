#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ip_status.py — IP 状态查询工具

从 registry.yaml（SSOT）按 优先级/类型/领域/状态 查询 IP，支持 table/csv 输出。

用法:
  python3 scripts/ip_status.py                        # 全部 IP
  python3 scripts/ip_status.py --priority P0          # 按优先级
  python3 scripts/ip_status.py --type generator       # 按类型
  python3 scripts/ip_status.py --domain infrastructure # 按领域（顶层前缀匹配）
  python3 scripts/ip_status.py --status released      # 按状态
  python3 scripts/ip_status.py --name uart            # 按名称模糊匹配
  python3 scripts/ip_status.py --format csv           # CSV 输出
  python3 scripts/ip_status.py --stats                # 状态统计速览

退出码：0=正常；10=校验失败；3=缺少 pyyaml。
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ip_lib import VALID_TYPE, VALID_PRIORITY, VALID_STATUS, md_table, load_registry, validate


def main():
    ap = argparse.ArgumentParser(description="从 registry.yaml 查询 IP 状态")
    ap.add_argument("--priority", choices=sorted(VALID_PRIORITY), help="按优先级过滤")
    ap.add_argument("--type", dest="type_", choices=sorted(VALID_TYPE), help="按类型过滤")
    ap.add_argument("--domain", help="按领域顶层过滤（如 infrastructure / system / memory）")
    ap.add_argument("--status", choices=sorted(VALID_STATUS), help="按状态过滤")
    ap.add_argument("--name", help="按名称模糊匹配（子串）")
    ap.add_argument("--format", choices=["table", "csv"], default="table", help="输出格式")
    ap.add_argument("--stats", action="store_true", help="输出状态统计速览")
    args = ap.parse_args()

    try:
        reg = load_registry()
    except Exception as exc:
        print("ERROR: %s" % exc)
        raise SystemExit(10)
    errors, warnings = validate(reg)
    for e in errors:
        print("ERROR: %s" % e)
    if errors:
        print("==> registry.yaml 校验失败，查询结果可能不可靠。")
        raise SystemExit(10)

    ips = reg.get("ips", [])
    if args.stats:
        by_status = {s: sum(1 for e in ips if e.get("status") == s) for s in VALID_STATUS}
        by_prio = {p: sum(1 for e in ips if e.get("priority") == p) for p in VALID_PRIORITY}
        by_type = {}
        for e in ips:
            tp = e.get("type", "?")
            by_type[tp] = by_type.get(tp, 0) + 1
        print("== 状态统计 ==")
        for s in VALID_STATUS:
            print("  %-12s %d" % (s, by_status[s]))
        print("== 优先级统计 ==")
        for p in VALID_PRIORITY:
            print("  %-3s %d" % (p, by_prio[p]))
        print("== 类型统计 ==")
        for t in sorted(by_type):
            print("  %-10s %d" % (t, by_type[t]))
        print("== 合计 ==")
        print("  共 %d 条" % len(ips))
        return

    result = []
    for e in ips:
        if args.priority and e.get("priority") != args.priority:
            continue
        if args.type_ and e.get("type") != args.type_:
            continue
        if args.domain and not e.get("domain", "").split("/")[0].startswith(args.domain):
            continue
        if args.status and e.get("status") != args.status:
            continue
        if args.name and args.name.lower() not in e.get("name", "").lower():
            continue
        result.append(e)
    result.sort(key=lambda x: (x.get("priority", ""), x.get("id", "")))

    if not result:
        print("（无匹配条目）")
        return
    if args.format == "csv":
        print("id,name,domain,type,priority,status,version")
        for e in result:
            print(",".join([e.get("id", ""), e.get("name", ""), e.get("domain", ""),
                            e.get("type", ""), e.get("priority", ""), e.get("status", ""),
                            str(e.get("version", ""))]))
        return
    rows = [[e.get("id", ""), e.get("name", ""), e.get("domain", ""), e.get("type", ""),
             e.get("priority", ""), e.get("status", ""), str(e.get("version", ""))]
            for e in result]
    print(md_table(["ID", "名称", "领域", "类型", "优先级", "状态", "版本"], rows))
    print()
    print("共 %d 条" % len(result))


if __name__ == "__main__":
    main()
