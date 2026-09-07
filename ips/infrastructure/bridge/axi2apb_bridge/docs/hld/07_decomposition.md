# 07. HLD 分解与验证规划 `[必填]`

> 对应原章节：16. HLD 到 LLD 的分解、17. 验证规划输入

---

## 16. HLD 到 LLD 的分解

| HLD 模块 | 建议 LLD 章节 | LLD 需要详细设计的内容 |
|---|---|---|
| AXI Frontend | Frontend LLD | AW/W 配对、队列写入、ID 捕获、READY 控制 |
| Request Buffers | Buffer LLD | 队列实现、满/空标志、AW/W 关联、depth 参数化 |
| Scheduler | Scheduler LLD | 仲裁状态机、粒度切换、Beat 原子单元 |
| Transfer Engine | Transfer LLD | INCR/WRAP 地址生成、Narrow lane 计算、宽度拆解 |
| CDC Layer | CDC LLD | 异步 FIFO、reset 安全、指针同步 |
| APB Engine | APB LLD | FSM 状态编码、Wait-State、Timeout 计数与恢复 |
| Response Engine | Response LLD | Read assembly、错误聚合、ID 还原、R/B 背压 |

### 16.2 RTL 实现约束输出

| 约束编号 | RTL 设计约束 | 来源 |
|---|---|---|
| RTL-CONS-001 | 所有跨时钟域控制信号必须使用 async FIFO / 同步器 | HLD CDC 设计 |
| RTL-CONS-002 | APB Engine FSM 必须具备 Timeout 恢复路径 | HLD Timeout |
| RTL-CONS-003 | 一个 AXI Beat 的 APB sub-transfer 不得被调度切分 | HLD 仲裁 |
| RTL-CONS-004 | Buffer Full 必须通过 AXI READY 反压 | HLD 队列 |
| RTL-CONS-005 | Reset 后不得产生伪 APB access / AXI 响应 | HLD 复位 |

---

## 17. 验证规划输入

### 17.1 验证特性列表

| 验证特性 | 验证目标 | 对应 LRS |
|---|---|---|
| AXI/APB 协议转换 | 读/写 channel 完整转换 | LRS.INTF.X2P.01.* |
| Burst 转换 | INCR/FIXED/WRAP 地址正确 | LRS.FUNC.X2P.02.* |
| Narrow/Width | 拆解/组装/STRB 正确 | LRS.FUNC.X2P.03.* |
| Buffer/Outstanding | 深度/背压/溢出 | LRS.FUNC.X2P.04.* |
| 仲裁 | 策略/粒度/无饥饿 | LRS.FUNC.X2P.05.* |
| 响应/错误 | OKAY/SLVERR、聚合、ID | LRS.FUNC.X2P.06.* |
| Timeout | 计数/恢复/无死锁 | LRS.FUNC.X2P.07.* |
| APB FSM | SETUP/ACCESS/Wait-State | LRS.FUNC.X2P.08.* |
| CDC | 同步/异步模式、无事务丢失 | LRS.FUNC.X2P.10.* |
| Register Stage | 三种 regslice | LRS.FUNC.X2P.09.* |

### 17.2 覆盖点建议

| 覆盖类型 | 覆盖内容 |
|---|---|
| 功能覆盖 | 全部 42 需求功能路径 |
| 状态覆盖 | APB FSM 全部状态与跳转 |
| 接口覆盖 | AXI/APB 合法与非法访问 |
| 异常覆盖 | Timeout、SLVERR、partial write |
| CDC 覆盖 | SYNC/ASYNC、深度、复位 |

### 17.3 断言建议

| 断言编号 | 断言描述 | 适用模块 |
|---|---|---|
| SVA-001 | PENABLE=1 且 PREADY=1 后 1 拍内该 transfer 必须完成或 timeout | APB Engine |
| SVA-002 | ACCESS 期间 PADDR/PSEL/PWDATA 稳定 | APB Engine |
| SVA-003 | BVALID 与 RVALID 不同时违规；同 ID R 按序 | Response Engine |
| SVA-004 | WRAP 地址回绕正确 | Transfer Engine |
| SVA-005 | CDC FIFO 不溢出/下溢 | CDC |