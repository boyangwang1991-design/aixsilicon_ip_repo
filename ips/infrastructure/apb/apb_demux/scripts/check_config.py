#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""check_config.py — APB Demux 配置合法性校验脚本

对应 LRS CONS 01.001-006 需求：在编译/综合前检查参数配置合法性，
避免非法配置进入 RTL。

用法:
    uv run python scripts/check_config.py \
      --num-slaves 4 --addr-width 32 --data-width 32 \
      --base-addr 0x40000000,0x40001000,0x40002000,0x40003000 \
      --addr-mask 0xfffff000,0xfffff000,0xfffff000,0xfffff000 \
      [--timeout-enable] [--timeout-cycles 16]

    # 从 YAML 读取参数空间配置
    uv run python scripts/check_config.py --config model/parameter_space.yaml --config-id CFG_BASE

退出码：0=通过；1=校验失败。
"""

from __future__ import annotations

import argparse
import sys
from typing import Any

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None


class ConfigError(Exception):
    pass


def parse_int_list(raw: str | None) -> list[int]:
    if not raw:
        return []
    return [int(x.strip(), 0) for x in raw.split(",") if x.strip()]


def validate_config(
    num_slaves: int,
    addr_width: int,
    data_width: int,
    base_addr: list[int],
    addr_mask: list[int],
    timeout_enable: bool = False,
    timeout_cycles: int = 16,
    output_register: bool = False,
    apb_profile: bool = True,
) -> list[str]:
    """校验配置，返回错误列表（空=通过）。"""
    errors: list[str] = []

    # CFG-001: NUM_SLAVES > 0
    if num_slaves <= 0:
        errors.append("CFG-001: NUM_SLAVES 必须 > 0")

    # CFG-002: 所有地址在 ADDR_WIDTH 范围内
    max_addr = 1 << addr_width
    for i, base in enumerate(base_addr):
        if not (0 <= base < max_addr):
            errors.append(f"CFG-002: BASE_ADDR[{i}] 超出 ADDR_WIDTH 范围")
    for i, mask in enumerate(addr_mask):
        if not (0 <= mask < max_addr):
            errors.append(f"CFG-002: ADDR_MASK[{i}] 超出 ADDR_WIDTH 范围")

    # CFG-003: 地址区域不重叠
    windows = []
    for i, (base, mask) in enumerate(zip(base_addr, addr_mask)):
        windows.append((i, base, mask))
    for idx in range(len(windows)):
        for jdx in range(idx + 1, len(windows)):
            i, b1, m1 = windows[idx]
            j, b2, m2 = windows[jdx]
            # 区间 [b1, b1|~m1] 与 [b2, b2|~m2] 是否重叠
            end1 = b1 | (~m1 & ((1 << addr_width) - 1))
            end2 = b2 | (~m2 & ((1 << addr_width) - 1))
            if not (end1 < b2 or end2 < b1):
                errors.append(
                    f"CFG-003: 地址窗口 [{i}] 与 [{j}] 重叠"
                )

    # CFG-004: power-of-two 窗口 + 基地址对齐
    for i, (base, mask) in enumerate(zip(base_addr, addr_mask)):
        size = (~mask & ((1 << addr_width) - 1)) + 1
        if size & (size - 1) != 0:
            errors.append(f"CFG-004: 地址窗口 [{i}] 大小非 power-of-two")
        elif base % size != 0:
            errors.append(f"CFG-004: BASE_ADDR[{i}] 未按 size 对齐")

    # CFG-005: 数组长度一致
    if len(base_addr) != num_slaves:
        errors.append(
            f"CFG-005: BASE_ADDR 数组长度 {len(base_addr)} != NUM_SLAVES {num_slaves}"
        )
    if len(addr_mask) != num_slaves:
        errors.append(
            f"CFG-005: ADDR_MASK 数组长度 {len(addr_mask)} != NUM_SLAVES {num_slaves}"
        )

    # CFG-006: TIMEOUT_CYCLES 合法
    if timeout_enable and timeout_cycles <= 0:
        errors.append("CFG-006: TIMEOUT_ENABLE=1 时 TIMEOUT_CYCLES 必须 > 0")

    # 附加：data_width 合法
    if data_width not in (8, 16, 32, 64, 128):
        errors.append(f"DATA_WIDTH={data_width} 不在合法值域 [8,16,32,64,128]")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="APB Demux 配置校验")
    parser.add_argument("--num-slaves", type=int, default=4)
    parser.add_argument("--addr-width", type=int, default=32)
    parser.add_argument("--data-width", type=int, default=32)
    parser.add_argument("--base-addr", type=str, default="")
    parser.add_argument("--addr-mask", type=str, default="")
    parser.add_argument("--timeout-enable", action="store_true")
    parser.add_argument("--timeout-cycles", type=int, default=16)
    parser.add_argument("--output-register", action="store_true")
    parser.add_argument("--apb-profile", action="store_true", default=True)
    parser.add_argument("--config", type=str, default="", help="parameter_space.yaml 路径")
    parser.add_argument("--config-id", type=str, default="", help="命名配置 ID")
    args = parser.parse_args()

    # 从 parameter_space.yaml 读取命名配置
    if args.config and args.config_id:
        if yaml is None:
            print("ERROR: 需要 pyyaml", file=sys.stderr)
            return 3
        data = yaml.safe_load(open(args.config, encoding="utf-8"))
        cfg = next(
            (c for c in data.get("configurations", []) if c["id"] == args.config_id), None
        )
        if cfg is None:
            print(f"ERROR: 未找到配置 {args.config_id}", file=sys.stderr)
            return 1
        v = cfg["values"]
        base_addr = parse_int_list(args.base_addr)
        addr_mask = parse_int_list(args.addr_mask)
        if not base_addr:
            # 若未提供地址，使用 0x4000_0000 + i*0x1000 示例
            n = int(v.get("NUM_SLAVES", 4))
            base_addr = [0x4000_0000 + i * 0x1000 for i in range(n)]
            addr_mask = [0xFFFF_F000] * n
        errors = validate_config(
            num_slaves=int(v.get("NUM_SLAVES", 4)),
            addr_width=int(v.get("ADDR_WIDTH", 32)),
            data_width=int(v.get("DATA_WIDTH", 32)),
            base_addr=base_addr,
            addr_mask=addr_mask,
            timeout_enable=bool(v.get("TIMEOUT_ENABLE", False)),
            timeout_cycles=int(v.get("TIMEOUT_CYCLES", 16)),
            output_register=bool(v.get("OUTPUT_REGISTER", False)),
            apb_profile=bool(v.get("APB_PROFILE", True)),
        )
    else:
        errors = validate_config(
            num_slaves=args.num_slaves,
            addr_width=args.addr_width,
            data_width=args.data_width,
            base_addr=parse_int_list(args.base_addr),
            addr_mask=parse_int_list(args.addr_mask),
            timeout_enable=args.timeout_enable,
            timeout_cycles=args.timeout_cycles,
            output_register=args.output_register,
            apb_profile=args.apb_profile,
        )

    if errors:
        print("配置校验失败：")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("配置校验通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())
