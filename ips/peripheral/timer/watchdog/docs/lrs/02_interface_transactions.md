# Watchdog：跨时钟事务与复位交错

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.INTF.WATCHDOG.CDC.001

<!-- LRS_META
id: LRS.INTF.WATCHDOG.CDC.001
category: INTF
feature: cdc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CDC-001
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

所有跨域状态修改通过单个单在途命令邮箱执行。APB 写成功只表示命令被邮箱接收；CMD_STATUS.EXEC_DONE 和 DONE_SEQ 表示 WDT 域执行完成。忙时新状态修改命令返回 PSLVERR/BUSY，不排队、不覆盖。

#### Acceptance Criteria

- APB 接收与域内执行分离；忙时拒绝新命令，DONE_SEQ/RESULT 只反映实际完成。

## LRS.INTF.WATCHDOG.CDC.002

<!-- LRS_META
id: LRS.INTF.WATCHDOG.CDC.002
category: INTF
feature: cdc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CDC-002
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

单在途命令的 channel/client/op/data/source/auth 与完整配置快照应从接收到执行保持一致，跨域传递不得撕裂。每条命令最多执行一次，执行序号为 32-bit 自然回卷数，相邻命令可区分。

#### Acceptance Criteria

- 任意时钟比下请求负载一致且最多执行一次；序号跨 0xffffffff 回卷仍可区分相邻命令。

## LRS.INTF.WATCHDOG.CDC.003

<!-- LRS_META
id: LRS.INTF.WATCHDOG.CDC.003
category: INTF
feature: cdc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CDC-003
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

命令邮箱、请求序号及完成记录应在 preset_n 和 warm_reset_evt 下保留。preset_n 只复位 APB 接口事务、staging、选择器及接口输出镜像；已接收命令继续完成且不重发。重启软件先查询 BUSY/DONE_SEQ/RESULT 再发下一命令。

#### Acceptance Criteria

- 在请求/接收/执行/应答各相位施加 preset，已接收命令不丢失不重放，完成记录可查询。

## LRS.INTF.WATCHDOG.CDC.004

<!-- LRS_META
id: LRS.INTF.WATCHDOG.CDC.004
category: INTF
feature: cdc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CDC-004
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

warm_reset_evt 到达 WDT 域时取消尚未执行的命令，结果 CANCELED_RESET；已经执行命令不回滚。该边沿服务不得在恢复启动后被重放。POR 同时初始化两个域邮箱；任何单域功能复位不得清握手 toggle 造成伪命令。

#### Acceptance Criteria

- warm 前已执行结果不回滚；未执行命令完成为 CANCELED_RESET，同拍服务不在重启后重放。

## LRS.INTF.WATCHDOG.CDC.005

<!-- LRS_META
id: LRS.INTF.WATCHDOG.CDC.005
category: INTF
feature: cdc
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-CDC-005
applicability:
  expr: 'true'
verification_method:
- simulation
- static
- review
END_LRS_META -->

#### Requirement

wdt_clk 停止后邮箱可能一直 BUSY；APB 状态读仍可完成，软件不可假定完成并重发。独立时钟监视器负责该失效。邮箱握手非法状态在 SAFETY 实例置 CDC_PROTOCOL。

#### Acceptance Criteria

- 停 wdt_clk 时状态读可完成且 BUSY 保持；恢复后不重发；SAFETY 非法握手产生 CDC_PROTOCOL。

