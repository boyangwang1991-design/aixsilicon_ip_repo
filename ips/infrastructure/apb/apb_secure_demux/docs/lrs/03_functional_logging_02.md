# 事件日志（2）

来源：输入契约的 LOG 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00702

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00702
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

未选候选数累加至 EVENT_LOST_COUNT；各自中断状态仍置位。

#### Acceptance Criteria

- 应满足：未选候选数累加至 EVENT_LOST_COUNT；各自中断状态仍置位。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00801

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00801
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO 满不覆盖旧记录，丢弃新入队记录，置 OVF 并增加 LOST；FIRST/LAST 仍更新。

#### Acceptance Criteria

- 应满足：FIFO 满不覆盖旧记录，丢弃新入队记录，置 OVF 并增加 LOST；FIRST/LAST 仍更新。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00802

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00802
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO_POP 与入队同周期时先释放槽位再入队，满 FIFO 可以接收新记录。

#### Acceptance Criteria

- 应满足：FIFO_POP 与入队同周期时先释放槽位再入队，满 FIFO 可以接收新记录。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00901

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00901
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO_DEPTH=0 时跳过入队，不因“未实现 FIFO”增加 LOST；同周期候选仲裁丢失仍计 LOST。

#### Acceptance Criteria

- 应满足：FIFO_DEPTH=0 时跳过入队，不因“未实现 FIFO”增加 LOST；同周期候选仲裁丢失仍计 LOST。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.00902

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.00902
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-009
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO 状态只读寄存器可读，POP/HEAD 地址返回未实现错误。

#### Acceptance Criteria

- 应满足：FIFO 状态只读寄存器可读，POP/HEAD 地址返回未实现错误。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.010

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.010
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-010
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

清除与新事件同周期时先清除再记录；FIRST 可被新事件重新置有效，LAST 更新；FIFO 清空后新事件可成为首条记录。

#### Acceptance Criteria

- 应满足：清除与新事件同周期时先清除再记录；FIRST 可被新事件重新置有效，LAST 更新；FIFO 清空后新事件可成为首条记录。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.01101

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.01101
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-011
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

FIFO 溢出、清除和事件丢失本身不再生成日志事件，防止递归日志。

#### Acceptance Criteria

- 应满足：FIFO 溢出、清除和事件丢失本身不再生成日志事件，防止递归日志。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.01102

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.01102
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-011
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

日志记录不能对 APB 形成反压。

#### Acceptance Criteria

- 应满足：日志记录不能对 APB 形成反压。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。

### LRS.FUNC.APB_SECURE_DEMUX.LOG.012

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOG.012
category: FUNC
feature: log
priority: P0
status: active
source_ref:
- REQ-LOG-012
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

全局 ACCESS_DENY_COUNT 统计所有被拒绝的非 CSR 请求（含地址空洞/多重命中）；CFG_DENY_COUNT 统计唯一命中 CSR 的失败；下游错误不计权限拒绝。

#### Acceptance Criteria

- 应满足：全局 ACCESS_DENY_COUNT 统计所有被拒绝的非 CSR 请求（含地址空洞/多重命中）；CFG_DENY_COUNT 统计唯一命中 CSR 的失败；下游错误不计权限拒绝。
- 比对八字记录、有效位、快照与 FIFO 队列；同时覆盖清除/弹出/新事件竞争。


## 已批准的错误码裁决

CR-002：FIFO 深度为 0 时 POP/HEAD 为 CSR_UNIMPLEMENTED(0x13)；已实现但空 FIFO 的 POP 为 CMD_INVALID(0x16)。这与 REQ-LOG-009 一致。
