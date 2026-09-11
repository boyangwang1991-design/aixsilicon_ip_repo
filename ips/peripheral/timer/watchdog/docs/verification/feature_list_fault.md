# 故障记录与升级：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.FAULT
name: 故障记录与升级
description: 故障记录与升级的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
- LRS.CONS.WATCHDOG.VER.003
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

触发每类非致命及致命原因、同拍多原因；LOCAL_DELAY=0及FINAL_DELAY边界；FAULT期间服务/清IRQ/重复错误；FIRST与COUNT选择清除。

独立判据：故障边沿保存旧状态/配置及候选年龄；主原因独立优先表；E用未分频绝对周期；最终保持；W1C不能清活动请求；FIRST首次锁存与set优先。

风险与边界：故障位×策略×响应模式×清除；FIRST有效×多原因×计数饱和。

### LRS.FUNC.WATCHDOG.ESC.001

升级年龄 E 从故障边沿置零，以未分频 wdt_clk 计，每个后续边沿递增且不可暂停。要求 `0 <= LOCAL_DELAY < FINAL_DELAY`；LOCAL_DELAY=0 同故障边沿请求局部复位。到 FINAL_DELAY 同拍必最终升级，恢复事件不能覆盖。

验收：LOCAL_DELAY=0 同拍请求，FINAL_DELAY 精确到期升级；暂停和恢复边界不能推迟期限。

### LRS.FUNC.WATCHDOG.ESC.002

FAULT 状态服务、清 IRQ、重复错误、配置访问不能重新起算 E。致命自身故障不等待 LOCAL_DELAY/FINAL_DELAY，立即最终升级。最终输出为保持型请求，不用计数器回卷清除。

验收：FAULT 中反复访问/服务/故障不重算升级年龄；致命异常立即升级，最终请求持续保持。

### LRS.FUNC.WATCHDOG.ESC.003

wake_req 为各通道 `(PREWARN_raw && WAKE_EN) || active_fault` 汇总。RAW PREWARN 由 W1C 清除；active_fault 仅由可信恢复流程清除。NMI/safety_alert 对活动故障保持，不由 W1C 解除。

验收：预警 wake 受 WAKE_EN 控制；活动故障始终 wake，W1C 不能解除活动 NMI/safety_alert。

### LRS.FUNC.WATCHDOG.FLT.001

FAULT_POLICY 以与上述位同位置的位图指定哪些非致命违规进入 FAULT；TIMEOUT、ALIVE_MISSING、ALIVE_OVERFLOW、FLOW_SEQUENCE、DEADLINE 必须使能。安全配置另强制 EARLY/BAD_KEY/SEQ_TIMEOUT 使能。位11～14、16、17为固定致命，不可降级或屏蔽其最终请求。PREWARN 不能配置成监督故障。

验收：强制监督故障不可关闭；致命事件不可屏蔽或降级；PREWARN 不成为 FAULT 策略。

### LRS.FUNC.WATCHDOG.FLT.002

记录型服务错误不能刷新计数、更新令牌或贡献客户端完成。重复错误不能覆盖 FIRST_FAULT。IRQ_ENABLE 只控制 IRQ，不能屏蔽原始记录、升级或安全请求。

验收：记录型错误不刷新、不更新 token、不贡献完成；IRQ mask 不影响原始事件与复位请求。

### LRS.DFX.WATCHDOG.DIA.001

每通道具有 EVENT_RAW、FIRST_FAULT、32-bit 饱和 FAULT_COUNT、LAST_SERVICE_SEQ、MISSING_MASK、RECOVERY_COUNT。EVENT_RAW 所有事件均可累积；FIRST_FAULT 只在进入 FAULT/最终升级时且 VALID=0 时捕获，不被普通 PREWARN/访问错误抢占。

验收：非故障预警/访问错误不抢 FIRST_FAULT；故障后新原因不覆盖首次记录。

### LRS.DFX.WATCHDOG.DIA.002

FIRST_FAULT 至少包含：原因位图、通道 ID、客户端 ID/有效位、可信来源/有效位、C 候选年龄、原通道状态、配置版本、缺失 mask、服务序号、TEST_CONTEXT。超时无唯一客户端时 client_valid=0；不得伪造某个客户端 ID。

验收：首故障字段完整且时间一致；无唯一客户端时 valid=0，不能伪造来源身份。

### LRS.DFX.WATCHDOG.DIA.003

同拍多个原因全部记录为位图，主原因按位11～14/17、16、1/6、9、8、7、2、3、4、其余的顺序编码。多个通道同时故障分别保存，各通道不争用一个全局首次记录。

验收：同时原因完整置位且主原因符合优先序；多通道同时故障分别保留。

### LRS.DFX.WATCHDOG.DIA.004

FAULT_COUNT 每次从正常/暂停状态进入 FAULT 或直接最终升级增加一次；同一次故障后升级不重复增加。饱和后保持最大值并置 SAT 标志；统计不可影响检测。

验收：每次进入故障只加一次，后续升级不重复计数；最大值饱和并置 SAT，检测继续。

### LRS.DFX.WATCHDOG.DIA.005

IRQ_CLEAR 仅 W1C 清 EVENT_RAW；活动 NMI/复位请求不随其消失。即使清除了 TIMEOUT 历史位，活动 FAULT 仍保持。清 FIRST_FAULT 使用 DIAG_CLEAR，要求授权/解锁且无活动故障；新故障和清除同拍时保留新故障。

验收：清历史位不解除活动故障；活动故障禁止清首故障，清除与新故障同拍保留新故障。

### LRS.DFX.WATCHDOG.DIA.006

DIAG_CLEAR 应允许独立选择清除 FIRST_FAULT 或 FAULT_COUNT；保留位非法写拒绝。不得清锁、恢复次数或活动请求，未选中诊断保持。字段编码由 SystemRDL 定义。

验收：DIAG_CLEAR 按选择只清首故障或次数；锁、恢复次数和活动请求均保持。

### LRS.CONS.WATCHDOG.VER.003

FAULT 后未发生合格恢复/POR，FINAL_DELAY 不能被服务、访问、暂停或重复故障延后。请求置位后，在指定恢复事件前必须保持。

验收：故障后持续施加服务/访问/暂停/重复故障，最终升级不延期，请求保持至合格恢复。
