# 接口协议（1）

来源：输入契约的 IF 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.INTF.APB_SECURE_DEMUX.IF.001

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.IF.001
category: INTF
feature: if
priority: P0
status: active
source_ref:
- REQ-IF-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

请求和 MASTERID 在 SETUP 到事务完成期间必须稳定；该项作为输入协议假设并通过断言检查。

#### Acceptance Criteria

- 应满足：请求和 MASTERID 在 SETUP 到事务完成期间必须稳定；该项作为输入协议假设并通过断言检查。
- 逐周期检查接口输出；输入假设违规由断言报告，不能作为 DUT 通过的合法激励。

### LRS.INTF.APB_SECURE_DEMUX.IF.002

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.IF.002
category: INTF
feature: if
priority: P0
status: active
source_ref:
- REQ-IF-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

m_master_id_valid_o 仅在对应 m_psel 为 1 时有效；未选端口该信号固定为 0。

#### Acceptance Criteria

- 应满足：m_master_id_valid_o 仅在对应 m_psel 为 1 时有效；未选端口该信号固定为 0。
- 逐周期检查接口输出；输入假设违规由断言报告，不能作为 DUT 通过的合法激励。

### LRS.INTF.APB_SECURE_DEMUX.IF.003

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.IF.003
category: INTF
feature: if
priority: P0
status: active
source_ref:
- REQ-IF-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

APB3 下游可以通过外部适配连接；本 IP 的输入不能无说明地丢弃 PPROT 和 MASTERID。

#### Acceptance Criteria

- 应满足：APB3 下游可以通过外部适配连接；本 IP 的输入不能无说明地丢弃 PPROT 和 MASTERID。
- 逐周期检查接口输出；输入假设违规由断言报告，不能作为 DUT 通过的合法激励。

### LRS.INTF.APB_SECURE_DEMUX.IF.00401

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.IF.00401
category: INTF
feature: if
priority: P0
status: active
source_ref:
- REQ-IF-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

DFX_EN=0 或 dfx_authorized_i=0 时，DFX 观测输出全部为 0。

#### Acceptance Criteria

- 应满足：DFX_EN=0 或 dfx_authorized_i=0 时，DFX 观测输出全部为 0。
- 逐周期检查接口输出；输入假设违规由断言报告，不能作为 DUT 通过的合法激励。

### LRS.INTF.APB_SECURE_DEMUX.IF.00402

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.IF.00402
category: INTF
feature: if
priority: P0
status: active
source_ref:
- REQ-IF-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

irq_o/security_alert_o 不受 DFX 授权控制。

#### Acceptance Criteria

- 应满足：irq_o/security_alert_o 不受 DFX 授权控制。
- 逐周期检查接口输出；输入假设违规由断言报告，不能作为 DUT 通过的合法激励。

