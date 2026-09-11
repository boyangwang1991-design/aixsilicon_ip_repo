# 日志事件与队列竞争：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.LOG.001
name: tc_apb_secure_demux_log
type: error_injection
description: 日志事件与队列竞争
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_log.sv
feature_ref:
- FL.APB_SECURE_DEMUX.LOG
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.EVENTS
- LLD.MOD.APB_SECURE_DEMUX.DFX
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 产生各类失败、真实完整性、阈值与合成事件；强制同周期候选组合；读FIRST/LAST字0后插入新事件再读1..7；FIFO满/空、POP+push、clear+event及序列/时间戳回绕。
expected_result:
- 256位记录逐字段匹配独立RM且无原始数据泄露；优先级及LOST数量准确；FIRST保持/LAST更新、快照独立；FIFO不反压、不覆盖旧项，depth0不计入队丢失。
timeout_policy: 200000 pclk cycles for simulation; 1200 s tool timeout
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
- CFG_MAX_DIRECT
- CFG_MAX_REGISTER
- CFG_MIN_NOFIFO
- CFG_MIN_FIFO1
- CFG_NONPOWER
- CFG_TRIMMED
END_TESTCASE_META -->

激励：产生各类失败、真实完整性、阈值与合成事件；强制同周期候选组合；读FIRST/LAST字0后插入新事件再读1..7；FIFO满/空、POP+push、clear+event及序列/时间戳回绕。

期望：256位记录逐字段匹配独立RM且无原始数据泄露；优先级及LOST数量准确；FIRST保持/LAST更新、快照独立；FIFO不反压、不覆盖旧项，depth0不计入队丢失。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
