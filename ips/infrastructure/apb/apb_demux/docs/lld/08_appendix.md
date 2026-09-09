# APB Demux — LLD 附录与 G2 门禁

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 设计验证关注点（Design Verification Focus）

以下为必须观察的行为（testcase/assertion/coverage 实现由 VPLAN 定义）：

1. 地址译码：每个下游端口读/写访问命中正确端口；
2. PSEL onehot0：任意时刻 `M_PSEL` onehot 或全零；
3. wait-state：`PREADY=0` 期间 selection 与响应源稳定；
4. PSLVERR 透传：下游 error 不被屏蔽；
5. Decode Miss：返回 `PREADY=1, PSLVERR=1, PRDATA=0`，立即结束；
6. remap：开启/关闭时下游地址正确；
7. timeout：超时终止并返回 error；
8. response register：插入后协议合规且延迟增加；
9. 复位：期间无有效下游事务，状态确定；
10. APB3/APB4 profile：PSTRB/PPROT 裁剪/透传正确；
11. 参数组合：NUM_SLAVES 1/2/4/8/16 均正确。

## 2. RTL TODO

| 优先级 | 路径 | 说明 | 引用 |
|--------|------|------|------|
| P0 | `rtl/apb_demux_top.sv` | 参数化顶层实现 | LLD.MOD.APB_DEMUX.TOP |
| P0 | `scripts/check_config.py` | 配置校验脚本 | LRS.CONS.APB_DEMUX.* |

## 3. G2 门禁

<!-- LLD_GATE_META
gate: G2
status: pass
microarchitecture_freeze: true

approvals:
  - role: Architecture
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
  - role: RTL
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
  - role: DV
    approver: rtl-team
    date: 2026-09-09
    conclusion: approved
END_LLD_GATE_META -->

## 4. G2 检查清单

| 检查项 | 状态 |
|--------|------|
| 所有 HLD module 被 LLD module 承接 | ✅（TOP 承接 4 个 HLD 模块） |
| module 与子对象引用闭合 | ✅ |
| FSM（timeout）与 datapath（decode/response/remap）完整 | ✅ |
| 复位语义定义 | ✅ |
| PPA 决策记录 | ✅ |
| register_model=none，无寄存器分支要求 | ✅ |

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
