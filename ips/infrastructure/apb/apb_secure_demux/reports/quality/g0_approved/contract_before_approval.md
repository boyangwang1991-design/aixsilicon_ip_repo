# AIXSILICON 安全 APB DEMUX 需求规格说明书

| 元数据 | 内容 |
|---|---|
| Document ID | aixsilicon:ip:apb_secure_demux:req |
| IP / RTL Top | apb_secure_demux |
| VLNV | aixsilicon:ip:apb_secure_demux:1.0.0 |
| 文档版本 | 1.0.0-draft |
| 状态 | 实现输入草案，待项目评审冻结；不表示 RTL 已实现或通过验证 |
| 日期 | 2026-09-11 |
| 实现类型 | Parameterized SystemVerilog IP |
| 接口 | APB4，32 bit 数据，可信 MASTERID 扩展 |
| 配置描述 | YAML；导出软件头文件、寄存器模型和地址检查结果 |

## 1. 目的、范围与约定

本 IP 将一个 APB 输入按静态地址映射分发到 N 个 APB 输出，按目标端口、可信 MASTERID、安全属性、特权属性和读写方向实施访问控制。集成本地权限配置寄存器、配置锁、原子提交、违规日志、中断、安全告警及受控 DFX。

“必须/不得”为验收要求；“建议”为非强制架构提示。带参数开关的功能必须实现开启和关闭两种配置。本文寄存器偏移、权限编码、错误编码、时序和复位行为是本 IP 的产品契约，不声称与某一商用 PPC 寄存器兼容。

APB 信号使用 PPROT；AXI 的 AWPROT/ARPROT 由上游桥接器转换并随请求传递。本 IP 没有 AXI 接口，也不接收 AWPROT/ARPROT 引脚。

### 1.1 功能范围

| 功能 | V1.0 范围 |
|---|---|
| DEMUX | 1→N，N=1～32，静态、不重叠的地址区 |
| 主体权限 | 每端口最多 64 个主体；MASTERID 直接索引 |
| 属性权限 | 四种 Secure/Non-secure 与特权/非特权组合，读写独立 |
| 配置 | 本地 CSR、shadow/active、按端口掩码原子提交 |
| 锁 | 每端口锁、全局配置锁，仅模块可信复位解除 |
| 错误 | 本地拒绝、下游错误透传、日志与中断 |
| DFX | 统计、硬件观测、受控合成事件、强制拒绝及完整性故障测试 |
| 完整性 | 参数化策略/锁完整性保护 |
| 时序 | 直接转发与寄存转发两种 elaboration 模式 |
| 裁剪 | 事件 FIFO、DFX、完整性保护、输出隔离可裁剪 |

不包含：多输入仲裁、CDC、运行时地址重映射、寄存器 bit 字段权限、DMA、协议转换、数据加密、网络报文过滤、APB 事务取消、软件可开启的无条件安全旁路。APB5 专属信号不属于 V1.0 接口。

### 1.2 系统信任边界

- REQ-SYS-001：MASTERID、PPROT 必须由可信系统路径产生；本 IP 检查属性而不认证其真实性。
- REQ-SYS-002：上游 X2P 必须将读请求 ARPROT、写请求 AWPROT 以及主体身份绑定到对应 APB 事务，缓冲、仲裁和 CDC 后不得错配。
- REQ-SYS-003：AXI AxID 不得在未经可信身份映射的情况下直接充当 MASTERID。
- REQ-SYS-004：所有抵达被保护外设的访问路径和别名入口必须有等效保护；本 IP 无法阻止绕过自身的另一条访问路径。
- REQ-SYS-005：普通外设复位不得清除本 IP 权限或锁。模块复位和 DFX 授权必须由可信系统控制。
- REQ-SYS-006：本 IP 不承诺抵抗任意物理故障注入、恶意时钟毛刺或篡改后的 scan 路径；完整性保护的覆盖边界见第 12 节。

## 2. 参数与合法配置

| 参数 | 类型/范围 | 默认 | 含义 |
|---|---|---:|---|
| NUM_PORTS | int，1～32 | 8 | 输出端口数 |
| ADDR_WIDTH | int，16～32 | 32 | 输入和输出地址宽度 |
| DATA_WIDTH | int，必须等于 32 | 32 | APB 数据宽度 |
| MASTER_ID_WIDTH | int，1～16 | 4 | 输入身份位宽 |
| NUM_MASTERS | int，1～64，且不超过 2^MASTER_ID_WIDTH | 16 | 有效主体数量 |
| PORT_BASE[i] | ADDR_WIDTH bit | 集成必填 | 端口起始地址 |
| PORT_SIZE[i] | ADDR_WIDTH+1 bit | 集成必填 | 字节容量，正数、4 字节整数倍 |
| CSR_BASE | ADDR_WIDTH bit | 集成必填 | 本地 CSR 起始地址，4 字节对齐 |
| MGMT_MASTER_MASK | NUM_MASTERS bit | 集成必填，非零 | 固定管理主体集合 |
| RESET_PORT_CFG[i] | 2 bit | 0 | 端口复位使能与指令许可 |
| RESET_PERM[i][m] | 8 bit | 0 | 复位权限表 |
| REGISTER_MODE | bit | 0 | 0 直接；1 寄存转发 |
| OUTPUT_ISOLATION_EN | bit | 1 | 未选端口负载信号置零 |
| EVENT_FIFO_DEPTH | int，0～32 | 8 | 0 表示不实现 FIFO |
| POLICY_PARITY_EN | bit | 1 | 策略完整性和锁编码保护 |
| DFX_EN | bit | 1 | DFX 统计、观测和注入 |
| PUBLIC_ID_EN | bit | 1 | 基本信息寄存器允许普通数据读取 |

- REQ-PAR-001：CSR_SIZE 固定按 `0x1000 + NUM_PORTS × 0x400` 字节推导；所有区间使用扩展位宽计算结束地址，不允许截断或回绕。
- REQ-PAR-002：任一 PORT 区间、本地 CSR 区间越出地址宽度，存在重叠、大小为零或未按 4 字节对齐，必须在 elaboration/配置检查阶段失败。
- REQ-PAR-003：端口支持任意符合上述约束的大小，无须是 2 的幂。结束地址为 BASE+SIZE-1。
- REQ-PAR-004：1 个端口、1 个主体、FIFO 深度 0/1、非 2 的幂规模必须可编译且行为正确；内部索引宽度不得出现零宽向量。
- REQ-PAR-005：MASTERID 必须先检查完整输入值是否小于 NUM_MASTERS，再索引权限表；禁止截断高位导致身份混叠。
- REQ-PAR-006：CAPABILITY 和地址只读镜像必须反映实际 elaboration 参数。

## 3. 外部接口

所有功能接口均属于 pclk 域。异步授权或告警接收的同步由集成层完成。

| 信号 | 方向 | 位宽 | 定义 |
|---|---|---:|---|
| pclk | 输入 | 1 | 功能时钟 |
| preset_ni | 输入 | 1 | 低有效可信模块复位，异步置位复位、同步释放 |
| s_paddr | 输入 | ADDR_WIDTH | 上游字节地址 |
| s_psel / s_penable / s_pwrite | 输入 | 各 1 | APB 控制 |
| s_pwdata / s_pstrb / s_pprot | 输入 | 32/4/3 | APB 写数据、字节选通与保护属性 |
| s_prdata / s_pready / s_pslverr | 输出 | 32/1/1 | 上游响应 |
| master_id_i / master_id_valid_i | 输入 | MASTER_ID_WIDTH/1 | 可信主体身份 |
| m_paddr[i] | 输出 | ADDR_WIDTH | 各输出原始地址 |
| m_psel[i] / m_penable[i] / m_pwrite[i] | 输出 | 各 1 | 各输出控制 |
| m_pwdata[i] / m_pstrb[i] / m_pprot[i] | 输出 | 32/4/3 | 各输出请求 |
| m_prdata[i] / m_pready[i] / m_pslverr[i] | 输入 | 32/1/1 | 各下游响应 |
| m_master_id_o[i] / m_master_id_valid_o[i] | 输出 | MASTER_ID_WIDTH/1 | 随选中事务透传身份，支持级联保护 |
| irq_o | 输出 | 1 | 普通中断，电平保持 |
| security_alert_o | 输出 | 1 | 安全事件告警，电平保持 |
| dfx_authorized_i | 输入 | 1 | 可信 DFX 授权，高有效 |
| busy_o / active_port_valid_o | 输出 | 各 1 | 受控 DFX 观测 |
| active_port_o | 输出 | 5 | 当前外设目标编号 |
| wait_threshold_o | 输出 | 1 | 等待超阈值粘滞观测 |

- REQ-IF-001：请求和 MASTERID 在 SETUP 到事务完成期间必须稳定；该项作为输入协议假设并通过断言检查。
- REQ-IF-002：m_master_id_valid_o 仅在对应 m_psel 为 1 时有效；未选端口该信号固定为 0。
- REQ-IF-003：APB3 下游可以通过外部适配连接；本 IP 的输入不能无说明地丢弃 PPROT 和 MASTERID。
- REQ-IF-004：DFX_EN=0 或 dfx_authorized_i=0 时，DFX 观测输出全部为 0。irq_o/security_alert_o 不受 DFX 授权控制。

## 4. 地址分发与权限

### 4.1 地址分发

- REQ-DEC-001：SETUP 阶段分别计算本地 CSR 命中和各端口命中；必须使用全部有效地址位。
- REQ-DEC-002：总命中数为 0，产生 ADDR_MISS；大于 1，产生 MULTI_HIT；均不得访问 CSR 或下游。
- REQ-DEC-003：本地 CSR 与外设同时命中时不得采用 CSR 优先级放行，必须按多重命中拒绝。
- REQ-DEC-004：端口关闭仍属于地址命中，错误原因为 PORT_DISABLED。
- REQ-DEC-005：下游透传原始地址，不减去 BASE；不存在隐式地址别名或地址转换。
- REQ-DEC-006：下游数据访问的低地址位与 PSTRB 由目标外设解释，本 IP 不增加通用未对齐拒绝规则。本地 CSR 必须按 4 字节对齐访问。

### 4.2 属性编码

| PPROT 位 | 0 | 1 |
|---|---|---|
| [0] | 非特权 | 特权 |
| [1] | Secure | Non-secure |
| [2] | 数据访问 | 指令访问 |

令 `c = {PPROT[1], PPROT[0]}`，属性索引固定如下：

| c | 类别 | 读允许位 | 写允许位 |
|---:|---|---:|---:|
| 0 | Secure 非特权 | PERM[0] | PERM[4] |
| 1 | Secure 特权 | PERM[1] | PERM[5] |
| 2 | Non-secure 非特权 | PERM[2] | PERM[6] |
| 3 | Non-secure 特权 | PERM[3] | PERM[7] |

- REQ-ACL-001：每个端口、每个主体维护独立 8 bit PERM。1 允许，0 拒绝；读写与四种属性均可独立配置。
- REQ-ACL-002：Secure、特权和管理主体均无隐含外设访问豁免。管理身份访问外设时仍查端口权限表。
- REQ-ACL-003：PORT_CFG[0]=ENABLE；[1]=INSTR_ALLOW。其余位保留为零。
- REQ-ACL-004：数据访问检查相应读写位。指令读还必须 INSTR_ALLOW=1；指令写一律拒绝。
- REQ-ACL-005：身份无效或越界必须拒绝，不映射为主体 0；PSTRB=0 仍执行正常写权限检查。
- REQ-ACL-006：判权结果与目标在事务边界锁定，等待期间不得重新按新策略改变当前事务。
- REQ-ACL-007：默认 RESET_PORT_CFG 和 RESET_PERM 全零；硬件启动权限只能通过显式参数定义，active 与 shadow 复位内容一致。

完整允许条件：

```text
唯一外设命中 && 非全局完整性故障 && ENABLE
&& master_id_valid && master_id < NUM_MASTERS
&& PERM[port][master][PPROT[1:0] + (PWRITE ? 4 : 0)]
&& (!PPROT[2] || (!PWRITE && INSTR_ALLOW))
```

## 5. APB 时序与错误响应

### 5.1 通用要求

- REQ-APB-001：非法访问从 SETUP 开始所有下游 PSEL 必须为 0，不得引发读清除、FIFO 弹出、写启动或其他副作用。
- REQ-APB-002：所有本地拒绝在第一个上游 ACCESS 周期响应 PREADY=1、PSLVERR=1、PRDATA=0；包括 REGISTER_MODE=1。
- REQ-APB-003：成功 CSR 访问在第一个 ACCESS 周期 PREADY=1、PSLVERR=0；CSR 副作用仅在完成边沿发生一次。
- REQ-APB-004：正常外设访问透传下游完成响应；下游 PSLVERR=1 时上游仍返回该错误，下游 PRDATA 原样透传，不按权限拒绝处理。
- REQ-APB-005：无有效 ACCESS 时上游 PSLVERR=0；PRDATA=0，PREADY=1。复位期间按第 13 节强制值。
- REQ-APB-006：所有周期 m_psel 满足 one-hot-or-zero。未选端口 m_penable=0，选中端口遵守完整 SETUP/ACCESS 时序。
- REQ-APB-007：OUTPUT_ISOLATION_EN=1 时，未选端口 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 均置零；=0 时可以广播当前请求，但 PSEL/PENABLE/身份有效不得广播。
- REQ-APB-008：支持 PSEL 连续保持的背靠背事务、读写交替、切换目标、CSR 与外设交替。每个新 SETUP 必须重新译码和判权。
- REQ-APB-009：不存在 posted write 或提前成功响应；外设事务完成前不得释放上游。
- REQ-APB-010：不支持主动取消已发出的下游事务。等待告警、DFX 授权撤销或新完整性故障均不得中途撤销 PSEL。

### 5.2 直接模式 REGISTER_MODE=0

上游 SETUP 内组合译码和判权，通过后同周期向下游输出 SETUP。SETUP 结束边沿保存目标、判权与事件所需属性。上游 ACCESS 与下游 ACCESS 对应，下游零等待时不增加额外周期。

| 周期 | 上游 | 下游合法访问 | 下游非法访问 |
|---|---|---|---|
| S | SETUP | SETUP | 不选中 |
| A0 | ACCESS | ACCESS，可完成 | 不选中，上游本地错误完成 |
| A1… | 等待 ACCESS | 等待/完成 | 不适用 |

- REQ-TIM-001：SETUP 的组合权限路径须纳入 STA，包括地址/身份/PPROT 到下游 PSEL 的路径；不承诺物理意义的无毛刺安全隔离。

### 5.3 寄存模式 REGISTER_MODE=1

上游 SETUP 结束边沿锁存全部请求和权限结果；合法外设访问在第一个上游 ACCESS 周期生成下游 SETUP，该周期上游 PREADY=0；下一周期进入下游 ACCESS。

| 周期 | 上游 | 下游合法访问 |
|---|---|---|
| S | SETUP | 不选中，周期末锁存 |
| A0 | ACCESS，PREADY=0 | SETUP |
| A1 | ACCESS | ACCESS，可完成 |
| A2… | 等待 ACCESS | 等待/完成 |

- REQ-TIM-002：零等待下游比直接模式多一个上游等待周期；该模式寄存请求路径，不保证切断下游响应到上游响应的组合路径。
- REQ-TIM-003：本地 CSR 和权限拒绝不走下游转发状态机，仍在第一个 ACCESS 周期完成。
- REQ-TIM-004：寄存模式必须锁存 PADDR/PWDATA/PSTRB/PWRITE/PPROT/MASTERID 和版本，禁止仅锁存地址却使用下一笔数据。

## 6. 本地 CSR 管理权限与通用语义

管理授权固定为：身份有效且范围合法、MGMT_MASTER_MASK 命中、PPROT=3'b001，即 Secure 特权数据访问。

- REQ-CSR-001：所有配置、日志、中断、DFX 寄存器的读写必须通过管理授权。PUBLIC_ID_EN=1 时仅 0x000～0x00C 的数据读取例外，但仍要求身份有效且在范围内。
- REQ-CSR-002：管理权限不可通过本 IP CSR 修改；管理授权不等同于外设访问授权。
- REQ-CSR-003：本地 CSR 仅支持 32 bit 对齐访问。所有写要求 PSTRB=4'b1111，包括 W1C、命令和锁；否则返回 CSR_STROBE 错误，无写副作用。
- REQ-CSR-004：写 RO、读 WO、访问未实现地址、访问已裁剪功能寄存器均返回错误。已实现寄存器保留位 RAZ/WI。
- REQ-CSR-005：未授权读返回零，未授权写不改变目标状态；允许产生一次违规日志/计数/中断，这是规定的审计副作用。
- REQ-CSR-006：RW 不受影响位保留当前值；W1C 写 1 清除、写 0 不变；W1S 只允许置位。命令仅在完成边沿触发。
- REQ-CSR-007：所有未另行指定的寄存器、状态、计数器、锁和中断复位为零。
- REQ-CSR-008：参数化表采用固定槽位地址，超出 NUM_PORTS/NUM_MASTERS 的槽位为未实现地址，不允许索引回绕。

## 7. 完整寄存器映射

以下为相对 CSR_BASE 的字节偏移。RO=只读，RW=读写，WO=只写，W1C=写一清，W1S=写一置位。

### 7.1 全局寄存器

| 偏移 | 名称 | 属性 | 字段与语义 |
|---:|---|---|---|
| 0x000 | IP_ID | RO | 0x41534458，本 IP 标识，不表示外部标准 ID |
| 0x004 | VERSION | RO | 0x00010000，major[23:16]/minor[15:8]/patch[7:0] |
| 0x008 | CAP0 | RO | [5:0] NUM_PORTS；[14:8] NUM_MASTERS；[21:16] ADDR_WIDTH；[28:24] MASTER_ID_WIDTH |
| 0x00C | CAP1 | RO | [0] REGISTER_MODE；[1] ISOLATION；[2] PARITY；[3] DFX；[4] PUBLIC_ID；[13:8] FIFO_DEPTH |
| 0x010 | STATUS | RO | [0] INTEGRITY_FATAL；[1] GLOBAL_LOCK；[2] FIRST_VALID；[3] LAST_VALID |
| 0x014 | POLICY_VERSION | RO | 32 bit，成功提交加一，模 2^32 |
| 0x018 | GLOBAL_LOCK | W1S | [0] 全局权限配置锁；可读当前值 |
| 0x01C | COMMIT_MASK | WO | bit i 选择端口；非空且无越界位；一次提交全部选中端口 |
| 0x020 | COMMIT_STATUS | RO | [0] LAST_OK；[1] LAST_FAIL；[7:4] FAIL_REASON；[12:8] FAIL_PORT；[13] FAIL_PORT_VALID |
| 0x024 | SHADOW_RELOAD | WO | 端口掩码；将所选 active 全部复制到 shadow，不增加版本 |
| 0x028 | MGMT_MASK_LO | RO | 管理主体掩码 [31:0]，不足补零 |
| 0x02C | MGMT_MASK_HI | RO | 管理主体掩码 [63:32]，不足补零 |
| 0x030 | INTR_RAW | W1C | 第 10 节 bit 编码，底层持续故障会重新置位 |
| 0x034 | INTR_ENABLE | RW | 普通中断使能，复位 0 |
| 0x038 | INTR_MASKED | RO | INTR_RAW & INTR_ENABLE |
| 0x03C | ALERT_ENABLE | RW | 安全告警使能，复位 bits 0/1/3/4/7=1，即 0x9B |
| 0x040 | INTR_TEST | WO | 仅 bit 8 有效；须 DFX 授权；仅测试通知，不伪造真实原因 |
| 0x044 | FAULT_CLEAR | WO | bit0 首错；bit1 最近错；bit2 FIFO 清空；bit3 OVF 清除；不清 INTR_RAW/统计 |
| 0x048 | FIFO_STATUS | RO | [5:0] COUNT；[8] EMPTY；[9] FULL；[10] OVF；FIFO=0 时 COUNT=0/EMPTY=1/FULL=0 |
| 0x04C | FIFO_POP | WO | bit0=1 弹出头记录；空 FIFO 或未实现时返回命令错误 |
| 0x050 | ACCESS_DENY_COUNT | RO | 外设拒绝次数，32 bit 饱和 |
| 0x054 | CFG_DENY_COUNT | RO | 本地 CSR 失败次数，32 bit 饱和 |
| 0x058 | EVENT_LOST_COUNT | RO | 因 FIFO 满或同周期仲裁丢失的事件数，32 bit 饱和 |
| 0x05C | DOWNSTREAM_ERR_COUNT | RO | 下游错误次数，32 bit 饱和 |
| 0x060 | COUNTER_CLEAR | WO | bit0～3 对应上述四个计数清除 |
| 0x064 | INTEGRITY_STATUS | RO | [0] FATAL；[1] LOCATION_VALID；[6:2] PORT；[12:7] MASTER；[15:13] LOCATION_TYPE |
| 0x068～0x09C | 保留 | — | 未实现，访问错误 |
| 0x0A0～0x0BC | FIRST_FAULT[0:7] | RO | 首错记录，无有效记录时读零 |
| 0x0C0～0x0DC | LAST_FAULT[0:7] | RO | 最近记录，无有效记录时读零 |
| 0x0E0～0x0FC | FIFO_HEAD[0:7] | RO | 队头记录，空时读零，读取无 POP 副作用 |

COMMIT_STATUS.FAIL_REASON：0=无；1=掩码非法；2=全局锁；3=端口锁；4=完整性故障。多个条件同时出现按此列表中的检查顺序（掩码、全局锁、端口锁、完整性）报告；多个端口取最低编号。未通过管理授权/基本 CSR 检查的访问不改变 COMMIT_STATUS。

### 7.2 DFX 寄存器（DFX_EN=1）

| 偏移 | 名称 | 属性 | 字段与语义 |
|---:|---|---|---|
| 0x100 | DFX_STATUS | RO | [0] 授权输入；[1] 拒绝注入已武装；[2] 完整性注入已武装；[3] WAIT_HIT |
| 0x104 | WAIT_THRESHOLD | RW | 阈值，0 禁用；统计单位为下游 ACCESS 等待周期 |
| 0x108 | DFX_CLEAR | WO | bit0 清 WAIT_HIT；bit1 解除全部注入武装 |
| 0x10C | INJECT_TARGET | RW | [4:0] PORT；[13:8] MASTER；必须在参数范围内 |
| 0x110 | INJECT_CMD | WO | bit0 合成日志事件；bit1 武装强制拒绝；bit2 武装完整性故障；必须恰有一个有效 bit |

DFX 全部读写要求管理授权且 dfx_authorized_i=1；授权不足返回 CFG_UNAUTHORIZED。0x114～0xFFF 为未实现扩展空间。

### 7.3 每端口寄存器

端口 p 的基址 `PB = 0x1000 + p × 0x400`。

| PB 内偏移 | 名称 | 属性 | 定义 |
|---:|---|---|---|
| 0x000 | MAP_BASE | RO | 起始地址，零扩展到 32 bit |
| 0x004 | MAP_LIMIT | RO | 结束地址，包含，零扩展 |
| 0x008 | PORT_LOCK | W1S | bit0，锁定该端口 shadow/active 配置，可读 |
| 0x00C | CFG_SHADOW | RW | bit0 ENABLE，bit1 INSTR_ALLOW |
| 0x010 | CFG_ACTIVE | RO | 当前生效配置 |
| 0x014 | SUCCESS_COUNT | RO | 成功外设完成次数，DFX_EN=1 才实现 |
| 0x018 | DENY_COUNT | RO | 已命中该端口的拒绝次数，DFX_EN=1 |
| 0x01C | SLVERR_COUNT | RO | 下游错误次数，DFX_EN=1 |
| 0x020 | WAIT_TOTAL | RO | 下游 ACCESS 且 !PREADY 周期累计，饱和，DFX_EN=1 |
| 0x024 | WAIT_MAX | RO | 单笔事务最大等待周期，完成时更新，DFX_EN=1 |
| 0x028 | DFX_COUNTER_CLEAR | WO | bits0～4 分别清上述五个统计，DFX_EN=1 |
| 0x100+4m | PERM_SHADOW[m] | RW | [7:0] 权限；m=0～NUM_MASTERS-1 |
| 0x200+4m | PERM_ACTIVE[m] | RO | 当前权限；m=0～NUM_MASTERS-1 |

每主体占一个 32 bit CSR，只有低 8 bit 存储权限；高 24 bit RAZ/WI，不要求真的实现 32 bit 权限存储。未列出的端口偏移均为未实现。端口 DFX 统计同样要求硬件 DFX 授权。

## 8. 配置提交、锁和版本

- REQ-UPD-001：shadow 可单独读写；正常访问仅使用 active；禁止 shadow 更新直接作用于下游判权。
- REQ-UPD-002：COMMIT_MASK 指定端口的 CFG_SHADOW 和全部 PERM_SHADOW 在同一完成边沿复制至 active，任何失败全部不提交。
- REQ-UPD-003：非零合法掩码、无相关锁且无完整性故障时提交成功；即使值未变化也增加 POLICY_VERSION。
- REQ-UPD-004：提交为本地单周期 ACCESS，不等待“上游 PSEL 降低”；持续背靠背访问也必须正常提交。
- REQ-UPD-005：由于仅一个 APB 输入且无后台请求队列，处理 COMMIT 时不得有尚未完成的下游事务。实现若引入队列必须维持此串行契约。
- REQ-UPD-006：COMMIT 完成边沿之后的 SETUP 使用新版本；此前外设事务已完成，不发生跨版本事务。上游桥内部尚未送入本 IP 的排队请求适用到达本 IP 时的策略。
- REQ-UPD-007：锁对 shadow 写、active 提交和 SHADOW_RELOAD 均生效；写锁只设锁，不隐式提交。软件必须先提交、读回，再设锁。
- REQ-UPD-008：GLOBAL_LOCK=1 后不得修改任何权限/端口配置或执行 reload/commit；PORT_LOCK 的额外置位仍允许，属于收紧保护。
- REQ-UPD-009：锁写 0 无效果，读回保留；只有 preset_ni 解除锁。无软件解锁口令或软复位绕过。
- REQ-UPD-010：策略锁不阻止日志读取清除、中断处理和授权 DFX 诊断；完整性故障锁存只能可信模块复位恢复。
- REQ-UPD-011：版本仅为诊断关联号，32 bit 自然回绕；不用于授权、不作为跨复位唯一编号。

## 9. 错误分类与日志

### 9.1 错误编码

| 码值 | 原因 | 含义 |
|---:|---|---|
| 0x01 | ADDR_MISS | 无地址命中 |
| 0x02 | MULTI_HIT | 多重地址命中 |
| 0x03 | ID_INVALID | 身份无效或范围错误 |
| 0x04 | INTEGRITY_BLOCK | 完整性故障下拒绝外设访问 |
| 0x05 | PORT_DISABLED | 端口关闭 |
| 0x06 | INSTR_DENIED | 指令读未授权或指令写 |
| 0x07 | READ_DENIED | 读权限位为零 |
| 0x08 | WRITE_DENIED | 写权限位为零 |
| 0x10 | CFG_UNAUTHORIZED | CSR 管理/DFX 授权失败 |
| 0x11 | CSR_ALIGN | CSR 地址未对齐 |
| 0x12 | CSR_STROBE | CSR 写选通非法 |
| 0x13 | CSR_UNIMPLEMENTED | 未实现/裁剪寄存器 |
| 0x14 | CSR_ACCESS_TYPE | RO 写、WO 读 |
| 0x15 | CFG_LOCKED | 锁定配置修改 |
| 0x16 | CMD_INVALID | 空/越界掩码、非法命令或目标等 |
| 0x17 | CFG_INTEGRITY | 完整性故障导致配置操作拒绝 |
| 0x20 | DOWNSTREAM_ERROR | 目标外设 PSLVERR |
| 0x30 | INTEGRITY_DETECTED | 新完整性故障 |
| 0x31 | WAIT_EXCEEDED | 单笔下游等待超阈值 |
| 0x40 | DFX_SYNTHETIC | 合成测试事件 |
| 0x41 | DFX_FORCED_DENY | 测试强制拒绝 |

外设请求主原因优先级：MULTI_HIT、ADDR_MISS、ID_INVALID、INTEGRITY_BLOCK、PORT_DISABLED、INSTR_DENIED、READ/WRITE_DENIED、DFX_FORCED_DENY。DFX 拒绝只消耗本来会允许的匹配请求。

CSR 主原因优先级：管理/公开读授权、地址对齐、写选通、寄存器存在性、读写类型、锁、命令参数、配置完整性。地址总译码错误在上述 CSR 检查之前处理。不得因未授权访问而泄露某个敏感寄存器是否存在。

### 9.2 记录格式

每条记录固定 8×32 bit。无效字段清零，以 valid bit 区分有效值 0。

| 字 | 编码 |
|---:|---|
| 0 | 原始地址零扩展；无关联事务时为 0 |
| 1 | [15:0] MASTERID 零扩展；[16] 原始 master_id_valid；[19:17] PPROT；[20] PWRITE；[21] REQUEST_VALID；[22] IS_CSR；[23] TEST |
| 2 | [7:0] REASON；[12:8] PORT；[13] PORT_VALID；[21:16] 事件来源位图 |
| 3 | POLICY_VERSION；事务事件用 SETUP 判权版本 |
| 4 | 时间戳低 32 bit |
| 5 | 时间戳高 32 bit |
| 6 | 32 bit EVENT_SEQUENCE |
| 7 | [3:0] PSTRB；其余保留 0 |

来源位图 bit0=外设拒绝、bit1=CSR 失败、bit2=下游错误、bit3=完整性事件、bit4=等待事件、bit5=合成事件。原始写数据和读数据不进入日志。

- REQ-LOG-001：首错为空时保存第一条选中记录，保持至 FAULT_CLEAR[0]；最近错误每次记录更新。
- REQ-LOG-002：FIRST/LAST 在读取字 0 时形成独立快照；读取字 1～7 返回该快照。下次读字 0 刷新快照。清除相应记录时清除其快照。
- REQ-LOG-003：FIFO 入队后队头不自动变化；读任意 HEAD 字不弹出，FIFO_POP 显式弹出。单管理软件须串行完成多字读取，多个管理主体通过软件互斥避免相互 POP。
- REQ-LOG-004：全局 64 bit 时间戳每功能周期加一、复位清零、自然回绕；DFX_EN=0 时仍保留日志时间戳。
- REQ-LOG-005：EVENT_SEQUENCE 每个选中的记录事件加一，记录使用递增前值；自然回绕，复位为零。
- REQ-LOG-006：拒绝/下游错误在事务完成边沿产生一次记录；新完整性故障、等待阈值和合成命令按事件产生边沿记录。
- REQ-LOG-007：同周期允许多个候选事件；记录写端口每周期接收一条，优先级为新完整性故障 > 总线事务失败 > 等待阈值 > 合成事件。未选候选数累加至 EVENT_LOST_COUNT；各自中断状态仍置位。
- REQ-LOG-008：FIFO 满不覆盖旧记录，丢弃新入队记录，置 OVF 并增加 LOST；FIRST/LAST 仍更新。FIFO_POP 与入队同周期时先释放槽位再入队，满 FIFO 可以接收新记录。
- REQ-LOG-009：FIFO_DEPTH=0 时跳过入队，不因“未实现 FIFO”增加 LOST；同周期候选仲裁丢失仍计 LOST。FIFO 状态只读寄存器可读，POP/HEAD 地址返回未实现错误。
- REQ-LOG-010：清除与新事件同周期时先清除再记录；FIRST 可被新事件重新置有效，LAST 更新；FIFO 清空后新事件可成为首条记录。
- REQ-LOG-011：FIFO 溢出、清除和事件丢失本身不再生成日志事件，防止递归日志。日志记录不能对 APB 形成反压。
- REQ-LOG-012：全局 ACCESS_DENY_COUNT 统计所有被拒绝的非 CSR 请求（含地址空洞/多重命中）；CFG_DENY_COUNT 统计唯一命中 CSR 的失败；下游错误不计权限拒绝。

## 10. 中断和安全告警

| 位 | 名称 | 触发条件 |
|---:|---|---|
| 0 | ACCESS_DENIED | 外设或非 CSR 请求拒绝，包括 DFX 强制拒绝 |
| 1 | CFG_ACCESS_ERROR | CSR 管理权限或其他 CSR 检查失败 |
| 2 | ADDR_MISS | 地址无命中，可与 bit0 同时置位 |
| 3 | MULTI_HIT | 地址多重命中，可与 bit0 同时置位 |
| 4 | INTEGRITY_ERROR | 完整性 FATAL 保持期间持续有效 |
| 5 | EVENT_LOST | 本周期事件丢失或 FIFO 满丢弃 |
| 6 | DOWNSTREAM_ERROR | 下游错误完成 |
| 7 | WAIT_EXCEEDED | 等待阈值首次达到 |
| 8 | DFX_TEST | 中断测试、合成日志或测试注入触发 |

- REQ-IRQ-001：`irq_o = |(INTR_RAW & INTR_ENABLE)`；`security_alert_o = |(INTR_RAW & ALERT_ENABLE)`。
- REQ-IRQ-002：INTR_RAW 为 W1C 粘滞状态，新事件优先于同周期清除；bits31:9 RAZ/WI。
- REQ-IRQ-003：屏蔽只控制输出，不影响事件捕获、拒绝、计数和日志。
- REQ-IRQ-004：完整性故障未复位时 bit4 清除后仍保持置位；其他事件清除后需新事件才重置。
- REQ-IRQ-005：INTR_TEST 仅产生 bit8，不设置真实错误位、不改变权限、不增加真实拒绝计数、不写日志。合成日志使用 INJECT_CMD。
- REQ-IRQ-006：ALERT_ENABLE 的修改仅限管理授权，不受策略锁影响。FATAL 本身即使告警被屏蔽仍阻断外设。
- REQ-IRQ-007：irq/alert 为 pclk 域电平，跨域送往中断/安全控制器由系统负责同步；本 IP 不直接复位系统。

## 11. DFX、统计与等待观测

- REQ-DFX-001：DFX 控制只在 DFX_EN=1、管理授权和 dfx_authorized_i=1 时允许。DFX 硬件授权不能由本 IP 的 CSR 自行产生。
- REQ-DFX-002：授权变低时，下一时钟边沿解除所有未触发注入武装；观测输出受授权门控。已经完成的事件和计数不自动清除。
- REQ-DFX-003：SUCCESS_COUNT 只统计下游 PREADY=1 且 PSLVERR=0 的完成事务；DENY_COUNT 只统计唯一命中该端口的拒绝；SLVERR_COUNT 统计下游错误。
- REQ-DFX-004：所有 32 bit 计数饱和不回绕；同周期清除和递增时先清零再累加本周期事件。
- REQ-DFX-005：WAIT_TOTAL 只计算下游 PSEL && PENABLE && !PREADY 周期，不包括寄存模式额外 SETUP 周期。WAIT_MAX 在完成时更新；未完成事务通过硬件阈值输出观测。
- REQ-DFX-006：WAIT_THRESHOLD=0 禁用告警；T>0 时，在单笔第 T 个等待周期边沿触发一次 WAIT_EXCEEDED 并置 WAIT_HIT；同笔不重复触发，新事务重新计数。
- REQ-DFX-007：busy_o 表示有外设事务正在 SETUP/ACCESS；active_port_valid_o 随有效目标，active_port_o 无效时为 0。仅诊断信号，不作为授权凭据。
- REQ-DFX-008：wait_threshold_o 表示授权条件下的粘滞 WAIT_HIT，清除由 DFX_CLEAR[0]；不会终止下游事务。
- REQ-DFX-009：INJECT_TARGET 写入时检查端口和主体范围；武装时锁存目标。武装期间改目标或再次武装返回 CMD_INVALID，须先解除。
- REQ-DFX-010：强制拒绝为一次性；匹配 MASTERID/端口、原本合法的下一笔事务在 SETUP 被拒绝，产生 DFX_FORCED_DENY，完成时计拒绝、bit0 与 bit8。自然非法事务不消耗武装。
- REQ-DFX-011：完整性故障注入为一次性；匹配的下一笔原本合法事务在 SETUP 阻断，在 SETUP 结束边沿置全局 FATAL，产生带 TEST 的 INTEGRITY_DETECTED；该笔完成再产生 INTEGRITY_BLOCK，标记 TEST。后续访问按普通 FATAL 拒绝。该模式需 POLICY_PARITY_EN=1，否则命令错误。
- REQ-DFX-012：DFX 完整性注入测试“检测结果至阻断/告警”路径，不翻转实际权限存储位，不能代替验证环境的真实 parity 位故障注入测试。
- REQ-DFX-013：合成日志命令在完成边沿产生 DFX_SYNTHETIC，TEST=1、REQUEST_VALID=0；不访问任何外设，不增加访问拒绝计数。
- REQ-DFX-014：无软件安全 bypass。scan/test 信号的工艺接入由 DFT 架构约束，功能模式下不得改变权限；不得以 DFX_EN 为条件绕过正常访问检查。
- REQ-DFX-015：单 APB 输入被下游等待占用时，软件无法通过同口读取 DFX CSR；这是接口边界。系统若需要独立救援访问，应在外围提供独立观测/复位通路，不能假定本 IP 可取消 APB。

注入目标匹配和武装消耗发生在 SETUP 结束边沿，同时锁存该事务的 TEST 标记。硬件授权在该边沿为低则不触发注入；此前已经触发的拒绝结果不因随后授权撤销而改变。两个注入模式互斥，任一已武装时再次武装均报错。授权撤销优先于同周期武装命令，命令返回 CFG_UNAUTHORIZED。WAIT_HIT 清除与新阈值事件同周期时，新事件优先保留。

## 12. 配置完整性与故障行为

- REQ-INT-001：POLICY_PARITY_EN=1 时，对每个 active/shadow PERM[7:0] 配置偶校验位，对每个 active/shadow CFG[1:0] 配置偶校验位；正常写、复制、复位同步更新校验。
- REQ-INT-002：PORT_LOCK 与 GLOBAL_LOCK 使用互补双位编码，合法解锁为 01、合法锁定为 10；00/11 为完整性错误，不得解码为解锁。
- REQ-INT-003：必须持续检查上述全部存储，稳定单 bit 错误最迟在下一 pclk 边沿置 INTEGRITY_FATAL。用于当前 SETUP 的组合判权同时受当前原始完整性错误指示门控，不能仅等待粘滞位生效。
- REQ-INT-004：任一 active/shadow/lock 完整性错误触发全局 FATAL；新外设请求全部拒绝；现有已经发到下游的事务继续完成，不承诺撤销已有副作用。
- REQ-INT-005：FATAL 后管理诊断入口仍开放，允许读状态/日志/配置和清除普通事件；shadow 写、reload、commit 返回 CFG_INTEGRITY，不支持通过写新 parity 清除 FATAL。
- REQ-INT-006：首个完整性位置记录在 INTEGRITY_STATUS；多处同时错误按 global lock、端口升序，每端口 lock→active CFG→shadow CFG→active PERM 主体升序→shadow PERM 主体升序的优先级选择。
- REQ-INT-007：LOCATION_TYPE：0=global lock，1=port lock，2=active CFG，3=shadow CFG，4=active PERM，5=shadow PERM，6=DFX synthetic。MASTER 仅 PERM 类型有效，其余为零。
- REQ-INT-008：POLICY_PARITY_EN=0 时不实现上述存储保护和注入功能，完整性状态读零，普通安全权限仍完整实现。
- REQ-INT-009：本保护不覆盖任意多 bit 错误、组合译码/比较逻辑故障、日志存储完整性或外部总线传输完整性，不宣称满足特定 ASIL 或安全认证等级。

## 13. 复位与运行流程

- REQ-RST-001：preset_ni 有效时全部 m_psel/m_penable/m_master_id_valid=0，上游 PREADY=0、PSLVERR=0、PRDATA=0，irq/alert 和 DFX 观测为零。
- REQ-RST-002：复位释放必须同步；释放后接收合法的新 SETUP，不将无先行 SETUP 的 ACCESS 视为新事务。输入违规只要求断言报告并保持下游不选中，不承诺正常 APB 完成。
- REQ-RST-003：复位清除锁、FATAL、日志/快照/FIFO、计数、时间戳、版本、提交状态、注入武装；策略恢复 RESET 参数，INTR_ENABLE=0，ALERT_ENABLE=0x9B。
- REQ-RST-004：复位中断在途事务属于系统复位行为，系统须协调上游、桥、下游的隔离与恢复；本 IP 不保证复位前写是否已发生。
- REQ-RST-005：不存在软件 soft reset；功能门控只允许在无进行中事务且系统保证配置/状态保持时由外部实现，禁止在等待期间停止必要的响应时钟。

推荐软件初始化：

1. 读取 ID、CAPABILITY 与地址映射，确认集成配置。
2. 配置日志/中断策略，检查无完整性故障。
3. 向各端口 CFG_SHADOW/PERM_SHADOW 写入完整权限。
4. 写 COMMIT_MASK，检查总线响应、COMMIT_STATUS、POLICY_VERSION 和 ACTIVE 读回。
5. 需要永久冻结时置 PORT_LOCK/GLOBAL_LOCK，再释放其他主体使用外设。

动态撤权：修改 shadow→提交→确认。只阻止此后进入本 IP 的请求；不能撤销已完成操作，也不会停止此前通过寄存器启动的 DMA/外设后台任务。任务停止与资源清理由系统软件协调。

示例：端口 2、主体 0 仅 Secure 特权读写，PERM=0x22；主体 1 仅 Non-secure 特权读写，PERM=0x88；主体 2 仅 Non-secure 非特权只读，PERM=0x04。CFG_SHADOW=0x1 启用数据访问；COMMIT_MASK=0x4 提交端口 2。管理主体自身不自动获得端口 2 访问权。

## 14. 架构与 PPA 提示

推荐内部模块：address_decode、access_check、apb_route、local_csr、policy_bank、fault_record、interrupt_ctrl、dfx_ctrl。该分解为建议，不限制 RTL 层次命名。

- 地址译码可生成 one-hot 命中，权限选择可与译码并行，响应采用 one-hot mux 或等效结构。
- 参数固定的地址比较、未实现端口/主体和裁剪功能应由综合消除。
- 每个 PERM CSR 只存低 8 bit；8 端口×16 主体的权限数据为单份 1024 bit，shadow/active 双份 2048 bit，另加校验、控制、锁和日志。
- 持续完整性检查会带来组合归约和扇出开销，STA 应覆盖 integrity→PSEL 路径；可通过层次化归约优化，但不能增加超出要求的故障阻断延迟。
- 不在寄存模式之外偷偷加入额外等待，不使用未约束的异步配置线驱动权限。
- 不规定无工艺依据的 MHz、面积或功耗数值；交付必须报告两种时序模式及典型/最大配置的综合面积、关键路径与约束。

## 15. 验证与验收要求

### 15.1 功能验证矩阵

| 验证项 | 必须覆盖 | 对应需求 |
|---|---|---|
| 参数 | 端口 1/8/32，主体 1/16/64，非 2 幂，FIFO 0/1/8/32，开关组合；非法配置拒绝 | PAR |
| 地址 | 首末地址、空洞、CSR 边界、越界槽位、故障注入多重命中 | DEC |
| 权限 | 每类属性、读写、主体有效/越界/高位别名、管理主体无外设豁免 | ACL/SYS |
| APB | 零等待、长等待、背靠背、读写交替、端口切换、CSR 交替、两时序模式 | APB/TIM |
| 副作用 | 用读清/写触发模型确认拒绝请求从未进入下游 SETUP | APB-001 |
| CSR | RO/WO、W1C/W1S、保留位、空洞、字节选通、未对齐、非授权读零 | CSR |
| 更新 | shadow 不生效、多端口原子提交、部分失败全回滚、提交版本与新 SETUP | UPD |
| 锁 | 每端口/全局、reload/commit 绕过尝试、写零、复位恢复 | UPD/RST |
| 日志 | 首错保持、最近错快照、FIFO 满/空、POP+push、clear+event、多候选丢失 | LOG |
| 中断 | 每位触发/屏蔽/清除、事件清除竞争、FATAL 重置位、独立 alert | IRQ |
| DFX | 授权拒绝/撤销、武装目标、自然拒绝不消耗、一次注入、饱和统计、阈值 | DFX |
| 完整性 | 逐类真实 bit flip、锁非法编码、当前 SETUP 阻断、在途继续、新请求拒绝 | INT |
| 复位 | 各状态复位、复位值、无误 PSEL、普通外设复位不解除策略 | RST |
| 系统 | X2P 读写属性和 MASTERID 绑定、缓冲次序、无旁路地址 | SYS |

### 15.2 必须建立的断言/形式性质

1. 下游选择 onehot0；非法请求不产生任何下游 PSEL。
2. 下游 SETUP/ACCESS 顺序合法；等待期间目标和请求稳定。
3. 非法写/读不产生目标端副作用；拒绝读数据固定零。
4. 未授权 CSR 写不改变目标状态（规定的日志/中断审计状态除外）。
5. 无成功提交时 active 权限不因软件写而改变；锁定状态只能由可信复位清除。
6. 提交所选端口在同一边沿全量更新，失败时全量保持。
7. 每笔失败事务事件至多一次；记录选中/丢失计数与仲裁一致。
8. 关闭中断或日志满不改变权限判断。
9. FATAL 状态阻断新的外设请求，既有下游事务仍遵守协议。
10. DFX 授权不足不能武装注入；强制拒绝永远不能把自然拒绝变为允许。

### 15.3 验收门槛

- 所有强制需求建立 REQ→Feature→Test/Assertion 追踪，未关闭偏差必须列入评审记录。
- 必需测试通过，无未解释的 scoreboard/协议断言错误；功能覆盖计划中的强制 bins 全命中或有评审豁免。
- Lint 无未豁免错误；复位域/时钟域检查与系统假设一致；综合无 latch、无越界索引、无多驱动。
- 不以单一代码覆盖率数字替代安全性质验证；未覆盖代码须分析并标明裁剪/不可达原因。
- 至少对拒绝无副作用、锁不可绕过、原子提交、onehot0 进行形式验证或等效可审计的穷尽检查；有限仿真不可声称证明全部安全性质。
- 提交典型与最大配置综合报告，验证 REGISTER_MODE=0 的零额外等待和 REGISTER_MODE=1 的单额外等待契约。

## 16. 实现交付件

| 交付件 | 内容 |
|---|---|
| RTL | 参数化模块、寄存器与策略逻辑、断言绑定文件 |
| HWIF | APB4 与 MASTERID sideband 契约、方向和稳定性要求 |
| 寄存器描述 | YAML SSOT，本文地址/字段/复位/访问权限一致 |
| 软件 | C 头文件、初始化/更新/锁定/中断示例；错误返回处理 |
| 验证 | 验证计划、参考权限模型、APB 测试环境、覆盖与形式性质 |
| 集成 | 地址/参数检查脚本、FuseSoC core、典型配置 |
| 文档 | architecture、verification_plan、rtm、user_guide 与需求偏差表 |
| 质量 | Lint、综合、时序、CDC/RDC 适用性、回归结果 |

## 17. 参考依据与使用限制

APB 协议基线应以项目受控的 Arm AMBA APB Protocol Specification（IHI 0024）为准，选择包含 APB4 定义的版本。MASTERID sideband、寄存器映射、权限表、DFX 与事件编码是本项目扩展，不属于 APB 标准。正式冻结前应由协议评审对照受控规范核验；本轮未成功取得 Arm PPC、STM32 GTZC 等官方产品正文，因此不宣称已完成这些产品的逐项兼容性核对。

访问控制验证方法可参考原始研究 [AKER: A Design and Verification Framework for Safe and Secure SoC Access Control](https://arxiv.org/abs/2106.13263)：该工作讨论基于硬件访问控制封装的隔离，并在 IP、固件和系统层面验证访问控制。本文借鉴分层验证思想，未复制其总线接口或寄存器设计。

本文已固定实现所需的产品行为；项目级待填项仅为实际端口地址、主体分配、管理主体掩码、启动权限、复位/DFX 授权来源以及工艺时序目标。这些值必须作为集成配置受控，不得在 RTL 中随意默认成全权限。
