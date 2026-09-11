# Watchdog：配置校验与软件可见属性

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.REG.WATCHDOG.REG.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.REG.001
category: REG
feature: reg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REG-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在第3/5/7/8/10章约束外，提交必须满足：

1. WIN_EN=0 时 WIN_MIN=0；WIN_EN=1 时 WIN_MIN<TIMEOUT。
2. PREWARN_EN=1 时 `WIN_MIN<=PRETIMEOUT<TIMEOUT`；关闭时 PRETIMEOUT 必须0。
3. BOOT_EN=0 时 BOOT_TIMEOUT=0；BOOT_EN=1 时 BOOT_TIMEOUT>0。
4. SINGLE 的 REQUIRE_MASK=1；未参与客户端的配置可保留但不得生效。
5. ALIVE 的 WIN_EN=0；FLOW 的 SERVICE_MODE=0；未支持增强时 SUP_MODE 必须 SINGLE。
6. DIRECT_SYSTEM 时 LOCAL_DELAY=FINAL_DELAY=0，ALLOW_LOCAL_RECOVERY=0，RECOVERY_LIMIT=0。
7. LOCAL_THEN_SYSTEM 时 FINAL_DELAY>LOCAL_DELAY；ALLOW_LOCAL_RECOVERY=1 时 RECOVERY_LIMIT>0，否则 RECOVERY_LIMIT=0。
8. 每个已选客户端的 OWNER_SOURCE 位宽合法；ALIVE/FLOW 特定字段按模式校验；未使用的 ALIVE/FLOW 字段允许保留但不参与判定。
9. 活动配置中的锁定限制和 HARD_CFG_LOCK 优先于 staged 参数。
10. 高于实现位宽的计数/分频位为0；任何截断可能改变时间的配置必须拒绝，禁止自动裁低。

#### Acceptance Criteria

- 合法边界整组接受；逐项违反阈值、模式、来源位宽、策略、锁和高位约束均整组拒绝。

## LRS.REG.WATCHDOG.REG.002

<!-- LRS_META
id: LRS.REG.WATCHDOG.REG.002
category: REG
feature: reg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REG-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

默认 IRQ_ENABLE=0，但默认 FAULT_POLICY 的强制位始终置1，不能因为中断关闭而关闭复位。安全档默认 PAUSE_DEBUG=0；NO_STOP_MASK 默认全1。

#### Acceptance Criteria

- 默认 IRQ 为零仍可复位；安全默认禁止调试暂停，默认启动后不可停止。

## LRS.REG.WATCHDOG.REG.003

<!-- LRS_META
id: LRS.REG.WATCHDOG.REG.003
category: REG
feature: reg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REG-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

运行状态字段、LOCK 和配置值的普通读取均以指定快照为准。软件必须等待当前 SNAPSHOT 的 DONE_SEQ 才使用 SNAP_SEQ；不能用陈旧 BUSY=0 或早先 EXEC_DONE 推断新的写已执行。

#### Acceptance Criteria

- 当前 SNAPSHOT 完成序号确认后才使用镜像；旧 BUSY/EXEC_DONE 不被误认作当前命令完成。

## LRS.REG.WATCHDOG.REG.004

<!-- LRS_META
id: LRS.REG.WATCHDOG.REG.004
category: REG
feature: reg
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-REG-004
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

IRQ_ENABLE 允许位0～18；IRQ_TEST 置事件位15。FAULT_POLICY 仅接收非致命监督事件位1～10，且强制位必须保持1；位0及11～31必须写0，致命响应由硬件固定实现。CFG_COMMIT 校验失败置事件18；普通取消和忙返回不属于配置错误。CLIENT_DEADLINE 在非FLOW模式只读elapsed为0；服务模式不支持token时CLIENT_TOKEN读0。

#### Acceptance Criteria

- 非法 IRQ/POLICY 位拒绝；提交失败置 CFG_REJECTED，忙/取消不置；非适用 Deadline/token 读零。

