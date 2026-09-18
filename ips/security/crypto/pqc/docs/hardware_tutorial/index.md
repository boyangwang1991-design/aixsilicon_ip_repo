# PQC 硬件教学手册

[PQC 学习与文档总入口](../index.md)

本手册以教学为主，帮助初学者把算法知识连接到硬件架构、模块协作、数据流与 RTL 实现。先读[算法教材](../learning/01-pqc-basics.md)，再按下面顺序追踪一条命令；不要求一开始就掌握总线协议和寄存器编程。

**版本基线：2026-09-18 的开发工作区。** 本材料不是标准 `user_manual`、集成规范或签核文档；这些材料留给后续对应 skill 生成。这里用当前源码做例子，分别说明目标方案、可见实现与已有验证证据；本次没有重新执行 EDA 算法回归。

| 顺序 | 章节 | 内容 |
|---|---|---|
| 1 | [架构、配置与 RTL 实现](01-architecture-implementation.md) | 模块层次、资源共享、配置、候选实现与源码入口 |
| 2 | [从软件命令理解外部接口](02-interfaces-programming.md) | 为什么分 APB/AXI、如何理解寄存器与描述符、谁发起工作 |
| 3 | [算法执行、数据流与存储](03-flows-memory.md) | KeyGen、Encaps、Decaps、Sign、Verify、页生命周期与性能 |
| 4 | [从故障场景理解安全控制](04-security-errors.md) | 授权、托管、背压、撤销、清零、状态与排错 |
| 5 | [怎样阅读 RTL 与验证结果](05-verification-status.md) | 模型/RTL 的证据层次、源码阅读练习、实现状态 |

## 快速定位

| 我想知道 | 去哪里看 |
|---|---|
| 哪些算法/参数集属于目标范围？ | [算法与参数表](../learning/01-pqc-basics.md)、[当前能力说明](05-verification-status.md) |
| 每一个 RTL 模块做什么？ | [完整模块地图](../learning/08-hardware-architecture.md)、[本手册实现章节](01-architecture-implementation.md) |
| 描述符的每个偏移是什么？ | [128 B 布局和缓冲区分配](../learning/09-command-flow.md) |
| 要连哪些顶层信号？ | [接口章节](02-interfaces-programming.md)、[pqc_top.sv](../../rtl/pqc_top.sv) |
| 私钥能否从 APB/DMA 读回？ | [密钥授权与专用托管](04-security-errors.md) |
| 怎么判断输出可以使用？ | [编程顺序](02-interfaces-programming.md)、[原子提交](../learning/09-command-flow.md) |
| 400 MHz、100 μs 是实测值吗？ | [性能口径](03-flows-memory.md)，均需区分目标和实测 |

## 文档与事实源

接口结构以 [SystemRDL](../../regs/pqc.rdl)、生成的 [C 头文件](../../sw/include/pqc_regs.h) 和顶层端口为准；功能要求以 [LRS](../lrs/index.md) 为准；目标资源组织与时序以 [HLD](../hld/index.md)、[LLD](../lld/index.md) 为准；实现完成度以当前 RTL 和 [统一报告](../../reports/report.md) 绑定的测试证据为准。

本手册不手工修改生成的 CSR/Header，也不以新增教学材料宣告任何交付门禁闭环。复杂流程图用于帮助追踪依赖；正式接口规范后续由标准文档承接。
