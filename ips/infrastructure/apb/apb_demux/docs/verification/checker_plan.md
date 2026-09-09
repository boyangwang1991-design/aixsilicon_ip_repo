# APB Demux 比对器策略

本文档是 `verification_plan.md` 第 9 章的详细展开。

## 1. 比对器分工

| 组件 | 职责 |
|------|------|
| RM（reference model） | 事务级建模 Demux：输入上游请求 + 地址映射 → 预期命中端口/响应 |
| scoreboard | 比对 DUT 上游完成事务与 RM 预期（地址/数据/错误/端口） |
| 协议 checker | 通过 SVA 断言检查 APB 协议合规（详见下方断言） |
| 下游 monitor | 记录每个下游观察到的事务，与上游请求一一对应 |

## 2. 断言（SVA）

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.001
name: psel_onehot0
property: $onehot0(m_psel)
feature_ref: FL.FUNC.APB_DEMUX.02
description: 任意时刻下游 M_PSEL 为 onehot 或全零
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.002
name: wait_stable
property: ACCESS phase && PREADY==0 期间 PADDR/PWRITE/PWDATA/PSTRB/PPROT/selected_slave 稳定
feature_ref: FL.FUNC.APB_DEMUX.03
description: wait-state 期间请求信号与选中端口保持稳定
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.003
name: decode_correct
property: 命中一个地址区域时只能选择对应下游 port
feature_ref: FL.FUNC.APB_DEMUX.01
description: 译码正确性
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.004
name: decode_miss_response
property: 未命中地址时无下游 PSEL 且产生合法 error 响应
feature_ref: FL.FUNC.APB_DEMUX.05
description: Decode Miss 错误响应合法性
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.005
name: penable_psel_legal
property: ~(M_PENABLE[i] && ~M_PSEL[i])
feature_ref: FL.FUNC.APB_DEMUX.02
description: 禁止 PENABLE=1 且 PSEL=0 的非法下游事务
severity: error
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASR.APB_DEMUX.01.006
name: reset_no_transaction
property: 复位期间所有 M_PSEL[i]==0
feature_ref: FL.RESET.APB_DEMUX.01
description: 复位期间无有效下游事务
severity: error
END_ASSERTION_META -->

## 3. 断言汇总

| ID | 名称 | 检查 |
|----|------|------|
| ASR.APB_DEMUX.01.001 | psel_onehot0 | $onehot0(M_PSEL) |
| ASR.APB_DEMUX.01.002 | wait_stable | wait 期间信号稳定 |
| ASR.APB_DEMUX.01.003 | decode_correct | 译码正确性 |
| ASR.APB_DEMUX.01.004 | decode_miss_response | Decode Miss 响应 |
| ASR.APB_DEMUX.01.005 | penable_psel_legal | PENABLE/PSEL 合法性 |
| ASR.APB_DEMUX.01.006 | reset_no_transaction | 复位期间无事务 |

## 4. 覆盖关联

断言通过 SVA bind 到 DUT；断言覆盖（assertion coverage）在 coverage_plan 中统计。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite - 06-verification-plan*
