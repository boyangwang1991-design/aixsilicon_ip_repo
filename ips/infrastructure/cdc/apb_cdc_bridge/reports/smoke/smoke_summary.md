# Smoke 与回归测试报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G4 | **Report schema**: 1.0

## REPORT_META
<!-- REPORT_META
ip_name: apb_cdc_bridge
report_type: smoke
status: pass
eda_profile: commercial-systemverilog
schema_version: "1.0"
END_REPORT_META -->

## 1. 运行

```bash
make -C verification/sim compile
make -C verification/sim regression   # 全 test_matrix 回归
```

## 2. 结果（9 个 UVM TC 全部 PASS）

| TC | tier | 时钟 | 事务匹配 | UVM_ERROR |
|----|------|------|---------|-----------|
| tc_sanity | smoke | 异步 1:2 | 7 up / 8 down | 0 |
| tc_downstream_wait | regression | 异步（RANDOM_WAIT） | 8 / 8 | 0 |
| tc_pslverr | regression | 异步（ADDRESS_RANGE） | 8 / 8 | 0 |
| tc_handshake_config | regression | 异步（SYNC=2） | 32 / 32 | 0 |
| tc_fifo_depth | regression | 异步（FIFO） | 24 / 24 | 0 |
| tc_clock_relation | regression | 异步 1:2 | 20 / 20 | 0 |
| tc_clock_pause | extended | 异步 | 16 / 16 | 0 |
| tc_reset_scenarios | regression | 异步 | 24 / 24 | 0 |
| tc_apb4 | regression | 异步 | 7 / 8 | 0 |

**全部 UVM_FATAL=0**；TC.CONS.CFG（编译期）由 elab 校验。

## 3. 覆盖功能

- 跨桥读写（sanity）、下游 wait-state（RANDOM_WAIT）、PSLVERR 传播、随机事务无丢失/重复、
  FIFO 深度、时钟关系（plusarg 矩阵入口 clk_matrix）、时钟暂停、独立复位、APB4 PSTRB/PPROT。

## 4. 结论

**Smoke/Regression: PASS（9/9，UVM_ERROR=0）** — 验证方案 test_matrix 闭环。

## 5. 时钟关系矩阵（clk_matrix 扩展回归）

`make -C verification/sim clk_matrix`（tc_clock_relation + S/M 周期 plusarg，全部 UVM_ERROR=0）：

| 场景 | S_PERIOD_PS | M_PERIOD_PS | 关系 | UVM_ERROR |
|------|------------|------------|------|-----------|
| clk_1to1 | 10000 | 10000 | 同频同相 | 0 |
| clk_1to4 | 10000 | 40000 | 快→慢 1:4 | 0 |
| clk_8to1 | 80000 | 10000 | 慢→快 1:8 | 0 |
| clk_near | 10003 | 10000 | 近同频异相（3ps 偏差） | 0 |

**结论**：时钟关系矩阵 4/4 PASS，补充 LRS.FUNC.APB_CDC_BRIDGE.05.001/.06.001/.07.001 快慢/近同频取证。
