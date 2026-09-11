# 配置原子提交与生效：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.COMMIT
name: 配置原子提交与生效
description: 配置原子提交与生效的可执行正确性证明
priority: must
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
- LRS.CONS.WATCHDOG.VER.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

多字阈值分步staging写；完整客户端表；非法模式/高位/mask/策略；RUN只改四类计时字段；pending后二次提交；旧窗口服务与故障边界。

独立判据：独立配置验证规则生成预期错误；失败整组不变；成功提交按状态立即或旧配置成功刷新时整体生效；无混合阈值；故障丢弃pending。

风险与边界：配置状态×合法性×锁×pending×版本；UNSUPPORTED与BAD_CONFIG优先级。

### LRS.REG.WATCHDOG.CFG.001

软件可先修改 pclk 域 staging 配置；配置仅在 CFG_COMMIT 经 WDT 域校验后成为 active。active 不得从多笔 APB 写中间状态直接取值。

验收：多笔 staging 写期间 active 保持；只在完整提交校验成功后切换为新配置。

### LRS.REG.WATCHDOG.CFG.002

CFG_COMMIT 包含完整配置快照和递增配置版本。检查模式支持、阈值、mask、权限、分频位宽、策略及高位；失败整组拒绝，不修改 active。配置写/提交不清计数。

验收：每类非法项分别使整组拒绝；active 版本及计数不变化，不能出现部分生效。

### LRS.REG.WATCHDOG.CFG.003

DISABLED 状态立即应用成功提交。RUN 且 ALLOW_RUNTIME_UPDATE=1、未锁定时仅允许 TIMEOUT/WIN_MIN/PRETIMEOUT/PRESCALE 更新，校验后置 PENDING；在下一次旧配置定义的成功刷新边沿整体应用，再将 C/D 置零。ALIVE 在成功周期边界应用；失败周期不应用。

验收：禁用态提交立即生效；运行态合法计时更新等待旧周期成功刷新，ALIVE 只在健康边界应用。

### LRS.REG.WATCHDOG.CFG.004

运行中不得更新服务算法、监督模式、客户端、身份、BOOT、暂停、故障策略和恢复策略。BOOT/PAUSED/FAULT/RESET_PENDING 不接受运行提交。已有 PENDING 时拒绝第二次提交；故障发生时丢弃 PENDING 并记录 CANCELED。可用 CANCEL_CFG 取消尚未生效的更新。

验收：禁止状态/字段提交拒绝；第二次 pending 拒绝；故障取消或 CANCEL_CFG 后旧配置保持。

### LRS.REG.WATCHDOG.CFG.007

任一 active 锁/配置在 wdt_clk 域为权威值。APB staging 的读回不代表 active 生效；软件必须检查 CFG_VERSION_ACTIVE。锁定同拍不存在跨来源命令合并，按单命令执行次序决定。

验收：以 active 版本确认生效；staging 读回不代表运行配置，跨来源命令按执行先后生效。

### LRS.REG.WATCHDOG.REG.001

在第3/5/7/8/10章约束外，提交必须满足： 1. WIN_EN=0 时 WIN_MIN=0；WIN_EN=1 时 WIN_MIN<TIMEOUT。 2. PREWARN_EN=1 时 `WIN_MIN<=PRETIMEOUT<TIMEOUT`；关闭时 PRETIMEOUT 必须0。 3. BOOT_EN=0 时 BOOT_TIMEOUT=0；BOOT_EN=1 时 BOOT_TIMEOUT>0。 4. SINGLE 的 REQUIRE_MASK=1；未参与客户端的配置可保留但不得生效。 5. ALIVE 的 WIN_EN=0；FLOW 的 SERVICE_MODE=0；未支持增强时 SUP_MODE 必须 SINGLE。 6. DIRECT_SYSTEM 时 LOCAL_DELAY=FINAL_DELAY=0，ALLOW_LOCAL_RECOVERY=0，RECOVERY_LIMIT=0。 7. LOCAL_THEN_SYSTEM 时 FINAL_DELAY>LOCAL_DELAY；ALLOW_LOCAL_RECOVERY=1 时 RECOVERY_LIMIT>0，否则 RECOVERY_LIMIT=0。 8. 每个已选客户端的 OWNER_SOURCE 位宽合法；ALIVE/FLOW 特定字段按模式校验；未使用的 ALIVE/FLOW 字段允许保留但不参与判定。 9. 活动配置中的锁定限制和 HARD_CFG_LOCK 优先于 staged 参数。 10. 高于实现位宽的计数/分频位为0；任何截断可能改变时间的配置必须拒绝，禁止自动裁低。

验收：合法边界整组接受；逐项违反阈值、模式、来源位宽、策略、锁和高位约束均整组拒绝。

### LRS.REG.WATCHDOG.REG.002

默认 IRQ_ENABLE=0，但默认 FAULT_POLICY 的强制位始终置1，不能因为中断关闭而关闭复位。安全档默认 PAUSE_DEBUG=0；NO_STOP_MASK 默认全1。

验收：默认 IRQ 为零仍可复位；安全默认禁止调试暂停，默认启动后不可停止。

### LRS.REG.WATCHDOG.REG.003

运行状态字段、LOCK 和配置值的普通读取均以指定快照为准。软件必须等待当前 SNAPSHOT 的 DONE_SEQ 才使用 SNAP_SEQ；不能用陈旧 BUSY=0 或早先 EXEC_DONE 推断新的写已执行。

验收：当前 SNAPSHOT 完成序号确认后才使用镜像；旧 BUSY/EXEC_DONE 不被误认作当前命令完成。

### LRS.REG.WATCHDOG.REG.004

IRQ_ENABLE 允许位0～18；IRQ_TEST 置事件位15。FAULT_POLICY 仅接收非致命监督事件位1～10，且强制位必须保持1；位0及11～31必须写0，致命响应由硬件固定实现。CFG_COMMIT 校验失败置事件18；普通取消和忙返回不属于配置错误。CLIENT_DEADLINE 在非FLOW模式只读elapsed为0；服务模式不支持token时CLIENT_TOKEN读0。

验收：非法 IRQ/POLICY 位拒绝；提交失败置 CFG_REJECTED，忙/取消不置；非适用 Deadline/token 读零。

### LRS.CONS.WATCHDOG.VER.005

锁只能按规定复位清除；多字阈值更新只能旧配置或新配置整体生效，不能使用混合值。

验收：全部复位类型验证锁保持/清除；多字参数观察结果只有完整旧值或完整新值。
