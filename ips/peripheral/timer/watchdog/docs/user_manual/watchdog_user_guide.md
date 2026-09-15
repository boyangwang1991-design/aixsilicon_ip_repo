# Watchdog 1.0.0 用户手册

本文由受用户委托的 AI 编写，适用候选 IP 和 sw/watchdog.c；当前完成范围以
[统一报告](../../reports/report.md)为准。集成连接见[集成指南](../integration/watchdog_integration_guide.md)。

## 功能和使用条件

看门狗在应用完成健康检查后接受软件/硬件服务，超时后记录故障并升级响应。
支持启动期、窗口、双密钥和可选 token/QA、多客户端组/存活/流程监督、快照、暂停及恢复。
不要使用无条件喂狗循环掩盖任务失效。token/QA 是确定性错误检测，不是密码认证。
能力以实例参数和寄存器读回为准。STANDARD 默认单通道32-bit、16-bit预分频、
BOOT+DUAL_KEY，TIMEOUT/BOOT_TIMEOUT=65536 WDT tick，默认禁止停止。
tick 取决于监督时钟和预分频，不能当作固定毫秒数；按实际系统重新核算预算。

## 初始化场景

前置：POR释放、两时钟可用、可信配置授权有效，MMIO 回调能上报 PSLVERR 并包含 barrier。
调用方持有覆盖全部通道/主体的全局邮箱与间接选择寄存器互斥锁。

1. 读 IP_ID、VERSION、CAPABILITY0/1，确认实际通道数、位宽和能力。
2. 写通道 staging，逐客户端设置 CLIENT_SELECT 与配置字。
3. 完成两步解锁，每一步都等待匹配 DONE_SEQ；提交 COMMIT 并检查硬件结果。
4. 需要 START 时重新取得解锁额度，提交并检查完成；应用健康检查驱动后续服务。

窗口下限须小于超时；预告警位于窗口下限和超时之间，服务/监督模式必须由实例支持。
客户端掩码不得引用未实现主体。两步解锁在32个 WDT 周期内执行，额度在64周期后到期；
很慢 APB 时钟需预算真实握手延迟。NO_STOP 和硬配置锁不能通过反复重试绕过。
字段和示例见[寄存器编程指南](watchdog_register_programming_guide.md)。

## 服务与完成场景

前置：应用已确认客户端健康，无 pending 命令，持有全局互斥。
watchdog_service 一次提交一个服务字。双密钥先 KEY1 再 KEY2，每次检查驱动返回值、
硬件 result 和期限。组/存活/流程监督还必须遵守 epoch、计数与 checkpoint 约束。
硬件 ready/valid 源要提供真实健康信息和可信来源，不得把 PPROT 当作身份授权。

WDT_DRIVER_OK 表示取得一次完成，仍须检查 result；TIMEOUT 保留 pending_seq，
应继续 watchdog_poll，不能盲重发。驱动不提供线程锁；所有主体、通道和间接窗口由调用方串行化。
budget 为轮询次数而非固定时间，必须适配平台时钟和最大响应延迟。

## 快照、故障与恢复场景

前置：通道有效、邮箱可用。完成 watchdog_snapshot 后检查 SNAP_META/SNAP_SEQ，
再读取同一保持镜像的高低字。watchdog_snapshot_count 会核对镜像有效及序号。
清 IRQ 不等于清故障或喂狗；FIRST_FAULT 的 POR 丢失需系统外部持久化处理。
局部恢复只能由实际恢复完成实体发 done，保持到 ack，并双方回零。最终期限到达时
恢复不能撤销最终请求，系统复位管理器必须响应。

## 低功耗与诊断场景

仅在系统允许、配置允许且授权有效时请求暂停并等待 pause_ack。
恢复遵守系统时钟/复位顺序；关闭 WDT 时钟必须由独立时基检测失效。
受控注入用于诊断验证，不作为生产屏蔽复位机制。

## 异常处理与限制

| 返回/现象 | 处理 |
|---|---|
| BUSY/PENDING | 等待当前全局操作，不提交第二个命令 |
| IO/PSLVERR | 检查地址、对齐、通道、字节使能和权限，保留平台错误 |
| TIMEOUT | 保留 pending_seq 继续 poll，检查时钟和复位 |
| BAD_CONFIG/UNSUPPORTED | 对照实例能力修正 staging 后完整提交 |
| LOCKED/EXPIRED_UNLOCK | 核对不可逆锁和解锁周期预算 |
| 最终请求有效 | 由系统复位/安全管理器处理，清 IRQ 不会撤销 |

未提供芯片/Pad/PCB 或模拟时钟签核，不声明 ASIL 等级或诊断覆盖百分比。
详细责任见[安全说明](../safety_manual.md)。
