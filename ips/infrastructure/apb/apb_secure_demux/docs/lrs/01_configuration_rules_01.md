# 参数合法性（1）

来源：输入契约的 PAR 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.CFG.APB_SECURE_DEMUX.PAR.001

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.001
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-001
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

CSR_SIZE 固定按 `0x1000 + NUM_PORTS × 0x400` 字节推导；所有区间使用扩展位宽计算结束地址，不允许截断或回绕。

#### Acceptance Criteria

- 应满足：CSR_SIZE 固定按 `0x1000 + NUM_PORTS × 0x400` 字节推导；所有区间使用扩展位宽计算结束地址，不允许截断或回绕。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.002

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.002
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-002
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

任一 PORT 区间、本地 CSR 区间越出地址宽度，存在重叠、大小为零或未按 4 字节对齐，必须在 elaboration/配置检查阶段失败。

#### Acceptance Criteria

- 应满足：任一 PORT 区间、本地 CSR 区间越出地址宽度，存在重叠、大小为零或未按 4 字节对齐，必须在 elaboration/配置检查阶段失败。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.00301

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.00301
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-003
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

端口支持任意符合上述约束的大小，无须是 2 的幂。

#### Acceptance Criteria

- 应满足：端口支持任意符合上述约束的大小，无须是 2 的幂。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.00302

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.00302
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-003
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

结束地址为 BASE+SIZE-1。

#### Acceptance Criteria

- 应满足：结束地址为 BASE+SIZE-1。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.004

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.004
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-004
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

1 个端口、1 个主体、FIFO 深度 0/1、非 2 的幂规模必须可编译且行为正确；内部索引宽度不得出现零宽向量。

#### Acceptance Criteria

- 应满足：1 个端口、1 个主体、FIFO 深度 0/1、非 2 的幂规模必须可编译且行为正确；内部索引宽度不得出现零宽向量。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.005

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.005
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-005
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

MASTERID 必须先检查完整输入值是否小于 NUM_MASTERS，再索引权限表；禁止截断高位导致身份混叠。

#### Acceptance Criteria

- 应满足：MASTERID 必须先检查完整输入值是否小于 NUM_MASTERS，再索引权限表；禁止截断高位导致身份混叠。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

### LRS.CFG.APB_SECURE_DEMUX.PAR.006

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PAR.006
category: CFG
feature: par
priority: P0
status: active
source_ref:
- REQ-PAR-006
applicability:
  expr: 'true'
verification_method:
- static
- simulation
END_LRS_META -->

#### Requirement

CAPABILITY 和地址只读镜像必须反映实际 elaboration 参数。

#### Acceptance Criteria

- 应满足：CAPABILITY 和地址只读镜像必须反映实际 elaboration 参数。
- 对边界值、非 2 幂、零值与越界配置执行检查；合法配置接受，违反本条的配置必须失败。

