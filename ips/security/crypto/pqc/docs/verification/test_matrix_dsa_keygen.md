# DSA KeyGen 和专用托管增量

<!-- TESTCASE_META
id: TC.PQC.DSA.KEYGEN.MAIN.001
name: tc_dsa_keygen_main
type: directed
description: 三参数集真实KeyGen、公钥DMA、私钥专用托管和确认退休
priority: must
tier: regression
implementation: verification/tc/tc_dsa_keygen_main.sv
proof_kind: uvm
feature_ref: [FL.PQC.ALGO]
design_ref: [LLD.MOD.PQC.DSASEQ.KEYGEN, LLD.MOD.PQC.WORKKEY.CUSTODY]
preconditions:
- 固定源码及离线dilithium-py 1.4.0向量，SCA_LEVEL小于2，真实RTL原语
stimulus:
- 每参数集三组独立xi，32B健康且tag匹配的熵经专用接口输入
- 托管头/word背压，先错误transaction ACK，再延迟匹配成功ACK
- 公钥/句柄/完成DMA背压、延迟B响应
expected_result:
- 九组公钥和私钥所有字节等于独立冻结向量；私钥仅专用托管口可观察
- 头与数据背压保持，错误ACK不能提交，成功ACK前没有公开输出
- 公钥B响应先于句柄，句柄B响应先于completion，completion B响应先于IRQ
- 所有输出恰好一次，guard不变，completion全字段正确
- 九个case和最终完成标记均存在；超时/零比较失败
config_ref: [CFGSET.PQC.DEFAULT]
applicability:
  expr: 'SCA_LEVEL < 2'
timeout_policy: 2000000 cycles per command; 600 s process watchdog
END_TESTCASE_META -->

