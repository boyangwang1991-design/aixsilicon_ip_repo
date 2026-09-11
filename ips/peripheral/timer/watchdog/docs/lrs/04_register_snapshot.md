# Watchdog：一致快照

本分册描述外部行为及验收要求；原契约编号用于来源追踪，阶段状态以文档控制与 G0 记录为准。

## LRS.REG.WATCHDOG.SNP.001

<!-- LRS_META
id: LRS.REG.WATCHDOG.SNP.001
category: REG
feature: snp
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SNP-001
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

SNAPSHOT 命令在 WDT 域一个边沿捕获指定通道的计数、状态、SEEN/缺失、统计、token、故障信息、active 参数及版本；整个镜像保持到下一次快照成功。普通读只读 pclk 可用镜像，不等待 WDT 域。

#### Acceptance Criteria

- 改变运行状态时验证全部字段来自同一 WDT 边沿；下一次成功快照前整个镜像保持。

## LRS.REG.WATCHDOG.SNP.002

<!-- LRS_META
id: LRS.REG.WATCHDOG.SNP.002
category: REG
feature: snp
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SNP-002
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

SNAP_VALID=0 时镜像读零；完成时提供 SNAP_SEQ 与配置版本。64-bit 高低字来自同一镜像。快照捕获该边沿状态更新后的值；软件想判断故障瞬间应读 FIRST_FAULT 的专用故障快照。

#### Acceptance Criteria

- 无效镜像读零；高低字、版本、SNAP_SEQ 同源；快照为本边沿更新后状态。

## LRS.REG.WATCHDOG.SNP.003

<!-- LRS_META
id: LRS.REG.WATCHDOG.SNP.003
category: REG
feature: snp
priority: P0
status: active
source_ref:
- watchdog_contract.md:WDT-SNP-003
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

CMD 状态、能力、IRQ 镜像可直接读，其他运行值需 SNAPSHOT 后读。镜像值允许陈旧，寄存器名称/驱动接口必须区分 staging、active snapshot 和即时事务状态。

#### Acceptance Criteria

- 即时 CMD/能力/IRQ 与快照运行值区分；未发新快照时运行值允许陈旧且无读取副作用。

