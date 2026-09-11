# GPIO LRS：验证交付约束（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.CONS.GPIO.VER001.001

<!-- LRS_META
id: LRS.CONS.GPIO.VER001.001
category: CONS
feature: ver001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-001
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-001 定义的场景下，使用独立功能参考模型检查输入处理、中断、FIFO和AON命令；不能仅复制 RTL 分支形成自证。功能覆盖包含上述边界交叉；不可达覆盖项需有配置依据。

#### Acceptance Criteria

- 使用独立功能参考模型检查输入处理、中断、FIFO和AON命令；不能仅复制 RTL 分支形成自证。功能覆盖包含上述边界交叉；不可达覆盖项需有配置依据。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

### LRS.CONS.GPIO.VER002.001

<!-- LRS_META
id: LRS.CONS.GPIO.VER002.001
category: CONS
feature: ver002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-002
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-002 定义的场景下，SVA 至少断言：非法APB事务无业务更新；OE不得越过能力/所有权；开漏不会主动驱动高；置位优先；锁不被软件清；AON BUSY数据稳定；FIFO容量边界；首次有效无伪边沿。

#### Acceptance Criteria

- SVA 至少断言：非法APB事务无业务更新；OE不得越过能力/所有权；开漏不会主动驱动高；置位优先；锁不被软件清；AON BUSY数据稳定；FIFO容量边界；首次有效无伪边沿。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

### LRS.CONS.GPIO.VER003.001

<!-- LRS_META
id: LRS.CONS.GPIO.VER003.001
category: CONS
feature: ver003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-003
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-003 定义的场景下，完成 lint、CDC、RDC、综合检查；所有未解决高风险问题阻止验收。

#### Acceptance Criteria

- 完成 lint、CDC、RDC、综合检查；所有未解决高风险问题阻止验收。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

### LRS.CONS.GPIO.VER003.002

<!-- LRS_META
id: LRS.CONS.GPIO.VER003.002
category: CONS
feature: ver003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-003
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-003 定义的场景下，数字仿真不能证明亚稳态MTBF或PAD电气波形；须交付同步器约束与PAD集成假设。

#### Acceptance Criteria

- 数字仿真不能证明亚稳态MTBF或PAD电气波形；须交付同步器约束与PAD集成假设。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

### LRS.CONS.GPIO.VER004.001

<!-- LRS_META
id: LRS.CONS.GPIO.VER004.001
category: CONS
feature: ver004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-004
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-004 定义的场景下，每项需求关联至少一项检查/测试/分析证据；验证计划在RTL完成前形成，并与架构同步更新。

#### Acceptance Criteria

- 每项需求关联至少一项检查/测试/分析证据；验证计划在RTL完成前形成，并与架构同步更新。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

### LRS.CONS.GPIO.VER004.002

<!-- LRS_META
id: LRS.CONS.GPIO.VER004.002
category: CONS
feature: ver004
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-VER-004
applicability:
  expr: 'true'
verification_method:
- review
- static
END_LRS_META -->

#### Requirement

在 GPIO-VER-004 定义的场景下，验收要求全部必备及所启用增强功能通过，不允许以未实现而静默读0替代已声明功能。

#### Acceptance Criteria

- 验收要求全部必备及所启用增强功能通过，不允许以未实现而静默读0替代已声明功能。
- 检查交付证据清单、来源与逐需求追踪；仅有计划或工具 PASS 摘要不视为完成。

