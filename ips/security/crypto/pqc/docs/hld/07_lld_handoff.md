# PQC LLD 工作包与验收边界

G1 冻结后，以下工作包按依赖顺序进入 LLD。本文定义架构责任，不分配 RTL 文件、FSM 编码或周期级信号。

| 工作包 | 架构 owner | 必须明确的 LLD 内容 |
|---|---|---|
| descriptor/命令事务 | FE、DMA | 完整 shadow、精确长度/容量/context/地址溢出与别名检查，输出/完成记录/IRQ 顺序，软件 abort 的安全点 |
| 私钥授权与材料 | KEYSLOT、WORKKEY、TOP | owner/domain/handle/epoch 一致性，材料导入与 ECC/语义校验的分工，KeyGen 新生成标记及 ACK，迟到确认拒绝，全部暂存擦除 |
| KEM 完整调度 | KEMSEQ | 六个输入/输出角色与种子域分离，矩阵行生成、变换/MAC/编码依赖，Decaps 重加密/比较/选择；不把 primitive 完成当作操作成功 |
| DSA 完整调度 | DSASEQ | 三参数集全算法，消息/context、拒绝循环与 nonce 不复用，z/r0/c*t0/hint 检查、完整 Verify 摘要与无效编码处理 |
| 多项式与编解码表示 | POLY、CODEC、SAMPLER | 每个原语输入/输出范围、NTT 顺序与归一化，signed centered low 与规范 residue 转换；不能仅凭 tag 名假设 Montgomery 因子 |
| 页生命周期与并行资源 | SRAM、POLY | 32 KiB 最大工作集逐阶段分配/最后消费者/重算，8 bank 端口收集与确定性冲突，实际 1/2/4 lane 发射与写回 |
| 哈希与流式供数 | KECCAK、DMA | 64-bit 吸收/尾字节、空消息与 rate 边界、两 context 的绑定/清理、两 word 供数，预算中所有内部等待可计量 |
| 系统安全收尾 | FAULT、全部存储/总线 owner | 自检、异常优先级、六方清零与总线排空，超时不假成功；复位释放与长期密钥所有权分离 |
| 寄存器与能力 | FE、KEYSLOT | 在当前 RDL 结构基础上定义 SW/HW 冲突、拒绝副作用与能力反映；字段生成回到 02，不手改派生 CSR |
| 复用 | TOP、SRAM、DMA | 按 docs/reuse_plan.md 接入 RR/公开 FIFO，核对取消及 held-request 语义，FuseSoC depend 唯一来源 |

## 跨原语表示合同

算法调度先使用规范 residue 与显式的 coefficient/NTT 域标签；使用 Montgomery 或 lazy
表示时，必须由独立转换原语定义比例与范围，并在所有生产者/消费者闭环中校验。
当前 RTL 的模乘并非自动接受 NTT_MONT，不能照旧文档标签把数值比例混用。

MakeHint 的输入是 centered low 与 high，而签名算法中概念上的 MakeHint 参数仍需经过
一致的分解；此适配由 CODEC/DSASEQ 合同明确。KEM 的二项 base multiplication 与 DSA
pointwise multiplication 分开选择，不以共用 MAC 名称替代数学差异。

## 权限与完整性不能相互替代

ECC 导入扫描证明存储完整性，不证明标准 key 编码或 H(ek) 等算法约束；后者由各算法
入口按完整长度校验。数据授权与页标签匹配要沿真实请求路径生效，不能只在 CSR 中存放元数据。
私钥导入来自可信端口也不能豁免长度、epoch、用途、范围或 ECC 拒绝。

## 当前安全设计保留项

Sign 时间约束已按用户继续指令落实为固定尝试调度、可变总时延。LLD 需给出完整尝试
预算、采样上限、各检查独立完成标记、nonce 防回绕与结果退休。Level 2 架构合同
见 09_masking_execution.md；算法实例、gadget 清单和组合安全分别在 G2/G3/G4 闭环。
用户明确 Level 2 本轮必须交付；
两 share、全链路保护与随机预算候选见 09_masking_level2.md，不能以功能 KAT 代替侧信道签核。
