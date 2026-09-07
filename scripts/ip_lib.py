#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ip_lib.py — AIXSILICON IP registry 公共库（供 build_ip_registry.py / update_registry_readme.py / ip_status.py 复用）

约定（对齐 cbb_repo 框架）：
- `registry.yaml` 为唯一 SSOT（schema_version 2.0），字段：
  id / name / domain / subdomain / type / priority / status / maturity / version / interfaces / description / path
- type:  ip | generator | wrapper | subsystem   （plan.md 第四节 4 类对象）
- status: planned | implemented | released | deprecated
- maturity: experimental | alpha | beta | production | legacy
- implemented/released 条目必须有物理目录（path 存在且包含 README.md / metadata.yaml）
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRY_PATH = os.path.join(ROOT, "registry.yaml")

VALID_TYPE = {"ip", "generator", "wrapper", "subsystem"}
VALID_PRIORITY = {"P0", "P1", "P2", "P3"}
VALID_STATUS = {"planned", "implemented", "released", "deprecated"}
VALID_MATURITY = {"experimental", "alpha", "beta", "production", "legacy"}

REQUIRED_FIELDS = ["id", "name", "domain", "type", "priority", "status", "version", "path"]

# 合法 domain 顶层（plan.md 推荐的 ips/<domain>/<subdomain>/<name>）
VALID_DOMAIN_TOPS = {
    "infrastructure", "system", "memory", "peripheral", "debug_trace", "safety",
    "security", "dft", "chip", "cache", "coherency", "mmu", "virtualization",
    "compute", "high_speed_io", "automotive", "multimedia", "crypto", "analog",
    "phy", "chiplet", "accelerator", "network", "reliability", "test", "subsystem",
}

# ID 前缀（自动编号，按 domain 顶层归类）
ID_PREFIX = {
    "infrastructure": "INF",
    "system": "SYS",
    "memory": "MEM",
    "peripheral": "PER",
    "debug_trace": "DBG",
    "safety": "SAF",
    "security": "SEC",
    "dft": "DFT",
    "chip": "CHP",
    "cache": "CAC",
    "coherency": "COH",
    "mmu": "MMU",
    "virtualization": "VIR",
    "compute": "CPU",
    "high_speed_io": "HSI",
    "automotive": "AUT",
    "multimedia": "MUL",
    "crypto": "CRY",
    "analog": "ANA",
    "phy": "PHY",
    "chiplet": "CHL",
    "accelerator": "AI",
    "network": "NET",
    "reliability": "REL",
    "test": "TST",
    "subsystem": "SUB",
}


def _disp_width(s):
    w = 0
    for ch in str(s):
        if ord(ch) > 0x2E7F:  # CJK 全角
            w += 2
        else:
            w += 1
    return w


def pad(s, width):
    s = str(s)
    return s + " " * max(0, width - _disp_width(s))


def md_table(headers, rows):
    """生成 Markdown 表格源码（按显示宽度对齐）。"""
    cols = list(zip(headers, *rows))
    widths = [max(_disp_width(str(c)) for c in col) for col in cols]
    sep = "|" + "|".join("-" * (w + 2) for w in widths) + "|"
    lines = ["|" + "|".join(" %s " % pad(str(c), w) for c, w in zip(headers, widths)) + "|", sep]
    for r in rows:
        lines.append("|" + "|".join(" %s " % pad(str(c), w) for c, w in zip(r, widths)) + "|")
    return "\n".join(lines)


def load_registry(path=REGISTRY_PATH):
    try:
        import yaml
    except ImportError:
        print("错误: 未找到 pyyaml —— 请用 workflow 根 uv 环境运行（本脚本依赖 yaml 模块）。")
        raise SystemExit(3)
    with open(path, encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not isinstance(data, dict) or not isinstance(data.get("ips"), list):
        raise ValueError("registry.yaml 为空或缺少 ips 列表（文件可能损坏或未正确加载）")
    return data


def validate(reg):
    """返回 (errors, warnings)。errors 非空 → 校验失败。"""
    errors, warnings = [], []
    ips = reg.get("ips", [])
    if not isinstance(ips, list):
        errors.append("ips 必须是列表")
        return errors, warnings
    ids = set()
    for i, e in enumerate(ips):
        if not isinstance(e, dict):
            errors.append("[%d] 条目不是 object" % i)
            continue
        cid = e.get("id")
        if not cid:
            errors.append("[%d] 缺 id" % i)
        elif cid in ids:
            errors.append("id 重复: %s" % cid)
        else:
            ids.add(cid)
        for field in REQUIRED_FIELDS:
            v = e.get(field)
            if v is None or (isinstance(v, str) and not v.strip()):
                errors.append("[%s] 缺必填字段: %s" % (cid or "?", field))
        tp = e.get("type")
        if tp and tp not in VALID_TYPE:
            errors.append("[%s] type 非法: %s" % (cid, tp))
        pr = e.get("priority")
        if pr and pr not in VALID_PRIORITY:
            errors.append("[%s] priority 非法: %s" % (cid, pr))
        st = e.get("status")
        if st and st not in VALID_STATUS:
            errors.append("[%s] status 非法: %s" % (cid, st))
        mt = e.get("maturity", "")
        if mt and mt not in VALID_MATURITY:
            errors.append("[%s] maturity 非法: %s" % (cid, mt))
        dom = e.get("domain", "")
        if dom:
            top = dom.split("/")[0]
            if top not in VALID_DOMAIN_TOPS:
                errors.append("[%s] domain 顶层非法: %s" % (cid, dom))
        p = e.get("path", "")
        vendor_layout = False
        if p:
            parts = p.split("/")
            if len(parts) < 2 or parts[0] != "ips":
                errors.append("[%s] path(%s) 必须以 ips/ 开头" % (cid, p))
            else:
                # ips/<vendor>/<ip>/<version> 布局（vendor 命名空间）或 ips/<domain>/<subdomain>/<name> 布局
                vendor_layout = len(parts) >= 3 and parts[1] in {"aixsilicon", "boyangwang1991-design", "lowrisc"}
                if not vendor_layout and st in ("planned",) and len(parts) >= 4 and parts[1] != (dom.split("/")[0] if dom else "?"):
                    # 纯规划条目应遵循 ips/<domain>/<subdomain>/<name> 布局
                    errors.append("[%s] planned 条目 path(%s) 与 domain(%s) 不一致" % (cid, p, dom))
        if st in ("implemented", "released"):
            if not os.path.isdir(os.path.join(ROOT, p)):
                errors.append("[%s] status=%s 但目录不存在: %s" % (cid, st, p))
        elif st == "planned":
            if p and os.path.isdir(os.path.join(ROOT, p)):
                warnings.append("[%s] status=planned 但目录存在（可能已实现未更新状态）: %s" % (cid, p))
    return errors, warnings
