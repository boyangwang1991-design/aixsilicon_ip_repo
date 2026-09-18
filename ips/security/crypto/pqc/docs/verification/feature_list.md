# PQC 验证功能：配置、命令与接口

每个 feature 的 req_ref 是需求归属；通过依据必须来自对应 testcase/assertion 的实际执行，覆盖率不是正确性证明。

## FL.PQC.CFG

<!-- FEATURE_META
id: FL.PQC.CFG
name: configuration_space
description: 综合期参数合法空间、命名配置与跨参数约束
priority: must
req_ref:
- LRS.CFG.PQC.NTT_LANES.001
- LRS.CFG.PQC.KECCAK_ROUNDS.001
- LRS.CFG.PQC.LOCAL_SRAM.001
- LRS.CFG.PQC.DMA_WIDTH.001
- LRS.CFG.PQC.KEY_SLOT.001
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.CFG.PQC.ALGO_MASK.001
- LRS.CFG.PQC.FEATURE_FLAGS.001
- LRS.CFG.PQC.EXEC_MODE.001
design_ref:
- HLD.CFG.PQC.NTT_LANES
- HLD.CFG.PQC.KECCAK_ROUNDS
- HLD.CFG.PQC.LOCAL_SRAM
- HLD.CFG.PQC.DMA_WIDTH
- HLD.CFG.PQC.SCA
- HLD.CFG.PQC.ALGO_MASK
applicability:
  expr: 'true'
proof_methods:
- simulation
- static
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.APB

<!-- FEATURE_META
id: FL.PQC.APB
name: apb_control_interface
description: APB4 寄存器读写、未映射地址 pslverr、reserved 语义
priority: must
req_ref:
- LRS.INTF.PQC.APB.001
- LRS.FUNC.PQC.CMD.004
design_ref:
- LLD.IF.PQC.FE.APB
- LLD.TIMING.PQC.APB.RW
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.DMA

<!-- FEATURE_META
id: FL.PQC.DMA
name: axi4_data_interface
description: INCR burst、4 KiB 边界、范围检查、分段等价
priority: must
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.002
- LRS.INTF.PQC.DMA.003
- LRS.SEC.PQC.SLOT.005
design_ref:
- LLD.IF.PQC.DMA.AXI
- LLD.TIMING.PQC.DMA.SPLIT
- LLD.ERR.PQC.DMA
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.SIDEBAND

<!-- FEATURE_META
id: FL.PQC.SIDEBAND
name: sideband_security_interface
description: lifecycle/tamper/zeroize 输入与五类中断输出
priority: must
req_ref:
- LRS.INTF.PQC.SIDEBAND.001
- LRS.REG.PQC.INTR.001
- LRS.REG.PQC.ALERT.001
- LRS.INTF.PQC.CLKRESET.001
design_ref:
- LLD.CDC.PQC.SIDEBAND
- LLD.IRQ.PQC.DONE
- LLD.IRQ.PQC.TAMPER
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.CMD

<!-- FEATURE_META
id: FL.PQC.CMD
name: command_semantics
description: 八类 opcode、descriptor 校验、BUSY 锁定、completion 写序、abort
priority: must
req_ref:
- LRS.FUNC.PQC.CMD.001
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.003
- LRS.FUNC.PQC.CMD.004
- LRS.FUNC.PQC.CMD.005
- LRS.FUNC.PQC.CMD.006
- LRS.FUNC.PQC.CMD.007
- LRS.FUNC.PQC.CMD.008
design_ref:
- LLD.FSM.PQC.TOP.MAIN
- LLD.BUF.PQC.FE.DESC
- LLD.REG.PQC.DOORBELL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.REG

<!-- FEATURE_META
id: FL.PQC.REG
name: register_capabilities
description: 软件可见能力、字段访问属性、SW/HW 冲突优先序、复位值
priority: must
req_ref:
- LRS.REG.PQC.ID.001
- LRS.REG.PQC.CTRL.001
- LRS.REG.PQC.STATUS.001
- LRS.REG.PQC.RESULT.001
- LRS.REG.PQC.ERRCODE.001
- LRS.REG.PQC.PERF.001
- LRS.REG.PQC.SLOT.001
- LRS.REG.PQC.COMPLETION.001
- LRS.CONS.PQC.REG.001
design_ref:
- LLD.REG.PQC.ID_VERSION
- LLD.REG.PQC.STATUS
- LLD.REG.PQC.RESULT
- LLD.REG.PQC.ERROR_CODE
applicability:
  expr: 'true'
proof_methods:
- simulation
- static
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。

## FL.PQC.CONS

<!-- FEATURE_META
id: FL.PQC.CONS
name: integration_constraints
description: 综合语言、FuseSoC、寄存器 SSOT、常量一致、交付件、驱动 API
priority: must
req_ref:
- LRS.CONS.PQC.LANG.001
- LRS.CONS.PQC.CORE.001
- LRS.CONS.PQC.CONST.001
- LRS.CONS.PQC.DELIVER.001
- LRS.CONS.PQC.API.001
design_ref:
- RTL.PQC.TOP
applicability:
  expr: 'true'
proof_methods:
- static
- review
END_FEATURE_META -->

验证对象由 design_ref 指定；实际刺激、独立预期、观察点、timeout 与 corner cases 见测试矩阵。


## 验证意图与风险

CFG要求合法参数功能等价及裁剪拒绝，不能只elaboration；APB检查全地址/权限/PSTRB/有界响应；DMA检查真实字节、4KiB/尾拍/背压/错误与排空；CMD检查原子快照、忙锁、staging→payload→completion→IRQ；REG检查全部RDL字段及硬件更新竞争；SIDEBAND检查五类中断独立屏蔽/W1C；CONS检查可综合源码、单core、生成来源与交付API。
关键风险为参数默认回退、非法访问挂死、漏尾字节、过早成功、W1C丢事件、静态扫描自证算法正确。各风险由测试矩阵具体刺激及独立checker关闭，不能用覆盖计数替代。
