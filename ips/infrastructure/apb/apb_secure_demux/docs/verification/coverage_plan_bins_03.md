# 强制覆盖义务 3

## LOG

- 四候选valid组合1..15，每组合检查选中与丢失
- FIFO空/非空/满×POP/push/clear竞争，depth0/1/3/8/32
- FIRST/LAST快照交错与清除+新事件
- 序列与时间戳回绕、全部记录原因及有效字段组合

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.LOG.MANDATORY
name: log_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.LOG
bins:
- 四候选valid组合1..15，每组合检查选中与丢失
- FIFO空/非空/满×POP/push/clear竞争，depth0/1/3/8/32
- FIRST/LAST快照交错与清除+新事件
- 序列与时间戳回绕、全部记录原因及有效字段组合
target: 100
END_COVERAGE_META -->
## IRQ

- 9个原始事件各自置位/屏蔽/清除
- 每位raw×enable×alert
- 每位新事件+同沿清除、FATAL持续源
- INTR_TEST不产生日志 vs INJECT_CMD合成日志

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.IRQ.MANDATORY
name: irq_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.IRQ
bins:
- 9个原始事件各自置位/屏蔽/清除
- 每位raw×enable×alert
- 每位新事件+同沿清除、FATAL持续源
- INTR_TEST不产生日志 vs INJECT_CMD合成日志
target: 100
END_COVERAGE_META -->
## DFX

- DFX开关×授权高低/SETUP撤销/ACCESS撤销
- 自然允许/拒绝×目标匹配×拒绝/完整性武装
- 非法目标/重武装/武装改目标/解除/仅一次消费
- WAIT阈值0/1/T及同笔一次；全部计数饱和/清除+递增

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.DFX.MANDATORY
name: dfx_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.DFX
bins:
- DFX开关×授权高低/SETUP撤销/ACCESS撤销
- 自然允许/拒绝×目标匹配×拒绝/完整性武装
- 非法目标/重武装/武装改目标/解除/仅一次消费
- WAIT阈值0/1/T及同笔一次；全部计数饱和/清除+递增
target: 100
END_COVERAGE_META -->
## INTEGRITY

- 六类真实保护位置及global lock，逐类数据位/校验位单错
- 多错优先global→端口序→类型→主体序
- 新SETUP/在途/诊断×raw错误/FATAL
- PARITY关闭、真实故障与DFX合成故障区别

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.INTEGRITY.MANDATORY
name: integrity_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.INTEGRITY
bins:
- 六类真实保护位置及global lock，逐类数据位/校验位单错
- 多错优先global→端口序→类型→主体序
- 新SETUP/在途/诊断×raw错误/FATAL
- PARITY关闭、真实故障与DFX合成故障区别
target: 100
END_COVERAGE_META -->
