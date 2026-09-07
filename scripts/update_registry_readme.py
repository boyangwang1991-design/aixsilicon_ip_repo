#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
update_registry_readme.py — 将 registry.yaml（SSOT）状态总览刷新到 README.md

职责（对齐 cbb_repo 框架）：
1. 加载 registry.yaml，统计 status / priority / type / domain 分布；
2. 生成「IP 状态总览」 Markdown 区块（含已交付表 + 优先级/类型/领域统计 + 全量明细）；
3. 就地替换 README.md 中 `<!-- IP-CATALOG-STATUS:BEGIN -->` 与 `<!-- IP-CATALOG-STATUS:END -->`
   之间的内容（无 marker 时退出并提示）。

用法:
  python3 scripts/update_registry_readme.py           # 校验并就地刷新 README.md
  python3 scripts/update_registry_readme.py --dry-run # 仅打印将写入的区块，不写文件
  python3 scripts/update_registry_readme.py --check   # 只读检查 README 是否一致（退出码 1=不一致）

退出码：0=通过/已刷新；10=校验失败；20=用法错误；3=缺少 pyyaml。
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ip_lib import ROOT, VALID_STATUS, md_table, load_registry, validate

# README 中用于刷新的 marker（与 ip_lib 保持一致）
BEGIN_MARKER = "<!-- IP-CATALOG-STATUS:BEGIN -->"
END_MARKER = "<!-- IP-CATALOG-STATUS:END -->"
README_PATH = os.path.join(ROOT, "README.md")


def build_status_section(reg):
    """从 registry 生成状态总览 Markdown 区块（不含 marker）。"""
    ips = reg.get("ips", [])
    total = len(ips)
    by_status = {s: [e for e in ips if e.get("status") == s] for s in VALID_STATUS}
    delivered = by_status["implemented"] + by_status["released"]
    updated = reg.get("updated", "未知")

    lines = []
    lines.append("> 本节由 `scripts/update_registry_readme.py` 依据 `registry.yaml`（SSOT）自动生成。")
    lines.append("> 修改 `registry.yaml` 后必须运行 `python3 scripts/update_registry_readme.py` 刷新本节；勿手工编辑。")
    lines.append("> 最后更新：`%s`" % updated)
    lines.append("")
    lines.append("### 总览")
    lines.append("")
    lines.append(md_table(
        ["指标", "数量"],
        [["总条目（ips）", str(total)],
         ["released（已发布）", str(len(by_status["released"]))],
         ["implemented（已实现/已交付）", str(len(by_status["implemented"]))],
         ["planned（规划候选）", str(len(by_status["planned"]))],
         ["deprecated（已废弃）", str(len(by_status["deprecated"]))],
         ["实现率", "%.1f%%" % (100.0 * len(delivered) / total if total else 0.0)]],
    ))
    lines.append("")

    # 已交付/已发布 IP 表
    lines.append("### 已发布 / 已实现 / 已纳管 IP（%d）" % len(delivered))
    lines.append("")
    if delivered:
        delivered_sorted = sorted(delivered, key=lambda e: e.get("id", ""))
        rows = []
        for e in delivered_sorted:
            rel = e.get("path", "")
            link = ("[%s](%s/README.md)" % (e.get("name", ""), rel)) if rel else e.get("name", "")
            rows.append([e.get("id", ""), link, e.get("type", ""),
                         e.get("priority", ""), e.get("status", ""),
                         e.get("version", ""), e.get("domain", "")])
        lines.append(md_table(["ID", "IP", "类型", "优先级", "状态", "版本", "领域"], rows))
    else:
        lines.append("（当前无已交付 IP）")
    lines.append("")

    # 按优先级分布
    lines.append("### 按优先级分布（released+implemented / planned）")
    lines.append("")
    pr_rows, pr_map = [], {}
    for e in ips:
        pr = e.get("priority", "?")
        pr_map.setdefault(pr, [0, 0])
        if e.get("status") in ("implemented", "released"):
            pr_map[pr][0] += 1
        else:
            pr_map[pr][1] += 1
    for pr in sorted(pr_map):
        imp, pla = pr_map[pr]
        pr_rows.append([pr, str(imp), str(pla), str(imp + pla)])
    lines.append(md_table(["优先级", "已交付", "planned", "合计"], pr_rows))
    lines.append("")

    # 按类型分布
    lines.append("### 按类型分布")
    lines.append("")
    type_counts = {}
    for e in ips:
        tp = e.get("type", "?")
        type_counts[tp] = type_counts.get(tp, 0) + 1
    tp_rows = [[tp, str(type_counts[tp])] for tp in sorted(type_counts)]
    lines.append(md_table(["类型", "数量"], tp_rows))
    lines.append("")

    # 按领域分布
    lines.append("### 按领域分布（顶层 domain）")
    lines.append("")
    dm_counts = {}
    for e in ips:
        dm = e.get("domain", "?").split("/")[0]
        dm_counts[dm] = dm_counts.get(dm, 0) + 1
    dm_rows = [[dm, str(dm_counts[dm])] for dm in sorted(dm_counts)]
    lines.append(md_table(["领域", "数量"], dm_rows))
    lines.append("")

    # 全部 IP 明细（按领域分组）
    lines.append("### 全部 IP 明细（%d，按领域分组）" % total)
    lines.append("")
    by_dom = {}
    for e in ips:
        by_dom.setdefault(e.get("domain", "(未分类)"), []).append(e)
    for dom in sorted(by_dom):
        entries = sorted(by_dom[dom], key=lambda x: x.get("id", ""))
        deliv_n = sum(1 for x in entries if x.get("status") in ("implemented", "released"))
        lines.append("#### %s（%d，已交付=%d）" % (dom, len(entries), deliv_n))
        lines.append("")
        rows = []
        for e in entries:
            rel = e.get("path", "")
            name_cell = ("[%s](%s/README.md)" % (e.get("name", ""), rel)) if rel else e.get("name", "")
            desc = str(e.get("description", "") or "").replace("|", "\\|").replace("\n", " ")
            rows.append([e.get("id", ""), name_cell, e.get("type", ""),
                         e.get("status", ""), e.get("priority", ""),
                         e.get("version", ""), desc])
        lines.append(md_table(["ID", "IP", "类型", "状态", "优先级", "版本", "功能/描述"], rows))
        lines.append("")

    return "\n".join(lines) + "\n"


def refresh_readme(reg, readme_path=README_PATH, dry_run=False):
    with open(readme_path, encoding="utf-8") as f:
        readme = f.read()
    section = build_status_section(reg)
    block = "%s\n%s\n%s" % (BEGIN_MARKER, section, END_MARKER)
    if BEGIN_MARKER in readme and END_MARKER in readme:
        start = readme.index(BEGIN_MARKER)
        end = readme.index(END_MARKER) + len(END_MARKER)
        new_readme = readme[:start] + block + readme[end:]
    else:
        print("错误: README.md 中缺少 %s / %s marker，无法安全定位刷新区。" % (BEGIN_MARKER, END_MARKER))
        print("请在 README.md 中放置该 marker（建议放在「IP 状态总览」章节内）。")
        raise SystemExit(20)
    changed = new_readme != readme
    if not dry_run:
        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(new_readme)
    return changed, new_readme


def main():
    ap = argparse.ArgumentParser(description="将 registry.yaml 状态总览同步到 README.md（派生视图刷新脚本）")
    ap.add_argument("--dry-run", action="store_true", help="只打印将写入的区块，不写文件")
    ap.add_argument("--check", action="store_true", help="只读检查 README 是否与 registry 一致（退出码 1=不一致）")
    args = ap.parse_args()

    try:
        reg = load_registry()
    except Exception as exc:
        print("ERROR: %s" % exc)
        raise SystemExit(10)
    errors, warnings = validate(reg)
    for w in warnings:
        print("  WARN: %s" % w)
    for e in errors:
        print("  ERROR: %s" % e)
    if errors:
        print("==> registry.yaml 校验失败（%d 个错误），不刷新 README。" % len(errors))
        raise SystemExit(10)

    if args.dry_run:
        print(build_status_section(reg))
        return

    changed, _ = refresh_readme(reg, dry_run=args.dry_run)
    if args.check:
        if changed:
            print("==> README.md 状态总览与 registry.yaml 不一致（需要刷新）。")
            raise SystemExit(1)
        print("==> README.md 状态总览与 registry.yaml 一致。")
        return

    if changed:
        delivered = sum(1 for e in reg.get("ips", []) if e.get("status") in ("implemented", "released"))
        print("==> README.md 状态总览已刷新（%d 条，已交付=%d）。" % (len(reg.get("ips", [])), delivered))
    else:
        print("==> README.md 状态总览已是最新，无需变更。")


if __name__ == "__main__":
    main()
