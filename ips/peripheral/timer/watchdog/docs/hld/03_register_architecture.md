# Watchdog：寄存器架构

本册冻结 Register Architecture 的候选设计，不定义 offset/bit 表。逻辑字段行为由 LLD
定义，地址/位宽/access/reset 的结构源为 SystemRDL。已有 RDL 是待核对输入，不是
架构需求的反向事实源。

## Register Group 与状态所有权

| 组 | 软件用途 | 权威所有者 | 访问/更新模型 |
|---|---|---|---|
| ID/CAPABILITY | 识别版本、实例通道/客户端/宽度及可用增强 | INTEGRATION/BUS | 本地域只读，反映真实能力 |
| COMMAND_STATUS | BUSY、ISSUED/DONE 序号、RESULT、完成目标 | TRANSPORT | POR 保持，接收/完成更新，读无副作用 |
| CONFIG_STAGE | 通道计时/服务/监督/暂停/故障策略及每客户端配置 | BUS | 可读写 staging，写不改变活动监督 |
| CONTROL | 解锁、START/STOP、COMMIT/CANCEL、LOCK | CHANNEL | 命令完成结果确认，敏感命令消费一次额度 |
| SERVICE | 选择器、密钥/响应或检查点命令 | BUS 捕获，CHANNEL 执行 | 客户端/来源与负载一起捕获，完整合法服务才贡献健康 |
| STATUS_SNAPSHOT | 运行状态、计数、active 配置/版本、客户端表 | CHANNEL 捕获，BUS 镜像 | 整体快照，未有效读零，跨字一致 |
| IRQ/EVENT | 使能、原始粘滞事件、W1C、IRQ_TEST | CHANNEL | 硬件新事件置位优先于软件清除；mask 不改变故障 |
| ERROR/HISTORY | FIRST_FAULT、缺失位图、饱和统计、恢复次数 | CHANNEL | 首故障一次捕获，授权清指定历史，活动请求保持 |
| SAFETY/DIAG | 诊断授权、保护锁、注入与 TEST_CONTEXT | CHANNEL/SAFETY | 受生命周期/外部权限/额度/锁共同保护 |

## 软件访问路径

BUS 完成 APB 格式/权限检查及解码；只有 accepted 命令进入单在途邮箱。WO 读零，
RO 写、部分写、保留位非零、不对齐和未实现地址均访问失败；裁剪不重排地址。
客户端窗口的存储是真正逐客户端独立，选择器只是访问选择，不能覆盖其他客户端。

## 激活、保护与清除

COMMIT 校验完整 staging 快照；DISABLED 立即应用，允许的 RUN 更新在旧周期成功
刷新边界应用。启动宽限、暂停、故障及最终请求态不接受运行提交；不可运行修改
算法、客户端、身份或恢复策略。第二 pending 拒绝，故障/取消丢弃 pending。

解锁两笔常量须同源和时限有效，成功只给一份敏感命令额度，失败敏感命令同样消费。
CFG/ENABLE/DEBUG/DIAG 锁只置位，POR 外不清；配置锁不阻止对已合法活动配置 START，
启动锁禁止 STOP，调试锁禁止暂停，诊断锁禁止注入；正常合法服务不被锁阻止。

IRQ_CLEAR 只清历史 EVENT_RAW。DIAG_CLEAR 仅按选择清首故障/故障次数，受授权且
无活动故障约束；恢复次数不能由普通清除复位。任何硬件新事件与软件清除竞争均
保留新状态。具体每字段 SW/HW collision 与 reset_semantics 在 LLD_REG_META 冻结。

## 快照与版本约定

SNAPSHOT 整体捕获更新后状态及客户端表，保持到下一次成功快照；64-bit 高低字
不能跨快照混用。CMD 状态、能力和 IRQ 镜像可直接读，其余运行值必须使用有效快照。
配置版本以已校验提交递增，取消允许留下间隙；staging 读回不能代替 active 版本确认。
## 寄存器架构决策

<!-- HLD_DECISION_META
id: ADR.WATCHDOG.REGISTER.001
level: HLD
status: approved
req_ref:
- LRS.REG.WATCHDOG.ACCESS.001
- LRS.REG.WATCHDOG.IDENTITY.001
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
options:
- 每次 APB 写直接影响监督
- staging + 原子提交 + 保持快照
decision: 采用 staging + 完整提交 + 成功周期边界切换；运行读采用保持快照
applicability:
  expr: 'true'
END_HLD_DECISION_META -->

代价是完整配置/镜像存储及较低命令吞吐；收益是跨时钟和多字访问的一致性，以及与停钟无关的 APB 响应。

