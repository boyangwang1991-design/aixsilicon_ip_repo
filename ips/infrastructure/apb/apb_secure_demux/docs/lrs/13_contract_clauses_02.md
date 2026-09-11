# 非编号契约条款补充需求

这些条目补齐原文表格和正文中的强制行为。结构明细继续引用受控契约，不导入寄存器位表。

### LRS.FUNC.APB_SECURE_DEMUX.LOGFORMAT.009

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.LOGFORMAT.009
category: FUNC
feature: logformat
priority: P0
status: active
source_ref:
- CONTRACT:§9.2 记录格式
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

每条记录包含固定八个 32 bit 字，记录原始地址、有效身份及保护属性、读写、原因和来源、端口有效性、SETUP 策略版本、时间戳、序号和选通；未关联事务和无效字段清零，不记录原始读写数据。

#### Acceptance Criteria

- 逐字对照第 9.2 节编码，覆盖无关联合成事件、端口 0 和主体 0 的有效值，确认有效零与无效字段可区分。

### LRS.FUNC.APB_SECURE_DEMUX.IRQMAP.010

<!-- LRS_META
id: LRS.FUNC.APB_SECURE_DEMUX.IRQMAP.010
category: FUNC
feature: irqmap
priority: P0
status: active
source_ref:
- CONTRACT:§10 中断位表
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

RAW 事件应按输入契约第 10 节位表映射访问拒绝、CSR 错误、空洞、多命中、完整性、丢失、下游错误、等待和 DFX；同一次失败可置多个相关位。

#### Acceptance Criteria

- 逐一触发九类事件及 ADDR_MISS+ACCESS_DENIED、MULTI_HIT+ACCESS_DENIED 组合；检查未相关位保持。

### LRS.DFX.APB_SECURE_DEMUX.REVOKE.011

<!-- LRS_META
id: LRS.DFX.APB_SECURE_DEMUX.REVOKE.011
category: DFX
feature: revoke
priority: P0
status: active
source_ref:
- CONTRACT:§11 注入边沿规则
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

注入匹配、武装消耗和事务 TEST 标记在 SETUP 结束边沿确定；该边沿硬件授权低时不得触发，已触发拒绝不因随后撤销而改变。授权撤销优先于同周期武装命令并返回 CFG_UNAUTHORIZED。

#### Acceptance Criteria

- 在 SETUP 前、采样边沿和 ACCESS 中撤销授权，核对消费次数、返回原因和 TEST 标记。

### LRS.DFX.APB_SECURE_DEMUX.MUTEX.012

<!-- LRS_META
id: LRS.DFX.APB_SECURE_DEMUX.MUTEX.012
category: DFX
feature: mutex
priority: P0
status: active
source_ref:
- CONTRACT:§11 注入边沿规则
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

强制拒绝与完整性注入模式互斥；已有任一武装时再次武装返回命令错误；WAIT_HIT 清除与新阈值事件同周期时新事件保留。

#### Acceptance Criteria

- 交叉两种武装与重复命令；构造清除/新阈值同周期并检查 WAIT_HIT 为一。

### LRS.PERF.APB_SECURE_DEMUX.MODES.013

<!-- LRS_META
id: LRS.PERF.APB_SECURE_DEMUX.MODES.013
category: PERF
feature: modes
priority: P0
status: active
source_ref:
- CONTRACT:§5.2/§5.3 模式时序
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

直接模式的合法零等待外设访问不得增加上游等待；寄存模式恰增加一个上游等待周期并完整保留请求；两模式的本地 CSR 和拒绝均在第一个 ACCESS 完成。

#### Acceptance Criteria

- 逐周期测量下游零等待及长等待，两模式完成延迟仅相差一个周期；本地访问延迟不受模式影响。

### LRS.CONS.APB_SECURE_DEMUX.PPA.014

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.PPA.014
category: CONS
feature: ppa
priority: P0
status: active
source_ref:
- CONTRACT:§14/§15.3 综合验收
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

交付应报告直接与寄存两种模式、典型与最大配置的综合面积、关键路径和约束；禁止无工艺依据宣称 MHz、功耗或面积达标。

#### Acceptance Criteria

- 保存各配置综合与 STA 原始报告、工艺库/角和输入哈希；目标尚未提供时标明未签核。

### LRS.CONS.APB_SECURE_DEMUX.VERIFICATION.015

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.VERIFICATION.015
category: CONS
feature: verification
priority: P0
status: active
source_ref:
- CONTRACT:§15.1/§15.2/§15.3
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

强制需求须建立 REQ→Feature→Test/Assertion 追踪，必需测试和强制功能 bins 应通过或有真实评审豁免；拒绝无副作用、锁不可绕过、原子提交及 onehot0 须具有形式或等效可审计穷尽证据。

#### Acceptance Criteria

- 比较需求集合与 trace；逐项核对日志、断言、覆盖和形式证明边界，有限随机仿真不得标为穷尽证明。

### LRS.CONS.APB_SECURE_DEMUX.DELIVERY.016

<!-- LRS_META
id: LRS.CONS.APB_SECURE_DEMUX.DELIVERY.016
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- CONTRACT:§16 实现交付件
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

完整交付应包含参数化 RTL、HWIF 契约、寄存器描述及派生软件接口、初始化/更新/锁定/中断示例、UVM 验证、集成配置检查、FuseSoC、用户和集成文档及质量证据。

#### Acceptance Criteria

- 按 full_process_status.md 逐项检查文件、来源和有效门禁；缺失项明确记录为未完成。

