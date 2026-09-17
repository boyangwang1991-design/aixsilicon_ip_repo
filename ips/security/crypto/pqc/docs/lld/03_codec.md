# PQC CODEC 微架构（恢复中）

### LLD.MOD.PQC.CODEC

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.CODEC
name: pqc_codec
parent_ref: HLD.MOD.PQC.CODEC
hld_ref:
- HLD.MOD.PQC.CODEC
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_VERIFY.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_codec
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

#### Responsibility

bit pack/unpack、Compress/Decompress、Power2Round/HighBits/LowBits/MakeHint/UseHint、
norm check（OR-reduce 全遍历）。

---
