# Module UT 检查报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G3

## 1. UT 清单与结果

| UT | 覆盖模块 | 结果 |
|----|----------|------|
| ut_sync_chain | apb_cdc_sync_chain | ✔ PASS |
| ut_handshake | apb_cdc_handshake | ✔ PASS |
| ut_async_fifo | apb_cdc_async_fifo（depth 1/2） | ✔ PASS |
| ut_source | apb_cdc_source | ✔ PASS |
| ut_dest | apb_cdc_dest | ✔ PASS |
| ut_top_path | apb_cdc_bridge_top（HS + FIFO 集成） | ✔ PASS |

**全部 6/6 PASS**。

## 2. 捕获的 RTL Bug（UT 价值）

- **BUG-HS-001（已修复）**：`apb_cdc_handshake.sv` 中 `s_req_ready` 输出缺少
  `assign s_req_ready = ~req_busy;`，导致源域 FSM 的 ready 信号为 X、握手挂死。
  - 现象：UT 请求通道 `m_req_valid` 正常但 `s_req_ready` 恒 X，`wait(s_req_ready)` 挂死。
  - 修复：补充 assign 语句。修复后握手/FIFO/顶层集成全部 PASS。

## 3. 仓库卫生

- 所有 UT 运行产物（simv/csrc/log）位于 `build/sim/run/ut/`，源码目录无中间件。
- `verification/unit_test/` 只含 `.sv` 与 `run_ut.sh`。

## 4. 结论

**Module UT: PASS（6/6）** — G3 固定步骤完成；RTL 握手 bug 已修复并经 UT 验证。
