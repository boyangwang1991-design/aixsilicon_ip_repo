# 强制覆盖义务 4

## RESET

- IDLE/SETUP/LOCAL/REG_SETUP/ACCESS/等待中复位
- 锁/FATAL/满FIFO/快照/武装/非零reset配置恢复
- 独立外设复位不解除权限，非法孤立ACCESS隔离

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.RESET.MANDATORY
name: reset_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.RESET
bins:
- IDLE/SETUP/LOCAL/REG_SETUP/ACCESS/等待中复位
- 锁/FATAL/满FIFO/快照/武装/非零reset配置恢复
- 独立外设复位不解除权限，非法孤立ACCESS隔离
target: 100
END_COVERAGE_META -->
## PPA

- 典型/最大×direct/register四点
- 准入/完整性/响应/状态更新四类关键路径已约束
- 每点面积/关键路径/库/SDC/工具hash齐全

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.PPA.MANDATORY
name: ppa_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.PPA
bins:
- 典型/最大×direct/register四点
- 准入/完整性/响应/状态更新四类关键路径已约束
- 每点面积/关键路径/库/SDC/工具hash齐全
target: 100
END_COVERAGE_META -->
## DELIVERY

- 合同交付表全部项有实际文件与当前证据
- RDL→RTL/RAL/Header一致；core依赖可解析
- 负向检验缺文件/错版本/过期hash/错误selector均失败

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.DELIVERY.MANDATORY
name: delivery_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.DELIVERY
bins:
- 合同交付表全部项有实际文件与当前证据
- RDL→RTL/RAL/Header一致；core依赖可解析
- 负向检验缺文件/错版本/过期hash/错误selector均失败
target: 100
END_COVERAGE_META -->
## ERROR

- 外设相邻原因优先级对及多重冲突
- CSR相邻优先级对及多重冲突
- CSR主错误与COMMIT_STATUS独立排序

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.ERROR.MANDATORY
name: error_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.ERROR
bins:
- 外设相邻原因优先级对及多重冲突
- CSR相邻优先级对及多重冲突
- CSR主错误与COMMIT_STATUS独立排序
target: 100
END_COVERAGE_META -->
