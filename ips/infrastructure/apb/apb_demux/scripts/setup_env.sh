#!/usr/bin/env bash
# setup_env.sh — APB Demux 环境设置脚本
set -euo pipefail

IP_DISPLAY_NAME="${IP_DISPLAY_NAME:-APB Demux (1-to-N APB Router)}"

export RTL_EDA_PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"

# EDA 工具路径（示例：Synopsys）
if [ -d /home/eda/app/synopsys/vcs ]; then
    VCS_HOME=$(ls -d /home/eda/app/synopsys/vcs/* 2>/dev/null | head -1 || true)
    [ -n "${VCS_HOME}" ] && export PATH="${VCS_HOME}/bin:${PATH}"
fi
if [ -d /home/eda/app/synopsys/spyglass ]; then
    SG_HOME=$(ls -d /home/eda/app/synopsys/spyglass/*/SPYGLASS_HOME 2>/dev/null | head -1 || true)
    [ -n "${SG_HOME}" ] && export PATH="${SG_HOME}/bin:${PATH}"
fi
if [ -d /home/eda/app/synopsys/syn ]; then
    DC_HOME=$(ls -d /home/eda/app/synopsys/syn/*/bin 2>/dev/null | head -1 || true)
    [ -n "${DC_HOME}" ] && export PATH="${DC_HOME}:${PATH}"
fi

echo "==> 环境已设置（${IP_DISPLAY_NAME}，${RTL_EDA_PROFILE}）"
