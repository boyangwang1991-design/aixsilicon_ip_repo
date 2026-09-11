#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ip_catalog_data — 聚合 P0/P1/P2/P3 清单及已交付 IP 覆盖。

已交付/已纳管 IP（status=implemented/released）覆盖 planned 条目，注入真实
version / path / core / maturity（由 build_ip_registry.py 消费）。
"""

from .ip_catalog_p0a import IP_LIST as P0A
from .ip_catalog_p0b import IP_LIST as P0B
from .ip_catalog_p1a import IP_LIST as P1A
from .ip_catalog_p1b import IP_LIST as P1B
from .ip_catalog_p2a import IP_LIST as P2A
from .ip_catalog_p2b import IP_LIST as P2B
from .ip_catalog_p3a import IP_LIST as P3A
from .ip_catalog_p3b import IP_LIST as P3B

# (priority, [条目...]) 有序
PRIORITY_LISTS = [
    ("P0", P0A + P0B),
    ("P1", P1A + P1B),
    ("P2", P2A + P2B),
    ("P3", P3A + P3B),
]

# 已交付 / 已纳管 IP 覆盖（key=name）
# 每条：vendor/version/status/maturity/path/core/description（覆盖或补充清单条目）
#
# 注意：status 必须与物理目录实态一致（registry 校验会检查目录存在性）。
# 当前实际落盘 IP：ips/boyangwang1991-design/uart/0.1.0（released）。
# hac_aes / lowrisc_* 目录未落盘（gitignore 或未同步），暂标记 planned，
# 待目录落盘后再置为 implemented/released。
IMPLEMENTED_OVERRIDES = {
    "apb_secure_demux": {
        "version": "1.0.0", "status": "planned", "maturity": "experimental",
        "path": "ips/infrastructure/apb/apb_secure_demux",
    },
    "spi_master": {
        "vendor": "aixsilicon", "version": "1.0.0", "status": "implemented",
        "maturity": "experimental", "interfaces": ["apb4", "spi"],
        "path": "ips/peripheral/serial/spi_master",
        "core": "aixsilicon:ip:spi_master:1.0.0",
        "description": "APB4 队列式 SPI master（四模式、暂停/中止，已完成仿真与 28nm 综合；候选实现，未量产冻结）",
    },
    "apb_demux": {
        "version": "1.0.0", "status": "implemented", "maturity": "experimental",
        "path": "ips/infrastructure/apb/apb_demux",
        "description": "APB Demux（1→N APB Router）",
    },
    "uart": {
        "vendor": "boyangwang1991-design", "version": "0.1.0", "status": "planned",
        "maturity": "beta", "path": "ips/boyangwang1991-design/uart/0.1.0",
        "core": "boyangwang1991-design:ip:uart:0.1.0",
        "description": "通用 UART（APB 接口，含 CSR/RX/TX，G0-G5 曾通过；工作区目录未落盘，待恢复）",
    },
    "hac_aes": {
        "vendor": "aixsilicon", "version": "0.1.0", "status": "planned",
        "maturity": "experimental", "path": "ips/aixsilicon/hac_aes/0.1.0",
        "core": "aixsilicon:ip:hac_aes:0.1.0",
        "description": "HAC Golden Example A - 小型 AES/CRC 核（Profile HAC-P0, CTRL + EVENT）",
    },
    "lowrisc_prim": {
        "vendor": "lowrisc", "version": "0.1.0", "status": "planned",
        "maturity": "production", "path": "ips/lowrisc/prim/0.1.0",
        "core": "lowrisc:ip:prim:0.1.0",
        "description": "OpenTitan primitives（secded ECC / ram / rom / cdc / sha2 / trivium 等）",
    },
    "lowrisc_tlul": {
        "vendor": "lowrisc", "version": "0.1.0", "status": "planned",
        "maturity": "production", "path": "ips/lowrisc/tlul/0.1.0",
        "core": "lowrisc:ip:tlul:0.1.0",
        "description": "OpenTitan TileLink-UL 总线组件（socket / adapter / fifo / jtag_dtm 等）",
    },
    "lowrisc_testlib": {
        "vendor": "lowrisc", "version": "1.0.0", "status": "planned",
        "maturity": "production", "path": "ips/lowrisc/testlib/1.0.0",
        "core": "lowrisc:ip:testlib:1.0.0",
        "description": "OpenTitan 测试库（dummy 仿真单元）",
    },
    "lowrisc_top": {
        "vendor": "lowrisc", "version": "0.1.0", "status": "planned",
        "maturity": "production", "path": "ips/lowrisc/top/0.1.0",
        "core": "lowrisc:ip:top:0.1.0",
        "description": "OpenTitan top 常量/包",
    },
}


def all_ip_entries():
    """返回所有 IP 条目（含已交付覆盖），按 (priority, name) 排序。"""
    entries = []
    seen = {}
    for priority, lst in PRIORITY_LISTS:
        for e in lst:
            key = e["name"]
            base = dict(e)
            base["priority"] = priority
            base["status"] = "planned"
            base["maturity"] = "alpha"
            base["version"] = "0.1.0"
            if key in IMPLEMENTED_OVERRIDES:
                base.update(IMPLEMENTED_OVERRIDES[key])
            if key in seen:
                # 已交付覆盖应优先（例如 uart 已在 peripheral 清单中）
                continue
            seen[key] = base
            entries.append(base)

    # 追加清单中未出现的已交付 IP（如 lowrisc_*）
    listed_names = {e["name"] for e in entries}
    for key, ov in IMPLEMENTED_OVERRIDES.items():
        if key in listed_names:
            continue
        domain = "memory" if key.startswith("lowrisc") else "system"
        sub = "prim" if key == "lowrisc_prim" else (
            "tlul" if key == "lowrisc_tlul" else "testlib")
        if key == "lowrisc_top":
            domain, sub = "system", "top"
        entries.append({
            "name": key, "type": "ip", "domain": domain, "subdomain": sub,
            "interfaces": [], "priority": "P0", **ov,
        })

    entries.sort(key=lambda e: (e.get("priority", ""), e.get("name", "")))
    return entries
