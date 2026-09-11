# 权限属性全矩阵：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.ACL.001
name: tc_apb_secure_demux_acl
type: directed
description: 权限属性全矩阵
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_acl.sv
feature_ref:
- FL.APB_SECURE_DEMUX.ACL
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 每端口/主体遍历四PPROT类别×读写×指令数据，逐一启闭8个PERM位和CFG位；含管理主体、无效ID、越界ID、高位别名与PSTRB0写。
expected_result:
- 独立RM按完整身份和有效位计算；管理/安全/特权无隐含豁免，指令写拒绝；自然非法访问从SETUP起无下游副作用。
timeout_policy: 200000 pclk cycles for simulation; 1200 s tool timeout
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
- CFG_MAX_DIRECT
- CFG_MAX_REGISTER
- CFG_MIN_NOFIFO
- CFG_MIN_FIFO1
- CFG_NONPOWER
- CFG_TRIMMED
END_TESTCASE_META -->

激励：每端口/主体遍历四PPROT类别×读写×指令数据，逐一启闭8个PERM位和CFG位；含管理主体、无效ID、越界ID、高位别名与PSTRB0写。

期望：独立RM按完整身份和有效位计算；管理/安全/特权无隐含豁免，指令写拒绝；自然非法访问从SETUP起无下游副作用。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
