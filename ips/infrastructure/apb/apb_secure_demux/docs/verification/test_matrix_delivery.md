# 交付与证据完整性：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.DELIVERY.001
name: tc_apb_secure_demux_delivery
type: static
description: 交付与证据完整性
priority: must
tier: extended
implementation: scripts/verification/check_delivery_evidence.py
feature_ref:
- FL.APB_SECURE_DEMUX.DELIVERY
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
preconditions:
- 合法实例配置与当前源码构建身份一致
- 系统/工艺证据需由对应owner提供
stimulus:
- 从干净受控源执行生成、构建和软件示例编译，验证core依赖、所有交付文件、需求RTM、签核日志及覆盖/形式证据身份；检测缺件/过期hash/伪PASS。
expected_result:
- 每项交付需求有有效当前证据；实例配置与CSR一致；无private路径构建依赖、无伪造审批、无未关闭必需偏差。
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
proof_kind: static
END_TESTCASE_META -->

激励：从干净受控源执行生成、构建和软件示例编译，验证core依赖、所有交付文件、需求RTM、签核日志及覆盖/形式证据身份；检测缺件/过期hash/伪PASS。

期望：每项交付需求有有效当前证据；实例配置与CSR一致；无private路径构建依赖、无伪造审批、无未关闭必需偏差。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
