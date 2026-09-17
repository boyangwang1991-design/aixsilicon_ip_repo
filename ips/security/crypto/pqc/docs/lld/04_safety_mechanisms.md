# PQC 全局安全机制

## 安全机制

### LLD.SAFE.PQC.CT_SELECT

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.CT_SELECT
mechanism: constant_time_compare_select
protects:
- shared_secret_output
detection: n/a（防护性机制）
response: 全长度 OR 累积比较 + 全位宽 mask select；mask 仅来自比较结果，不控制调度
req_ref:
- LRS.FUNC.PQC.KEM_DECAPS.002
- LRS.SEC.PQC.CT.001
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x7'
END_LLD_SAFETY_META -->

### LLD.SAFE.PQC.VERIFY_DUAL

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.VERIFY_DUAL
mechanism: redundant_comparison
protects:
- dsa_verify_result
detection: 两路比较结果不一致时判定为故障
response: 不一致时置 fatal 并拒绝输出 valid（fail-closed）
req_ref:
- LRS.SEC.PQC.VERIFY.001
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x38'
END_LLD_SAFETY_META -->

### LLD.SAFE.PQC.CTRL_SPARSE

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.CTRL_SPARSE
mechanism: sparse_redundant_encoding
protects:
- control_fsm
- opcode_param_keytype_perm
detection: 非法/多热编码检测
response: 强制进入 ZEROIZE 并置 fatal；绝不进入 EXECUTE
req_ref:
- LRS.SEC.PQC.INTEGRITY.001
applicability:
  expr: 'true'
END_LLD_SAFETY_META -->

### LLD.SAFE.PQC.COUNTER_PARITY

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.COUNTER_PARITY
mechanism: parity_check
protects:
- loop_counter
- ntt_stage
- dma_length
- micro_pc
detection: 奇偶不匹配
response: 终止命令并进入安全收尾
req_ref:
- LRS.SEC.PQC.INTEGRITY.001
applicability:
  expr: 'true'
END_LLD_SAFETY_META -->

### LLD.SAFE.PQC.ECC

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.ECC
mechanism: secded_ecc
protects:
- working_sram
detection: 单比特（可纠正）与双比特（不可纠正）错误
response: SEC 可纠正并记录；DED 不可纠正，进入 fatal 安全收尾，禁止消费损坏数据
req_ref:
- LRS.RESET.PQC.SAFE.001
- LRS.DFX.PQC.MBIST.001
applicability:
  expr: 'true'
END_LLD_SAFETY_META -->

### LLD.SAFE.PQC.NO_SECRET_GATING

<!-- LLD_SAFETY_META
id: LLD.SAFE.PQC.NO_SECRET_GATING
mechanism: static_gating_policy
protects:
- whole_datapath
detection: 静态检查确认门控使能仅来自公开状态
response: 违规视为设计缺陷，阻塞 G3
req_ref:
- LRS.SEC.PQC.CT.002
applicability:
  expr: 'true'
END_LLD_SAFETY_META -->




