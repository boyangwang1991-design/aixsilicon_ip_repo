# Configuration Model 与依赖

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


参数为 elaboration 配置；地址/管理掩码必须由集成提供，不定义全权限默认值。
NUM_MASTERS 不超过 2^MASTER_ID_WIDTH；所有地址区间不得重叠、截断或回绕。
强制验证配置包括端口 1/8/32、主体 1/16/64、非 2 幂、FIFO 0/1/8/32 及开关组合。
19-PC 应从此需求冻结基线形成 PARAM/CONFIG/CONSTRAINT META 和参数合同。
