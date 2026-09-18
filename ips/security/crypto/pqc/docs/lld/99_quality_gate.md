# PQC G2 微架构与寄存器评审入口

<!-- LLD_GATE_META
gate: G2
status: open
microarchitecture_freeze: false
END_LLD_GATE_META -->

G1 已完成用户委托的实际架构评审。本阶段尚未完成，不能沿用旧版全 PASS 清单。

待闭环：各 HLD 模块的实际状态/数据通路，完整算法依赖和 masked gadget 清单，
固定尝试预算、转换/采样范围、页生命周期/端口调度，全部错误/清除握手，寄存器
字段行为及从当前 RDL 重建的 CSR/RAL 一致性。已完成分册每次运行 owning extractor；
结构抽取通过不等于上述技术检查通过。后续决策和冻结按用户委托办理，不重复询问。

当前设计交接的具体剩余条件：

- 已明确 RANDOM 独立服务与 FE.DESC_FETCH 子模块；TOP 共享 AXI 读事务锁定、
  描述符 done/error 接入 FE、抓取超时与清除仍待实现对齐。模块 META 和映射不代表 RTL 完成。

- KEMSEQ 已补命令/原语 FSM、三操作依赖链和比较/选择数据通路；精确页生命周期、
  完整原语周期与 Level 2 gadget 仍未闭环。SAMPLER 已补流接口 FSM/数据通路及秘密
  扫描基线，固定候选的顺序检查和概率证书通过；但朴素串行扫描的 SampleInBall
  仅访存就至少 196608 周期，必须优化并重算完整尝试预算，不能据模块对象齐全冻结 G2。
  masked gadget/随机清单、FIFO 双域擦除和实际端口时序仍需闭环。
- CODEC A2B/B2A、秘密比较/乘法的通用算法实例与实际 gadget 清单未闭环；
  Sign 完整固定尝试周期表未完成，不能按分配额度直接填实际消耗。
- KEYSLOT/SRAM/TOP/DMA 的身份、撤销、返回容量和清除设计已有分册；模型检查
  只覆盖其明确列出的逻辑性质。FAULT 全局 clear_epoch 汇聚、端到端安全收尾和
  非 NTT 端口轨迹仍须联合审核。
- RDL 已按当前行为意图修正句柄、请求脉冲、写保护、计数器更新和元数据缺口。
  `check_register_contract.py` 检查的是选定结构义务，不是全部字段行为批准。
  寄存器全量评审及 CSR/RAL/Header 再生、实际 APB 行为检查仍属未完成输入；
  现有生成物是历史版本，禁止将源检查通过写成 CSR 一致性通过。

本文保持 open/false；技术缺项归本阶段继续完成，不需要再次索取已有范围的执行授权。

2026-09-18恢复审查：Decaps 的 word/byte 单位、私钥区段偏移、不可变原密文页、
hash/WORKKEY 请求响应和完整比较选择已在 `03_kemseq_decaps.md` 写明修正目标。
现存 RTL 仍有未驱动写数据、未锁存长度、哈希不吸收完整输入、9-bit比较游标对比
byte长度、始终选择Kbar等缺陷；实现、逐原语FSM及Level2联合评审未完成。
`evaluate_quality.py` 当前输出的 G2 PASS 不覆盖本页明确的技术冻结条件，不能据此
授权 RTL/UVM 签核；本轮 LLD 变更后的下游实现和历史执行证据均待重建。
