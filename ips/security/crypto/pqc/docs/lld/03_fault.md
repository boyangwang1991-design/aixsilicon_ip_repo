# PQC FAULT 微架构（恢复中）

### LLD.MOD.PQC.FAULT

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.FAULT
name: pqc_fault_ctrl
parent_ref: HLD.MOD.PQC.FAULT
hld_ref:
- HLD.MOD.PQC.FAULT
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.LOCK.001
- LRS.RESET.PQC.SAFE.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_fault_ctrl
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

#### Responsibility

异步请求汇聚、同步化、独立 zeroize 计数器与完成信号、lock 状态、冗余/奇偶校验检查。

---
