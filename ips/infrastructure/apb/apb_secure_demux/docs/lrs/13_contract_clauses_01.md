# 非编号契约条款补充需求

这些条目补齐原文表格和正文中的强制行为。结构明细继续引用受控契约，不导入寄存器位表。

### LRS.CFG.APB_SECURE_DEMUX.PARAMETERS.001

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.PARAMETERS.001
category: CFG
feature: parameters
priority: P0
status: active
source_ref:
- CONTRACT:§2 参数表
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

IP 应支持 NUM_PORTS=1..32、ADDR_WIDTH=16..32、DATA_WIDTH=32、MASTER_ID_WIDTH=1..16、NUM_MASTERS=1..64，且主体数量不超过身份编码空间。

#### Acceptance Criteria

- 逐参数检查上下界、相邻非法值和非 2 幂规模；DATA_WIDTH 不等于 32 必须拒绝。

### LRS.CFG.APB_SECURE_DEMUX.OPTIONS.002

<!-- LRS_META
id: LRS.CFG.APB_SECURE_DEMUX.OPTIONS.002
category: CFG
feature: options
priority: P0
status: active
source_ref:
- CONTRACT:§2 参数表
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

REGISTER_MODE、OUTPUT_ISOLATION_EN、POLICY_PARITY_EN、DFX_EN、PUBLIC_ID_EN 均为独立布尔参数；EVENT_FIFO_DEPTH 为 0..32。复位权限和端口使能默认全零；管理掩码非零且由集成提供。

#### Acceptance Criteria

- 检查各开关开启和关闭；组合配置不得出现身份绕过或意外开放权限。

### LRS.INTF.APB_SECURE_DEMUX.SIGNALS.003

<!-- LRS_META
id: LRS.INTF.APB_SECURE_DEMUX.SIGNALS.003
category: INTF
feature: signals
priority: P0
status: active
source_ref:
- CONTRACT:§3 接口表
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

IP 应提供本分册接口表中列出的全部方向和位宽，数据宽度固定 32 bit，输出身份按端口与请求绑定；不得新增 AXI 或 APB5 接口作为必需依赖。

#### Acceptance Criteria

- 在每个强制配置上检查 elaboration 顶层接口与受控接口契约一致。

### LRS.SEC.APB_SECURE_DEMUX.ATTRIBUTES.004

<!-- LRS_META
id: LRS.SEC.APB_SECURE_DEMUX.ATTRIBUTES.004
category: SEC
feature: attributes
priority: P0
status: active
source_ref:
- CONTRACT:§4.2 属性编码
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

PPROT 的低两位以 {Non-secure, privileged} 编码四类属性，读权限分别使用 PERM 低四位，写权限使用高四位；指令属性不改变主体身份。

#### Acceptance Criteria

- 穷尽四类属性、读写和八个 one-hot 权限设置，预期仅对应授权组合允许。

### LRS.REG.APB_SECURE_DEMUX.AUTHORIZATION.005

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.AUTHORIZATION.005
category: REG
feature: authorization
priority: P0
status: active
source_ref:
- CONTRACT:§6 管理授权
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

管理授权必须同时满足完整身份有效、身份范围合法、固定 MGMT_MASTER_MASK 命中、PPROT 为 Secure 特权数据属性。

#### Acceptance Criteria

- 遍历管理掩码内外身份及全部 PPROT；仅满足全部条件的管理事务访问受保护 CSR。

### LRS.REG.APB_SECURE_DEMUX.MAP.006

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.MAP.006
category: REG
feature: map
priority: P0
status: active
source_ref:
- CONTRACT:§7 完整寄存器映射
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

软件 ABI 应保持输入契约第 7 节的全局、DFX 和每端口寄存器名称、地址、访问属性、复位值及裁剪语义。字段结构交由寄存器 owner 建模，本 LRS 不重复维护位表。

#### Acceptance Criteria

- 将寄存器 owner 生成的地址/字段/复位/访问清单逐项与受控契约第 7 节比较；任何差异必须评审。

### LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007

<!-- LRS_META
id: LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007
category: REG
feature: commitstatus
priority: P0
status: active
source_ref:
- CONTRACT:§7.1 提交状态
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

通过管理与基本 CSR 检查后，提交状态分别记录最近成功或失败；失败原因按掩码、全局锁、端口锁、完整性排序，多个端口选择最低编号；基本检查失败不得改变提交状态。

#### Acceptance Criteria

- 交叉非法掩码、多个锁和完整性故障，检查 COMMIT_STATUS；总线日志错误码仍按第 9.1 节，两个字段不可混为同一优先级。

### LRS.FUNC.APB_SECURE_DEMUX.ERRORPRIORITY.008

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.ERRORPRIORITY.008
category: FUNC
feature: errorpriority
priority: P0
status: active
source_ref:
- CONTRACT:§9.1 错误编码
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

外设主错误按 MULTI_HIT、ADDR_MISS、ID_INVALID、INTEGRITY_BLOCK、PORT_DISABLED、INSTR_DENIED、READ/WRITE_DENIED、DFX_FORCED_DENY 排序；CSR 按授权、对齐、选通、存在性、访问类型、锁、命令、完整性排序。

#### Acceptance Criteria

- 构造多条件并发故障，检查首原因；未授权请求不得通过错误原因泄漏敏感寄存器是否实现。

