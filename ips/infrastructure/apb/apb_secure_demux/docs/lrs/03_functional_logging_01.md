# 事件日志（1）

来源：输入契约的 LOG 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.001

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.001
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-001
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

首错为空时保存第一条选中记录，保持至 FAULT_CLEAR[0]；最近错误每次记录更新。

#### Acceptance Criteria

- 应满足：首错为空时保存第一条选中记录，保持至 FAULT_CLEAR[0]；最近错误每次记录更新。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00201

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00201
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIRST/LAST 在读取字 0 时形成独立快照；读取字 1～7 返回该快照。

#### Acceptance Criteria

- 应满足：FIRST/LAST 在读取字 0 时形成独立快照；读取字 1～7 返回该快照。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00202

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00202
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

下次读字 0 刷新快照。

#### Acceptance Criteria

- 应满足：下次读字 0 刷新快照。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00203

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00203
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-002
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

清除相应记录时清除其快照。

#### Acceptance Criteria

- 应满足：清除相应记录时清除其快照。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00301

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00301
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO 入队后队头不自动变化；读任意 HEAD 字不弹出，FIFO_POP 显式弹出。

#### Acceptance Criteria

- 应满足：FIFO 入队后队头不自动变化；读任意 HEAD 字不弹出，FIFO_POP 显式弹出。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00302

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00302
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-003
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

单管理软件须串行完成多字读取，多个管理主体通过软件互斥避免相互 POP。

#### Acceptance Criteria

- 应满足：单管理软件须串行完成多字读取，多个管理主体通过软件互斥避免相互 POP。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.004

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.004
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-004
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

全局 64 bit 时间戳每功能周期加一、复位清零、自然回绕；DFX_EN=0 时仍保留日志时间戳。

#### Acceptance Criteria

- 应满足：全局 64 bit 时间戳每功能周期加一、复位清零、自然回绕；DFX_EN=0 时仍保留日志时间戳。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.005

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.005
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-005
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

EVENT_SEQUENCE 每个选中的记录事件加一，记录使用递增前值；自然回绕，复位为零。

#### Acceptance Criteria

- 应满足：EVENT_SEQUENCE 每个选中的记录事件加一，记录使用递增前值；自然回绕，复位为零。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.006

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.006
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

拒绝/下游错误在事务完成边沿产生一次记录；新完整性故障、等待阈值和合成命令按事件产生边沿记录。

#### Acceptance Criteria

- 应满足：拒绝/下游错误在事务完成边沿产生一次记录；新完整性故障、等待阈值和合成命令按事件产生边沿记录。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00701

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00701
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

同周期允许多个候选事件；记录写端口每周期接收一条，优先级为新完整性故障 > 总线事务失败 > 等待阈值 > 合成事件。

#### Acceptance Criteria

- 应满足：同周期允许多个候选事件；记录写端口每周期接收一条，优先级为新完整性故障 > 总线事务失败 > 等待阈值 > 合成事件。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

