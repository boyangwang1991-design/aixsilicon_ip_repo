# ML-DSA Verify 集成验证增量

<!-- TESTCASE_META
id: TC.PQC.DSA.VERIFY.MAIN.001
name: tc_dsa_verify_main
type: directed
description: pure ML-DSA 三参数集独立向量、长消息DMA和验签负向结果
priority: must
tier: regression
implementation: verification/tc/tc_dsa_verify_main.sv
proof_kind: uvm
feature_ref: [FL.PQC.ALGO]
design_ref: [LLD.MOD.PQC.DSASEQ.VERIFY]
preconditions:
- 离线冻结dilithium-py 1.4.0向量与固定RTL源码，SCA_LEVEL小于2
stimulus:
- 每参数集三组密钥及签名，message长度0/137/65537，context长度0/1/255
- 每组正常签名及挑战、z范数、hint边界、公钥、message、context六类篡改
- AXI读写背压和延迟B响应，实际输入DMA和片内消息哈希
expected_result:
- 九组正常验签成功，五十四组篡改返回VERIFY_INVALID而非operation error
- 所有读取限于公开描述符、pk及signature、message、context对应范围
- 唯一输出为完整32B completion，每字节一次且字段匹配，guard不变
- completion B响应先于IRQ，RESULT保持verify_done及对应verify_valid
- 六十三个case完成标记及最终标记齐全，超时或缺失比较失败
config_ref: [CFGSET.PQC.DEFAULT]
applicability:
  expr: 'SCA_LEVEL < 2'
timeout_policy: 10000000 cycles per command; 1200 s process watchdog
END_TESTCASE_META -->

该增量不关闭Sign、HashML-DSA、Level2、故障组合与正式覆盖率义务。
