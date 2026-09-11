# DFX 与可观测性

DFX 既受 DFX_EN 裁剪，又受管理授权和硬件授权约束。busy/目标/等待观测门控不影响 IRQ/alert。
硬件授权撤销解除未触发武装，不能撤销已经决定的拒绝，也不能取消已发出的总线事务。

强制拒绝与完整性注入模式互斥，仅匹配原本允许的主体/目标请求才消耗武装。授权在触发边沿为低时不得消费。
合成日志没有关联事务、不访问外设且不增加真实拒绝计数；INTR_TEST 只测试 DFX 通知，不生成日志。

统计区分成功、权限拒绝、下游错误和等待；所有饱和计数清除后再累加同周期事件。
等待阈值为观测功能，不是 watchdog 取消机制；同一事务触发一次，新事务重新计数，阈值零禁用。

## 架构级验证钩子

保留策略存储、锁编码、提交掩码、版本、准入判定和事件候选的可追踪层次语义，以供后续验证绑定。
不新增功能性调试后门或旁路端口。实际绑定路径、断言和用例由 LLD/VPLAN 冻结。
<!-- HLD_VERIFY_HOOK_META
id: HLD.HOOK.APB_SECURE_DEMUX.STORAGE_FAULT
type: fault_injection
architecture_ref: HLD.MOD.APB_SECURE_DEMUX.POLICY
description: 验证环境真实翻转 active/shadow/lock 存储，功能接口不新增注错后门。
END_HLD_VERIFY_HOOK_META -->

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.APB_SECURE_DEMUX.DFX_AUTH
constraint: 授权撤销优先于同周期武装命令；既有在途传输不能取消。
status: active
req_ref:
- LRS.DFX.APB_SECURE_DEMUX.DFX.00101
- LRS.DFX.APB_SECURE_DEMUX.DFX.00102
- LRS.DFX.APB_SECURE_DEMUX.DFX.00201
- LRS.DFX.APB_SECURE_DEMUX.DFX.00202
- LRS.DFX.APB_SECURE_DEMUX.DFX.003
- LRS.DFX.APB_SECURE_DEMUX.DFX.004
- LRS.DFX.APB_SECURE_DEMUX.DFX.00501
- LRS.DFX.APB_SECURE_DEMUX.DFX.00502
END_HLD_CONSTRAINT_META -->

