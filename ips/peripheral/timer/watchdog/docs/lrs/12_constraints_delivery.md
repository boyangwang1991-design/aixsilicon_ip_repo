# Watchdog：完整交付与软件一致性

## LRS.CONS.WATCHDOG.DELIVERY.001

<!-- LRS_META
id: LRS.CONS.WATCHDOG.DELIVERY.001
category: CONS
feature: delivery
priority: P0
status: active
source_ref:
- watchdog_contract.md:§20、§19.3
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

应交付规范 LRS、HLD、LLD、SystemRDL 及派生视图、参数化 RTL、软件驱动、完整验证环境/RAL/参考模型/断言/覆盖率、约束、安全说明、用户及集成手册、验证报告和 FuseSoC 入口。交付追踪必须区分计划、实现、实测、冻结和发布状态。

#### Acceptance Criteria

- 全流程交付映射表中每项均有真实文件、内容与对应证据；不使用目录存在或短摘要替代。

## LRS.CONS.WATCHDOG.SOFTWARE.001

<!-- LRS_META
id: LRS.CONS.WATCHDOG.SOFTWARE.001
category: CONS
feature: software
priority: P0
status: active
source_ref:
- watchdog_contract.md:§17、§19.3
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

驱动应按原契约 §17 实现初始化、服务、故障读取和恢复协作：命令逐笔核对序号/结果、服务超时不盲目重发、选择器和邮箱互斥、锁与解锁额度对应。喂狗应基于真实任务健康条件。

#### Acceptance Criteria

- 可执行示例覆盖服务成功、过早、超时、局部恢复、最终升级和暖复位留痕。
- 中断清除不刷新或撤销活动故障，重启先读首次诊断。

