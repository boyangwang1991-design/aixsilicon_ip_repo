# Watchdog 验证报告（候选实现）

输入契约 SHA-256：`9bbb88115193928f73fe13e899f4713a677bc4a6be1c78a5153299619769f302`。
原始契约未修改。执行依据为用户要求的自主实现；没有代填评审、冻结或发布签核。

## 已完成的可执行验证

| 配置 | 结果 | 检查次数 | 原始日志 |
|---|---|---:|---|
| channel32 | PASS | 1137 | [channel32.log](20260910_102926/channel32.log) |
| channel48 | PASS | 1137 | [channel48.log](20260910_102926/channel48.log) |
| channel64 | PASS | 1137 | [channel64.log](20260910_102926/channel64.log) |
| top_async | PASS | 157 | [top_async.log](20260910_102926/top_async.log) |
| top_fast_apb | PASS | 184 | [top_fast_apb.log](20260910_102926/top_fast_apb.log) |

合计 **3752** 次自检。每个 channel 配置含 21 组场景和 80 个受约束随机计时案例，
覆盖六类真实故障注入。两个 top 配置使用独立 APB/WDT 时钟，验证停钟、在途
preset、同步链内 warm 取消、来源拒绝、快照、独立自动启动及超时。

- VCS `W-2024.09-SP1_Full64`；SV Module UT，使用 UVM 1.2 库，未宣称 UVM 环境闭合。
- [执行 manifest](20260910_102926/manifest.json) 绑定实际命令、源码、日志和二进制 SHA-256。
- [JUnit](module_regression.xml) 仅由上述实际五项通过结果生成。
- C11 驱动编译启用 `-Wall -Wextra -Werror`，超时不重发、陈旧序号、IO 错误、回卷测试通过。
- 工作区 `make check` 与 pre-commit 全文件检查通过，原始日志已保留。

## 静态工具与覆盖率

SpyGlass X-2025.06：**0 fatal、0 error、2418 warning、16 info**，无豁免。
FuseSoC lint 因 warnings 返回非零，因此**lint gate 尚未通过**。
[完整压缩原报告](static/spyglass_moresimple.rpt.gz) 与 [规则统计](static/lint_counts.json)
保留生成代码顺序归约、未使用裁剪端口等提示，不通过修改严重度隐藏。

Design Compiler V-2023.12-SP3 完成默认 STANDARD 顶层的可综合前端 analyze/elaborate/link；
[原始日志](static/dc_synth.log) 含 `WATCHDOG_SYNTH_ELAB PASS`。
未指定真实工艺库，未执行 mapped compile/布局布线，**PPA 未验证**。
Generic check_design 的未用/常量/直通端口提示不等同于物理签核。

VCS 覆盖数据库按 elaboration 分开保留。已导出 32-bit 通道 DUT 的 code coverage：
line **87.61%**、condition **69.62%**、branch **69.23%**、toggle **1.07%**、FSM **11.36%**。
这些是 watchdog_channel 的工具分母；不是全 IP 功能覆盖率，也不包含自动排除项。
[模块报告](static/coverage_modlist.txt) 保留 DUT 与 testbench 的区分。
URG 初次在 libsnpsmalloc 崩溃，保留失败堆栈；仅重试子进程设置 VCS_USE_MALLOC=1 后成功。
其数据库来自上一轮相同 RTL/相同测试内容的独立编译；没有与本轮或异构参数库合并。

## 尚未满足的契约验收条件

- §19.3 全需求逐条验证、功能覆盖交叉闭合、完整 UVM/APB VIP qualification 尚未完成。
- CDC/RDC 工具签核、形式证明、所有复位相位、最大通道/客户端参数空间未闭合。
- 64-bit 长周期饱和及所有参数/非法组合边界还需要专门验证，位宽编译通过不能替代。
- SAFETY 的 mapped-netlist 故障注入、防综合合并与物理共因分析未完成。
- STANDARD/SAFETY/SUPERVISOR 的实际工艺面积、时序、功耗未测量。
- 全套 full-flow canonical META/G0–G5 未建立或批准；本次按 direct-contract partial-task
  交付候选电路和可执行证据，**不是“全部契约验收已通过”或正式发布包**。

未修改资产登记状态、未生成发布签名，未提交或推送 Git。
技能观察见 [优化记录](../docs/skill_improvements.md)。
