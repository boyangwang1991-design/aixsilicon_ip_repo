# GPIO LRS：并发事务优先级

### LRS.FUNC.GPIO.RACE.001

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.001
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/主域复位 vs 主业务写/事件
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

主域复位 vs 主业务写/事件 发生竞争时，IP 应满足：复位优先，业务事务不计完成；APB上游与主域同步复位。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“复位优先，业务事务不计完成；APB上游与主域同步复位”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.002

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.002
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/W1C vs 新中断/诊断/唤醒
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

W1C vs 新中断/诊断/唤醒 发生竞争时，IP 应满足：新事件置位优先。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“新事件置位优先”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.003

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.003
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/FIFO POP vs PUSH
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FIFO POP vs PUSH 发生竞争时，IP 应满足：按13节处理，满可同拍换入。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“按13节处理，满可同拍换入”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.004

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.004
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/FIFO FLUSH vs PUSH
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

FIFO FLUSH vs PUSH 发生竞争时，IP 应满足：清旧队列，新事件按丢失记录。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“清旧队列，新事件按丢失记录”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.005

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.005
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/清首访问错误 vs 新错误
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

清首访问错误 vs 新错误 发生竞争时，IP 应满足：记录新错误。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“记录新错误”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.006

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.006
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/软件写锁定位
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件写锁定位 发生竞争时，IP 应满足：整笔错误，无部分更新。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“整笔错误，无部分更新”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.007

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.007
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/sleep进入 vs OUT写
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

sleep进入 vs OUT写 发生竞争时，IP 应满足：捕获旧物理输出，正常锁存接收新写。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“捕获旧物理输出，正常锁存接收新写”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.008

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.008
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/safe请求 vs sleep
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

safe请求 vs sleep 发生竞争时，IP 应满足：safe覆盖优先，休眠状态机继续保持。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“safe覆盖优先，休眠状态机继续保持”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.009

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.009
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/IRQ配置变化 vs 边沿
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IRQ配置变化 vs 边沿 发生竞争时，IP 应满足：新配置生效边沿重建基线，不解释为输入边沿。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“新配置生效边沿重建基线，不解释为输入边沿”；错开一拍作为对照。

### LRS.FUNC.GPIO.RACE.010

<!-- LRS_META
id: LRS.FUNC.GPIO.RACE.010
category: FUNC
feature: race
priority: P0
status: active
source_ref:
- gpio_contract.md#§16/软件快照 vs 硬件快照
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

软件快照 vs 硬件快照 发生竞争时，IP 应满足：合并一次。

#### Acceptance Criteria

- 将两类激励对齐到同一完成/采样边沿，结果为“合并一次”；错开一拍作为对照。

