# 时钟复位（1）

来源：输入契约的 RST 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.RESET.APB_SECURE_DEMUX.RST.001

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.001
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

preset_ni 有效时全部 m_psel/m_penable/m_master_id_valid=0，上游 PREADY=0、PSLVERR=0、PRDATA=0，irq/alert 和 DFX 观测为零。

#### Acceptance Criteria

- 应满足：preset_ni 有效时全部 m_psel/m_penable/m_master_id_valid=0，上游 PREADY=0、PSLVERR=0、PRDATA=0，irq/alert 和 DFX 观测为零。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

### LRS.RESET.APB_SECURE_DEMUX.RST.00201

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.00201
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

复位释放必须同步；释放后接收合法的新 SETUP，不将无先行 SETUP 的 ACCESS 视为新事务。

#### Acceptance Criteria

- 应满足：复位释放必须同步；释放后接收合法的新 SETUP，不将无先行 SETUP 的 ACCESS 视为新事务。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

### LRS.RESET.APB_SECURE_DEMUX.RST.00202

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.00202
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

输入违规只要求断言报告并保持下游不选中，不承诺正常 APB 完成。

#### Acceptance Criteria

- 应满足：输入违规只要求断言报告并保持下游不选中，不承诺正常 APB 完成。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

### LRS.RESET.APB_SECURE_DEMUX.RST.003

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.003
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

复位清除锁、FATAL、日志/快照/FIFO、计数、时间戳、版本、提交状态、注入武装；策略恢复 RESET 参数，INTR_ENABLE=0，ALERT_ENABLE=0x9B。

#### Acceptance Criteria

- 应满足：复位清除锁、FATAL、日志/快照/FIFO、计数、时间戳、版本、提交状态、注入武装；策略恢复 RESET 参数，INTR_ENABLE=0，ALERT_ENABLE=0x9B。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

### LRS.RESET.APB_SECURE_DEMUX.RST.004

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.004
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

复位中断在途事务属于系统复位行为，系统须协调上游、桥、下游的隔离与恢复；本 IP 不保证复位前写是否已发生。

#### Acceptance Criteria

- 应满足：复位中断在途事务属于系统复位行为，系统须协调上游、桥、下游的隔离与恢复；本 IP 不保证复位前写是否已发生。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

### LRS.RESET.APB_SECURE_DEMUX.RST.005

<!-- LRS_META
id: LRS.RESET.APB_SECURE_DEMUX.RST.005
category: RESET
feature: rst
priority: P0
status: active
source_ref:
- REQ-RST-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

不存在软件 soft reset；功能门控只允许在无进行中事务且系统保证配置/状态保持时由外部实现，禁止在等待期间停止必要的响应时钟。

#### Acceptance Criteria

- 应满足：不存在软件 soft reset；功能门控只允许在无进行中事务且系统保证配置/状态保持时由外部实现，禁止在等待期间停止必要的响应时钟。
- 在空闲、SETUP、ACCESS 等待和日志有效时复位；逐项检查输出、策略、锁、状态及释放后的首笔事务。

