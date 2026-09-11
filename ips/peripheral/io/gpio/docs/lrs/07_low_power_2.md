# GPIO LRS：休眠与安全覆盖（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.LP.GPIO.LP006.002

<!-- LRS_META
id: LRS.LP.GPIO.LP006.002
category: LP
feature: lp006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-LP-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-LP-006 定义的场景下，软件需要降低输入处理功耗时显式配置 IN_ENABLE；若依赖主域中断唤醒则不能停其时钟。

#### Acceptance Criteria

- 软件需要降低输入处理功耗时显式配置 IN_ENABLE；若依赖主域中断唤醒则不能停其时钟。
- 逐拍检查 sleep 请求建立/解除、同拍 APB 写、safe 抢占、停钟及恢复，比较最终 OUT/OE 与 ack。

