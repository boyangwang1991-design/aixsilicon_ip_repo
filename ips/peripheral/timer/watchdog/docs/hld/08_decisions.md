# Watchdog：架构决策与复用依据

所有 ADR 随本次用户 G1 批准确认；设计批准不等于实现和验证证据已通过。

## 并行通道与客户端状态

<!-- HLD_DECISION_META
id: ADR.WATCHDOG.CHANNEL.001
level: HLD
status: approved
options:
- 共享轮询计时/多拍扫描
- 每通道并行监督及原子整表快照
decision: 每通道并行监督及原子整表快照
req_ref:
- LRS.CFG.WATCHDOG.PAR.001
- LRS.CFG.WATCHDOG.PAR.002
- LRS.CFG.WATCHDOG.PAR.003
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.CONS.WATCHDOG.NFR.001
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.NFR.003
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.NFR.005
- LRS.CONS.WATCHDOG.NFR.006
applicability:
  expr: 'true'
END_HLD_DECISION_META -->

选择并行监督以保证固定期限和一致快照，代价是大配置的组合与存储面积。

## 单在途跨域事务

<!-- HLD_DECISION_META
id: ADR.WATCHDOG.MAILBOX.001
level: HLD
status: approved
options:
- 多在途队列
- 单在途稳定负载与序号完成记录
decision: 单在途稳定负载与序号完成记录
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
applicability:
  expr: 'true'
END_HLD_DECISION_META -->

与来源/配置快照及 reset 语义一致，证明边界简单；代价是软件命令吞吐受完整往返限制。

## 保护独立性

<!-- HLD_DECISION_META
id: ADR.WATCHDOG.SAFETY.001
level: HLD
status: approved
options:
- 仅复制主状态组合结果
- 独立演进/独立比较与保持请求
decision: 独立演进/独立比较与保持请求
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
applicability:
  expr: 'true'
END_HLD_DECISION_META -->

允许清晰单点故障分析，代价是冗余面积及必须保留的物理结构。

## 复用与依赖质量

<!-- HLD_DECISION_META
id: ADR.WATCHDOG.REUSE.001
level: HLD
status: approved
options:
- 复制资产源码或只依赖标签
- 引用已实现 CBB，并单独核对未闭合 VIP
decision: 引用已实现 CBB，并单独核对未闭合 VIP
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.CONS.WATCHDOG.NFR.001
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.NFR.003
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.NFR.005
- LRS.CONS.WATCHDOG.NFR.006
- LRS.CONS.WATCHDOG.VER.001
- LRS.CONS.WATCHDOG.VER.002
- LRS.CONS.WATCHDOG.VER.003
- LRS.CONS.WATCHDOG.VER.004
- LRS.CONS.WATCHDOG.VER.005
- LRS.CONS.WATCHDOG.VER.006
applicability:
  expr: 'true'
END_HLD_DECISION_META -->

当前 RR arbiter 可复用；APB VIP developing/M1、G4/G5 partial、G6未发布，不能直接支撑 G4。

## 当前资产基线

读取本地 CBB registry：round_robin_arbiter 0.1.0 为 implemented，选择两请求公平仲裁。
既有 core 元数据存在 paramtype 兼容问题，必须在 FuseSoC 阶段用实际解析/展开核对；
不复制或改写 CBB 源码，不把临时 metadata 适配当成原资产已修复。

读取 APB VIP registry 与其 gate_status：developing/M1/PARTIAL_DEVELOPING，
G4/G5 partial、G6 NOT_RUN。VPLAN 可预备接入现有组件，但验证闭环不能只引用该
成熟度标签。需要精确 APB4 范围 qualification 或有记录的临时自包含方案。
当前已存在完整源码不是放弃复用的理由；接入采用 depend/只读引用，不能搬进 IP。

HWIF 参考资产仓 IFC-APB-001 基础契约：原生地址宽度 15、数据宽度 32，保留
PPROT 和 PSTRB。基础契约允许该地址宽度，但当前 apb4_base profile 限定 32 位地址，
apb_csr_v1 profile 限定 32/64 位地址且禁止 protection，均不能直接宣称匹配。
LLD/接口绑定须明确原生端口和这些差异；若系统使用较宽地址，集成端先完成完整地址
译码再缩窄，不能截断后产生地址别名。基础契约/profile 当前均为 draft，不能视为
已发布合格依赖。IP 的可信来源/授权是额外侧带，不能混同 APB PPROT。
完整复用证据和输入 SHA 见本阶段检查报告。
