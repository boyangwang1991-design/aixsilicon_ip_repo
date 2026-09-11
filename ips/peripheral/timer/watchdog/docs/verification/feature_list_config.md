# 构建参数与能力：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.CONFIG
name: 构建参数与能力
description: 构建参数与能力的可执行正确性证明
priority: must
req_ref:
- LRS.CFG.WATCHDOG.NUM_CHANNELS.001
- LRS.CFG.WATCHDOG.COUNTER_WIDTH.001
- LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001
- LRS.CFG.WATCHDOG.NUM_CLIENTS.001
- LRS.CFG.WATCHDOG.SOURCE_WIDTH.001
- LRS.CFG.WATCHDOG.SYNC_STAGES.001
- LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001
- LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001
- LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001
- LRS.CFG.WATCHDOG.SAFETY_EN.001
- LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001
- LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001
- LRS.CFG.WATCHDOG.AUTO_START_MASK.001
- LRS.CFG.WATCHDOG.NO_STOP_MASK.001
- LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001
- LRS.CFG.WATCHDOG.DEFAULT_CFG.001
- LRS.CFG.WATCHDOG.PROFILE.001
- LRS.CFG.WATCHDOG.PROFILE.002
- LRS.CFG.WATCHDOG.PROFILE.003
- LRS.CFG.WATCHDOG.PAR.001
- LRS.CFG.WATCHDOG.PAR.002
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
proof_methods:
- static
- simulation
END_FEATURE_META -->

遍历PC全部188配置；合法配置真实elaborate并读能力；非法配置以独立预期核对拒绝原因；三个产品档均做功能代表运行。

独立判据：无静默截断；合法配置能力与实际实例一致；非法值或结构依赖错误必须在构建时失败。

风险与边界：参数×合法性×能力裁剪；通道1/16、客户端1/32、W32/48/64、同步2/3/4及16参数风险组合。

### LRS.CFG.WATCHDOG.NUM_CHANNELS.001

`NUM_CHANNELS` 应配置独立监督通道数，合法值为 `1～16`，默认 `1`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `NUM_CHANNELS=1`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.COUNTER_WIDTH.001

`COUNTER_WIDTH` 应配置计数及阈值的统一位宽，合法值为 `[32, 48, 64]`，默认 `32`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `COUNTER_WIDTH=32`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001

`PRESCALE_WIDTH` 应配置分频配置有效位宽，合法值为 `1～16`，默认 `16`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `PRESCALE_WIDTH=16`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.NUM_CLIENTS.001

`NUM_CLIENTS` 应配置每通道客户端数，合法值为 `1～32`，默认 `1`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `NUM_CLIENTS=1`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SOURCE_WIDTH.001

`SOURCE_WIDTH` 应配置可信来源 ID 位宽，合法值为 `1～16`，默认 `4`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SOURCE_WIDTH=4`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SYNC_STAGES.001

`SYNC_STAGES` 应配置同步释放及跨域单比特传递的配置级数，合法值为 `[2, 3, 4]`，默认 `2`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SYNC_STAGES=2`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001

`SUPPORT_TOKEN_QA` 应配置动态令牌/问答服务能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SUPPORT_TOKEN_QA=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001

`SUPPORT_SUPERVISION` 应配置GROUP/ALIVE/FLOW 增强监督能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SUPPORT_SUPERVISION=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001

`SUPPORT_HW_EVENT` 应配置WDT 同域硬件事件接口能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SUPPORT_HW_EVENT=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.SAFETY_EN.001

`SAFETY_EN` 应配置自身安全诊断增强能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `SAFETY_EN=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001

`ALLOW_RUNTIME_UPDATE` 应配置运行计时配置的原子边界切换能力，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `ALLOW_RUNTIME_UPDATE=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001

`DIAG_INJECT_EN` 应配置受控诊断注入入口，生产默认关闭，合法值为 `[0, 1]`，默认 `0`。非法输入应拒绝，不能通过截断或静默降级改变配置语义。

验收：默认实例读回/体现 `DIAG_INJECT_EN=0`；合法值域端点及代表中间点可构建。；越界或非枚举值在生成/编译阶段报错；功能关闭时仍检查未支持访问的拒绝行为。

### LRS.CFG.WATCHDOG.AUTO_START_MASK.001

`AUTO_START_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择POR 后自动启动的通道，默认0。位图不得引用未实现通道。

验收：分别选中首/末/全部/无通道核对行为。；NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

### LRS.CFG.WATCHDOG.NO_STOP_MASK.001

`NO_STOP_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择启动后禁止软件停止的通道，默认全部已实现通道为 1。位图不得引用未实现通道。

验收：分别选中首/末/全部/无通道核对行为。；NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

### LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001

`HARD_CFG_LOCK_MASK` 应为 NUM_CHANNELS 位通道位图，用于选择POR 后即配置锁定的通道，默认0。位图不得引用未实现通道。

验收：分别选中首/末/全部/无通道核对行为。；NUM_CHANNELS 变化后默认位图仍符合上述语义；超范围输入拒绝。

### LRS.CFG.WATCHDOG.DEFAULT_CFG.001

每个通道应具有完整合法静态 DEFAULT_CFG。自动启动通道的默认配置必须在构建阶段校验，包含服务/监督模式、阈值、策略及全部必需客户端条件。默认 BOOT_EN=1，默认服务算法为双密钥；具体时间由实例声明，不能假定一个固定时长适用于所有时钟。

验收：逐通道检查 DEFAULT_CFG 满足原契约 §16.5 全部适用约束。；自动启动选中但默认配置不合法必须构建失败，不得静默关闭通道。

### LRS.CFG.WATCHDOG.PROFILE.001

STANDARD 应提供默认普通/窗口单通道实例；生产默认关闭诊断注入。

验收：构建参数、能力寄存器及产品档要求一致。；分别完成适用需求追踪、配置回归与真实 PPA 条件报告。

### LRS.CFG.WATCHDOG.PROFILE.002

SAFETY 应提供单通道自身诊断增强实例；生产默认关闭诊断注入。

验收：构建参数、能力寄存器及产品档要求一致。；分别完成适用需求追踪、配置回归与真实 PPA 条件报告。

### LRS.CFG.WATCHDOG.PROFILE.003

SUPERVISOR 应提供完整增强双通道、双客户端、64-bit 代表实例；生产默认关闭诊断注入。

验收：构建参数、能力寄存器及产品档要求一致。；分别完成适用需求追踪、配置回归与真实 PPA 条件报告。

### LRS.CFG.WATCHDOG.PAR.001

非法参数组合必须在生成/编译检查阶段报错。自动启动且默认配置非法时不得静默关闭 WDT。

验收：非法参数和非法自动启动默认配置均在生成或编译阶段失败；不得退化成关闭监督。

### LRS.CFG.WATCHDOG.PAR.002

能力寄存器必须反映实际 elaboration 结果；软件写入未实现模式返回 `UNSUPPORTED`，不改变运行状态。

验收：逐配置读能力与编译参数一致；选择裁剪模式得到 UNSUPPORTED，运行状态及计时不变。
