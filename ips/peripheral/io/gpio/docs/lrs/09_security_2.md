# GPIO LRS：访问安全（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.SEC.GPIO.SEC006.002

<!-- LRS_META
id: LRS.SEC.GPIO.SEC006.002
category: SEC
feature: sec006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-SEC-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-SEC-006 定义的场景下，违规设置 FAULT_STATUS.ACCESS 并在空闲的首故障槽记录地址和 PPROT，不记录写数据。FAULT_IRQ_ENABLE 控制其是否输出中断。

#### Acceptance Criteria

- 违规设置 FAULT_STATUS.ACCESS 并在空闲的首故障槽记录地址和 PPROT，不记录写数据。FAULT_IRQ_ENABLE 控制其是否输出中断。
- 对正文保护对象执行直接/别名、同值/混合位写及暖/冷复位；非法事务所有业务目标均保持。

