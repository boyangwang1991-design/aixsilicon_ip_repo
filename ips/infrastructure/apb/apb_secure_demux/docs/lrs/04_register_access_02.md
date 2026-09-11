# 软件访问语义（2）

来源：输入契约的 CSR 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.REG.APB_SECURE_DEMUX.CSR.007

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.007
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

所有未另行指定的寄存器、状态、计数器、锁和中断复位为零。

#### Acceptance Criteria

- 应满足：所有未另行指定的寄存器、状态、计数器、锁和中断复位为零。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

### LRS.REG.APB_SECURE_DEMUX.CSR.008

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.CSR.008
category: REG
feature: csr
priority: P0
status: active
source_ref:
- REQ-CSR-008
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

参数化表采用固定槽位地址，超出 NUM_PORTS/NUM_MASTERS 的槽位为未实现地址，不允许索引回绕。

#### Acceptance Criteria

- 应满足：参数化表采用固定槽位地址，超出 NUM_PORTS/NUM_MASTERS 的槽位为未实现地址，不允许索引回绕。
- 对合法/非法授权、地址、读写类型和选通执行访问；检查响应、目标状态及允许的审计副作用。

