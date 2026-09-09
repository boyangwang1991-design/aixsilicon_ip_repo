# 环境检查报告 - APB Demux

## 基本信息
- IP: apb_demux
- 显示名称：APB Demux (1-to-N APB Router)
- 日期：2026-09-09 00:09:33
- 平台：Linux

## EDA Profile 状态

| 项目 | 状态 | 版本/路径 |
|------|--------|--------------|
| 选定 profile | ✅ | commercial-systemverilog |
| VCS | ✅ | vcs script version : W-2024.09 |
| SpyGlass | ✅ | 
- |
| DC | ✅ | 
- |

## Python 环境

| 项目 | 状态 | 版本 |
|------|--------|---------|
| uv | ✅ | uv 0.11.27 (x86_64-unknown-linux-gnu) |
| Python | ✅ | Python 3.11.13 |
| 虚拟环境 | ✅ | .venv |

## Python 依赖

| 包 | 状态 | 版本 |
|---------|--------|---------|
| pyyaml | ✅ | - |
| jinja2 | ✅ | - |
| numpy | ✅ | - |
| pytest | ✅ | - |
| peakrdl | ✅ | - |

## 建议
- 若 VCS/SpyGlass/DC 缺失，对应 RTL 检查 Gate（G3）将被阻塞。
- 运行: bash scripts/init_env.sh 以安装 Python 依赖。

