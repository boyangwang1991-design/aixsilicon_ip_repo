# GPIO LRS：AON唤醒（3）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.LP.GPIO.WAK012.001

<!-- LRS_META
id: LRS.LP.GPIO.WAK012.001
category: LP
feature: wak012
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-012
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-012 定义的场景下，PMU 仅在 COMMIT DONE、wake_req_o=0、主域 sleep_ack_o=1 及系统 PAD 接管完成后允许关电。

#### Acceptance Criteria

- PMU 仅在 COMMIT DONE、wake_req_o=0、主域 sleep_ack_o=1 及系统 PAD 接管完成后允许关电。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

### LRS.LP.GPIO.WAK012.002

<!-- LRS_META
id: LRS.LP.GPIO.WAK012.002
category: LP
feature: wak012
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-WAK-012
applicability:
  expr: AON_WAKE_EN == 1
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-WAK-012 定义的场景下，AON 检测全程运行，入睡边界发生事件应阻止关电或触发立即恢复；该最终仲裁属于 PMU。

#### Acceptance Criteria

- AON 检测全程运行，入睡边界发生事件阻止关电或触发立即恢复；该最终仲裁属于 PMU。
- 以异步时钟比、AON 停钟、每握手阶段暖复位、超时和迟到 ACK 检查命令次数、状态与活动配置。

