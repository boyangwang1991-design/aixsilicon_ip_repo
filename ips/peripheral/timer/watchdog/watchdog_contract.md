# AIXSILICON Watchdog IP 需求规格说明书

| 项目 | 内容 |
|---|---|
| Document ID | `aixsilicon:ip:watchdog:req` |
| IP Name | `watchdog` |
| VLNV | `aixsilicon:ip:watchdog:1.0.0` |
| 文档版本 | 1.0.0-draft |
| 状态 | 实现输入草案，待项目评审冻结；不代表已实现、已验证或已通过功能安全认证 |
| 日期 | 2026-09-10 |
| 实现形态 | Parameterized SystemVerilog IP |
| 配置接口 | APB4 Slave，32-bit 数据 |
| 配置格式 | YAML；寄存器、参数、能力描述使用同一配置源 |
| 适用范围 | CPU/多核/异构控制核的软件活性监督、硬件心跳监督及功能安全增强 |

## 1. 目的、范围与规范用语

本规格定义可以直接分解为架构、RTL、驱动及验证任务的看门狗行为。需求编号用于追踪；“应/必须/不得”均为强制要求。“可选”仅表示允许在 elaboration 时裁剪，选中后必须完整满足对应需求；不得以运行时空实现替代。

本 IP 包括独立计时、普通/窗口模式、启动监督、预警、多级故障响应、受保护服务、多通道、多客户端监督、低功耗/调试协作、故障留痕和可选自身安全机制。计数器、故障状态和升级逻辑位于 `wdt_clk` 域。

**边界：**本 IP 提出复位、唤醒及安全状态请求，不实现 SoC 复位树、振荡器、电源开关、任务调度器或完整的软件控制流验证器。来源授权依赖可信侧带或外部访问控制；APB 的 `PPROT` 不提供通用 Master ID。芯片级故障处理时限必须包含请求产生后的系统响应延迟。

**需求优先关系：**复位/安全故障与计时边界规则优先于一般寄存器描述；本规格优先于参考实现。所有寄存器未定义位读零，写非零返回访问错误；裁剪功能对应位置保留，不挪动其他地址。

## 2. 参考与设计取舍

| 参考 | 可借鉴能力 | 本规格取舍 |
|---|---|---|
| [OpenTitan AON Timer](https://opentitan.org/book/hw/ip/aon_timer/) | AON 计时、Bark/Bite、睡眠策略、配置锁 | 采用独立计时和分级响应；改用专用服务命令，不开放运行计数写入 |
| [OpenTitan 运行原理](https://opentitan.org/book/hw/ip/aon_timer/doc/theory_of_operation.html) | 系统域与 AON 域协作、复位/电源请求、异步寄存器 | 明确命令接收与域内执行的区别，并给出完成序号 |
| [STM32 WDG 说明](https://wiki.st.com/stm32mcu/wiki/Getting_started_with_WDG) | 独立看门狗、窗口监督、提前中断、调试冻结 | 独立时钟与窗口模式同时支持，冻结受授权限制 |
| [TI Watchdog 技术介绍](https://www.ti.com/video/6313371139112) | 关闭窗口与开放窗口 | 使用明确的最早/最晚服务边界 |

这些资料用于设计参考，不构成寄存器兼容承诺。本文指定的令牌算法、客户端模式、寄存器布局和恢复协议为本 IP 的设计定义。

## 3. 配置档与静态参数

### 3.1 配置档

| 配置档 | 必须包含 |
|---|---|
| STANDARD | 普通/窗口、预警、启动宽限、单/双密钥、配置原子提交与锁、多通道参数、CDC、故障留痕、睡眠/调试策略、直接/分级响应 |
| SAFETY | STANDARD + 冗余计时/比较、关键配置完整性、非法状态检测、受控诊断注入、严格故障锁存 |
| SUPERVISOR | SAFETY + 多客户端、Alive 次数、顺序/Deadline 监督、动态令牌及问答服务、硬件事件接口 |

配置档是受支持的参数组合，不改变编程接口。默认交付实例为 STANDARD、单通道、32-bit 计数、16-bit 分频、双密钥服务。SUPERVISOR 为完整功能实例。

### 3.2 参数要求

| 参数 | 合法值/默认值 | 说明 |
|---|---|---|
| `NUM_CHANNELS` | 1～16 / 1 | 独立监督通道数 |
| `COUNTER_WIDTH` | 32、48、64 / 32 | 统一计数及阈值宽度 |
| `PRESCALE_WIDTH` | 1～16 / 16 | 分频寄存器有效宽度 |
| `NUM_CLIENTS` | 1～32 / 1 | 每通道客户端数 |
| `SOURCE_WIDTH` | 1～16 / 4 | 可信来源标识宽度 |
| `SYNC_STAGES` | 2～4 / 2 | 单比特 CDC 同步级数 |
| `SUPPORT_TOKEN_QA` | 0/1 / 0 | 动态令牌及问答服务 |
| `SUPPORT_SUPERVISION` | 0/1 / 0 | GROUP/ALIVE/FLOW 模式 |
| `SUPPORT_HW_EVENT` | 0/1 / 0 | 同域硬件事件接口 |
| `SAFETY_EN` | 0/1 / 0 | 自身诊断增强 |
| `ALLOW_RUNTIME_UPDATE` | 0/1 / 0 | 运行中待提交配置切换 |
| `AUTO_START_MASK` | 通道位图 / 0 | POR 后自动启动通道 |
| `NO_STOP_MASK` | 通道位图 / 全 1 | 启动后禁止软件停止 |
| `HARD_CFG_LOCK_MASK` | 通道位图 / 0 | POR 后即锁定的通道 |
| `DEFAULT_CFG[ch]` | 静态合法配置 | AUTO_START 通道必须提供完整合法默认配置 |
| `DIAG_INJECT_EN` | 0/1 / 0 | 生产实例默认关闭故障注入写入口 |

**WDT-PAR-001** 非法参数组合必须在生成/编译检查阶段报错。自动启动且默认配置非法时不得静默关闭 WDT。

**WDT-PAR-002** 能力寄存器必须反映实际 elaboration 结果；软件写入未实现模式返回 `UNSUPPORTED`，不改变运行状态。

**WDT-PAR-003** 每通道计数、分频相位、服务状态、故障和升级期限独立。允许共享 APB/CDC 和诊断汇总，但不得因其他通道等待或故障而停止本通道计时。

## 4. 外部接口与集成合同

| 接口 | 方向/域 | 语义 |
|---|---|---|
| `pclk`, `preset_n` | 输入/APB | 配置总线时钟与接口复位 |
| `wdt_clk`, `por_n` | 输入/WDT | 独立计时时钟；POR 异步置位、各域同步释放 |
| APB4 `PSEL/PENABLE/PADDR/PWRITE/PWDATA/PSTRB/PPROT` | 输入/APB | 32-bit、little-endian，地址至少 15 bit |
| APB4 `PRDATA/PREADY/PSLVERR` | 输出/APB | 仅在完成传输时采样响应 |
| `access_source_i` | 输入/APB | 可信发起者 ID；与 APB 请求稳定 |
| `cfg_auth_i`, `service_auth_i`, `diag_auth_i` | 输入/APB | 外部授权结果；随该事务锁存 |
| `sleep_req_i`, `debug_req_i`, `debug_auth_i` | 输入/WDT | 电源/调试授权请求，进入 IP 前完成同步 |
| `pause_ack_o[ch]` | 输出/WDT | 通道已进入允许的暂停状态 |
| `warm_reset_evt_i` | 输入/WDT | 可信系统暖复位事件；不是直接清零 WDT 的复位脚 |
| `recovery_done_i[ch]` | 输入/WDT | 可信复位管理器完成恢复的保持型握手请求 |
| `recovery_ack_o[ch]` | 输出/WDT | 接受恢复完成握手；双方回零后才允许下一次握手 |
| `irq_o[ch]` | 输出/APB | 同步到 APB 域的粘滞中断电平 |
| `nmi_req_o[ch]` | 输出/WDT | 粘滞故障请求，接收方负责跨域 |
| `local_reset_req_o[ch]` | 输出/WDT | 通道局部复位保持型请求 |
| `system_reset_req_o` | 输出/WDT | 各通道最终请求及全局致命故障 OR 汇总 |
| `safety_alert_o`, `safe_state_req_o` | 输出/WDT | 安全告警/安全状态保持型请求 |
| `wake_req_o` | 输出/WDT | 预警或故障产生的唤醒请求汇总 |
| `hw_evt_valid/ready/channel/client/type/data/source` | 可选/WDT | 握手事件；valid && ready 仅接收一次 |
| `test_auth_i` | 输入/WDT | 生命周期和测试控制提供的诊断授权 |

**WDT-IF-001** 未使用可信来源功能的系统必须将来源固定为 0，并在外部限制服务访问者；不得宣称任务身份隔离。权限拒绝不得转化为喂狗。

**WDT-IF-002** IRQ 依赖 pclk 同步；pclk 停止时，安全告警、唤醒和复位请求仍必须工作。复位请求不得依赖 IRQ 被软件处理。

**WDT-IF-003** 任意异步输入必须由集成层同步或握手，禁止异步脉冲直接接入。硬件事件基础接口仅接受 wdt_clk 同域输入；其他域使用外部无丢失事件桥，不直接接裸脉冲。

**WDT-IF-004** IP 不检测自身时钟整体停振；系统必须用独立参考时基或外部看门狗覆盖。若 IP 失电，输出也不能保证有效，系统安全分析必须覆盖电源故障。

## 5. 状态与逐拍计时语义

### 5.1 通道状态

| 状态 | 计时/服务行为 | 退出条件 |
|---|---|---|
| DISABLED | 不计时；不接受服务 | 授权 START |
| BOOT | 使用启动期限；不启用普通窗口和预警 | 第一次完整合法服务后进入 RUN；超时进入 FAULT |
| RUN | 正常分频、窗口及服务协议 | 故障、授权暂停、允许的 STOP |
| PAUSED | 冻结监督计数/分频/序列/检查点 | 暂停请求解除；故障优先 |
| FAULT | 普通服务无效，升级计时继续 | 可信局部恢复完成，或最终升级 |
| RESET_PENDING | 最终请求保持，普通服务/配置无效 | POR 或可信系统暖复位完成事件 |

PREWARN 是 RUN 内的周期标志和粘滞事件，不另设会阻止合法喂狗的状态。普通软件不能将 FAULT/RESET_PENDING 清成 RUN。

### 5.2 计数定义

**WDT-TIM-001** 通道包含 W-bit 饱和向上计数 `C` 和分频相位 `D`。启动/成功刷新边沿设 `C=0,D=0`。此后每个 wdt_clk 边沿：若 `D=P`，产生 tick 并置 `D=0`；否则 `D=D+1`。因此每 `P+1` 个边沿产生一次 tick。

**WDT-TIM-002** 每个运行边沿先计算候选年龄 `A = tick ? sat(C+1) : C`，所有窗口、预警、超时及服务合法性均用 A。无成功刷新时 `C=A`；成功刷新则 `C=0,D=0`。启动边沿本身不执行年龄递增。

**WDT-TIM-003** 正常周期：`A >= TIMEOUT` 必须判超时；窗口开启时，完整服务仅在 `WIN_MIN <= A < TIMEOUT` 合法；普通模式等效 `WIN_MIN=0`。TIMEOUT 边沿的服务必须失败。允许在 WIN_MIN 边沿成功。

**WDT-TIM-004** PRETIMEOUT 使能且 `A >= PRETIMEOUT`、本周期尚未预警时，产生一次预警事件。该边沿若有成功刷新则不产生新的预警；已存在的历史预警不自动清除。计数饱和不能导致超时消失。

**WDT-TIM-005** 未暂停时，从刷新/启动边沿到超时故障边沿恰为 `TIMEOUT*(P+1)` 个 wdt_clk 周期。启动周期改用 BOOT_TIMEOUT。软件应按最坏时钟偏差、总线/CDC 延迟预留服务裕量。

### 5.3 同周期优先级

**WDT-TIM-006** 从高到低按以下顺序处理，互斥状态更新只能执行最高有效项：

1. POR 初始化。
2. 自身致命完整性/冗余故障；最终升级到期。
3. 当前监督超时、服务违规、检查点 Deadline 违规；同拍发生的各原因全部置位。
4. 可信恢复事件；不得覆盖第 2/3 项本拍新故障。
5. 完整合法服务/刷新；含已批准待提交配置的边界切换。
6. 合法 START/STOP；STOP 不得覆盖本拍超时。
7. 授权暂停进入/退出。
8. 普通计数、预警、诊断清除。

进入暂停的该边沿仍执行到期判断；退出暂停的边沿只恢复状态，下一边沿恢复递增。暂停前已锁存故障不得暂停升级。硬件置位与 W1C 同拍时硬件置位优先。

## 6. 启动、停止与启动宽限

**WDT-STA-001** START 仅在 DISABLED 有效，必须使用已生效合法配置。BOOT_EN=1 则进入 BOOT，否则 RUN；重复 START 返回 BAD_STATE，不重置时间。

**WDT-STA-002** BOOT 使用 BOOT_TIMEOUT、普通服务时间区间 `[0,BOOT_TIMEOUT)`；服务算法、来源、客户端完成要求仍适用。BOOT 不发普通 PRETIMEOUT 预警。第一次完整成功服务切入 RUN，并清零计数、分频、客户端本轮状态；不能反复 START 获取 BOOT 宽限。

**WDT-STA-003** AUTO_START 通道在 POR 同步释放后的第一个可用 wdt_clk 边沿自动启动，不依赖 pclk 或软件。该时点即服务周期起点。

**WDT-STA-004** NO_STOP_MASK=1 或 ENABLE_LOCK=1 的通道一旦启动不可由软件停止。其他通道 STOP 要求配置授权和有效解锁；仅 RUN/BOOT 可停止，清除未完成服务序列，不清历史故障，不解除锁。

**WDT-STA-005** START、STOP、配置提交不直接清除 IRQ 或 FIRST_FAULT。冷启动默认 BOOT_EN=1；各通道默认时间通过 DEFAULT_CFG 明确，不将任意固定时长假设为适用于所有时钟。

## 7. 服务协议

### 7.1 通用要求

**WDT-SRV-001** 所有软件服务通过 SERVICE 命令，运行计数只读。一次服务由 `client_id/op/source/data` 和硬件生成的完成序号关联。来源来自可信侧带，不使用软件可写寄存器替代。

**WDT-SRV-002** 只有完整合法服务才可刷新计数；读取状态、第一笔密钥、IRQ 清除、配置写入不得刷新。RUN/BOOT 之外服务返回 BAD_STATE，PAUSED 返回 PAUSED；不因此产生服务协议故障。

**WDT-SRV-003** 服务来源不匹配、权限拒绝、错误写宽度属于访问错误，不推进服务序列也不自动停止计时。密钥错误、顺序错误、有效序列超时属于监督故障类别，按 FAULT_POLICY 处理。

**WDT-SRV-004** 服务序列时间以未分频 wdt_clk 周期计，定义第一笔在边沿 e0 完成，第二笔允许在 `1 <= e-e0 <= SEQ_LIMIT`；在 `e-e0=SEQ_LIMIT` 无合法完成即置序列超时。暂停期间冻结序列年龄。SEQ_LIMIT 必须大于 0，主监督期限优先。

### 7.2 模式与算法

| SERVICE_MODE | 完整服务定义 |
|---|---|
| 0 SINGLE_KEY | 单次写 `0xA5C35A3C` |
| 1 DUAL_KEY | 先写 `0xA5C35A3C`，再写 `0x5A3CA5C3`；两笔来源/客户端相同 |
| 2 TOKEN | 写当前期望 32-bit token |
| 3 QA | 读取当前 challenge，写精确响应 |

**WDT-SRV-005** SINGLE_KEY/DUAL_KEY 为必选。DUAL_KEY 第二笔没有第一笔、第一笔重复、第二笔值错误均置 BAD_KEY_SEQUENCE，并清空该客户端未完成序列。无关合法寄存器读写不打断序列，主计时继续。

**WDT-SRV-006** TOKEN/QA 为可裁剪功能；每客户端状态独立。启动时 `token = 0x1D872B41 XOR (channel_id<<8) XOR client_id`，channel/client 从 0 编号，运算按 32 bit；若结果为 0 则取 1。

**WDT-SRV-007** 定义 `next(x) = (x >> 1) XOR ((x & 1) ? 0x80200003 : 0)`。TOKEN 模式期望值为 token；QA 模式 challenge=token，响应为 `ROL32(token,7) XOR 0x6D2B79F5 XOR (channel_id<<8) XOR client_id`。每个被接受的完整客户端服务后更新 token=next(token)，错误服务不更新；暂停/读取不更新。该算法仅为确定性的执行/重放错误检测，不提供密码学认证。

**WDT-SRV-008** TOKEN/QA 的当前值通过 SNAPSHOT 的客户端表读取，读取不产生新挑战。跨轮旧值必须失败；系统重启后种子会重复，不宣称跨启动防重放。服务完成反馈提供该客户端新 token 的可读快照途径。

**WDT-SRV-009** 软件必须等待上一条服务结果后才发下一条。驱动不得因等待超时盲目重发；应读取最终执行序号和结果。窗口服务按 WDT 域完整服务完成边沿判断。

### 7.3 硬件事件

**WDT-SRV-010** 每通道 SERVICE_PATH 为 SOFTWARE 或 HARDWARE，运行中锁定，避免两个来源互相替代。硬件事件采用同一客户端/来源校验和监督状态；在硬件路径下 `data` 提交服务密钥/响应，FLOW 的 START/STEP/END 使用 type/data。

**WDT-SRV-011** APB 命令与硬件事件同拍竞争时采用轮询仲裁，每 wdt_clk 最多执行一个状态修改命令；运行计时不受仲裁反压影响。硬件 valid 在 ready 前必须保持负载稳定。超过窗口的事件即使早先拉高 valid 也不能成功。

## 8. 多客户端监督

### 8.1 模式总则

每通道 SUP_MODE：0 SINGLE、1 GROUP、2 ALIVE、3 FLOW，彼此互斥。SINGLE 使用客户端 0；其他模式仅 REQUIRE_MASK 中的客户端参与，mask 必须非零且不得引用未实现客户端。每客户端配置 OWNER_SOURCE。未选中客户端服务返回 BAD_CLIENT，不贡献健康条件。

**WDT-SUP-001** 客户端 ID 只是选择索引，身份保护由 OWNER_SOURCE 与可信来源比较实现。同一个 OWNER_SOURCE 管理多个客户端时，不宣称这些任务彼此隔离。

### 8.2 SINGLE / GROUP

**WDT-SUP-002** SINGLE 的完整服务在合法窗口直接刷新通道。GROUP 的各客户端完整服务在合法窗口置 SEEN_MASK 位；最后一个必需客户端服务使 mask 完整时，才刷新通道。同拍刷新后 SEEN_MASK 清零开始新轮。

**WDT-SUP-003** GROUP 在窗口开启前的完整客户端服务属于 EARLY_SERVICE；重复报到属于 DUPLICATE_CLIENT，默认记录且不贡献第二次报到。重复报到不更新 token。主超时记录 `REQUIRE_MASK & ~SEEN_MASK`。第一笔双密钥允许在窗口前开始，但完整服务仍需在窗口内完成。

### 8.3 ALIVE

**WDT-SUP-004** ALIVE 使用固定观测周期 TIMEOUT，不接受由窗口大小决定的提前刷新；WIN_EN 必须为 0。每客户端每次完整服务增加 16-bit 饱和事件数，MIN_ALIVE/MAX_ALIVE 满足 `1 <= MIN <= MAX <= 65535`。超过 MAX 当拍产生 ALIVE_OVERFLOW。

**WDT-SUP-005** `A=TIMEOUT` 边沿先对刚结束的周期统计进行评估：全部必需客户端计数满足范围则自动刷新周期、清零统计；否则 ALIVE_MISSING 故障并记录不足客户端。该边沿新到来的服务拒绝为 EPOCH_BOUNDARY，不归前后任一周期、不形成额外故障，调用方需下一拍重试。该规则是 ALIVE 对普通“TIMEOUT 必故障”的唯一例外。

**WDT-SUP-006** ALIVE 周期中 PRETIMEOUT 到期只在当时尚有客户端未达 MIN 时产生预警。BOOT 周期使用 BOOT_TIMEOUT 作为首个固定观测周期，成功后转 RUN。固定时间检查能够发现软件过快报到，不能被高频服务无限推迟检查。

### 8.4 FLOW / Deadline

**WDT-SUP-007** FLOW 为每客户端定义线性检查点 `0..LAST_STEP`，LAST_STEP 为 1～255。START(data=0) 开启该客户端本轮流程；之后 STEP 必须严格递增至 LAST_STEP-1；END(data=LAST_STEP) 结束。LAST_STEP=1 时 START 后直接 END。该模式不使用密钥服务，SERVICE_MODE 必须设 0，采用来源授权和检查点检查。

**WDT-SUP-008** 每客户端 START 在本轮只允许一次；重复、跳步、倒序、未 START 的 END 均为 FLOW_SEQUENCE。START/STEP 可在主窗口前发生，但 END 必须满足主窗口，否则 EARLY_SERVICE。所有必需客户端 END 后刷新通道。

**WDT-SUP-009** 独立未分频 W-bit deadline 计数从 START 边沿置零，下一个边沿起递增。END 必须满足 `DEADLINE_MIN <= elapsed < DEADLINE_MAX`，MAX>MIN；到达 MAX 边沿时，Deadline 超时优先于 END。PAUSED 冻结；其他客户端服务不延后该期限。

**WDT-SUP-010** 完整完成前主 TIMEOUT 仍有约束；两类期限先到先故障。FLOW 仅覆盖配置的线性检查点顺序及时间，不声称完整控制流或数据正确性验证。

## 9. 配置更新与锁

**WDT-CFG-001** 软件可先修改 pclk 域 staging 配置；配置仅在 CFG_COMMIT 经 WDT 域校验后成为 active。active 不得从多笔 APB 写中间状态直接取值。

**WDT-CFG-002** CFG_COMMIT 包含完整配置快照和递增配置版本。检查模式支持、阈值、mask、权限、分频位宽、策略及高位；失败整组拒绝，不修改 active。配置写/提交不清计数。

**WDT-CFG-003** DISABLED 状态立即应用成功提交。RUN 且 ALLOW_RUNTIME_UPDATE=1、未锁定时仅允许 TIMEOUT/WIN_MIN/PRETIMEOUT/PRESCALE 更新，校验后置 PENDING；在下一次旧配置定义的成功刷新边沿整体应用，再将 C/D 置零。ALIVE 在成功周期边界应用；失败周期不应用。

**WDT-CFG-004** 运行中不得更新服务算法、监督模式、客户端、身份、BOOT、暂停、故障策略和恢复策略。BOOT/PAUSED/FAULT/RESET_PENDING 不接受运行提交。已有 PENDING 时拒绝第二次提交；故障发生时丢弃 PENDING 并记录 CANCELED。可用 CANCEL_CFG 取消尚未生效的更新。

**WDT-CFG-005** UNLOCK 两笔常量依次为 `0xC0DE1234`、`0x3F21EDCB`，来源必须相同，在 32 个 wdt_clk 周期内完成；窗口从第一笔执行边沿起算，规则同服务序列。成功后提供一次敏感命令额度，在 64 个 wdt_clk 周期后过期；不暂停。敏感命令为 CFG_COMMIT/START/STOP/LOCK/DIAG_CLEAR/FAULT_INJECT。额度在命令被 WDT 域处理时消耗，失败也消耗；staging 写不消耗额度。

**WDT-CFG-006** CFG_LOCK、ENABLE_LOCK、DEBUG_LOCK、DIAG_LOCK 为只置位锁，置位即时生效，只能 POR 清除。HARD_CFG_LOCK_MASK 对应 CFG_LOCK POR 值为 1。CFG_LOCK 禁止配置提交但允许对合法已有配置 START；ENABLE_LOCK 禁止 STOP；DEBUG_LOCK 强制禁止调试暂停；DIAG_LOCK 禁止注入。锁不阻止合法服务。

**WDT-CFG-007** 任一 active 锁/配置在 wdt_clk 域为权威值。APB staging 的读回不代表 active 生效；软件必须检查 CFG_VERSION_ACTIVE。锁定同拍不存在跨来源命令合并，按单命令执行次序决定。

## 10. 预警、故障与升级

### 10.1 事件分类及位分配

| 位 | 名称 | 默认响应 |
|---|---|---|
| 0 | PREWARN | 历史事件、IRQ，可选 wake；不进入 FAULT |
| 1 | TIMEOUT | FAULT |
| 2 | EARLY_SERVICE | FAULT |
| 3 | BAD_KEY_SEQUENCE / BAD_RESPONSE | FAULT |
| 4 | SEQUENCE_TIMEOUT | FAULT |
| 5 | DUPLICATE_CLIENT | 记录，不刷新 |
| 6 | ALIVE_MISSING | FAULT |
| 7 | ALIVE_OVERFLOW | FAULT |
| 8 | FLOW_SEQUENCE | FAULT |
| 9 | DEADLINE | FAULT |
| 10 | ACCESS_ERROR | 记录，不刷新 |
| 11 | CFG_INTEGRITY | 立即最终升级 |
| 12 | COUNTER_MISMATCH | 立即最终升级 |
| 13 | STATE_INVALID | 立即最终升级 |
| 14 | SERVICE_PATH_INTEGRITY | 立即最终升级 |
| 15 | DIAG_TEST_EVENT | 记录为测试事件 |
| 16 | RECOVERY_LIMIT | 立即最终升级 |
| 17 | CDC_PROTOCOL | 立即最终升级 |
| 18 | CFG_REJECTED | 记录 |

**WDT-FLT-001** FAULT_POLICY 以与上述位同位置的位图指定哪些非致命违规进入 FAULT；TIMEOUT、ALIVE_MISSING、ALIVE_OVERFLOW、FLOW_SEQUENCE、DEADLINE 必须使能。安全配置另强制 EARLY/BAD_KEY/SEQ_TIMEOUT 使能。位11～14、16、17为固定致命，不可降级或屏蔽其最终请求。PREWARN 不能配置成监督故障。

**WDT-FLT-002** 记录型服务错误不能刷新计数、更新令牌或贡献客户端完成。重复错误不能覆盖 FIRST_FAULT。IRQ_ENABLE 只控制 IRQ，不能屏蔽原始记录、升级或安全请求。

### 10.2 响应策略

| RESPONSE_MODE | 行为 |
|---|---|
| 0 DIRECT_SYSTEM | 进入 FAULT 的同拍直接置系统复位及安全状态请求，状态 RESET_PENDING |
| 1 LOCAL_THEN_SYSTEM | FAULT 同拍置 NMI/safety_alert；LOCAL_DELAY 后置局部复位请求；FINAL_DELAY 后置系统复位/安全状态请求 |

**WDT-ESC-001** 升级年龄 E 从故障边沿置零，以未分频 wdt_clk 计，每个后续边沿递增且不可暂停。要求 `0 <= LOCAL_DELAY < FINAL_DELAY`；LOCAL_DELAY=0 同故障边沿请求局部复位。到 FINAL_DELAY 同拍必最终升级，恢复事件不能覆盖。

**WDT-ESC-002** FAULT 状态服务、清 IRQ、重复错误、配置访问不能重新起算 E。致命自身故障不等待 LOCAL_DELAY/FINAL_DELAY，立即最终升级。最终输出为保持型请求，不用计数器回卷清除。

**WDT-ESC-003** wake_req 为各通道 `(PREWARN_raw && WAKE_EN) || active_fault` 汇总。RAW PREWARN 由 W1C 清除；active_fault 仅由可信恢复流程清除。NMI/safety_alert 对活动故障保持，不由 W1C 解除。

### 10.3 恢复语义

**WDT-REC-001** recovery_done 只在 LOCAL_THEN_SYSTEM、FAULT、局部请求已置位、未到最终期限、ALLOW_LOCAL_RECOVERY=1 时可接受；其他状态不得触发重启或获得宽限。它表示目标复位已经实际完成且恢复条件已满足，不是“请求收到”。

**WDT-REC-002** 接受后清活动局部请求/NMI，E 清零，保留历史诊断/锁/active 配置，清除旧服务序列及客户端状态，重新进入 BOOT（BOOT_EN=0 则 RUN）。握手 ack 拉高直到 done 拉低；仅接受一次。下一故障若旧 done 未回零，必须等待新的完整握手，不能自动恢复。

**WDT-REC-003** LOCAL_RECOVERY_LIMIT 为 0～255；0 表示禁止局部恢复，非零为两次可信系统暖复位之间最大允许恢复次数。超出时置 RECOVERY_LIMIT 并最终升级；成功运行和喂狗不清此计数。

**WDT-REC-004** RESET_PENDING 仅由 POR 或可信 warm_reset_evt 解除；warm_reset_evt 表示已完成系统暖复位并进入启动阶段。活动通道自动重新启动，保持锁和 active 配置，恢复计数清零；不自动启动原本 DISABLED 通道。FIRST_FAULT 保留。

**WDT-REC-005** 任意非看门狗发起的 warm_reset_evt 对运行通道同样重启监督，因此必须限制在可信复位管理器。系统不能允许软件无限伪造该事件规避监督；看门狗不独立承担整机重复复位次数管理。

## 11. 低功耗与调试

**WDT-PWR-001** PAUSE_SLEEP/PAUSE_DEBUG 为 active 配置位，默认均 0。sleep_req 且 PAUSE_SLEEP 可进入 PAUSED；debug_req 且 debug_auth 且 PAUSE_DEBUG 且 !DEBUG_LOCK 可暂停。任一有效暂停源存在则保持暂停，两者均解除后恢复原 BOOT/RUN 状态。

**WDT-PWR-002** 暂停冻结 C、D、服务序列年龄、客户端 Deadline；不改变 active 配置、令牌及本轮 SEEN/ALIVE。进入/退出不授予新周期、不清故障。PAUSED 拒绝服务，不缓存待恢复执行的服务。

**WDT-PWR-003** 故障升级、自身完整性检查、锁和诊断逻辑不暂停。自身故障在 PAUSED 仍直接升级。由 debug_auth 失效导致暂停撤销时，下一个运行边沿恢复监督。

**WDT-PWR-004** sleep 参数切换不另设隐式模式：若需要睡眠专用期限，软件在允许更新的配置中提交新期限并确认其已生效后才能睡眠。禁止以睡眠请求直接重载计数或修改阈值。

**WDT-PWR-005** 系统允许无限期暂停时，暂停期间没有时间监督覆盖；若需要暂停时长上限，应由不暂停的其他 WDT 通道或独立电源管理计时器监督。生产安全配置应禁用普通调试冻结。

## 12. APB、CDC、事务执行与状态快照

### 12.1 APB 规则

**WDT-BUS-001** 仅支持 32-bit 对齐访问；读取 PSTRB 不参与判断。所有有效寄存器写要求 PSTRB=4'b1111；非完整写、越界/未实现地址、写 RO、权限拒绝、保留位非零应在该笔完成时 PSLVERR=1 且不产生状态副作用。读 WO 返回 0。

**WDT-BUS-002** APB 访问仅在 PSEL && PENABLE && PREADY 边沿接受一次。常规访问采用固定有限延迟，最多进入 ACCESS 后 2 个 pclk 周期完成；不得等待停住的 wdt_clk 无限拉低 PREADY。

**WDT-BUS-003** 能定位到有效通道的权限/格式拒绝，通过独立合并型事件握手将 ACCESS_ERROR 送达该通道，不占用命令邮箱、不推进服务协议；连续错误允许合并为一个粘滞事件，不承诺逐次计数。该事件发送状态由 POR 复位，preset_n 不丢弃已经捕获的事件。无有效通道的全局/越界访问只返回 PSLVERR，不伪造通道故障。忙拒绝属于流控，不产生 ACCESS_ERROR。该诊断路径不改变“返回错误的写不能执行其请求操作”的要求。

### 12.2 单命令邮箱

**WDT-CDC-001** 所有跨域状态修改通过单个单在途命令邮箱执行。APB 写成功只表示命令被邮箱接收；CMD_STATUS.EXEC_DONE 和 DONE_SEQ 表示 WDT 域执行完成。忙时新状态修改命令返回 PSLVERR/BUSY，不排队、不覆盖。

**WDT-CDC-002** 邮箱负载在请求发出到确认返回期间稳定，含 channel/client/op/data/source/auth/完整配置快照。请求和应答使用受验证握手；禁止跨域逐位同步多位数据。每条命令最多执行一次，执行序号为 32-bit 回卷自然数，单在途保证相邻序号可区分。

**WDT-CDC-003** 邮箱、请求序号及完成记录属于 POR 保持状态，不由 preset_n 或 warm_reset_evt 复位。preset_n 只复位 APB 事务 FSM、staging、选择器及输出同步寄存器；已经接收的命令继续完成，不重发。重启软件先查询 BUSY/DONE_SEQ/RESULT，再发送下一命令。

**WDT-CDC-004** warm_reset_evt 到达 WDT 域时取消尚未执行的命令，结果 CANCELED_RESET；已经执行命令不回滚。该边沿服务不得在恢复启动后被重放。POR 同时初始化两个域邮箱；任何单域功能复位不得清握手 toggle 造成伪命令。

**WDT-CDC-005** wdt_clk 停止后邮箱可能一直 BUSY；APB 状态读仍可完成，软件不可假定完成并重发。独立时钟监视器负责该失效。邮箱握手非法状态在 SAFETY 实例置 CDC_PROTOCOL。

### 12.3 快照

**WDT-SNP-001** SNAPSHOT 命令在 WDT 域一个边沿捕获指定通道的计数、状态、SEEN/缺失、统计、token、故障信息、active 参数及版本；整个镜像保持到下一次快照成功。普通读只读 pclk 可用镜像，不等待 WDT 域。

**WDT-SNP-002** SNAP_VALID=0 时镜像读零；完成时提供 SNAP_SEQ 与配置版本。64-bit 高低字来自同一镜像。快照捕获该边沿状态更新后的值；软件想判断故障瞬间应读 FIRST_FAULT 的专用故障快照。

**WDT-SNP-003** CMD 状态、能力、IRQ 镜像可直接读，其他运行值需 SNAPSHOT 后读。镜像值允许陈旧，寄存器名称/驱动接口必须区分 staging、active snapshot 和即时事务状态。

## 13. 复位与留痕

| 对象 | POR | preset_n | warm_reset_evt | 已接受局部恢复 |
|---|---|---|---|---|
| active 配置 | DEFAULT_CFG | 保持 | 保持 | 保持 |
| staging 配置 | DEFAULT_CFG | DEFAULT_CFG | 保持，软件应重新建立 | 保持 |
| 配置/启动/调试/诊断锁 | 参数默认 | 保持 | 保持 | 保持 |
| C、D、未完成服务、客户端本轮状态 | 初始化 | 保持 | 活动通道重启时清零 | 目标通道重启时清零 |
| token | 启动种子 | 保持 | 活动通道重新播种 | 目标通道重新播种 |
| 活动故障及请求 | 清除 | 保持 | 清除后按当前新故障重新判定 | 仅目标通道非致命故障解除 |
| FIRST_FAULT、历史事件、错误统计 | 清除 | 保持 | 保持 | 保持 |
| 待生效配置 | 无 | 保持 | 取消 | 取消 |
| 命令邮箱 | 初始化 | 已接收命令保持 | 未执行命令取消 | 不改变其他命令 |
| 局部恢复次数 | 0 | 保持 | 0 | 加 1 |

**WDT-RST-001** warm_reset_evt 必须由复位管理器转换为 wdt_clk 单周期事件，或在外部使用完整握手形成一次事件；不得在系统复位电平持续期间每拍重启 WDT。por_n 释放同步链为 SYNC_STAGES 级；AUTO_START 在同步释放后首边沿启动。

**WDT-RST-002** 冗余检查仅在主/影子状态均初始化后的第一个正常边沿起有效；允许的初始屏蔽不得超过 SYNC_STAGES+2 个 wdt_clk 周期。禁止使用可由软件无限保持的“初始化屏蔽”关闭安全诊断。

**WDT-RST-003** preset_n 期间 IRQ 输出可复位为低，但释放后必须由保留原始状态重新同步产生；WDT 域复位/唤醒请求不受影响。

**WDT-RST-004** POR 后留痕丢失属于设计行为。若整机要求断电保持，必须由外部 retention/NVM 记录；本 IP 不隐含非易失存储。

## 14. 自身故障检测与测试

### 14.1 SAFETY 实例的强制机制

**WDT-SAF-001** 主计数与独立影子计数必须每拍进行一致性检查。允许采用正向 C 与反向表示 ~C，但影子必须独立寄存并按自己的下一状态更新，禁止每拍直接由主值组合取反后写入作为“冗余”。启动、服务、暂停、饱和、恢复均纳入检查。

**WDT-SAF-002** 分频状态及 tick 生成必须有独立影子路径；不能只复制主计数、仍共享一个失效后可能停住的 tick 使能。阈值、故障策略、锁、使能至少使用独立反码副本并持续校验。

**WDT-SAF-003** 窗口、超时和最终升级比较使用双路径判定；任一路超时应能提出故障，路径不一致本身置致命状态。状态机采用有非法编码检测的实现；非法状态不得归零后静默继续服务。

**WDT-SAF-004** 命令控制、关键状态以及服务通过判定需要完整性保护；任意单一受保护寄存器翻转不得导致永久关闭监督而无报告。最终请求的锁存路径不得只依赖已经失效的普通通道状态机。

**WDT-SAF-005** 对“已定义的数字比较/编码异常”从异常可观测边沿起到 safety_alert/system_reset_req 有效最多 2 个 wdt_clk 周期。该期限不涵盖尚未激活的潜伏故障、模拟问题或时钟整体停振；具体诊断覆盖由故障分析给出。

**WDT-SAF-006** 关键逻辑应避免综合将冗余路径合并，交付相应综合约束和门级检查方法；仅 RTL 上存在两份变量不能作为冗余有效性证据。面积/功耗增加必须按具体配置报告。

### 14.2 自检与注入

**WDT-TST-001** DIAG_INJECT_EN=1 且 test_auth、配置诊断授权、未 DIAG_LOCK、解锁额度有效时，允许注入：主计数位翻转、分频位翻转、阈值副本翻转、状态非法编码、单比较路径翻转、服务判定完整性错误。注入选择由 FAULT_INJECT 命令数据定义，单次消费，不能持续压制真实故障。

**WDT-TST-002** 注入后必须经过真实故障检测和真实告警锁存路径；默认不屏蔽最终复位请求。若测试平台需防止实际复位，旁路由外部测试环境实现，并记录这不等于已测试真实系统执行链。

**WDT-TST-003** IRQ_TEST 仅测试中断通路，置单独测试状态，不推进监督计数、不证明超时比较器覆盖。超时自检通过专用未承担生产监督的通道配置短期限并停止服务完成，不提供运行中任意写 C 的后门。

**WDT-TST-004** 诊断测试事件标记 TEST_CONTEXT；真实故障位仍置位，FIRST_FAULT 应记录当时测试上下文。生产配置可彻底裁剪注入入口；scan/test 模式及生命周期要求须在集成文档列出。

**WDT-TST-005** 交付安全说明应列出故障模型、检测路径、最大检测延迟、未覆盖故障、时钟/电源/复位共因、周期测试建议及系统假设。不得在没有分析和验证证据时标注 ASIL 达成或固定诊断覆盖百分比。

## 15. 诊断信息与清除规则

**WDT-DIA-001** 每通道具有 EVENT_RAW、FIRST_FAULT、32-bit 饱和 FAULT_COUNT、LAST_SERVICE_SEQ、MISSING_MASK、RECOVERY_COUNT。EVENT_RAW 所有事件均可累积；FIRST_FAULT 只在进入 FAULT/最终升级时且 VALID=0 时捕获，不被普通 PREWARN/访问错误抢占。

**WDT-DIA-002** FIRST_FAULT 至少包含：原因位图、通道 ID、客户端 ID/有效位、可信来源/有效位、C 候选年龄、原通道状态、配置版本、缺失 mask、服务序号、TEST_CONTEXT。超时无唯一客户端时 client_valid=0；不得伪造某个客户端 ID。

**WDT-DIA-003** 同拍多个原因全部记录为位图，主原因按位11～14/17、16、1/6、9、8、7、2、3、4、其余的顺序编码。多个通道同时故障分别保存，各通道不争用一个全局首次记录。

**WDT-DIA-004** FAULT_COUNT 每次从正常/暂停状态进入 FAULT 或直接最终升级增加一次；同一次故障后升级不重复增加。饱和后保持最大值并置 SAT 标志；统计不可影响检测。

**WDT-DIA-005** IRQ_CLEAR 仅 W1C 清 EVENT_RAW；活动 NMI/复位请求不随其消失。即使清除了 TIMEOUT 历史位，活动 FAULT 仍保持。清 FIRST_FAULT 使用 DIAG_CLEAR，要求授权/解锁且无活动故障；新故障和清除同拍时保留新故障。

**WDT-DIA-006** DIAG_CLEAR 数据 bit0 清 FIRST_FAULT、bit1 清 FAULT_COUNT，其余保留；不能清锁、恢复次数或活跃请求。未选中的诊断保持原值。

## 16. 寄存器地图与字段

### 16.1 访问类别

- RO-L：APB 本地域即时信息。
- RW-S：APB staging 或选择器；不直接影响运行。
- RO-SNAP：最近一次完成快照中的值。
- WO-CMD：成功 APB 写将命令放入邮箱，实际结果以 DONE_SEQ/RESULT 为准。
- 所有地址按字节计，4 字节对齐；未列地址不实现并返回 PSLVERR。
- POR 默认除下表注明/DEFAULT_CFG 外均为 0；WO 读零。

### 16.2 全局寄存器

| 偏移 | 名称 | 类型 | 字段/复位值 |
|---|---|---|---|
| 0x000 | IP_ID | RO-L | `0x57445431`（WDT1） |
| 0x004 | VERSION | RO-L | `0x00010000`（major[31:16]=1，minor[15:8]=0，patch[7:0]=0） |
| 0x008 | CAPABILITY0 | RO-L | [4:0]通道数-1，[10:5]客户端数-1，[17:11]计数位宽，[22:18]分频位宽 |
| 0x00C | CAPABILITY1 | RO-L | bit0 TOKEN_QA，1 SUPERVISION，2 HW_EVENT，3 SAFETY，4 RUNTIME_UPDATE，5 DIAG_INJECT；[9:8]SYNC_STAGES-2 |
| 0x010 | CMD_STATUS | RO-L | bit0 BUSY，1 EXEC_DONE；[15:8]RESULT；读无副作用 |
| 0x014 | ISSUED_SEQ | RO-L | 最近接收的命令序号 |
| 0x018 | DONE_SEQ | RO-L | 最近执行完成序号 |
| 0x01C | DONE_INFO | RO-L | [3:0]channel，[8:4]client，[16:9]opcode |
| 0x020 | IRQ_SUMMARY | RO-L | 同步后各通道 irq 电平位图 |
| 0x024 | FAULT_SUMMARY | RO-L | 同步后各通道 active_fault 位图，允许同步延迟 |
| 0x028 | RESET_SUMMARY | RO-L | [15:0]local请求，[16]system请求，[17]safe_state请求，同步镜像 |

EXEC_DONE 在接收新命令时清零、完成时置位；读状态不清。ISSUED_SEQ 每次成功接收邮箱命令加一，0 为 POR 初值。

RESULT 枚举：0 OK，1 BUSY，2 ACCESS_DENIED，3 BAD_STATE，4 BAD_CONFIG，5 LOCKED，6 UNSUPPORTED，7 BAD_SERVICE，8 PAUSED，9 CANCELED_RESET，10 CANCELED_FAULT，11 PENDING_APPLY，12 BAD_CLIENT，13 EPOCH_BOUNDARY，14 EXPIRED_UNLOCK，15 NO_PENDING。APB 层同步拒绝不覆盖上一次 DONE 记录；其错误用 PSLVERR 指示。

### 16.3 通道地址

通道基址：`0x1000 + channel_id * 0x400`，channel_id 为 0～NUM_CHANNELS-1。最大实现地址低于 0x5000。下表偏移相对于通道基址。

| 偏移 | 名称 | 类型 | 说明 |
|---|---|---|---|
| 0x000 | CTRL_STAGE | RW-S | 控制字段，见后表 |
| 0x004 | PRESCALE_STAGE | RW-S | 低 PRESCALE_WIDTH 位 |
| 0x008/00C | WIN_MIN_LO/HI_STAGE | RW-S | 64-bit 容器，高于 COUNTER_WIDTH 的位必须 0 |
| 0x010/014 | TIMEOUT_LO/HI_STAGE | RW-S | 必须 >0 |
| 0x018/01C | PRETIMEOUT_LO/HI_STAGE | RW-S | 使能时小于 TIMEOUT |
| 0x020/024 | BOOT_TIMEOUT_LO/HI_STAGE | RW-S | BOOT_EN 时必须 >0 |
| 0x028 | SEQ_LIMIT_STAGE | RW-S | 未分频周期数，32 bit，>0 |
| 0x02C | REQUIRE_MASK_STAGE | RW-S | 客户端位图 |
| 0x030 | FAULT_POLICY_STAGE | RW-S | 事件到 FAULT 位图 |
| 0x034 | LOCAL_DELAY_STAGE | RW-S | 未分频 wdt_clk 周期，32 bit |
| 0x038 | FINAL_DELAY_STAGE | RW-S | 未分频 wdt_clk 周期，32 bit |
| 0x03C | RECOVERY_LIMIT_STAGE | RW-S | [7:0]次数 |
| 0x040 | UNLOCK | WO-CMD | 两笔解锁常量 |
| 0x044 | COMMAND | WO-CMD | [7:0]命令枚举，其余 0 |
| 0x048 | LOCK_SET | WO-CMD | bit0 CFG、1 ENABLE、2 DEBUG、3 DIAG；只置位 |
| 0x04C | SERVICE_SELECT | RW-S | [4:0]client；[10:8]event_type |
| 0x050 | SERVICE | WO-CMD | 完整 32-bit 密钥、令牌、响应或检查点编号 |
| 0x054 | IRQ_ENABLE | WO-CMD | 原始事件位图掩码，设置不需解锁但需 cfg_auth |
| 0x058 | IRQ_CLEAR | WO-CMD | W1C 原始事件位图；需 diag_auth，不需解锁 |
| 0x05C | IRQ_TEST | WO-CMD | bit0=1 产生测试中断事件，需 diag_auth；其余 0 |
| 0x060 | DIAG_CLEAR | WO-CMD | bit0 FIRST，bit1 COUNT；需解锁/diag_auth |
| 0x064 | FAULT_INJECT | WO-CMD | [3:0]target，[9:4]bit_index；其余 0 |
| 0x068 | SNAP_META | RO-L | bit0 VALID；[31:1]保留 |
| 0x06C | SNAP_SEQ | RO-L | 最近完成快照对应命令序号 |
| 0x070 | STATUS_SNAP | RO-SNAP | 状态、锁及 pending，见后表 |
| 0x074 | CFG_VERSION_SNAP | RO-SNAP | active 配置版本 |
| 0x078/07C | COUNT_LO/HI_SNAP | RO-SNAP | C |
| 0x080 | EVENT_RAW_SNAP | RO-SNAP | 原始粘滞事件位图 |
| 0x084 | IRQ_ENABLE_SNAP | RO-SNAP | IRQ 掩码 |
| 0x088 | SEEN_MASK_SNAP | RO-SNAP | GROUP/FLOW 完成位图，SINGLE/ALIVE 为 0 |
| 0x08C | MISSING_MASK_SNAP | RO-SNAP | 当前轮尚未满足健康条件的 mask |
| 0x090 | LAST_SERVICE_SEQ_SNAP | RO-SNAP | 成功完整客户端服务次数序号，32 bit 自然回卷；不等同邮箱序号 |
| 0x094 | FAULT_COUNT_SNAP | RO-SNAP | 饱和故障次数 |
| 0x098 | RECOVERY_COUNT_SNAP | RO-SNAP | 低8位局部恢复次数，饱和 |
| 0x09C | ESC_AGE_SNAP | RO-SNAP | 未分频升级年龄 E，32 bit 饱和 |
| 0x0A0 | FIRST_FLAGS_SNAP | RO-SNAP | bit0 VALID，1 client_valid，2 source_valid，3 test_context；[11:8]ch，[16:12]client，[24:17]主原因编号 |
| 0x0A4 | FIRST_CAUSE_SNAP | RO-SNAP | 同拍故障原因位图 |
| 0x0A8/0AC | FIRST_COUNT_LO/HI_SNAP | RO-SNAP | 故障时候选年龄 A |
| 0x0B0 | FIRST_SOURCE_SNAP | RO-SNAP | 低 SOURCE_WIDTH 位 |
| 0x0B4 | FIRST_CFG_VERSION_SNAP | RO-SNAP | 故障时 active 版本 |
| 0x0B8 | FIRST_MISSING_SNAP | RO-SNAP | 故障时缺失客户端 |
| 0x0BC | FIRST_SERVICE_SEQ_SNAP | RO-SNAP | 故障时服务次数序号 |
| 0x0C0 | FIRST_STATE_SNAP | RO-SNAP | 原状态编码 |
| 0x100～0x13C | ACTIVE_CFG_SNAP | RO-SNAP | 与 0x000～0x03C 顺序一致的 active 配置镜像 |
| 0x140 | CLIENT_SELECT | RW-S | [4:0]客户端索引，影响客户端 staging/快照窗口 |
| 0x144 | CLIENT_OWNER_STAGE | RW-S | 低 SOURCE_WIDTH 位 OWNER_SOURCE |
| 0x148 | CLIENT_ALIVE_STAGE | RW-S | [15:0]MIN，[31:16]MAX |
| 0x14C | CLIENT_FLOW_STAGE | RW-S | [7:0]LAST_STEP |
| 0x150/154 | CLIENT_DEADLINE_MIN_LO/HI_STAGE | RW-S | 未分频周期 |
| 0x158/15C | CLIENT_DEADLINE_MAX_LO/HI_STAGE | RW-S | 未分频周期 |
| 0x180 | CLIENT_FLAGS_SNAP | RO-SNAP | bit0 selected，1 seen，2 sequence_pending，3 flow_active；[15:8]last_step |
| 0x184 | CLIENT_TOKEN_SNAP | RO-SNAP | token/challenge；未实现时 0 |
| 0x188 | CLIENT_ALIVE_COUNT_SNAP | RO-SNAP | [15:0]本轮次数 |
| 0x18C/190 | CLIENT_ELAPSED_LO/HI_SNAP | RO-SNAP | FLOW deadline 年龄 |
| 0x1A0～0x1B8 | CLIENT_CFG_SNAP | RO-SNAP | 与0x144～0x15C顺序一致的 active 客户端配置 |

CLIENT_SELECT/SERVICE_SELECT 为 APB 域本地选择器；SERVICE 被接收时必须把选择器快照锁入命令。客户端 staging 是实际每客户端独立存储的间接窗口；切换选择器不得覆盖其他客户端。CFG_COMMIT 捕获所有客户端配置，不仅当前选中项。SNAPSHOT 捕获整个客户端表；之后 CLIENT_SELECT 只选择已捕获镜像，不触发域内读取。

### 16.4 关键字段与操作码

| CTRL_STAGE 位 | 字段 | 编码 |
|---|---|---|
| 0 | WIN_EN | 1窗口，0普通 |
| 1 | PREWARN_EN | 预警使能 |
| 2 | BOOT_EN | 启动宽限 |
| [4:3] | SERVICE_MODE | SINGLE_KEY/DUAL_KEY/TOKEN/QA = 0/1/2/3 |
| [6:5] | SUP_MODE | SINGLE/GROUP/ALIVE/FLOW = 0/1/2/3 |
| 7 | RESPONSE_MODE | DIRECT_SYSTEM=0，LOCAL_THEN_SYSTEM=1 |
| 8 | ALLOW_LOCAL_RECOVERY | 可信局部恢复使能 |
| 9 | PAUSE_SLEEP | 睡眠暂停许可 |
| 10 | PAUSE_DEBUG | 调试暂停许可 |
| 11 | WAKE_EN | 预警唤醒许可 |
| 12 | SERVICE_PATH | SOFTWARE=0，HARDWARE=1 |
| [31:13] | Reserved | 0 |

STATUS_SNAP：[2:0]state（DISABLED=0，BOOT=1，RUN=2，PAUSED=3，FAULT=4，RESET_PENDING=5）；bit3 active_fault，4 prewarn_this_epoch，5 cfg_pending，6 unlocked_credit，7 fault_count_sat；bit8～11 依次为 CFG/ENABLE/DEBUG/DIAG_LOCK；bit12 pause_sleep_active，13 pause_debug_active；其余0。

COMMAND opcode：1 CFG_COMMIT，2 START，3 STOP，4 CANCEL_CFG，5 SNAPSHOT。写其他值返回 BAD_CONFIG。CFG_COMMIT 的版本为上次成功校验提交版本+1，应用后成为 active 版本；取消可以留下版本间隙。版本32 bit自然回卷。

SERVICE_SELECT.event_type：0 SERVICE_WORD，1 FLOW_START，2 FLOW_STEP，3 FLOW_END。FLOW 只允许1～3；其他模式只允许0。硬件事件使用相同编码。

FAULT_INJECT.target：0计数主副本，1分频主副本，2TIMEOUT保护副本，3状态编码，4超时比较输出，5服务判定保护。位选择必须在对象宽度内；目标3注入预定义非法编码、目标4/5按下一次检查周期翻转，不使用bit_index且要求其为0。

### 16.5 完整配置合法性

**WDT-REG-001** 在第3/5/7/8/10章约束外，提交必须满足：

1. WIN_EN=0 时 WIN_MIN=0；WIN_EN=1 时 WIN_MIN<TIMEOUT。
2. PREWARN_EN=1 时 `WIN_MIN<=PRETIMEOUT<TIMEOUT`；关闭时 PRETIMEOUT 必须0。
3. BOOT_EN=0 时 BOOT_TIMEOUT=0；BOOT_EN=1 时 BOOT_TIMEOUT>0。
4. SINGLE 的 REQUIRE_MASK=1；未参与客户端的配置可保留但不得生效。
5. ALIVE 的 WIN_EN=0；FLOW 的 SERVICE_MODE=0；未支持增强时 SUP_MODE 必须 SINGLE。
6. DIRECT_SYSTEM 时 LOCAL_DELAY=FINAL_DELAY=0，ALLOW_LOCAL_RECOVERY=0，RECOVERY_LIMIT=0。
7. LOCAL_THEN_SYSTEM 时 FINAL_DELAY>LOCAL_DELAY；ALLOW_LOCAL_RECOVERY=1 时 RECOVERY_LIMIT>0，否则 RECOVERY_LIMIT=0。
8. 每个已选客户端的 OWNER_SOURCE 位宽合法；ALIVE/FLOW 特定字段按模式校验；未使用的 ALIVE/FLOW 字段允许保留但不参与判定。
9. 活动配置中的锁定限制和 HARD_CFG_LOCK 优先于 staged 参数。
10. 高于实现位宽的计数/分频位为0；任何截断可能改变时间的配置必须拒绝，禁止自动裁低。

**WDT-REG-002** 默认 IRQ_ENABLE=0，但默认 FAULT_POLICY 的强制位始终置1，不能因为中断关闭而关闭复位。安全档默认 PAUSE_DEBUG=0；NO_STOP_MASK 默认全1。

**WDT-REG-004** IRQ_ENABLE 允许位0～18；IRQ_TEST 置事件位15。FAULT_POLICY 仅接收非致命监督事件位1～10，且强制位必须保持1；位0及11～31必须写0，致命响应由硬件固定实现。CFG_COMMIT 校验失败置事件18；普通取消和忙返回不属于配置错误。CLIENT_DEADLINE 在非FLOW模式只读elapsed为0；服务模式不支持token时CLIENT_TOKEN读0。

**WDT-REG-003** 运行状态字段、LOCK 和配置值的普通读取均以指定快照为准。软件必须等待当前 SNAPSHOT 的 DONE_SEQ 才使用 SNAP_SEQ；不能用陈旧 BUSY=0 或早先 EXEC_DONE 推断新的写已执行。

## 17. 软件使用流程

### 17.1 初始化

1. 读 IP_ID/VERSION/CAPABILITY，确认实际实例能力。
2. 查询邮箱 BUSY/DONE_SEQ；对跨接口复位的在途命令等待完成，不重复发送。
3. SNAPSHOT 并读取保留 FIRST_FAULT；诊断策略需要时授权清除。
4. DISABLED 通道填写 staging 主配置及所有必需客户端配置。
5. 完成 UNLOCK 两笔并逐笔等待执行，再 CFG_COMMIT；检查结果和 active 配置版本快照。
6. 完成新的 UNLOCK，再 START；AUTO_START 通道跳过启动，按其已有状态接管。
7. 使用新 UNLOCK 置必要锁；每次敏感命令各需一次解锁额度。
8. 配置中断路由和 IRQ_ENABLE；系统复位/告警路由必须在承担监督前已接好。

### 17.2 正常服务

1. 应用层完成真实任务健康检查，确定有资格服务。
2. 提前预留 APB、CDC、仲裁和时钟误差裕量，不在 TIMEOUT 边界发起访问。
3. 设置 SERVICE_SELECT；按协议发一笔或两笔 SERVICE；每笔核对 DONE_SEQ 与 RESULT。
4. TOKEN/QA 模式按当前客户端状态生成合法值；并发软件由驱动互斥管理邮箱和选择器。
5. GROUP/FLOW 只有最后一个必需客户端完成才刷新；ALIVE 在固定周期边界检查，不靠一次服务延长周期。

不得在无条件周期中断、DMA循环或与任务健康无关的硬件脉冲中自动喂软件监督通道。驱动可暴露 service/query/pretimeout 等能力，但不应为满足某个操作系统接口而绕过窗口和配置锁。

### 17.3 故障处理

预警 ISR 可读取快照并保存上下文；IRQ_CLEAR 不刷新计数。若健康检查通过且尚在窗口，可执行正常服务。FAULT 后软件仅可读取/清历史中断；局部/系统恢复由可信管理器按第10章执行。重启首先读取 FIRST_FAULT，再决定是否清历史记录。

## 18. 非功能需求与架构约束

**WDT-NFR-001** 控制与数据逻辑同步实现，不推断锁存器；异步复位仅用于明确复位触发器。计时通过 clock enable，禁止用普通组合逻辑生成新时钟。

**WDT-NFR-002** 从命令接收至执行的 CDC 固定延迟和最大仲裁延迟必须在架构文档中给出，以 pclk/wdt_clk 周期表达。只在两个时钟持续运行的假设下给出该上界；不得承诺停钟后仍有有限命令完成时间。

**WDT-NFR-003** 无硬件事件竞争时，合法 mailbox 命令进入 WDT 域可见后最多2个 wdt_clk 周期内执行；有持续硬件事件竞争时最多3个周期。快照与配置提交为一个原子操作，不可循环扫描数十拍后对外声称同拍快照/提交。

**WDT-NFR-004** 通道计时和升级不得受 APB backpressure、长读操作、客户端数或诊断访问影响。配置及客户端存储可按参数裁剪；不以共享轮询计数方案牺牲检测时限。

**WDT-NFR-005** PPA 无通用工艺无关数值门限。交付应报告 STANDARD单通道、SAFETY单通道、SUPERVISOR代表配置的面积/时序/功耗条件，包含工艺、库、时钟、活动假设及冗余开销；不虚构频率或门数达标。

**WDT-NFR-006** RTL、寄存器头文件、驱动常量、验证RAL和能力元数据必须使用同一配置定义生成/核对，防止模式、位宽与寄存器地图不一致。无需强制使用某一种RTL生成语言。

## 19. 验证需求与验收条件

### 19.1 验证矩阵

| 验证组 | 必须覆盖的行为 | 关联需求前缀 |
|---|---|---|
| 基础计时 | P=0/最大，最小/最大阈值，32/48/64位，饱和与精确周期 | TIM/PAR |
| 窗口 | WIN_MIN-1、WIN_MIN、TIMEOUT-1、TIMEOUT，tick/非tick服务 | TIM/SRV |
| 预警 | 阈值同拍服务，W1C同拍新事件，屏蔽不影响复位 | TIM/FLT/DIA |
| 服务协议 | 正确/错值/乱序/重复/序列边界/来源变化/部分写 | SRV/IF/BUS |
| 令牌问答 | 已知种子向量、更新、错误不更新、跨轮重放、读取无副作用 | SRV |
| 客户端 | 最后客户端刷新、重复报到、缺失位图、可信来源 | SUP |
| Alive | MIN/MAX边界、超次数当拍故障、固定周期评估、边界事件拒绝 | SUP |
| Flow | 正确顺序、跳步倒序、MIN/MAX deadline、主超时竞争 | SUP |
| 配置 | 合法性整组拒绝、运行提交、旧参数边界切换、取消、锁不可清 | CFG/REG |
| 启动 | AUTO_START无pclk、BOOT首轮、重复START不得延时 | STA/RST |
| 低功耗 | tick边界进入暂停、恢复相位、双暂停源、故障不可冻结 | PWR |
| CDC/APB | 任意时钟比、pclk停止、wdt_clk停止、邮箱忙、无重复执行 | CDC/BUS |
| 复位交错 | 接收前/后、执行前/后preset，warm取消与服务同拍，POR释放 | CDC/RST |
| 升级恢复 | 延迟0、最终期限边界、反复故障不延期、旧done电平、恢复限额 | ESC/REC |
| 快照诊断 | 64bit一致读取、首故障不覆盖、暖复位保留、同拍清置 | SNP/DIA |
| 自身安全 | 故障注入、独立tick故障、非法状态、请求保持和综合冗余 | SAF/TST |
| 参数裁剪 | 最小/完整/代表组合、未支持模式拒绝、寄存器地址固定 | PAR/REG |

### 19.2 必须证明的性质

**WDT-VER-001** RUN普通/窗口模式、wdt_clk持续、无授权暂停/恢复条件下，从周期开始 TIMEOUT*(P+1) 个周期内若无合法刷新，必须进入对应故障响应。

**WDT-VER-002** 不合法服务、IRQ清除、配置写、第一次密钥、其他通道服务不能重置本通道 C/D。ALIVE 固定周期刷新为明确列出的例外。

**WDT-VER-003** FAULT 后未发生合格恢复/POR，FINAL_DELAY 不能被服务、访问、暂停或重复故障延后。请求置位后，在指定恢复事件前必须保持。

**WDT-VER-004** 一个被APB成功接收的邮箱命令最多执行一次；未接收/返回PSLVERR的写无对应状态副作用；执行、取消、错误结果与DONE_SEQ一一对应。

**WDT-VER-005** 锁只能按规定复位清除；多字阈值更新只能旧配置或新配置整体生效，不能使用混合值。

**WDT-VER-006** 对每种配置档必须建立需求→feature→test/checker/assertion→coverage追踪。功能覆盖需包含边界和关键交叉，不能仅用代码覆盖率替代。安全机制另外提供故障注入结果和未覆盖项说明。

### 19.3 完成门槛

- 所有适用强制需求已实现并有可追踪验证结果；所有例外有评审记录。
- 定向边界用例、受约束随机回归、APB协议、CDC/RDC检查通过；未豁免错误为0。
- 关键安全/计时性质有断言或形式验证/等价强度证据。
- 所选配置档的功能覆盖闭合，未达项有明确不可达或不适用依据；不预设未经项目评审的统一覆盖百分比。
- 驱动示例与RTL行为一致；能够演示服务成功、过早故障、超时、局部恢复、最终升级和暖复位留痕。
- 未获得实际工艺/库、综合、后端数据时，PPA状态明确标注未验证，不影响对功能行为的独立评审。

## 20. 交付件及架构提示

| 交付件 | 内容 |
|---|---|
| requirement.md | 本规格及版本历史 |
| architecture.md | 时钟/复位域、状态机、邮箱、冗余路径、时限预算、模块接口 |
| register.yaml | 地址/位域/权限/复位值/命令副作用的机器可读定义 |
| rtl/ | 参数化RTL及顶层wrapper |
| sw/ | C寄存器头、驱动、初始化/服务/诊断示例 |
| dv/ | 验证环境、参考模型、RAL、序列、断言及覆盖 |
| constraints/ | 时钟/CDC/RDC、冗余防合并、集成约束 |
| safety_manual.md | 系统假设、诊断覆盖范围、故障清除和测试方法 |
| validation_report.md | 回归/覆盖/静态检查/故障注入结果 |
| user_guide.md | 配置档、寄存器流程、时序预算、典型集成 |
| FuseSoC core | 参数、文件集、仿真/综合入口 |

推荐模块：apb_if、command_mailbox、cfg_bank、channel_core、service_checker、client_supervisor、escalation、diagnostic、safety_checker。模块划分不是外部可观察行为要求，可以在不改变本规格的前提下优化。

**实现顺序建议：**先完成时钟复位/邮箱与单通道普通计时，再加入窗口/双密钥/故障升级/留痕，随后完成多通道与客户端监督，最后闭合冗余诊断和全部交叉场景。各阶段均沿用本规格的最终寄存器地址和行为，不引入临时兼容模式。

## 附录 A：精确边界示例

配置 P=1、WIN_MIN=2、PRETIMEOUT=4、TIMEOUT=5；刷新边沿记为 e0。假设无暂停：

| 边沿 | D更新后 | A | 行为 |
|---|---|---|---|
| e0 | 0 | 0 | 周期起点 |
| e1 | 1 | 0 | 完整服务过早 |
| e2 | 0 | 1 | 产生第1个tick，完整服务过早 |
| e3 | 1 | 1 | 仍过早 |
| e4 | 0 | 2 | 窗口开启；完整服务合法 |
| e8 | 0 | 4 | 若此前未服务，预警；同拍合法服务则抑制本次新预警 |
| e9 | 1 | 4 | 最后一个合法服务边沿 |
| e10 | 0 | 5 | 超时优先，同拍完整服务失败 |

表中“过早”仅描述如果该拍提交完整服务的结果；例子持续到e10假定此前没有真的提交会导致故障/刷新的服务。

## 附录 B：必须保留的安全边界

1. 独立数字逻辑不等于独立振荡器、电源或复位源。
2. 反码/LFSR/问答服务不等于密码学认证。
3. 多客户端报到不等于软件任务已被硬件隔离。
4. 清历史故障不等于解除活动故障或撤销复位。
5. APB写成功不等于WDT域已执行；必须核对完成序号。
6. 开放暂停、可信恢复输入、系统暖复位事件均属于系统安全假设，不能由被监督软件任意伪造。
7. 看门狗故障检测时间、升级时间和系统安全状态实际到达时间必须分别预算。
