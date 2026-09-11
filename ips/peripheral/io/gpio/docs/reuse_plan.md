# GPIO 复用评估

本次读取 CBB/VIP registry 与 APB4 HWIF 实际文件，资产成熟度仅用于候选选择，不代表当前 GPIO 已完成集成或验证。

| 对象 | 当前资产与状态 | GPIO 语义比较 | 决策与参数映射 |
|---|---|---|---|
| parity | aixsilicon:cbb:parity_gen_check:0.1.0，implemented | GPIO需32-bit偶parity及单周期内检测；必须选无额外寄存延迟配置 | 候选复用，通过FuseSoC depend接入；部分写合并与故障保持仍由GPIO实现 |
| 事件FIFO | aixsilicon:cbb:sync_fifo:0.1.0，implemented | 当前源码push_ok=push_i && !full，满+POP不能同时接收；没有原生FLUSH | 不直接复用，选择IP专用事件队列，避免以reset胶水冒充同步FLUSH；不复制CBB源码 |
| 主输入同步 | single_bit_synchronizer，planned | 主域2～4级及输入有效填充要求 | 依赖未实现；GPIO实现合同指定同步路径并交付约束 |
| AON命令桥 | handshake_synchronizer / cdc_config_bridge，planned | 需要跨暖复位保留身份/稳定载荷、迟到ACK及恢复排空 | GPIO专用桥接，不把planned资产列为已通过依赖 |
| APB VIP | VIP-004 apb，developing，version未发布 | 支持PPROT/PSTRB/错误路径，但qualification为PARTIAL_DEVELOPING | 后续检查实际core版本与G4适用证据；未闭合前不得当已验证依赖 |
| GPIO VIP | VIP-011 gpio，planned | 引脚激励与有效性/拥有权需要项目约束 | 后续允许IP专用激励与独立功能模型，记录替换边界 |
| APB HWIF | aixsilicon:interface:apb:1.0.0 | apb_csr_v1禁止protection，不适用；apb4_base声明ADDR_W=32、允许PPROT | 在验证/系统边界使用32位APB4接口，GPIO局部14位地址显式零扩展适配，保持PPROT/PSTRB；不声称已有原生14位profile |

当前未产生 FuseSoC core 或复制任何 VIP/CBB RTL。真正接入前重新核对 registry、CAPI参数类型、fileset/depend闭包和实际elaboration，再固定源码哈希。
