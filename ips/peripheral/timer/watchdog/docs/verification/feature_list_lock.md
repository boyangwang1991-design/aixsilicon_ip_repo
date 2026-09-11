# 权限解锁和只置位锁：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.LOCK
name: 权限解锁和只置位锁
description: 权限解锁和只置位锁的可执行正确性证明
priority: must
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.SEC.WATCHDOG.AUTH.001
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

逐类权限拒绝；双解锁同源/异源；第二笔32周期边界与额度64周期；错误敏感命令消耗额度；四把锁及硬锁；warm/preset后查询。

独立判据：可信侧带捕获后不随引脚变化；额度一次性；所有拒绝无喂狗；锁只能规定置位/POR清除；暂停与故障不能绕过。

风险与边界：权限×命令×状态×信用年龄；同拍锁与后续命令。

### LRS.INTF.WATCHDOG.IF.001

未使用可信来源功能的系统必须将来源固定为 0，并在外部限制服务访问者；不得宣称任务身份隔离。权限拒绝不得转化为喂狗。

验收：无可信来源时固定来源 0，并记录外部访问控制；拒绝事务不刷新任何通道。

### LRS.REG.WATCHDOG.CFG.005

UNLOCK 两笔常量依次为 `0xC0DE1234`、`0x3F21EDCB`，来源必须相同，在 32 个 wdt_clk 周期内完成；窗口从第一笔执行边沿起算，规则同服务序列。成功后提供一次敏感命令额度，在 64 个 wdt_clk 周期后过期；不暂停。敏感命令为 CFG_COMMIT/START/STOP/LOCK/DIAG_CLEAR/FAULT_INJECT。额度在命令被 WDT 域处理时消耗，失败也消耗；staging 写不消耗额度。

验收：密钥来源一致且边界 32 周期有效；额度 64 周期过期，失败敏感命令也消费一次额度。

### LRS.REG.WATCHDOG.CFG.006

CFG_LOCK、ENABLE_LOCK、DEBUG_LOCK、DIAG_LOCK 为只置位锁，置位即时生效，只能 POR 清除。HARD_CFG_LOCK_MASK 对应 CFG_LOCK POR 值为 1。CFG_LOCK 禁止配置提交但允许对合法已有配置 START；ENABLE_LOCK 禁止 STOP；DEBUG_LOCK 强制禁止调试暂停；DIAG_LOCK 禁止注入。锁不阻止合法服务。

验收：四种锁只能置位；preset/warm/局部恢复不清锁，POR 使用参数默认，合法服务不受锁影响。

### LRS.SEC.WATCHDOG.AUTH.001

配置、服务、诊断和测试权限应来自可信外部控制，并随事务捕获。软件可写 client/source 索引不得充当身份授权；拒绝访问不得刷新监督。

验收：逐类撤销授权确认拒绝且不改变运行周期。；集成说明列出可信侧带和外部访问控制责任，APB PPROT 不被宣称为通用 Master ID。
