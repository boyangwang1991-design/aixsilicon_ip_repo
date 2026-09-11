# 参数与入口运行合同

TESTCASE_META.param_config指定单次默认实例；configuration_matrix记录需要遍历的实例集合。runner必须展开当前支持矩阵，逐一判断feature可达性、编译身份、测试class和seed；这个自定义列表不能假定通用runner已经消费。参数验证结果按19-PV实际执行格式写入，不把现有PC结构检查或RDL矩阵当作IP RTL执行。

强制配置为CFG_TYPICAL_DIRECT、CFG_TYPICAL_REGISTER、CFG_MAX_DIRECT、CFG_MAX_REGISTER、CFG_MIN_NOFIFO、CFG_MIN_FIFO1、CFG_NONPOWER、CFG_TRIMMED。8个实例均运行复位/APB/权限/CSR；裁剪实例仍运行关闭功能地址错误和正常权限安全检查，不能整体跳过对应feature。75个支持点包含11个负例，负例必须真的在指定阶段拒绝，日志中缺构建/缺许可证不算“参数预期失败”。

非零启动策略采用configs/csr_nonzero_reset_fixture.yaml扩展验证，active/shadow/校验/RAL值均应一致；其余实例不因该夹具改变。随机压力在典型两模式、最大两模式运行10个额外种子，所有强制属性/安全场景必须由定向激励保证可达。

SYSTEM/PPA/DELIVERY三个静态用例使用真实scripts/verification入口和command-proof manifest；文件尚未实现时保持未执行。必须绑定实际依赖、工具版本、退出码和精确成功行。手工评审材料由owner提供真实身份，checker只能检查/消费，不能生成签名。
<!-- CONFIG_COVERAGE_META
id: CCOV.APB_SECURE_DEMUX.SUPPORT
dimensions:
- NUM_PORTS
- NUM_MASTERS
- MASTER_ID_WIDTH
- ADDR_WIDTH
- REGISTER_MODE
- EVENT_FIFO_DEPTH
- OUTPUT_ISOLATION_EN
- POLICY_PARITY_EN
- DFX_EN
- PUBLIC_ID_EN
strategy:
  default: true
  boundary: true
  pairwise: true
  risk_based: true
feature_ref:
- FL.APB_SECURE_DEMUX.PARAM
END_CONFIG_COVERAGE_META -->
