# 环境检查报告 - x2p

## 基本信息
- IP: x2p
- 显示名称：AXI-to-APB Bridge (X2P)
- 日期: 2026-09-03
- 平台: Linux 4.18

## EDA Profile 状态

| 项目 | 状态 | 版本/路径 |
|------|--------|--------------|
| 选定 profile | ✅ | commercial-systemverilog |
| VCS (仿真/elab) | ✅ | W-2024.09-SP1 |
| SpyGlass (lint) | ✅ | X-2025.06 |
| DC (综合) | ✅ | V-2023.12-SP3 |
| VC Formal (formal) | ❌ | 未安装（formal 检查降级为限制性 elab + lint 证据） |

## Python 环境

| 项目 | 状态 | 版本/路径 |
|------|--------|---------|
| uv | ✅ | 0.11.27 |
| Python | ✅ | 3.11.13 |
| 虚拟环境 | ✅ | ip_x2p/.venv |

## Python 依赖

| 包 | 状态 |
|---------|--------|
| pyyaml | ✅ |
| jinja2 | ✅ |
| numpy | ✅ |
| pytest | ✅ |
| peakrdl | ✅ |
| peakrdl-regblock | ✅ |
| peakrdl-html | ✅ |
| peakrdl-cheader | ✅ |
| peakrdl-ipxact | ✅ |
| pyslang | ✅ |
| cocotb / cocotbext-axi | ✅ |

## 建议
- VC Formal 未安装：formal 阶段以 RTL lint + 限制性 elaboration 证据替代，并如实标记为 exploratory（不用于 G3-G5 正式门禁）。