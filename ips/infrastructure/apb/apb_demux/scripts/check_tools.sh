#!/usr/bin/env bash
# check_tools.sh — APB Demux 工具检查脚本
# 用法: RTL_EDA_PROFILE=commercial-systemverilog bash scripts/check_tools.sh --report reports/quality/env_check_report.md
set -uo pipefail

IP_DISPLAY_NAME="${IP_DISPLAY_NAME:-APB Demux (1-to-N APB Router)}"
RTL_EDA_PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"
REPORT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --report) REPORT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
os="$(uname -s)"

# 工具探测
probe() {
    command -v "$1" >/dev/null 2>&1 && echo "✅" || echo "❌"
}
vcs_status=$(probe vcs)
vcs_ver=$(command -v vcs >/dev/null 2>&1 && vcs -ID 2>/dev/null | head -1 || echo "-")
sg_status=$(probe spyglass)
sg_ver=$(command -v spyglass >/dev/null 2>&1 && spyglass -version 2>/dev/null | head -1 || echo "-")
dc_status=$(probe dc_shell)
dc_ver=$(command -v dc_shell >/dev/null 2>&1 && dc_shell -version 2>/dev/null | head -1 || echo "-")
uv_status=$(probe uv)
uv_ver=$(command -v uv >/dev/null 2>&1 && uv --version 2>/dev/null || echo "-")
py_ver=$(command -v uv >/dev/null 2>&1 && uv run python --version 2>/dev/null || echo "-")
venv_status=$( [ -d .venv ] && echo "✅" || echo "❌" )

# Python 依赖探测
py_dep() {
    command -v uv >/dev/null 2>&1 && uv run python -c "import $1; print('✅')" 2>/dev/null || echo "❌"
}

report_content="# 环境检查报告 - APB Demux

## 基本信息
- IP: apb_demux
- 显示名称：${IP_DISPLAY_NAME}
- 日期：${timestamp}
- 平台：${os}

## EDA Profile 状态

| 项目 | 状态 | 版本/路径 |
|------|--------|--------------|
| 选定 profile | ✅ | ${RTL_EDA_PROFILE} |
| VCS | ${vcs_status} | ${vcs_ver} |
| SpyGlass | ${sg_status} | ${sg_ver} |
| DC | ${dc_status} | ${dc_ver} |

## Python 环境

| 项目 | 状态 | 版本 |
|------|--------|---------|
| uv | ${uv_status} | ${uv_ver} |
| Python | ${py_status:-✅} | ${py_ver} |
| 虚拟环境 | ${venv_status} | .venv |

## Python 依赖

| 包 | 状态 | 版本 |
|---------|--------|---------|
| pyyaml | $(py_dep yaml) | - |
| jinja2 | $(py_dep jinja2) | - |
| numpy | $(py_dep numpy) | - |
| pytest | $(py_dep pytest) | - |
| peakrdl | $(py_dep peakrdl) | - |

## 建议
- 若 VCS/SpyGlass/DC 缺失，对应 RTL 检查 Gate（G3）将被阻塞。
- 运行: bash scripts/init_env.sh 以安装 Python 依赖。
"

if [ -n "$REPORT" ]; then
    mkdir -p "$(dirname "$REPORT")"
    echo "$report_content" > "$REPORT"
    echo "报告已写入: $REPORT"
else
    echo "$report_content"
fi
