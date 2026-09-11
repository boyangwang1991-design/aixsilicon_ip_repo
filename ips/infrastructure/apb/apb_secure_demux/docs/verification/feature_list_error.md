# 多错误主原因排序

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.ERROR
name: 多错误主原因排序
description: 多错误主原因排序
priority: must
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.ERRORPRIORITY.008
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.FUNC.APB_SECURE_DEMUX.ERRORPRIORITY.008`：外设主错误按 MULTI_HIT、ADDR_MISS、ID_INVALID、INTEGRITY_BLOCK、PORT_DISABLED、INSTR_DENIED、READ/WRITE_DENIED、DFX_FORCED_DENY 排序；CSR 按授权、对齐、选通、存在性、访问类型、锁、命令、完整性排序。
