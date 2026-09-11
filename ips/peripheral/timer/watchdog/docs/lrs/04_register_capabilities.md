# Watchdog：软件可见寄存器能力

## LRS.REG.WATCHDOG.ACCESS.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.ACCESS.001
category: REG
feature: access
priority: P0
status: active
source_ref:
- watchdog_contract.md:§1、§16.1
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

IP 应提供本地即时只读信息、staging 配置、保持快照和命令访问四类软件可见寄存器能力。未定义位读零、保留位非零写拒绝；裁剪功能保留地址空间，不挪动其他寄存器。

#### Acceptance Criteria

- 逐访问类别检查读写/复位/拒绝语义。
- 不同配置对同一已定义地址保持一致，未实现位置返回规定错误。

## LRS.REG.WATCHDOG.IDENTITY.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.IDENTITY.001
category: REG
feature: identity
priority: P0
status: active
source_ref:
- watchdog_contract.md:§16.2
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

软件应可查询 IP 标识、版本、实际能力、在途命令状态、已发/已完成序号、结果及通道中断/复位/故障汇总。读事务完成状态不得清除完成记录。

#### Acceptance Criteria

- 读回符合实例能力；命令接收清 EXEC_DONE，完成置位，读不清。
- APB 同步拒绝不覆盖上一条 DONE 记录。

## LRS.REG.WATCHDOG.CLIENT_WINDOW.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.CLIENT_WINDOW.001
category: REG
feature: client_window
priority: P0
status: active
source_ref:
- watchdog_contract.md:§16.3
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

每通道应独立保存每客户端 staging 配置和快照客户端表，选择器只选择访问目标。提交应捕获全部客户端配置，快照应捕获整个客户端表，SERVICE 接收时应捕获当时选择器。

#### Acceptance Criteria

- 交错修改多个客户端后整组提交，每客户端值保持独立。
- 快照完成后切换选择器只读已有镜像，不重新访问运行域。

