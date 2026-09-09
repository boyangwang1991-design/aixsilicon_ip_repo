#!/usr/bin/env bash
# init_env.sh — APB Demux 环境初始化脚本
set -euo pipefail

IP_DISPLAY_NAME="${IP_DISPLAY_NAME:-APB Demux (1-to-N APB Router)}"
RTL_EDA_PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"

echo "==> 初始化环境: ${IP_DISPLAY_NAME}"
echo "    EDA Profile: ${RTL_EDA_PROFILE}"

# Python 环境（uv）
if ! command -v uv >/dev/null 2>&1; then
    echo "错误：必须安装 uv（https://docs.astral.sh/uv/）" >&2
    exit 1
fi

uv lock
uv sync --frozen --all-groups

echo "==> Python 环境就绪"
uv run python -c "import yaml, jinja2; print('pyyaml/jinja2 可用')"
