# 全表原子快照：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.SNAPSHOT
name: 全表原子快照
description: 全表原子快照的可执行正确性证明
priority: must
req_ref:
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

随机更新各客户端后SNAPSHOT；W64跨低字回卷；计时/服务/故障同拍快照；改变客户端选择器；停WDT读取旧镜像；preset保留上次成功快照，仅复位选择器及接口输出镜像。

独立判据：命令执行边沿之后的模型状态生成整表期望；高低字、token、版本、序号同一代；普通读不更新；SNAP_VALID=0全镜像零。

风险与边界：通道/客户端端点×快照并发事件×时钟比；保持到下一成功快照。

### LRS.REG.WATCHDOG.CLIENT_WINDOW.001

每通道应独立保存每客户端 staging 配置和快照客户端表，选择器只选择访问目标。提交应捕获全部客户端配置，快照应捕获整个客户端表，SERVICE 接收时应捕获当时选择器。

验收：交错修改多个客户端后整组提交，每客户端值保持独立。；快照完成后切换选择器只读已有镜像，不重新访问运行域。

### LRS.REG.WATCHDOG.SNP.001

SNAPSHOT 命令在 WDT 域一个边沿捕获指定通道的计数、状态、SEEN/缺失、统计、token、故障信息、active 参数及版本；整个镜像保持到下一次快照成功。普通读只读 pclk 可用镜像，不等待 WDT 域。

验收：改变运行状态时验证全部字段来自同一 WDT 边沿；下一次成功快照前整个镜像保持。

### LRS.REG.WATCHDOG.SNP.002

SNAP_VALID=0 时镜像读零；完成时提供 SNAP_SEQ 与配置版本。64-bit 高低字来自同一镜像。快照捕获该边沿状态更新后的值；软件想判断故障瞬间应读 FIRST_FAULT 的专用故障快照。

验收：无效镜像读零；高低字、版本、SNAP_SEQ 同源；快照为本边沿更新后状态。

### LRS.REG.WATCHDOG.SNP.003

CMD 状态、能力、IRQ 镜像可直接读，其他运行值需 SNAPSHOT 后读。镜像值允许陈旧，寄存器名称/驱动接口必须区分 staging、active snapshot 和即时事务状态。

验收：即时 CMD/能力/IRQ 与快照运行值区分；未发新快照时运行值允许陈旧且无读取副作用。
