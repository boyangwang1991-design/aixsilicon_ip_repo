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

## 故障归并的可综合语义

故障输入使用普通OR归并。不得在可综合逻辑中以`=== 1'bx`识别或吞掉未知值，
否则仿真与综合的don't-care优化语义可能不同。仿真未知值须在其产生源复位/valid
边界修复；已知故障为1时必须主导其他输入。CDC/RDC与未知值诊断不靠过滤故障实现。
