---
document_id: aixsilicon:ip:gpio:req
ip_name: gpio
title: GPIO IP 需求规格说明书
version: 1.0.0-draft
status: implementation-ready-draft
implementation_type: parameterized_systemverilog
interface: APB4
register_data_width: 32
owner: 待指定
---

# GPIO IP 需求规格说明书

> 本文定义通用 GPIO IP 的完整 V1.0 功能、接口、软件可见行为与验证要求，可作为 RTL、寄存器生成、驱动和 UVM 验证的共同输入。“应/必须”均为强制要求；可裁剪表示 V1.0 产品必须提供该实现，但实例可通过静态参数关闭，不表示延期实现。本文是待评审的实现基线，不代表 RTL 已完成、验收通过或具有安全认证。

## 1. 产品范围与参考

### 1.1 目标

**GPIO-SCP-001** IP 应提供 1～128 路 GPIO，支持 32-bit APB4 配置、输入同步、滤波去抖、推挽/开漏输出、原子位操作、完整中断、配置锁、低功耗控制，以及可裁剪的 AON 唤醒、事件记录、快照、Strap 和诊断。

**GPIO-SCP-002** 实现采用 Parameterized SystemVerilog。Bank 是软件寄存器组织单位，每 Bank 最多 32 路，不自动代表独立电源域或独立时钟域。V1.0 主功能域只有一个时钟。

**GPIO-SCP-003** GPIO 不承担全芯片 Pinmux、模拟模式、上下拉电阻、驱动强度、Slew Rate、Schmitt、耐压和工艺 IO Cell 的实现。上述能力由 Pinmux/Pad Controller/Pad Adapter 提供。GPIO 应提供明确的数字数据、OE、输入有效性和所有权接口。

### 1.2 业界参考与适配

| 来源 | 参考内容 | 本 IP 的设计选择 |
|---|---|---|
| [OpenTitan GPIO 原理](https://opentitan.org/book/hw/ip/gpio/doc/theory_of_operation.html) | OUT/OE 分离、掩码写、滤波、边沿/电平中断、Strap | 采用相似能力，另定义同步器、可编程滤波和本 IP 寄存器语义 |
| [OpenTitan GPIO 寄存器](https://opentitan.org/book/hw/ip/gpio/doc/registers.html) | W1C Pending、软件中断测试、半字掩码写 | 参考操作形式，不兼容其地址布局 |
| [STM32 AN4899](https://www.st.com/resource/en/application_note/an4899-stm32-microcontroller-gpio-hardware-settings-and-lowpower-consumption-stmicroelectronics.pdf) | 推挽/开漏、位操作、配置锁、PAD 电气与低功耗 | 数字 GPIO 与 PAD 电气控制分离 |
| [OpenTitan Pinmux 原理](https://opentitan.org/book/hw/ip/pinmux/doc/theory_of_operation.html) | 休眠状态、常开域唤醒 | 独立 AON 唤醒模块，明确系统集成分工 |

本文后续需求为本产品的工程定义，不将其他厂商寄存器或行为视为通用 GPIO 标准。APB 协议实现应以项目采用的 Arm 官方 APB4 规范及 HWIF 合同为依据。

## 2. 配置与能力

### 2.1 静态参数

| 参数 | 合法值/默认 | 作用 |
|---|---|---|
| N_GPIO | 1～128 / 32 | 引脚数；N_BANK=ceil(N_GPIO/32) |
| SYNC_STAGES | 2～4 / 2 | 主域输入同步级数 |
| INPUT_CAP_MASK | N_GPIO 位 / 全 1 | 输入能力 |
| OUTPUT_CAP_MASK | N_GPIO 位 / 全 1 | 输出能力 |
| RESET_OUT | N_GPIO 位 / 0 | 输出锁存复位值 |
| RESET_OE | N_GPIO 位 / 0 | 输出使能复位值 |
| RESET_IN_EN | N_GPIO 位 / INPUT_CAP_MASK | 输入处理复位使能 |
| N_IRQ_GROUPS | 1～4 / 1 | 中断分组 |
| OUT_INV_EN | 0/1 / 1 | 输出反相 |
| AON_WAKE_EN | 0/1 / 1 | 常开唤醒模块 |
| SNAPSHOT_EN | 0/1 / 1 | 输入快照 |
| STRAP_EN | 0/1 / 1 | 主功能域一次性 Strap |
| EVENT_FIFO_DEPTH | 0、4、8、16、32、64 / 16 | 0 裁剪事件记录 |
| DIAG_EN | 0/1 / 1 | 输出回读诊断 |
| ACCESS_CTRL_EN | 0/1 / 1 | 安全/特权访问控制 |
| CFG_PARITY_EN | 0/1 / 0 | 关键寄存器 parity |
| BOOT_SECURE_ONLY | 0/1 / 1 | 上电业务访问安全限制 |
| BOOT_PRIV_ONLY | 0/1 / 1 | 上电业务访问特权限制 |
| HW_SAFE_OUT / HW_SAFE_OE | N_GPIO 位 / 0 | 独立安全覆盖的物理值 |

**GPIO-CFG-001** RESET_OE/HW_SAFE_OE 不得对无输出能力引脚置 1；RESET_IN_EN 不得对无输入能力引脚置 1。参数非法必须 elaboration 或配置检查失败。

**GPIO-CFG-002** 裁剪后寄存器地址不移动；声明的可选寄存器读 0、写忽略。参数范围外 Bank/引脚地址为非法地址。未实现引脚位读 0、写忽略。

**GPIO-CFG-003** FEATURE 寄存器如实反映裁剪；能力位为静态只读，不可由软件修改。默认配置用于功能覆盖，不作为最小面积推荐配置。

## 3. 顶层接口与时钟复位

| 接口 | 方向 | 定义 |
|---|---|---|
| pclk_i | 输入 | 主域及 APB 时钟 |
| por_ni | 输入 | 芯片冷复位；各域异步置位、同步释放 |
| main_rst_ni | 输入 | 主功能暖复位；与 POR 组合生成主域复位 |
| APB4 | 双向 | PADDR[13:0]、PWDATA/PRDATA[31:0]、PSTRB[3:0]、PPROT[2:0]、PSEL/PENABLE/PWRITE/PREADY/PSLVERR |
| gpio_in_i[N_GPIO] | 输入 | 来自 PAD/输入路由的数字信号，可异步 |
| input_available_i[N_GPIO] | 输入 | 主域同步状态；输入路由和接收器有效 |
| output_owned_i[N_GPIO] | 输入 | 主域同步状态；GPIO 当前拥有输出路径 |
| gpio_out_o / gpio_oe_o | 输出 | 主域数字输出/OE，高有效 |
| irq_pin_o[N_GPIO] | 输出 | 逐引脚电平中断 |
| irq_group_o[N_IRQ_GROUPS] | 输出 | 路由后分组电平中断 |
| irq_summary_o | 输出 | 全部引脚 IRQ 的 OR |
| event_o[N_GPIO] | 输出 | 主域单周期合格边沿事件，与 IRQ_ENABLE 无关 |
| sleep_req_i / sleep_ack_o | 输入/输出 | 主域同步休眠覆盖握手 |
| safe_req_i | 输入 | 主域同步安全覆盖请求 |
| safe_active_o | 输出 | 主域安全覆盖已生效 |
| snapshot_req_i | 输入 | 主域单周期快照触发 |
| strap_sample_i | 输入 | 主域同步 Strap 捕获请求 |
| fault_irq_o | 输出 | 主域诊断/访问/FIFO 故障汇总 |
| dma_req_o | 输出 | 主域事件 FIFO 数据可用请求 |
| aon_clk_i / aon_rst_ni | 输入 | 可选常开时钟/复位，aon_rst_ni 仅由冷复位树控制 |
| aon_gpio_in_i / aon_input_available_i | 输入 | AON 电源域有效的 PAD 输入及路由有效性 |
| wake_req_o | 输出 | AON 粘滞唤醒请求，供 PMU 同步 |

**GPIO-IF-001** 未使用的 available/owned 接口应按实际集成情况绑常量，不能默认以读到 0 代替有效性说明。改变输入路由时，集成层应先撤销 available，切换并稳定后再拉高。

**GPIO-IF-002** 内部 RTL 不产生 Z；OE=0 表示释放 PAD。GPIO 输出拥有权不能直接替代 Pinmux 的最终物理选择逻辑。

**GPIO-IF-003** safe_req_i 仅提供主域有时钟时的同步响应。断钟/掉电下必须生效的安全覆盖，由常开 PAD/安全控制器实施，可复用 HW_SAFE_OUT/OE 参数；不得宣称主域同步逻辑提供异步紧急切断。

**GPIO-IF-004** AON 输入数据经过 AON 同步器；aon_input_available_i 由常开路由控制逻辑同步提供。CDC 同步器须有约束与实现属性，禁止组合逻辑置于同步器级间。

## 4. APB 访问合同

**GPIO-BUS-001** 本地 CSR 支持零等待 APB 传输：PREADY=1；错误同样在合法 APB Access 阶段返回。写副作用仅在 PSEL && PENABLE && PREADY && !PSLVERR 的完成边沿发生，Setup 阶段无副作用。

**GPIO-BUS-002** 所有地址按 4 字节对齐。PADDR[1:0]!=0、未定义字地址、向 RO 写入、非法字段编码、锁定目标写入、权限错误，均返回 PSLVERR=1，PRDATA=0，整个事务无业务副作用。错误记录寄存器更新属于允许的诊断副作用。

**GPIO-BUS-003** RW/W1C/W1S/SET/CLR/TOGGLE 均按 PSTRB 展开的 byte mask 生效。RW 写 PSTRB=0 为无操作成功。掩码组合写和命令寄存器只允许 PSTRB=1111；否则报错。WO 读取返回 0。

**GPIO-BUS-004** 保留位读 0、写忽略；字段非法编码仅检查真正被字节使能写到的字段。不存在引脚位写忽略，存在但不支持相关输入/输出能力的位尝试置 1 返回错误。

**GPIO-BUS-005** 读数据为事务完成边沿前的状态。读无隐含清除；仅显式 EVENT_POP 命令消费 FIFO。APB4 PPROT[0] 为 privileged，PPROT[1] 为 non-secure，PPROT[2] 为 instruction 属性。本 IP 拒绝 PPROT[2]=1 的访问。

**GPIO-BUS-005A** 命令寄存器写 0 为成功无操作。有效命令位与保留位同时写入时忽略保留位；AON_CMD 多个有效命令位置 1 报错。更新使能字段使其从 1→1 不重建边沿历史；IRQ_MODE 即使写相同值仍按重配置建立基线。针对某个 PIN_CFG 的写入，若只改变 OUT/SLEEP/GROUP 字段，不重置输入滤波历史；仅 IRQ_MODE 写字段被有效字节覆盖时重建中断基线。

**GPIO-BUS-006** AON 使用主域 staging/命令/结果窗口，不拉长 APB 等待。忙时冲突命令返回错误，软件读 BUSY/DONE/TIMEOUT。禁止等待停止的 AON 时钟而永久占用 APB。

## 5. 输入与有效性

**GPIO-IN-001** 路径固定为 PAD→SYNC_STAGES 同步器→毛刺滤波→去抖→输入反相。IN_SYNC 是同步器末级物理逻辑值；IN_DATA 为处理后逻辑值；禁止运行时旁路同步器。

**GPIO-IN-002** 输入有效前提为 INPUT_CAP_MASK && IN_ENABLE && input_available_i。前提失效当拍清 IN_VALID、IN_DATA=0、清处理历史和计数、抑制新检测；IN_SYNC 在前提失效时软件读 0。已记录 Pending/FIFO/快照不隐式清除。

**GPIO-IN-003** 前提重新成立后等待 SYNC_STAGES 个完整主域边沿填充同步路径，然后按启用的滤波/去抖阶段建立初值。最后一级首次给出有效值时设置 IN_VALID 并建立边沿基线，不产生边沿事件；有效电平模式可以立即置 Pending。

**GPIO-IN-004** 输入反相只影响 IN_DATA、中断和主域事件；不影响 IN_SYNC、Strap、诊断物理比较以及 AON 唤醒定义。

**GPIO-IN-005** 输出模式可同时采样输入。关闭 GPIO 输入处理不等同关闭 PAD 接收器；PAD 接收器由 Pad Controller 控制。

## 6. 毛刺滤波与去抖

**GPIO-FLT-001** 每引脚 PIN_CFG.FILTER_EN 独立开启滤波；K=FILTER_CFG[7:0]+1，范围 1～256。滤波每主时钟采样一次同步输入。连续 K 次同一候选值后更新输出；遇到另一值时该值成为候选、计数从 1 开始。输入与当前输出相等时不输出变化事件。初始化也要求 K 次一致样本。

**GPIO-FLT-002** DEBOUNCE_EN 独立控制去抖；D=DEBOUNCE_CFG[7:0]+1，范围 1～256。每 Bank 共享 DIV+1 主周期一个采样使能，DIV 为 16-bit。去抖仅在采样使能时观察滤波输出，连续 D 次一致才更新。

**GPIO-FLT-003** 已启用滤波阶段尚无有效输出时，去抖不能计数。各引脚候选/计数独立；共享的只有采样节拍。

**GPIO-FLT-004** 关闭滤波时直接采用已有效同步值，关闭去抖时直接采用有效滤波值。各启用阶段使用注册输出；下游边沿上的计算使用上拍上游状态，避免 RTL 与参考模型产生一拍歧义。

**GPIO-FLT-005** 写入 FILTER_CFG、DEBOUNCE_CFG、PIN_CFG 的 FILTER_EN/DEBOUNCE_EN/IN_INV，重新初始化该引脚输入处理和边沿历史。写 BANK_DEBOUNCE_DIV 重新初始化该 Bank 的所有已开启去抖引脚，并重启共享分频计数。重新初始化不清已有 Pending。

**GPIO-FLT-006** 在时钟正常且输入保持稳定的前提下，主输入更新延迟的保守设计上界为 (SYNC_STAGES+4+K_eff+D_eff×(DIV+1))×Tclk，其中关闭滤波取 K_eff=0，关闭去抖取 D_eff=0。具体 RTL 周期模型必须满足该上界并在架构文档给出精确拍数。用于保证边沿识别时，高低两种稳定时间均须满足处理链的稳定要求。

**GPIO-FLT-007** GPIO 不保证捕获任意窄异步脉冲，也不提供异步脉冲捕获锁存器。软件时钟分频变化会改变实际去抖时间，驱动应按频率重算。

## 7. 输出与原子更新

**GPIO-OUT-001** OUT_DATA 与 OUT_OE 独立锁存。软件可在 OE=0 时预装载 OUT，然后使能 OE。OUT_DATA 读取锁存值，IN_SYNC/IN_DATA 读取输入通路，两者不可混淆。

**GPIO-OUT-002** 正常模式先令 D=OUT_DATA XOR OUT_INV，再执行开漏转换。推挽：physical_out=D，physical_oe=OUT_OE；开漏：physical_out=0，physical_oe=OUT_OE && !D。最终 OE 再与 OUTPUT_CAP_MASK、output_owned_i 相与。

**GPIO-OUT-003** OUT_SET/CLR/TOGGLE 分别对写 1 且 PSTRB 有效位执行置位/清除/翻转。OE_SET/CLR 语义相同。每事务原子更新，不进行软件读改写。

**GPIO-OUT-004** MASKED_LO 操作引脚 [15:0]、MASKED_HI 操作 [31:16]；PWDATA[31:16] 为位 mask，PWDATA[15:0] 为新值。仅 mask=1 的存在位改变。mask/value 必须同一完整 32-bit 事务提交；读这些 WO 别名返回 0。

**GPIO-OUT-005** 单次事务原子性不扩展到多个 Bank。V1.0 不提供 OUT/OE Shadow Commit；跨寄存器输出配置应按“关 OE→配置数据/模式→开 OE”执行。需要多引脚相同周期数据切换可使用单 Bank OUT_DATA 写。

**GPIO-OUT-006** 修改 PIN_CFG.OUT_OD 或 OUT_INV 时，对应 OUT_OE 必须为 0，否则整笔写报错。OUT_DATA 在开漏释放与拉低之间切换属于正常允许操作。

**GPIO-OUT-007** 一次 APB 完成边沿更新 OUT/OE；物理输出经组合译码变化，不经过额外隐藏流水。工艺传播延迟、PAD 延迟、Pinmux 切换和外部 RC 不在零周期承诺内。

## 8. 中断与事件检测

**GPIO-IRQ-001** 每引脚 IRQ_MODE：0=禁用、1=上升沿、2=下降沿、3=双边沿、4=高电平、5=低电平；6/7 非法。检测基于有效 IN_DATA。

**GPIO-IRQ-002** IRQ_DETECT_EN 控制新事件检测；IRQ_ENABLE 只控制 Pending 输出。关闭 DETECT 不清 Pending，关闭 ENABLE 不停止检测。DETECT 从 0→1 时，用当前有效输入建立边沿基线，无历史边沿补发；电平模式可立即触发。

**GPIO-IRQ-003** IRQ_PENDING 为 W1C 粘滞状态：next=(old & ~sw_clear)|hw_event|sw_test，置位优先。IRQ_STATUS=PENDING & ENABLE；irq_pin_o 等于 IRQ_STATUS；irq_summary_o 为 OR。

**GPIO-IRQ-004** 电平模式条件持续成立时 hw_event 持续为 1，清除不能压过有效电平；输入解除后由软件清 Pending。边沿模式未清期间新边沿可能合并，不表示计数。

**GPIO-IRQ-005** IRQ_TEST 写 1 设置 Pending，不依赖输入有效、MODE、DETECT_EN；仍受访问权限约束；不产生 EVENT_FIFO 数据、RISING/FALLING_PENDING 或 event_o。

**GPIO-IRQ-006** RISING_PENDING/FALLING_PENDING 分别记录被当前边沿模式选中且 DETECT_EN 有效的上升/下降事件，独立 W1C，硬件置位优先。清 IRQ_PENDING 不清方向状态，反之亦然。

**GPIO-IRQ-007** 改写 IRQ_MODE 后重建边沿基线，保留 Pending。IN_VALID 首次有效的边沿不作为事件。改写 IRQ_GROUP 仅改变现存 IRQ 的路由，不清状态。

**GPIO-IRQ-008** 每引脚只选择一个 IRQ_GROUP，编码小于 N_IRQ_GROUPS。group[g]=OR(IRQ_STATUS[i] && route[i]==g)。IRQ 路由无独立消费者 Pending；共享消费者须由驱动协调清除。

**GPIO-IRQ-009** event_o 仅对合格物理输入处理后的边沿事件输出 1 拍，受 IRQ_MODE 和 DETECT_EN 约束，不受 IRQ_ENABLE 约束；电平中断不每拍写事件 FIFO。跨域消费者必须采用额外握手/计数/FIFO，不能直接同步短脉冲。

## 9. 锁与权限

**GPIO-SEC-001** CFG_LOCK、DATA_LOCK、WAKE_LOCK 均为每引脚 W1S；GLOBAL_LOCK 为全局 W1S。锁仅冷复位清除，main_rst_ni 不清锁。暖复位仍可将被锁寄存器恢复默认值，锁阻止后续软件写，非防复位机制。

**GPIO-SEC-002** CFG_LOCK 保护 PIN_CFG、FILTER_CFG、DEBOUNCE_CFG、DIAG_CFG、IRQ_DETECT_EN、IRQ_ENABLE；DATA_LOCK 保护 OUT/OE 所有写入口。GLOBAL_LOCK 阻止新增配置、共享分频/FIFO 控制/访问策略修改和清故障命令以外的诊断配置；不阻止正常 OUT/OE、Pending 清除、FIFO POP、快照触发。DATA_LOCK 才锁正常数据通路。

**GPIO-SEC-002A** GLOBAL_LOCK 同时禁止 IN_ENABLE、IRQ_DETECT_EN、IRQ_ENABLE、EVENT_ENABLE、DIAG_ENABLE、所有逐引脚配置，以及 FAULT_IRQ_ENABLE 的写入；允许设置更多 CFG_LOCK/DATA_LOCK。WAKE_LOCK 只能通过 AON LOCK 命令更新，该命令固定要求 secure/privileged（ACCESS_CTRL_EN=1 时），且受 GLOBAL_LOCK 限制。IRQ_TEST/DIAG_TEST 在 GLOBAL_LOCK=1 时禁止。

**GPIO-SEC-003** 写一个锁定的 RW 字段，即使新值相同也报错；位操作 mask=0 不视为尝试修改。共享 Bank 分频在该 Bank 任一 CFG_LOCK=1 时禁止修改。锁定同样覆盖可用引脚的所有别名入口。

**GPIO-SEC-004** ACCESS_CTRL_EN=1 时，ACCESS_CFG.SECURE_ONLY 和 PRIV_ONLY 对所有业务访问生效；ACCESS_CFG 与所有锁寄存器的写入固定要求 secure 且 privileged，不能通过放宽 ACCESS_CFG 绕过。安全属性来自可信 APB 上游。

**GPIO-SEC-005** ACCESS_CFG 为全局 Bank 以外策略，不实现 per-pin Master ID ACL。PPROT 不包含 Master ID；多核身份隔离应由上游防火墙负责。关闭访问控制参数时忽略 PPROT[1:0]，PPROT[2] 的数据访问限制仍有效。

**GPIO-SEC-006** 同笔事务只要存在一个有效写目标被锁/无能力/无权限，整个事务不更新业务寄存器。违规设置 FAULT_STATUS.ACCESS 并在空闲的首故障槽记录地址和 PPROT，不记录写数据。FAULT_IRQ_ENABLE 控制其是否输出中断。

## 10. 休眠与安全覆盖

**GPIO-LP-001** 每引脚 SLEEP_MODE 为 0=保持、1=强制低、2=强制高、3=高阻。强制低/高是物理推挽 OUT=0/1、OE=1；高阻 OE=0；均仍受输出能力/拥有权约束。GPIO 对开漏线路通常应配置保持或高阻，由系统配置负责选择。

**GPIO-LP-002** sleep_req_i 拉高的下一主域边沿锁存当时正常模式有效 physical_out/oe 到 sleep_hold，应用休眠覆盖并拉高 sleep_ack_o。请求保持期间 ack 保持。请求拉低的下一边沿解除覆盖并拉低 ack。

**GPIO-LP-003** 保持捕获使用进入边沿前的 OUT/OE。若同拍完成 APB OUT 写，先前输出被保持，新数据进入正常锁存，在退出休眠后生效。休眠有效期间允许写 OUT/OE，但 PIN_CFG.SLEEP_MODE 写入报错；CFG_LOCK 仍生效。

**GPIO-LP-004** 主域内输出选择优先级：复位默认值 > safe_req_i 或内部 parity 安全请求 > 休眠覆盖 > 正常输出；最终始终应用 capability/ownership 门控。safe 覆盖用 HW_SAFE_OUT/OE 物理值，旁路反相/开漏。safe_req 解除后回到仍有效的休眠或正常状态。

**GPIO-LP-005** 主域断钟但不断电时已锁存输出继续保持。主域掉电时，本 IP 主域 RTL 不保证保持；SoC 必须在断电前通过 AON PAD 控制/retention/isolation 接管，且退出时先恢复值和路由再解除接管。

**GPIO-LP-006** V1.0 休眠覆盖仅控制 GPIO 输出，不自动关闭输入/中断。软件需要降低输入处理功耗时显式配置 IN_ENABLE；若依赖主域中断唤醒则不能停其时钟。

## 11. AON 唤醒模块及 CDC 合同

### 11.1 检测语义

**GPIO-WAK-001** AON_WAKE_EN=1 时提供独立 gpio_aon_wake 模块。AON 始终采样独立输入，不依赖主域 IN_ENABLE/IRQ_ENABLE/反相/滤波。每引脚 WAKE_MODE 编码同 IRQ_MODE，基于物理同步输入。

**GPIO-WAK-002** AON 每引脚固定 2 级同步器；Bank 共享 WAKE_DIV+1 周期采样节拍；连续 WAKE_COUNT+1 次一致样本后更新检测值，WAKE_COUNT 为 8-bit。WAKE_MODE=0 或 WAKE_ENABLE=0 停止新增事件。首次有效值只建立边沿基线，电平可立即触发。

**GPIO-WAK-003** WAKE_PENDING 为 AON W1C，事件置位优先，wake_req_o=OR(WAKE_PENDING)，不因关闭 WAKE_ENABLE 自动撤销已记录请求。软件必须显式清除；持续电平仍可立即重置位。

### 11.2 配置与读取

**GPIO-WAK-004** 每 Bank 主域窗口维护 staging：ENABLE、MODE_LO/MID/HI（三个位平面）、DIV、COUNT、CLEAR_MASK。模式由三个平面组成 3-bit 编码。提交前检查存在且启用引脚的模式、输入能力和 WAKE_LOCK。

**GPIO-WAK-005** AON_CMD 一次只接受一个 Bank 的一个命令：bit0 COMMIT、bit1 SNAPSHOT、bit2 CLEAR、bit3 LOCK；必须 one-hot。全 IP 仅一个 outstanding AON 命令。COMMIT 原子传输该 Bank 整组配置，AON 生效后返回 ACK；重建该 Bank 唤醒历史但不清 Pending。

**GPIO-WAK-006** SNAPSHOT 在 AON 单个边沿捕获 Pending 和有效位，经 mailbox 返回主域缓存。CLEAR 在 AON 按 CLEAR_MASK 清除 Pending，然后返回清除后（含同拍新事件）状态。LOCK 使用 CLEAR_MASK 作为置锁 mask，在 AON 域置 WAKE_LOCK，软件 SNAPSHOT 同时返回锁状态。

**GPIO-WAK-007** staging 可在 BUSY=0 时写，BUSY=1 时所有 staging/命令写入报错。COMMIT 对包含已锁引脚的配置不得改变锁定字段；锁定位的值与当前 AON 活动配置不一致则整个 Bank COMMIT 失败。WAKE_DIV/COUNT 在该 Bank 任一 WAKE_LOCK=1 时不得改变。

**GPIO-WAK-008** main_rst_ni 不影响 AON 活动配置、WAKE_LOCK、Pending。主域 staging 复位为 0；暖复位后要修改含锁引脚 Bank，先执行 SNAPSHOT，返回的活动配置填充 AON_READBACK 窗口，软件据此重建 staging。未完成同步前不得自动重放旧请求。

### 11.3 超时和复位

**GPIO-WAK-009** 使用双时钟 request/ack mailbox，数据在请求到应答期间保持稳定，多位数据不得逐位裸同步。主复位后通道先进入 RECOVER 状态，完成 request/ack 空闲重同步后 READY=1。READY=0 时命令报错。

**GPIO-WAK-010** AON_TIMEOUT 为 24-bit 主时钟周期数，默认 65535，最小 16。到期设置 TIMEOUT 和全局故障，但 BUSY 保持，禁止复用 mailbox；迟到 ACK 仍完成原操作。超时不保证操作未生效，也不提供命令撤销。软件应查询/恢复 AON 后确认实际状态，不能直接重发。

**GPIO-WAK-010A** AON_STATUS.TIMEOUT 为命令局部状态，下一合法命令接受时清除；FAULT_STATUS.AON_TIMEOUT 为独立 sticky 诊断，仅 FAULT_CLEAR 或主复位清除。ERROR 与 AON_ERROR 同理。超时之后 BUSY 未解除时，下一命令不可能被接受。AON硬件运行错误不能仅以APB错误代替，必须通过应答ERROR和FAULT_STATUS报告。

**GPIO-WAK-011** 暖复位中断已发送命令时，AON 可能已经执行，桥接器通过序号/握手恢复保证旧命令不重复执行；返回主域 READY 前必须排空旧应答。冷复位两域均清初始状态。具体 CDC/RDC 结构须在架构设计中证明满足本语义。

**GPIO-WAK-012** PMU 仅在 COMMIT DONE、wake_req_o=0、主域 sleep_ack_o=1 及系统 PAD 接管完成后允许关电。AON 检测全程运行，入睡边界发生事件应阻止关电或触发立即恢复；该最终仲裁属于 PMU。

## 12. 快照与 Strap

**GPIO-CAP-001** SNAPSHOT_CMD bit0 或 snapshot_req_i 触发时，同一主边沿捕获所有 Bank 的边沿前 IN_DATA 与 IN_VALID。软件读 SNAP_DATA/SNAP_VALID 为冻结值；SNAP_SEQ 加 1（32-bit 回绕）。同拍软硬件请求合并一次；允许下一拍覆盖，SEQ 用于检测读取期间更新。

**GPIO-CAP-002** Strap 使用 IN_SYNC 的物理值，忽略 IN_INV/滤波/去抖；仅在所有 INPUT_CAP_MASK 指定输入均处于可用且同步填充完成后接受第一次 strap_sample_i=1。捕获 STRAP_DATA、STRAP_VALID=1，之后忽略请求直至主域复位。过早请求忽略并置 FAULT_STATUS.STRAP_EARLY，软件/启动逻辑须重新请求。

**GPIO-CAP-003** Strap 只能用于主域时钟和复位已可用后的配置读取。决定主时钟/复位释放本身的启动 Strap 必须由专用 Boot/AON 模块承担。

## 13. 事件 FIFO、时间戳及 DMA

**GPIO-EVT-001** FIFO 记录 IRQ 边沿检测事件，受每 Bank EVENT_ENABLE 进一步筛选。IRQ_TEST 和电平模式不写 FIFO。每个记录 128-bit：WORD0[6:0]=pin_id、[8]=1 上升/0 下降，其余 0；WORD1=timestamp[31:0]；WORD2=timestamp[63:32]；WORD3=0（保留）。

**GPIO-EVT-002** timestamp 为主域 64-bit 每周期加 1 自由运行计数器，主复位清零，停钟停止，不代表墙上时间。事件时间戳为生成 event_o 的主域周期计数值。读取当前时间 TS_LO 时锁存 TS_HI 快照，后续读 TS_HI 返回锁存高位；多执行者需要软件互斥。

**GPIO-EVT-003** 每周期最多写一条记录。同拍多个选中引脚事件按最小 pin_id 选择一个，其余按丢失计入 LOST_COUNT；FIFO 满时丢弃新事件，不覆盖旧记录。LOST_COUNT 为 32-bit 饱和计数；任何丢失置 OVERFLOW。该产品不承诺多引脚事件无损记录。

**GPIO-EVT-004** EVENT_HEAD0～3 是不消费的队头读取。EVENT_POP bit0=1 显式弹出一条，空 FIFO POP 成功无操作；空 FIFO HEAD 读 0。非空期间新写入不改变队头，因此软件先读四字再 POP 可一致读取。多个消费者须软件互斥。

**GPIO-EVT-005** 同拍 POP 与写入允许互换槽位；FIFO 满且成功 POP 时可接收一个新事件。FIFO 空且 POP 与新事件同拍，新事件留下，POP 不消费尚不存在的记录。FLUSH 清 FIFO/LEVEL，且当拍新事件丢弃计入 LOST_COUNT。CLEAR_LOST 与丢失同拍时从 0 加本拍丢失数，OVERFLOW 置位优先。

**GPIO-EVT-006** WATERMARK 合法范围 1～DEPTH，FIFO_CTRL.EN 控制记录，DMA_EN 控制 dma_req_o=DMA_EN && LEVEL!=0。FAULT_IRQ 的 FIFO 水位源采用 LEVEL>=WATERMARK，溢出源采用粘滞 OVERFLOW。关闭记录不清存量。

**GPIO-EVT-007** DMA 是外部 APB Master，经系统互联读 HEAD0～3 并写 POP；GPIO 无内存 Master 端口、无独立 DMA ACK、无自动 pop-on-read。驱动/DMA 描述符必须支持读四字后显式写 POP 的事务序列。普通仅固定源地址搬运的 DMA 不自动兼容本 FIFO。

## 14. 诊断与安全输出

**GPIO-DIAG-001** DIAG_EN 启用逐引脚物理回读比较，使用 IN_SYNC 而非 IN_DATA。只有输入有效、输出拥有权成立，且当前最终 OE=1 时检查；高阻、开漏释放不检查。

**GPIO-DIAG-002** 最终 OUT/OE、输出拥有权、输入 available、休眠/安全状态变化时重启消隐计数；BLANK=DIAG_CFG[15:0]，合法值至少 SYNC_STAGES+2。消隐 BLANK 个完整周期后比较物理回读与期望 OUT。持续 M=DIAG_CFG[23:16]+1 次失配后置 DIAG_PENDING[i]；匹配时失配计数清零。复位默认 BLANK=SYNC_STAGES+2，M=1。

**GPIO-DIAG-003** DIAG_PENDING 为 W1C，持续故障到阈值后每拍保持置位优先，软件清除不能隐藏未恢复失配。DIAG_PENDING & DIAG_ENABLE 的 OR 进入 FAULT_STATUS 的实时汇总，不自动控制主安全覆盖。

**GPIO-DIAG-004** DIAG_TEST 为 WO，写 1 对应引脚置 DIAG_PENDING，测试后应软件清除。它验证记录/报警路径，不验证 PAD、电气驱动或完整输入路径。V1.0 不提供输入软件强制回环，避免与正常输入有效性混淆。

**GPIO-DIAG-005** CFG_PARITY_EN=1 时，对 OUT_DATA、OUT_OE、PIN_CFG、IRQ_ENABLE、IRQ_DETECT_EN、ACCESS_CFG 的存储值提供每 32-bit 字偶 parity。每拍检查；部分写根据合并后的完整字重算 parity。故障置 FAULT_STATUS.PARITY，内部安全请求保持到冷复位；软件不能通过 W1C解除安全请求。暖复位不清该锁存故障。parity 检测延迟上界为 1 个运行的主时钟周期。

**GPIO-DIAG-006** parity 故障注入寄存器只在 CFG_PARITY_EN=1 且 secure/privileged 访问时支持：选择现有 Bank OUT_DATA parity bit 翻转一次，不更改数据；GLOBAL_LOCK=1 时禁止注入。用于验证检测和 HW_SAFE 输出。其余冗余/TMR/锁步不属于本 V1.0 实现承诺。

**GPIO-DIAG-007** 安全交付不得以本功能列表声明 ASIL 或诊断覆盖率。必须结合 FMEDA、故障模型、PAD 与外部电路、时钟和电源假设单独评估；输出回读不能保证覆盖所有开路/短路。

## 15. 寄存器地图

### 15.1 通用约定

地址空间 16 KiB，均为相对 IP 基址偏移。Bank b=0..N_BANK-1；引脚 i=0..N_GPIO-1。没有列出的字地址均非法。RW/W1S 默认 0，例外在表中明确；RO 动态状态随硬件。bit 向量寄存器按 Bank 位号映射实际引脚。RO 常量在暖复位不变。

### 15.2 全局 0x0000～0x00FF

| 偏移 | 名称 | 属性 | 定义/复位 |
|---|---|---|---|
| 0x0000 | IP_ID | RO | 0x4750494F |
| 0x0004 | VERSION | RO | 0x00010000，major[31:16]/minor[15:8]/patch[7:0] |
| 0x0008 | FEATURE | RO | bit0 OUT_INV、1 AON、2 SNAPSHOT、3 STRAP、4 FIFO、5 DIAG、6 ACCESS、7 PARITY |
| 0x000C | GEOMETRY | RO | [7:0] N_GPIO，[15:8] N_BANK，[23:16] N_IRQ_GROUPS，[31:24] SYNC_STAGES |
| 0x0010 | GLOBAL_LOCK | W1S | bit0，POR 清 |
| 0x0014 | ACCESS_CFG | RW | bit0 SECURE_ONLY、1 PRIV_ONLY；默认 BOOT_*；POR 清/恢复 |
| 0x0018 | FAULT_STATUS | RO | bit0 ACCESS、1 FIFO_OVERFLOW、2 AON_TIMEOUT、3 STRAP_EARLY、4 PARITY、5 DIAG_ANY、6 FIFO_WATERMARK、7 AON_ERROR |
| 0x001C | FAULT_CLEAR | WO | 写 1 清对应 sticky 源；bit4/5/6 不可清、忽略 |
| 0x0020 | FAULT_IRQ_ENABLE | RW | 对应 FAULT_STATUS，默认0 |
| 0x0024 | ACCESS_FIRST | RO | [13:0] PADDR、[18:16] PPROT、[19] write、[31] valid |
| 0x0028 | SNAPSHOT_CMD | WO | bit0 trigger |
| 0x002C | SNAP_SEQ | RO | 0起，快照时递增 |
| 0x0030 | STRAP_VALID | RO | bit0 |
| 0x0034 | LP_STATUS | RO | bit0 sleep_active、1 safe_active |
| 0x0038 | TS_LO | RO | 当前时间低位，读时锁高位 |
| 0x003C | TS_HI | RO | 锁存高位 |
| 0x0040 | FIFO_CTRL | RW | bit0 EN、1 DMA_EN；默认0 |
| 0x0044 | FIFO_WATERMARK | RW | [6:0]，默认1 |
| 0x0048 | FIFO_LEVEL | RO | 当前条数 |
| 0x004C | FIFO_LOST | RO | 饱和丢失数 |
| 0x0050～0x005C | EVENT_HEAD0～3 | RO | 队头4字 |
| 0x0060 | EVENT_POP | WO | bit0 pop |
| 0x0064 | FIFO_CMD | WO | bit0 FLUSH、1 CLEAR_LOST，可同时置位 |
| 0x0068 | AON_STATUS | RO | bit0 READY、1 BUSY、2 DONE、3 TIMEOUT、4 ERROR、[9:8] bank |
| 0x006C | AON_TIMEOUT | RW | [23:0]，默认65535 |
| 0x0070 | PARITY_INJECT | WO | bit0 trigger，[9:8] Bank，非法 Bank 报错 |

FAULT_CLEAR.ACCESS 同时释放 ACCESS_FIRST 槽；同拍新错误占用新槽、置位优先。FAULT_CLEAR 的 FIFO_OVERFLOW 仅清溢出标志不清 LOST；FIFO_CMD.CLEAR_LOST 清两者。AON_ERROR 表示命令在 AON 端因锁/校验等拒绝，无活动配置副作用。

### 15.3 Bank：0x0100 + b×0x0100

| Bank内偏移 | 名称 | 属性 | 说明 |
|---|---|---|---|
| 0x00 | INPUT_CAP | RO | 输入能力 |
| 0x04 | OUTPUT_CAP | RO | 输出能力 |
| 0x08 | IN_SYNC | RO | 同步物理值 |
| 0x0C | IN_DATA | RO | 处理逻辑值 |
| 0x10 | IN_VALID | RO | 有效向量 |
| 0x14 | IN_ENABLE | RW | 默认 RESET_IN_EN；受 CFG_LOCK |
| 0x18 | OUT_DATA | RW | 默认 RESET_OUT |
| 0x1C | OUT_SET | WO | 原子置位 |
| 0x20 | OUT_CLR | WO | 原子清除 |
| 0x24 | OUT_TOGGLE | WO | 原子翻转 |
| 0x28 | OUT_MASKED_LO | WO | 半字掩码写 |
| 0x2C | OUT_MASKED_HI | WO | 半字掩码写 |
| 0x30 | OUT_OE | RW | 默认 RESET_OE |
| 0x34 | OE_SET | WO | 置位 |
| 0x38 | OE_CLR | WO | 清除 |
| 0x3C | OE_MASKED_LO | WO | 半字掩码写 |
| 0x40 | OE_MASKED_HI | WO | 半字掩码写 |
| 0x44 | IRQ_DETECT_EN | RW | 默认0 |
| 0x48 | IRQ_ENABLE | RW | 默认0 |
| 0x4C | IRQ_PENDING | W1C | 置位优先 |
| 0x50 | IRQ_STATUS | RO | Pending & Enable |
| 0x54 | IRQ_TEST | WO | 强制 Pending |
| 0x58 | RISING_PENDING | W1C | 上升事件 |
| 0x5C | FALLING_PENDING | W1C | 下降事件 |
| 0x60 | CFG_LOCK | W1S | POR 清 |
| 0x64 | DATA_LOCK | W1S | POR 清 |
| 0x68 | BANK_DEBOUNCE_DIV | RW | [15:0]，默认0 |
| 0x6C | EVENT_ENABLE | RW | 事件 FIFO 引脚掩码，受 CFG_LOCK |
| 0x70 | SNAP_DATA | RO | 快照数据 |
| 0x74 | SNAP_VALID | RO | 快照有效位 |
| 0x78 | STRAP_DATA | RO | 一次捕获 |
| 0x7C | DIAG_ENABLE | RW | 受 CFG_LOCK |
| 0x80 | DIAG_PENDING | W1C | 诊断状态 |
| 0x84 | DIAG_TEST | WO | 测试置位 |
| 0x88 | OUTPUT_OWNED | RO | 拥有权状态 |
| 0x8C | INPUT_AVAILABLE | RO | 输入可用状态 |

### 15.4 逐引脚：0x1000 + i×0x0020

| 偏移 | 名称 | 属性 | 字段 |
|---|---|---|---|
| 0x00 | PIN_CFG | RW | [0] FILTER_EN，[1] DEBOUNCE_EN，[2] IN_INV，[3] OUT_OD，[4] OUT_INV，[7:5] IRQ_MODE，[9:8] IRQ_GROUP，[11:10] SLEEP_MODE；其余0 |
| 0x04 | FILTER_CFG | RW | [7:0] K-1，默认0 |
| 0x08 | DEBOUNCE_CFG | RW | [7:0] D-1，默认0 |
| 0x0C | DIAG_CFG | RW | [15:0] BLANK，[23:16] M-1，默认 BLANK=SYNC_STAGES+2 |

PIN_CFG 默认0，SLEEP_MODE=保持。关闭 OUT_INV 参数后该位读0写忽略；没有 DIAG 时 DIAG_CFG 读0写忽略。其他空余逐引脚字地址非法。

### 15.5 AON Bank 主域窗口：0x3000 + b×0x0100

| 偏移 | 名称 | 属性 | 说明 |
|---|---|---|---|
| 0x00 | WAKE_ENABLE_STAGE | RW | staging使能 |
| 0x04/08/0C | WAKE_MODE_STAGE0/1/2 | RW | 模式位平面 |
| 0x10 | WAKE_DIV_STAGE | RW | [15:0] DIV |
| 0x14 | WAKE_COUNT_STAGE | RW | [7:0] COUNT |
| 0x18 | WAKE_MASK_STAGE | RW | CLEAR/LOCK mask |
| 0x1C | AON_CMD | WO | bit0 COMMIT、1 SNAPSHOT、2 CLEAR、3 LOCK，one-hot |
| 0x20 | WAKE_PENDING_READ | RO | 最近应答快照 |
| 0x24 | WAKE_VALID_READ | RO | 最近应答有效输入 |
| 0x28 | WAKE_LOCK_READ | RO | 最近应答锁 |
| 0x2C | WAKE_ENABLE_READ | RO | 活动配置读回 |
| 0x30/34/38 | WAKE_MODE_READ0/1/2 | RO | 活动模式 |
| 0x3C | WAKE_DIV_READ | RO | 活动分频 |
| 0x40 | WAKE_COUNT_READ | RO | 活动计数 |

每个成功 AON 应答更新上述完整读回窗口，DONE 保持到下一条合法命令被接受；接受新命令清 DONE/ERROR/TIMEOUT。AON_STATUS.BANK 指示当前或最后一条命令 Bank。活动唤醒配置仅 POR 复位。GLOBAL_LOCK 阻止 COMMIT/LOCK，允许 SNAPSHOT/CLEAR；WAKE_LOCK 本身不阻止 Pending 清除。

## 16. 优先级与复位矩阵

| 竞争 | 必须行为 |
|---|---|
| 主域复位 vs 主业务写/事件 | 复位优先，业务事务不计完成；APB上游与主域同步复位 |
| W1C vs 新中断/诊断/唤醒 | 新事件置位优先 |
| FIFO POP vs PUSH | 按13节处理，满可同拍换入 |
| FIFO FLUSH vs PUSH | 清旧队列，新事件按丢失记录 |
| 清首访问错误 vs 新错误 | 记录新错误 |
| 软件写锁定位 | 整笔错误，无部分更新 |
| sleep进入 vs OUT写 | 捕获旧物理输出，正常锁存接收新写 |
| safe请求 vs sleep | safe覆盖优先，休眠状态机继续保持 |
| IRQ配置变化 vs 边沿 | 新配置生效边沿重建基线，不解释为输入边沿 |
| 软件快照 vs 硬件快照 | 合并一次 |

| 状态 | POR/AON冷复位 | main暖复位 |
|---|---|---|
| 主功能CSR、FIFO、主Pending、快照、Strap | 默认值 | 默认值 |
| CFG/DATA/GLOBAL锁、ACCESS_CFG | 默认值 | 保持 |
| 主 parity 故障安全锁存 | 清 | 保持 |
| AON配置/锁/Pending | 清 | 保持 |
| 主域AON staging/缓存 | 清 | 清，握手恢复后READY |
| 休眠覆盖保持值 | 清 | 清，输出进入RESET_* |

保持跨暖复位的锁/策略/故障状态必须采用独立 POR 复位存储，不得将 main_rst_ni 错接到这些寄存器。

## 17. 软件使用顺序

### 17.1 输出配置

1. 检查 CAP、锁和权限；协调 Pinmux 拥有权。
2. OE_CLR 关闭目标输出。
3. 配置 OUT_OD/OUT_INV，并设置 OUT_DATA。
4. 配置 PAD 电气属性并保证路由稳定。
5. OE_SET 开输出；必要时等待 DIAG_BLANK 后检查 IN_SYNC。

### 17.2 中断配置

1. 清 IRQ_ENABLE 与 IRQ_DETECT_EN 对应位。
2. 配置输入处理与 IRQ_MODE，等待 IN_VALID。
3. 清历史 IRQ/RISING/FALLING Pending。
4. 开 IRQ_DETECT_EN；基线建立不补发历史边沿。
5. 开 IRQ_ENABLE。电平模式若已有效，可以立即中断。
6. ISR 读取状态、处理外部源，再 W1C；持续电平先处理源再清。

### 17.3 深睡唤醒

1. 完成 AON READY，读取/清历史唤醒原因。
2. 写 staging、发 COMMIT，等待 DONE 且无 ERROR/TIMEOUT。
3. 配置 GPIO SLEEP_MODE，拉 sleep_req，等待 ack。
4. PMU 检查 wake_req 并完成 PAD 常开接管后关电。
5. 恢复主域，等待桥接 READY，SNAPSHOT 读取原因。
6. 恢复主CSR/OUT/Pinmux，解除接管及sleep请求。
7. 处理外部唤醒源，CLEAR 原因；确认 wake_req 已撤销。

## 18. 架构约束与PPA

**GPIO-ARC-001** 建议模块为 gpio_apb_if、gpio_regfile、gpio_input、gpio_output、gpio_irq、gpio_aon_wake、gpio_aon_mailbox、gpio_event_fifo、gpio_diag。划分可调整，但软件行为不可变化。

**GPIO-ARC-002** 同步器必须真实存在，未使用通道及裁剪功能可综合移除；滤波/去抖计数采用使能，Bank 共享分频。不要求每引脚独立分频器。

**GPIO-ARC-003** IRQ 汇总和 Bank 读数据使用平衡结构，128路配置不得出现非必要串行优先链。事件 FIFO 单写端仲裁允许树形优先编码。

**GPIO-ARC-004** V1.0 无 AXI/AHB 接口、无自动波形发生器、PWM、协议引擎或专用高速脉冲计数器。APB 持续零等待访问最短每两主时钟完成一次写；通过 TOGGLE 连续写实现完整输出方波最快每四主周期一周期，实际受上游限制。

**GPIO-ARC-005** 综合报告至少覆盖 N_GPIO=8/32/128、最小裁剪和完整配置，分别报告面积、关键路径、动态功耗估计和 AON 成本。频率目标由目标库/工艺集成约束给出，本文不虚构 MHz/PPA 指标。

## 19. 验证要求与可追踪验收

| 验证ID | 需求范围 | 强制验收场景 |
|---|---|---|
| GPIO-V-001 | CFG/IF | 1、8、31、32、33、64、128路；不同能力mask；非法参数失败 |
| GPIO-V-002 | BUS | APB Setup/Access、背靠背、PSTRB所有组合、非法地址/RO写/字段/PPROT、错误无业务副作用 |
| GPIO-V-003 | IN/FLT | 初始高低、异步相位、valid撤销恢复、K/D阈值前后、DIV极值、处理中重配置 |
| GPIO-V-004 | OUT | 所有原子操作、mask边界、开漏释放、反相、关OE配模式、模式违规写 |
| GPIO-V-005 | IRQ | 所有模式、DETECT/ENABLE组合、首次valid、W1C与事件同拍、持续电平、方向记录、分组 |
| GPIO-V-006 | SEC | 全写入口锁定、混合锁定位整笔失败、暖复位保持锁/策略、越权首故障记录 |
| GPIO-V-007 | LP | sleep请求保持/解除、同拍写、safe优先、断钟保持、外部隔离模型 |
| GPIO-V-008 | WAK | 异步时钟比、AON停钟、超时迟到ACK、COMMIT原子性、暖复位在每握手阶段、入睡边界事件 |
| GPIO-V-009 | CAP | 所有Bank同拍快照、SEQ回绕、Strap过早/首次/重复/复位 |
| GPIO-V-010 | EVT | 同拍多引脚仲裁、满/空POP+PUSH、FLUSH冲突、LOST饱和、队头一致、DMA读后POP |
| GPIO-V-011 | DIAG | 消隐边界、持续失配/恢复、开漏释放不查、失配清除竞争、parity注入安全覆盖 |
| GPIO-V-012 | RESET | 复位矩阵全部状态，主APB与主域同步复位，AON独立保留 |

**GPIO-VER-001** 使用独立功能参考模型检查输入处理、中断、FIFO和AON命令；不能仅复制 RTL 分支形成自证。功能覆盖包含上述边界交叉；不可达覆盖项需有配置依据。

**GPIO-VER-002** SVA 至少断言：非法APB事务无业务更新；OE不得越过能力/所有权；开漏不会主动驱动高；置位优先；锁不被软件清；AON BUSY数据稳定；FIFO容量边界；首次有效无伪边沿。

**GPIO-VER-003** 完成 lint、CDC、RDC、综合检查；所有未解决高风险问题阻止验收。数字仿真不能证明亚稳态MTBF或PAD电气波形；须交付同步器约束与PAD集成假设。

**GPIO-VER-004** 每项需求关联至少一项检查/测试/分析证据；验证计划在RTL完成前形成，并与架构同步更新。验收要求全部必备及所启用增强功能通过，不允许以未实现而静默读0替代已声明功能。

## 20. 交付清单与集成必须填写项

### 20.1 产品交付

- requirement.md（本文）、architecture.md、寄存器机器可读定义及生成结果。
- 参数化 RTL、FuseSoC core、编译/仿真/综合入口。
- APB及GPIO验证环境、RAL、参考模型、SVA、测试和覆盖报告。
- C寄存器头文件及输出、中断、AON唤醒、事件FIFO示例驱动。
- CDC/RDC/STA约束、复位/电源域接口说明、低功耗集成例。
- 功能裁剪和能力查询说明、PPA报告、已知限制。
- 启用安全增强时的故障模型、注入测试和使用假设；不附未经证实的认证声明。

### 20.2 每个SoC实例必须确定的集成值

| 项目 | 必须提供的信息 |
|---|---|
| 引脚映射 | GPIO编号、PAD名称、Pinmux选择、输入/输出能力 |
| 默认输出 | RESET_OUT/OE、HW_SAFE_OUT/OE及板级影响 |
| 时钟 | pclk/aon_clk范围、停钟条件、同步器MTBF目标 |
| 复位 | POR、main、AON的真实复位树与释放顺序 |
| 电源 | PAD/AON/主域供电、隔离保持位置及PMU握手 |
| 电气 | 开漏上拉、负载、驱动能力、诊断消隐的外部延迟上界 |
| 总线 | 基地址、访问权限、APB HWIF、可信PPROT来源 |
| 中断/DMA | IRQ路由、DMA是否支持四字读取加显式POP |
| 安全 | 故障输出接收者、系统安全态、诊断覆盖评估责任 |

上述项目是实例配置与系统环境输入，不改变本文已经定义的寄存器和功能行为。完成实例信息和文档评审后，方可将状态从 implementation-ready-draft 更新为冻结基线。
