# 授权及寄存器访问：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.CSR.001
name: tc_apb_secure_demux_csr
type: register
description: 授权及寄存器访问
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_csr.sv
feature_ref:
- FL.APB_SECURE_DEMUX.CSR
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.CSR
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 遍历所有实际RDL寄存器、固定槽位空洞与裁剪位置；测试管理掩码/PPROT/身份/公开读组合、所有PSTRB和低地址位、RO写/WO读、保留位写一。
expected_result:
- 授权优先于存在性且拒绝读零；错误无目标副作用；RW/RO/WO/W1C/W1S、复位和保留位行为符合生成结构与LLD；DFX状态需当前硬件授权。
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

激励：遍历所有实际RDL寄存器、固定槽位空洞与裁剪位置；测试管理掩码/PPROT/身份/公开读组合、所有PSTRB和低地址位、RO写/WO读、保留位写一。

期望：授权优先于存在性且拒绝读零；错误无目标副作用；RW/RO/WO/W1C/W1S、复位和保留位行为符合生成结构与LLD；DFX状态需当前硬件授权。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
