# PQC 验证功能：安全与生命周期

每个 feature 的 req_ref 是需求归属；通过依据必须来自对应 testcase/assertion 的实际执行，覆盖率不是正确性证明。

## FL.PQC.KEYMANAGER.PENDING

<!-- FEATURE_META
id: FL.PQC.KEYMANAGER.PENDING
name: key_manager_lifecycle
type: security
priority: must
description: 专用私钥导入、KeyGen 托管、完整接收确认、可信域授权、撤销与退休清除
req_ref:
- LRS.INTF.PQC.KEY_MANAGER.001
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
design_ref:
- HLD.IF.EXT.PQC.KEY_MANAGER
- LLD.MOD.PQC.WORKKEY
proof_methods:
- simulation
- assertion
applicability:
  expr: 'true'
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.ENTROPY

<!-- FEATURE_META
id: FL.PQC.ENTROPY
name: entropy_interface
description: valid/ready 握手、health、domain tag、授权策略
priority: must
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.RESET.PQC.CLK.001
design_ref:
- LLD.CDC.PQC.ENTROPY
- LLD.ERR.PQC.RNG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.CLKRESET

<!-- FEATURE_META
id: FL.PQC.CLKRESET
name: clock_reset_interface
description: 单时钟域、低有效异步复位、复位释放行为
priority: must
req_ref:
- LRS.INTF.PQC.CLKRESET.001
- LRS.RESET.PQC.CLK.001
design_ref:
- LLD.RST.PQC.MAIN
applicability:
  expr: 'true'
proof_methods:
- static
- simulation
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.RESET

<!-- FEATURE_META
id: FL.PQC.RESET
name: reset_and_safe_shutdown
description: 冷复位自检门控、warm reset key 保持、故障统一收尾、掉电收尾
priority: must
req_ref:
- LRS.RESET.PQC.COLD.001
- LRS.RESET.PQC.WARM.001
- LRS.RESET.PQC.SAFE.001
- LRS.RESET.PQC.POWERDOWN.001
design_ref:
- LLD.RST.PQC.MAIN
- LLD.RST.PQC.WARM
- LLD.RST.PQC.ZEROPATH
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.CT

<!-- FEATURE_META
id: FL.PQC.CT
name: constant_time_security
description: 秘密不控制可观察行为、禁止秘密门控、确定性本地存储
priority: must
req_ref:
- LRS.SEC.PQC.CT.001
- LRS.SEC.PQC.CT.002
- LRS.SEC.PQC.CT.003
- LRS.FUNC.PQC.KEM_DECAPS.002
design_ref:
- LLD.SAFE.PQC.CT_SELECT
- LLD.SAFE.PQC.NO_SECRET_GATING
applicability:
  expr: 'true'
proof_methods:
- formal
- static
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.INTEGRITY

<!-- FEATURE_META
id: FL.PQC.INTEGRITY
name: control_integrity
description: 稀疏编码、字段完整性、冗余计数器、verify 双轨
priority: must
req_ref:
- LRS.SEC.PQC.INTEGRITY.001
- LRS.SEC.PQC.VERIFY.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.LOCK.001
design_ref:
- LLD.SAFE.PQC.CTRL_SPARSE
- LLD.SAFE.PQC.COUNTER_PARITY
- LLD.SAFE.PQC.VERIFY_DUAL
applicability:
  expr: 'true'
proof_methods:
- simulation
- formal
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.KEY

<!-- FEATURE_META
id: FL.PQC.KEY
name: key_slot_and_permissions
description: slot 元数据、私钥不可导出、generation 失效、debug/lifecycle 约束
priority: must
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.004
design_ref:
- LLD.REG.PQC.SLOT_CTRL
- LLD.REG.PQC.SLOT_META
- LLD.REG.PQC.SLOT_DESTROY
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.DFX

<!-- FEATURE_META
id: FL.PQC.DFX
name: dfx_observability
description: scan 排除、MBIST 安全、受限 debug、故障注入、性能计数
priority: must
req_ref:
- LRS.DFX.PQC.SCAN.001
- LRS.DFX.PQC.MBIST.001
- LRS.DFX.PQC.DEBUG.001
- LRS.DFX.PQC.FI.001
- LRS.DFX.PQC.PERFCNT.001
design_ref:
- HLD.SAFETY.PQC.DFXTEST
applicability:
  expr: 'true'
proof_methods:
- static
- review
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。


## 各功能的核心风险与证明

| Feature | 观察及证明 | 主要风险 |
|---|---|---|
| KEYMANAGER.PENDING（保留稳定ID） | 专用导入/托管/ACK/revoke，真实材料与授权检查 | 部分密钥发布、旧ACK重放、普通导出 |
| ENTROPY | ready/valid、身份、配额、clear | 未握手消费、随机复用、错误域 |
| CLKRESET/RESET | 复位相位、各阶段取消、自检、排空与物理清除 | 旧结果复活、假ack、冷暖策略混淆 |
| CT | 配对公开trace、固定尝试调度、taint/static | KEM失配早退、秘密控制地址/门控 |
| INTEGRITY | 状态/计数/判决故障注入与SVA | invalid被故障变valid |
| KEY | handle代际、owner/domain/usage与普通出口 | stale handle、越权私钥访问 |
| DFX | 生命周期门控、scan/MBIST/debug清单 | 测试旁路泄密 |
