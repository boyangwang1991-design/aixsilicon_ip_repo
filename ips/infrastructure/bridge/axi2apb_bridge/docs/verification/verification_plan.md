# X2P 验证计划 / Verification Plan

> Document ID: VP-X2P-V100
> IP: x2p · 版本 1.0.0
> 日期: 2026-09-03 · 作者: rtl-team/dv-team

<!-- VPLAN_META
id: VP.X2P.V1
schema_version: "1.0"
ip_name: x2p
version: "1.0"
methodology: UVM 1.2
dut: rtl/x2p_top.sv
agents:
  - name: axi_agent
    interface: AXI4/AXI4-Lite slave
    mode: active
  - name: apb_agent
    interface: APB3/APB4 master
    mode: passive
reference_model: x2p_scoreboard (UVM, 唯一参考来源)
tools: VCS 2024.09-SP1 · SpyGlass X-2025.06 · DC V-2023.12-SP3
END_VPLAN_META -->

---

## 1. DUT 概述

X2P 是可参数化 AXI-to-APB Bridge（1 AXI Slave → 1 APB Master），完成协议转换、
Burst 拆解、宽度转换、仲裁、超时与 CDC。详见 [HLD](../hld/index.md)。

## 2. 时钟与复位

- 时钟：clk_axi（AXI 域）、clk_apb（APB 域），SYNC/ASYNC 参数化。
- 复位：rst_axi_n / rst_apb_n，低有效异步 assert 同步 release；ASYNC 可独立。

## 3. 接口列表

- AXI Slave：AW/W/B/AR/R（参数化位宽）
- APB Master：PADDR/PSEL/PENABLE/PWRITE/PWDATA/PRDATA/PREADY/PSLVERR(+PSTRB/PPROT)

## 4. Agent 列表

| Agent | 接口 | 模式 |
|---|---|---|
| axi_agent | AXI | active |
| apb_agent | APB | passive |
| apb_slave_bfm | APB | active |

详见 [agent_plan.md](agent_plan.md)。

## 5. 寄存器验证范围

**N/A** - X2P 无可编程寄存器（register_model=none）。

## 6. 功能验证范围

覆盖 AXI Slave 接口、APB Master 接口、时钟复位、AW/W 关联、Burst 转换
（INCR/FIXED/WRAP/4KB）、Narrow/Width 转换、Request Buffer、仲裁、响应/错误、
APB Timeout、APB 事务、Regslice/Ordering、CDC/Async。详见
[feature_list.md](feature_list.md) 与 [test_matrix.md](test_matrix.md)。

## 7. 错误注入范围

- APB PSLVERR 注入（读/写）。
- PREADY 恒 0 触发 Timeout。
- APB3 partial write。
- 非法事务（AXI4-Lite+WRAP 等）。

## 8. 参考模型策略

UVM scoreboard `x2p_scoreboard` 作为唯一参考模型：对每个 AXI 事务按
burst/WRAP/width 语义计算期望 APB 序列与响应，比对 AXI/APB 两侧观测。
行为 Python 模型不接入验证。

## 9. 比对器策略

Scoreboard + 四类 checker（burst/width/apb/protocol）+ 13 条 assertion。
详见 [checker_plan.md](checker_plan.md)。

## 10. 功能覆盖率策略

9 个 covergroup（burst/aw_w_order/width/apb_fsm/arb/timeout/cdc 等）。
详见 [coverage_plan.md](coverage_plan.md)。

## 11. 测试矩阵

测试组：sanity(1) + basic(2) + scenario(1) + corner(2) + random(1) + 其余
regression/extended，去重总数 ≤ 20。详见 [test_matrix.md](test_matrix.md)。

## 12. 回归策略

| Tier | 内容 | 运行时机 |
|---|---|---|
| smoke | TC.INTF.X2P.01.01 | 每次编译 |
| regression | 核心 12 项 | 门禁回归 |
| extended | corner/performance/约束 | 发布前 |

## 13. Signoff 标准

- 全部 test_matrix testcase 通过。
- assertion 全绿。
- 覆盖率达标（功能覆盖 + FSM + 关键边界）。
- 无 blocked/error。

## 14. 假设与待确认项

- AXI/APB 按 AMBA 规范实现，无自定义协议。
- APB3 partial write 返回 SLVERR（基线冻结）。
- VC Formal 缺失：formal 降级为 lint+elab 证据（探索性，不支撑 G3-G5 正式门禁）。