# AIXSILICON Pad Controller IP — 需求规格与架构建议

- Document ID：`aixsilicon:ip:pad_controller:req`
- IP / VLNV：`pad_controller` / `aixsilicon:ip:pad_controller:1.0.0`
- 版本：1.0.0-draft；日期：2026-09-10
- 产品形式：参数化 SystemVerilog IP，APB4 Slave；Python 生成配置与连接；FuseSoC 管理构建。
- 状态：建议需求基线，可进入架构/RTL/验证设计；工艺绑定前须填写 Pad 能力与板级复位配置，本文不代表已实现或已验证。
- 约定：“必须”是验收要求；架构建议允许等价实现。本文提出的接口、编码、严格写检查和时序是本 IP 的设计选择，不是被引用项目的原样规格。

## 1. 参考实现与采用原则

| 参考 | 可借鉴内容 | 本 IP 的选择 |
|---|---|---|
| OpenTitan Pinmux | 属性控制与 Pad wrapper 分层；逐引脚休眠输出保持；唤醒后显式释放 | 采用分层与保持原则；不包含其完整 Pinmux、调试或唤醒模块 |
| PULP Padrick | YAML 描述 Padframe，生成 SV、软件与文档 | 借鉴配置一致性；核心 Controller 保持手写参数化 SV |
| Linux PINCTRL | 功能复用与电气属性配置分别建模 | 软件接口保留 pinconf 对应关系；本 IP 不实现功能复用矩阵 |

OpenTitan 提供驱动能力、上下拉、开漏等属性，通过 wrapper 适配实际 Pad 支持范围；其文档也明确描述休眠保持及软件释放机制。[OpenTitan 原理说明](https://opentitan.org/book/hw/ip/pinmux/doc/theory_of_operation.html)

Padrick 从 YAML 生成 Pad 连接、复用逻辑及配套软件、文档。其仓库仍明确提示早期开发、未经作者确认勿用于实际流片，因此这里只将其作为生成方法参考，不当作生产成熟度背书。[Padrick 官方仓库](https://github.com/pulp-platform/padrick)

Linux 将电气属性配置与引脚复用分别暴露为 pin configuration 和 mux functions；这有利于明确软硬件边界。[Linux PINCTRL 文档](https://docs.kernel.org/driver-api/pin-control.html)

其他章节均为基于上述原则制定的独立工程方案；不承诺通过任何功能安全等级认证。

## 2. 产品定位及边界

**PC-SCP-001**：IP 必须控制普通数字 Pad 的属性、输出许可、运行期隔离、休眠行为及配置保护。支持固定功能 Pad 和来自独立 Pinmux 的复用 Pad。

**PC-SCP-002**：功能数据路径必须为组合路径，不因经过 Controller 固定增加 PCLK 周期。只对配置、管理状态及监测副本寄存。不得把外设功能输入统一打两拍。

**PC-SCP-003**：IP 不包含 GPIO 输出寄存器/中断、Pinmux 路由矩阵、模拟 PHY、电源 Pad、ESD、Pad 物理放置、边界扫描链和动态 I/O 电压切换。DDR/SerDes/USB PHY 等专用 Pad 由对应 PHY 管理。

**PC-SCP-004**：V1.0 支持电气属性、严格配置检查、逐 Pad 隔离、开漏、休眠保持/释放、写锁、可信访问限定、错误状态/IRQ、多 I/O bank 状态接口。唤醒检测、strap 采样、配置奇偶校验、冗余控制、分组原子提交不属于 V1.0 基线。

## 3. 结构及所有权

建议模块：

| 模块 | 职责 |
|---|---|
| `pad_controller.sv` | APB、寄存器、管理逻辑、逐 Pad 通道集成 |
| `pad_ctrl_regs.sv` | 固定步长地址解码、能力查询、访问校验 |
| `pad_ctrl_channel.sv` | 数据/OE 选择、开漏、隔离、输入钳位 |
| `pad_ctrl_sleep.sv` | 全局休眠握手、逐 Pad 保持与显式释放 |
| `pad_ctrl_pkg.sv` | 固定属性结构、枚举、接口类型 |
| `pad_tech_wrapper.sv` | 独立工艺适配：Cell、极性、编码、物理安全控制 |
| `pad_generic_model.sv` | 仅用于仿真，建模数字驱动、弱拉与总线争用 |

**PC-ARC-001**：功能连接关系是外设/Pinmux → Controller → 工艺 wrapper → Pad。Pad 输入沿反向组合路径返回；Controller 不决定外设功能归属。

**PC-ARC-002**：Controller 输出统一逻辑属性。工艺 wrapper 负责最终 Cell 端口编码。仿真模型不得作为综合 Pad 实现。

**PC-ARC-003**：每个物理属性必须有唯一配置所有者。若多个 Pad 共享驱动或电气控制寄存器，V1.0 不得伪装成各自独立可编程；须将共享项固定，或由独立 bank 控制模块管理，并在逐 Pad 能力中标为不可写。

## 4. 参数与静态配置

| 参数/配置 | 定义与限制 |
|---|---|
| `NUM_PADS` | 1～512，推荐默认 32 |
| `NUM_BANKS` | 1～16；每个 Pad 归属一个 bank |
| `PADDR_WIDTH` | 默认 16；至少覆盖 `0x1000 + NUM_PADS*0x40` 字节 |
| `HAS_SLEEP` | 0/1，默认 1 |
| `HAS_IRQ` | 0/1，默认 1 |
| `PAD_CAP[i]` | 输入、输出、各属性能力的常量描述 |
| `DRIVE_VALID[i]` | 16 位合法驱动档位掩码；至少一位有效 |
| `SLEW_VALID[i]` | 4 位合法转换速率档位掩码；至少一位有效 |
| `RESET_ATTR[i]` | 复位属性，必须通过合法性检查 |
| `RESET_ISOLATE[i]` | 默认 1，特殊启动 Pad 可按板级要求设为 0 |
| `RESET_SLEEP_CFG[i]` | 默认 Hi-Z，必须符合 Pad 能力 |
| `RESET_LOCK[i]` | 默认 0；1 表示上电即禁止配置修改 |
| `TRUSTED_ONLY[i]` | 默认 1；逐 Pad 固定访问策略 |
| `PAD_BANK[i]` | 0～NUM_BANKS-1 |
| `AON_SOURCE[i]` | 允许休眠 FOLLOW 的功能源是否始终供电且有效 |
| `INPUT_CLAMP[i]` | 输入关闭/隔离时向内部返回的固定 0 或 1，默认 0 |

**PC-PAR-001**：非法参数必须在生成检查或 elaboration 阶段失败，包括不合法复位值、不存在的 bank、空合法值集合、输入专用 Pad 配置输出、非 AON 源配置 FOLLOW。

**PC-PAR-002**：未支持字段必须裁剪为常量；固定字段允许非零复位值。能力读回区分“支持/可写”与当前值。支持可写值集合只作用于相应字段。

**PC-PAR-003**：1、32、非 2 次幂 33 和 512 Pad 均须可构建；不得出现零宽向量与地址别名。

## 5. 接口与时钟复位

### 5.1 APB4

32 位 `PWDATA/PRDATA`、4 位 `PSTRB`、`PADDR`、`PSEL/PENABLE/PWRITE/PREADY/PSLVERR`、`PPROT[2:0]`；所有事务在 `pclk_i` 域。

### 5.2 功能与工艺接口

| 信号 | 方向 | 语义 |
|---|---|---|
| `func_out_i[N]` | 输入 | 外设/Pinmux 输出值 |
| `func_oe_i[N]` | 输入 | 外设输出使能，1=请求驱动 |
| `func_in_o[N]` | 输出 | 返回外设的组合输入 |
| `pad_in_i[N]` | 输入 | Pad 输入缓冲输出 |
| `pad_out_o[N]` | 输出 | 提交给 wrapper 的输出值 |
| `pad_oe_o[N]` | 输出 | 统一高有效输出使能 |
| `pad_ie_o[N]` | 输出 | 统一高有效输入缓冲使能 |
| `pad_attr_o[N]` | 输出 | 最终统一电气属性；OD 在通用数字逻辑实现 |
| `bank_ready_i[B]` | 输入 | 已同步到 PCLK 的 bank 可用状态 |
| `force_hiz_i[N]` | 输入 | 已同步的功能管理强制高阻，优先于一般控制 |
| `sleep_req_i` | 输入 | 同步、保持型休眠请求 |
| `sources_quiesced_i` | 输入 | 同步握手：待保持源已稳定、满足捕获条件 |
| `sleep_ack_o` | 输出 | 保持策略已接管，可按约定关断功能源 |
| `irq_o` | 输出 | 错误状态与使能的或归约；裁剪后为 0 |

`bank_ready_i` 是数字管理指示，不代替工艺电源排序信号、level shifter、isolation cell 或 Pad 自身 fail-safe 能力。

**PC-CLK-001**：基线 Controller 及其寄存器、保持状态位于 AON 电源域；PCLK 在管理事务与休眠握手期间必须运行。V1.0 不含内部 APB CDC，不承诺停钟时受理请求。

**PC-CLK-002**：`por_ni` 异步置复位、同步释放；控制全部配置、锁及休眠状态。APB 的 `preset_ni` 只屏蔽/复位总线事务，不清除 Pad 属性与锁。集成必须保证冷启动同时正确复位两者。

**PC-CLK-003**：SoC warm reset 不直接清除 Pad 配置；外设先复位时，集成方必须先通过保持或 `force_hiz_i` 防止引脚跳变。对 CPU 可访问的 APB 复位不构成解除写锁的方法。

**PC-CLK-004**：POR 期间 `pad_oe_o=0`；属性输出复位值，输入使能按复位属性和 bank 状态确定。POR 释放后按 `RESET_ISOLATE` 决定输出许可。需要 POR 期间主动驱动的特殊引脚不属于该通用输出保证，须专用工艺/启动控制。

## 6. 属性编码及功能语义

`ATTR` 为一个 32 位字，字段布局固定：

| 位 | 字段 | 编码 |
|---|---|---|
| 0 | IE | 1：开启输入缓冲 |
| 1 | OUT_ALLOW | 1：允许所选功能请求驱动；不强制驱动 |
| 3:2 | BIAS | 0：无内部偏置；1：上拉；2：下拉；3：Keeper |
| 4 | SCHMITT | 施密特输入使能 |
| 5 | OD | 数字开漏模式 |
| 9:6 | DRIVE | 0～15 逻辑档位，合法集合由 `DRIVE_VALID` 指定 |
| 11:10 | SLEW | 0～3 逻辑档位，合法集合由 `SLEW_VALID` 指定 |
| 31:12 | 保留 | 读 0；选中写入非零报错 |

**PC-ATR-001**：BIAS 采用互斥枚举，禁止同时打开上拉/下拉或 Keeper。只允许 Pad 声明支持的模式。

**PC-ATR-002**：DRIVE 不直接表示 mA，SLEW 不直接表示 ns。工艺映射表必须给出每一有效编码对应的 Cell 编码及工艺数据来源；不得虚构跨工艺统一电气值。

**PC-ATR-003**：不支持字段固定为复位值；尝试改变固定字段报错，不静默截断。不支持档位报错。与 OpenTitan 的 WARL 方式不同，本 IP 选择严格拒绝非法写入。

**PC-DAT-001**：运行模式先选择 `d=func_out_i`、`oe=func_oe_i`，再应用：

```systemverilog
// 语义示意；高优先级复位/管理控制见下文。
pad_out = attr.OD ? 1'b0 : d;
pad_oe  = oe & attr.OUT_ALLOW & (!attr.OD | !d);
```

OD=1 时 d=0 且 oe=1 才拉低；d=1 表示释放。禁止数字逻辑主动驱动高电平。外部上拉及 RC 时序由系统设计保证；内部弱上拉不等同于满足 I2C 电气要求。

**PC-DAT-002**：`ISOLATE=1` 禁止输出驱动，但不强制关闭输入或偏置。`force_hiz_i=1` 同样仅禁止输出。bank 不可用时 OE、IE 均为 0，内部输入钳为 `INPUT_CLAMP`。

**PC-DAT-003**：有效 IE=0 或 Pad 不支持输入时，`func_in_o=INPUT_CLAMP`；否则返回 `pad_in_i`。此钳位不防止物理浮空输入产生功耗，wrapper 仍须正确关闭输入缓冲。

**PC-DAT-004**：输入监测采用独立两级同步副本，只用于 CSR。有效 IE 或 bank 条件不成立时监测有效位为 0；条件恢复连续两个 PCLK 采样后有效。同步器不得放在正常功能路径上。

## 7. 配置更新与输出交接

**PC-UPD-001**：V1.0 不实现 shadow/commit。每次合法 ATTR 写在 APB 完成边沿一次更新完整合并后的属性字；跨 Pad 不保证原子性。

**PC-UPD-002**：ATTR 写入要求该 Pad 已经 `ISOLATE=1`，且不在休眠请求/接管周期，也未锁定。即使新旧值相同，也按写权限检查。硬件不通过瞬时 `func_oe=0` 推断外设已停止。

**PC-UPD-003**：安全操作顺序：停止外设 → 设置 ISOLATE=1 → 等待板级/工艺所需释放时间 → 修改属性及外部 Pinmux → 等待属性稳定 → 确认新源数据/OE 稳定 → ISOLATE=0 → 启动外设。

**PC-UPD-004**：隔离提供输出关闭窗口，不承诺开关时无任何模拟毛刺，也不保证修改 IE/BIAS 时输入电平不变化。对 SPI CLK、片选、复位引脚，必须由上层在协议空闲状态配置；需要保持恒定电平而非高阻的切换需专用协调逻辑。

**PC-UPD-005**：属性在 ISOLATE 期间更新后，软件须等待工艺要求的稳定时间才能清除 ISOLATE；连续两笔 APB 访问本身不构成所有工艺均满足稳定时间的保证。不能把“同一 PCLK 边沿更新”表述为物理无毛刺。实现须对 OE、属性到 Pad 的路径约束，检查译码瞬态、时钟偏斜和最小稳定时间。基线通过外部静止协议满足切换条件。

## 8. 休眠、保持与恢复

`HAS_SLEEP=1` 时支持以下逐 Pad 模式。睡眠期间 ATTR 保持不变，V1.0 不提供第二套睡眠电气属性。

| SLEEP_CFG.MODE | 编码 | 休眠所选 d/oe |
|---|---|---|
| HIZ | 0 | 0/0 |
| LOW | 1 | 0/1 |
| HIGH | 2 | 1/1 |
| KEEP | 3 | 捕获进入休眠前的功能 d/oe |
| FOLLOW | 4 | 继续使用功能 d/oe；仅允许 AON_SOURCE=1 |
| 保留 | 5～7 | 拒绝写入 |

所有模式仍受 OUT_ALLOW、OD、ISOLATE、force_hiz、bank 状态及 POR 约束。HIGH 在 OD=1 时表示释放而非主动拉高；软件文档必须明确。KEEP 保存数字控制值，不采样物理 Pad 电平，也不实现模拟 Keeper。

**PC-SLP-001**：全局握手状态为 IDLE、WAIT_QUIESCE、ACKED。仅在 IDLE 接受新的高电平请求；所有请求必须保持到 ACK，之后请求方拉低请求，Controller 才拉低 ACK 并返回 IDLE。

**PC-SLP-002**：IDLE 看到 sleep_req=1 进入 WAIT；WAIT 中等到 sources_quiesced=1 后，在一个 PCLK 边沿捕获所有 KEEP 的 d/oe，置全部 Pad 的 HELD=1，并置 ACK。即使 sources_quiesced 已为 1，也至少经过 WAIT 再 ACK。WAIT 中请求提前撤销则取消，保持状态不变、无 ACK。

**PC-SLP-003**：捕获的是施加 OD/OUT_ALLOW 之前的功能 d/oe。管理隔离等仍在捕获值之后起作用。休眠接管边沿之后，功能域才可按系统电源序列关闭。

**PC-SLP-004**：sources_quiesced 不能仅表示“CPU 执行了 WFI”。对 KEEP 通道，外部必须保证数据与 OE 在捕获边沿前后满足建立/保持条件，并在 ACK 返回前保持稳定。跨域必须采用稳定数据总线与同步握手，而非对数据/OE 独立打拍后假定一致。FOLLOW 通道不要求数据停止，但必须始终供电且有定义。

**PC-SLP-005**：sleep_req 拉低、时钟恢复或 CPU warm reset均不自动清除 HELD。软件重新初始化外设后，逐 Pad 写 RELEASE 显式交还功能控制。

**PC-SLP-006**：RELEASE 仅在请求/ACK 均为 0、FSM=IDLE 时允许。HELD=0 时合法 RELEASE 为无操作。清 HELD 不修改 ATTR、ISOLATE 和 LOCK。软件必须保证切换时外设数据/OE 已稳定；否则不承诺无毛刺。

**PC-SLP-007**：新一轮请求要求全部 HELD=0。若仍有 HELD，FSM 留在 IDLE、ACK=0，记录 SLEEP_CONFLICT；请求方必须撤销请求，再释放上轮状态后重试。不得覆盖尚未释放的 KEEP 快照。

**PC-SLP-008**：sleep_req=1、FSM 非 IDLE 或该 Pad HELD=1 时，禁止修改 ATTR/SLEEP_CFG/ISOLATE/LOCK。与接管同周期的这些 APB 写必须报错且无修改。ERR 清除及状态读仍可执行；RELEASE 遵循独立条件。

**PC-SLP-009**：HAS_SLEEP=0 时相关只读状态为 0；写 SLEEP_CFG/RELEASE 返回错误；sleep_req 必须静态绑 0，ACK=0，综合移除保持寄存器。输入 sources_quiesced 可绑 0。

## 9. 优先级与电源/测试边界

从高到低：

1. 工艺层电源安全钳位和合法物理隔离（wrapper/电源集成负责，任何 DFT 不得绕过必要的断电保护）。
2. Controller POR：OE=0。
3. bank 不可用：OE=IE=0。
4. force_hiz 或 ISOLATE：OE=0。
5. HELD 选择的休眠 d/oe。
6. 正常功能 d/oe。

OUT_ALLOW 与 OD 对第 5、6 层统一生效，不能由休眠常量驱动绕过。

**PC-PWR-001**：突然掉电不能依赖 PCLK 同步后才断开输出。原始 power-good、Pad power sequencing 及异步保护路径由经过工艺验证的 wrapper/电源方案处理；Controller 不宣称自身提供该物理保护。

**PC-PWR-002**：bank_ready 从 0 变 1 后按已有配置恢复，可能重新驱动。若系统不允许立即恢复，必须先保持 force_hiz 或 ISOLATE，再显式交接。不得把 bank 恢复隐含等同于软件已初始化。

**PC-TST-001**：V1.0 不包含软件可开启的 DFT override。测试插入逻辑由专门的可信 test/lifecycle 控制，在 wrapper 集成；须单独验证其与复位、物理隔离及锁的关系。正常功能验证时测试模式必须关闭。

## 10. APB 语义、保护与诊断

**PC-BUS-001**：正常工作零等待；PREADY=1。事务仅在 `PSEL && PENABLE && PREADY && preset_ni && por_ni` 的上升沿产生一次副作用；SETUP 不写。复位期间 PREADY=0、PSLVERR=0、PRDATA=0，复位打断事务不产生新副作用。

**PC-BUS-002**：只接受字对齐地址。未映射地址、无效 Pad 索引、RO 写、非法字段、权限不足、锁定、更新条件不满足均返回 PSLVERR=1；错误读数据=0；错误写除诊断记录外无副作用。不得等待软件或电源状态而拉长 APB 事务。

**PC-BUS-003**：RW 字段按 PSTRB 字节合并后对整个新值校验，任一项非法则整笔拒绝。保留位仅对选中的写字节检查非零。PSTRB=0 的写对已映射可写寄存器是无操作，跳过数据/权限/动态条件检查；地址错、RO 写仍报错。

**PC-SEC-001**：定义可信数据访问为 `PPROT[0]=1 && PPROT[1]=0 && PPROT[2]=0`。所有写要求 PPROT[2]=0；TRUSTED_ONLY=1 的 Pad 写还须满足可信访问。读不限制。APB 属性由可信上游提供，不包含 master ID 识别。

**PC-SEC-002**：每 Pad LOCK 为 W1S，置 1 后锁定 ATTR、SLEEP_CFG、ISOLATE；LOCK 写 0 无操作，重复写 1 无操作，但仍须满足访问和休眠条件。LOCK 本身只由 POR 清除。锁不会冻结外设数据/OE、阻止硬件休眠或强制高阻。

**PC-SEC-003**：RELEASE 是运行命令，不受 LOCK 阻止，但仍受 TRUSTED_ONLY 限定。软件应在完成配置、确认 ISOLATE 正确后再锁定，避免将关键 Pad 永久锁在高阻。锁定后的运行期高阻要求使用可信管理侧 force_hiz，而不能继续写 ISOLATE。V1.0 不提供软件解锁 key。

**PC-ERR-001**：全局错误原因：ACCESS=bit0、VALUE=bit1、LOCKED=bit2、STATE=bit3、SLEEP_CONFLICT=bit4。ACCESS 含地址/对齐/RO/访问属性错误。单笔错误优先级 ACCESS > LOCKED > STATE > VALUE。

**PC-ERR-002**：错误位 sticky、W1C，硬件置位优先于软件清除；HAS_IRQ=1 时 `irq=|(ERR_STATUS & ERR_ENABLE)`，否则 irq=0。ERR_ENABLE 和 ERR_STATUS 的非零写均仅允许可信访问。ERR_ENABLE 复位 0。

**PC-ERR-003**：FIRST_ERR_INFO 在 ERR_STATUS 旧值为 0 且有新事件时捕获；在清除周期同时有新事件且清除后旧原因全空时重新捕获新事件。若同周期 APB 和休眠错误，先记录 APB。其他情况下保留首错，不提供日志队列。ERR_STATUS 变为 0 时 FIRST_ERR_INFO 清零。

## 11. 寄存器映射

地址为 IP 基址相对偏移；全局未定义区域保留，访问报错。固定 Pad stride=0x40，参数裁剪不改变已存在 Pad 的偏移。

### 11.1 全局

| 偏移 | 名称 | 属性 | 位定义 |
|---|---|---|---|
| 0x000 | IP_ID | RO | 固定 0x50414443，ASCII PADC |
| 0x004 | VERSION | RO | 0x00010000，major[31:16]/minor[15:8]/patch[7:0] |
| 0x008 | INFO | RO | NUM_PADS[9:0]；NUM_BANKS[14:10]；HAS_SLEEP[16]；HAS_IRQ[17] |
| 0x00C | GLOBAL_STATUS | RO | REQ[0]；ACK[1]；ANY_HELD[2]；FSM[4:3]：IDLE=0/WAIT=1/ACKED=2 |
| 0x010 | ERR_STATUS | RW1C | 原因[4:0] |
| 0x014 | ERR_ENABLE | RW | 原因使能[4:0] |
| 0x018 | FIRST_ERR_INFO | RO | VALID[0]；REASON[3:1]：ACCESS=0/VALUE=1/LOCKED=2/STATE=3/SLEEP_CONFLICT=4；PAD_VALID[4]；PAD_ID[13:5]；WRITE[14] |
| 0x01C | BANK_STATUS | RO | bank_ready[NUM_BANKS-1:0]，其他位 0 |

FIRST_ERR_INFO 的 PAD_VALID 仅在地址能解析为存在的 Pad 时置位；全局、未映射和 SLEEP_CONFLICT 为 0。WRITE 对 APB 按事务方向，对休眠事件为 0。所有未定义位读 0。

### 11.2 每 Pad：`BASE(i)=0x1000+i*0x40`

| 偏移 | 名称 | 属性 | 说明 |
|---|---|---|---|
| +0x00 | CAP | RO | 能力位，定义见下 |
| +0x04 | DRIVE_VALID | RO | [15:0] 合法档位 |
| +0x08 | SLEW_VALID | RO | [3:0] 合法档位 |
| +0x0C | ATTR | RW | 第 6 节编码，复位 RESET_ATTR |
| +0x10 | ISOLATE | RW | bit0，复位 RESET_ISOLATE |
| +0x14 | SLEEP_CFG | RW | MODE[2:0]，复位 RESET_SLEEP_CFG |
| +0x18 | LOCK | RW1S | bit0，复位 RESET_LOCK |
| +0x1C | STATUS | RO | HELD[0]；ISOLATE[1]；LOCK[2]；BANK_READY[3]；FORCE_HIZ[4]；INPUT_VALID[5]；INPUT_SYNC[6] |
| +0x20 | RELEASE | WO | bit0 写 1 清 HELD；读 0；写 0 无操作 |
| +0x24 | RESET_ATTR | RO | 上电属性常量，非当前属性 |
| +0x28 | PAD_INFO | RO | BANK_ID[3:0]；TRUSTED_ONLY[4]；AON_SOURCE[5]；INPUT_CLAMP[6]；RESET_ISOLATE[7]；RESET_LOCK[8] |
| +0x2C～+0x3C | 保留 | — | 访问报错 |

CAP：HAS_INPUT[0]、HAS_OUTPUT[1]、IE_WRITABLE[2]、OUT_ALLOW_WRITABLE[3]、BIAS_WRITABLE[4]、SUP_PULLUP[5]、SUP_PULLDOWN[6]、SUP_KEEPER[7]、SCHMITT_WRITABLE[8]、OD_WRITABLE[9]、DRIVE_WRITABLE[10]、SLEW_WRITABLE[11]、HAS_SLEEP[12]。其他位为 0。

固定属性的写规则：合并后的固定字段等于 RESET_ATTR 对应字段时可通过该字段检查；改变则 VALUE 错误。输入/输出能力与默认字段必须一致。无输出 Pad 只允许 SLEEP_MODE=HIZ/FOLLOW（FOLLOW 仍要求 AON_SOURCE）；V1.0 的 CAP.HAS_SLEEP 对所有 Pad 等于实例参数 HAS_SLEEP，不提供逐 Pad 休眠硬件裁剪；需要持续工作的 Pad 通过 FOLLOW 表达。

RELEASE 仅接受 bit0，其他选中位写 1 报错；bit0=0 是无动作命令，但非零字节写仍检查访问属性。ISOLATE 不支持 SET/CLEAR 别名；多个软件调用者由驱动锁序列化。

## 12. 软件使用约定

初始化：读取版本/CAP/合法值 → 按板级需求停止源 → ISOLATE=1 → 写 ATTR → 写 SLEEP_CFG → 初始化外设及外部 Pinmux → 等待稳定 → ISOLATE=0 → 按需 LOCK=1。

休眠：停止非 AON 功能源并维持输出稳定 → 电源管理器保证 sources_quiesced → 提出 sleep_req → 等 ACK → 执行隔离/关电 → 完成请求撤销握手。

恢复：恢复供电/时钟 → 初始化外设、Pinmux 和有效输出 → 确认请求/ACK 为 0 → 对需要恢复的 Pad 写 RELEASE。不同 Pad 可分别释放；完成全部释放后才允许下一次全局休眠。

软件接口建议：`pad_get_caps`、`pad_set_attr`、`pad_set_isolate`、`pad_set_sleep_mode`、`pad_lock`、`pad_release`、`pad_get_status`。驱动不能把 ATTR 读回成功当作物理电气行为已测量成功。

## 13. YAML、生成及工艺适配交付

配置示例（示意，属性值须由真实工艺和板级要求确认）：

```yaml
schema_version: '1.0'
ip: pad_controller
num_banks: 1
features:
  sleep: true
  irq: true
pads:
  - id: 0
    name: GPIO0
    bank: 0
    type: digital_bidir
    trusted_only: true
    aon_source: false
    capabilities:
      input: true
      output: true
      bias: [none, pull_up, pull_down]
      schmitt: true
      digital_open_drain: true
      drive_codes: [0, 1, 2, 3]
      slew_codes: [0, 1]
    reset:
      isolate: true
      ie: true
      out_allow: true
      bias: none
      schmitt: false
      od: false
      drive: 0
      slew: 0
      lock: false
    sleep_mode: hiz
    tech_binding: gpio_cell_type_a
```

**PC-GEN-001**：Python 将 YAML 校验并规范化为明确的数据模型，生成 SV 参数/package、实例连接、C 头文件、Pad 能力/复位文档与配置指纹；不要求动态重写通用控制 RTL。

**PC-GEN-002**：Pad ID、属性编码、寄存器定义必须单一来源，软件与 RTL 不得分别维护。固定 stride 支持无需生成器直接参数化实例化；FuseSoC 的 generator 仅作为可选构建入口。

**PC-TECH-001**：工艺映射表必须列出 Cell 名称、IN/OUT/OE/IE 极性、BIAS 编码、DRIVE/SLEW 编码、固定控制端、电源域、power-good 连接及支持范围；遗漏项必须构建失败。

**PC-TECH-002**：通用 OD 已由 Controller 转为“只驱动 0 或释放”；wrapper 不得再次施加不同语义的 OD/inversion。V1.0 不含输入/输出反相配置。

**PC-TECH-003**：无配置能力的 FPGA 目标须按实际静态约束生成 CAP 与固定属性，不能让软件读回动态配置成功但物理实现不生效。

## 14. PPA 与实现要求

**PC-PPA-001**：功能路径不增加流水级；OD/OE/隔离选择尽可能合并逻辑，避免串联多层宽 mux。输入路径只含必要钳位。

**PC-PPA-002**：逐 Pad 不存在的属性寄存器、无休眠时的保持寄存器必须综合裁剪。只读能力采用常量，不实现可写存储。

**PC-PPA-003**：寄存器写采用局部 enable；保持值只在接管时捕获。全局解码可按地址高位分组，避免 512 Pad 全扇出比较成为 PCLK 关键路径。

**PC-PPA-004**：功能输入监测同步器仅对支持输入的 Pad 实例化；输出数据/OE 不为读回额外插入功能寄存器。

**PC-PPA-005**：报告 32、128、512 Pad 的寄存器数、组合面积、PCLK 关键路径、功能 out/OE/in 的增量延迟。数值门限由选定库和目标频率冻结；不得在无工艺条件下承诺 MHz 或面积。

## 15. 验证要求与验收矩阵

| 验证项 | 必须覆盖的场景 | 对应需求 |
|---|---|---|
| APB | 连续读写、PSTRB 四字节组合、零 strobe、非对齐、RO/空洞、事务复位 | PC-BUS-* |
| 属性 | 每合法值、每固定字段非法修改、BIAS 互斥、非法档位、整体拒绝 | PC-ATR-* |
| 数据路径 | d/oe/OUT_ALLOW/OD 全组合，输入钳位，路径无周期延迟 | PC-DAT-* |
| 隔离更新 | 未隔离写拒绝；合法隔离序列；不同 Pad 无串扰 | PC-UPD-* |
| 写保护 | 可信与非可信访问；W1S；warm/APB reset 不解锁；POR 解锁 | PC-SEC-*、PC-CLK-* |
| 休眠 | 5 种模式，源未稳定不 ACK，提前撤销，接管后关闭源 | PC-SLP-* |
| 恢复 | 请求撤销不释放；锁定后 RELEASE；逐 Pad 释放；新请求冲突 | PC-SLP-* |
| 优先级 | 休眠与配置同周期；管理高阻叠加 OD/LOW/HIGH/KEEP | PC-PWR-*、PC-SLP-* |
| 错误 | 分类优先级、同周期 W1C+置位、首错保持/重捕获、IRQ 屏蔽 | PC-ERR-* |
| 能力裁剪 | 输入专用/输出专用/双向、非 AON FOLLOW 拒绝、FPGA 固定属性 | PC-PAR-*、PC-TECH-* |
| 物理模型 | 开漏外部上拉、双驱动争用为 X、输入关闭、弱拉行为 | PC-DAT-* |
| 集成 | 真实 Pad wrapper 映射、CDC/RDC、AON/关电隔离、复位瞬态 | PC-TECH-*、PC-CLK-* |

必须的断言：

- 非法 APB 写不改变受控配置和锁；仅允许错误诊断副作用。
- LOCK 置位后直到 POR，ATTR/SLEEP_CFG/ISOLATE 不被软件改变。
- POR、bank 不可用、ISOLATE 或 force_hiz 时 OE 必须为 0。
- 正常测试模式关闭时，OD=1 且 OE=1 蕴含 OUT=0。
- 无 HELD/无覆盖、OD=0 时，输出数据等于功能源，无额外时钟周期。
- HELD 且 KEEP 时，功能源变化不改变被选中的保存 d/oe。
- 请求撤销不清除 HELD；RELEASE 不修改锁及属性。
- WAIT 未收到 sources_quiesced 时不产生 ACK。
- 新事件不会被同周期 W1C 丢失。

仿真弱拉/争用不能替代 IBIS/SPICE 或工艺电气签核。输入两级同步器 MTBF、输出切换毛刺、电源顺序需要相应 CDC、STA、门级和物理集成证据。

验收必须完成需求→测试/断言追踪；功能覆盖中所有有效枚举和上述关键交叉闭合；不可达项有说明；Lint/CDC/RDC 无未处置问题；32/128/512 配置可综合；至少一个真实或公开工艺 Pad wrapper 完成集成验证，纯 generic model 通过只能标记为通用 RTL 验证完成。

## 16. 实施顺序及交付物

1. 冻结 ATTR/CAP、参数结构与 APB 地址表，实现属性、隔离、严格错误检查和锁。
2. 完成开漏、输入钳位、监测副本及 generic Pad model，跑通单 Pad 与异构多 Pad。
3. 实现休眠握手、KEEP、显式 RELEASE 和所有竞争行为。
4. 完成 YAML 检查、参数/软件/文档生成与 FuseSoC 构建。
5. 绑定具体 Pad 库、复位/供电方案，完成 PPA 和集成验证。

交付：需求规格、架构与详细设计、寄存器单一数据源、可综合 RTL、generic model、UVM 环境/断言/覆盖、软件头文件和示例、YAML schema 与校验工具、FuseSoC core、工艺 wrapper 及映射表、Lint/CDC/RDC/综合报告、集成说明。

V1.0 的工程重点是“属性配置可预测，输出交接可控制，休眠保持不会被复位或软件竞争破坏”。后续若扩展 Pinmux 或唤醒检测，作为上层引脚管理子系统组合，不改变本 IP 已冻结的逐 Pad 寄存器布局。
