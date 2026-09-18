# PQC 验证功能：完整计算与性能

每个 feature 的 req_ref 是需求归属；通过依据必须来自对应 testcase/assertion 的实际执行，覆盖率不是正确性证明。

## FL.PQC.PERF

<!-- FEATURE_META
id: FL.PQC.PERF
name: performance_requirements
description: 重叠、无软件回退、延迟目标、Sign bubble、cycle model
priority: must
req_ref:
- LRS.PERF.PQC.OVERLAP.001
- LRS.PERF.PQC.NOSW.001
- LRS.PERF.PQC.LATENCY.001
- LRS.PERF.PQC.SIGNBUBBLE.001
- LRS.PERF.PQC.MODEL.001
design_ref:
- HLD.PERF.PQC.KEM768
- LLD.PPA.PQC.POLY
applicability:
  expr: 'true'
proof_methods:
- performance
- review
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.ALGO

<!-- FEATURE_META
id: FL.PQC.ALGO
name: algorithm_correctness
description: 六参数集真实 RTL 完整计算输出与独立 DV oracle 逐字节比较；含编码、负向与流式消息
priority: must
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.001
- LRS.FUNC.PQC.KEM_LEN.001
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.FUNC.PQC.DSA_SIGN.002
- LRS.FUNC.PQC.DSA_SIGN.003
- LRS.FUNC.PQC.DSA_VERIFY.001
- LRS.FUNC.PQC.DSA_MU.001
- LRS.FUNC.PQC.DSA_MESSAGE.001
design_ref:
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DSASEQ
applicability:
  expr: 'true'
proof_methods:
- simulation
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。


## 验证意图与风险

ALGO观察真实公钥/密文/秘密/签名及Verify；覆盖编码端序、重加密、J拒绝输出、域分离、拒绝尝试和流式消息。主要风险是两端同源错误或只看完成；必须与独立冻结KAT逐字节比对。
PERF观察真实接受/退休时间与公开PERF；风险是忽略内部等待、错误换算频率或泄露秘密事件。以当前LRS阈值检查，物理PPA另按已有范围。
