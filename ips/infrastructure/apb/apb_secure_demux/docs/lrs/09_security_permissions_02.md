# 权限判定（2）

来源：输入契约的 ACL 需求族。以下条目与同 source_ref 的其他条目共同保持原文语义。

### LRS.SEC.APB_SECURE_DEMUX.ACL.007

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ACL.007
category: SEC
feature: acl
priority: P0
status: active
source_ref:
- REQ-ACL-007
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

默认 RESET_PORT_CFG 和 RESET_PERM 全零；硬件启动权限只能通过显式参数定义，active 与 shadow 复位内容一致。

#### Acceptance Criteria

- 应满足：默认 RESET_PORT_CFG 和 RESET_PERM 全零；硬件启动权限只能通过显式参数定义，active 与 shadow 复位内容一致。
- 交叉主体、四种属性、读写与指令属性，检查准入结果及被拒绝请求的下游选择为零。

