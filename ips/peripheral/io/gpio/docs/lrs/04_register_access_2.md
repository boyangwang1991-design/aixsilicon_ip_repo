# GPIO LRS：APB访问（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.REG.GPIO.BUS006.001

<!-- LRS_META
id: LRS.REG.GPIO.BUS006.001
category: REG
feature: bus006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-006 定义的场景下，AON 使用主域 staging/命令/结果窗口，不拉长 APB 等待。

#### Acceptance Criteria

- AON 使用主域 staging/命令/结果窗口，不拉长 APB 等待。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

### LRS.REG.GPIO.BUS006.002

<!-- LRS_META
id: LRS.REG.GPIO.BUS006.002
category: REG
feature: bus006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-BUS-006
applicability:
  expr: 'true'
verification_method:
- simulation
- formal
END_LRS_META -->

#### Requirement

在 GPIO-BUS-006 定义的场景下，忙时冲突命令返回错误，软件读 BUSY/DONE/TIMEOUT。禁止等待停止的 AON 时钟而永久占用 APB。

#### Acceptance Criteria

- 忙时冲突命令返回错误，软件读 BUSY/DONE/TIMEOUT。禁止等待停止的 AON 时钟而永久占用 APB。
- 覆盖 Setup/Access、背靠背访问及合法/非法地址、PSTRB、PPROT；只在合法完成边沿产生业务副作用。

