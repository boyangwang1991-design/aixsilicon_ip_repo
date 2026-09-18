# PQC 验证覆盖率计划

## 覆盖率目标

| 类别 | 目标 | 依据 |
|---|---|---|
| 需求覆盖率 | 100% | 全部 84 条 LRS 需求均有 feature 承接 |
| 功能覆盖率 | 100%（批准的不可达项除外） | 本计划 coverpoints |
| RTL line coverage | >= 95% | LRS §11.4 |
| RTL toggle coverage | >= 95% | LRS §11.4 |
| RTL branch coverage | >= 95% | LRS §11.4 |
| RTL FSM coverage | >= 95% | LRS §11.4 |
| 安全关键 FSM 与 error path | 100% | LRS §11.4 |

覆盖率只证明"场景是否触达"；行为正确性由 UVM checker/assertion/formal 承担。

---

### COV.PQC.CMD.001 命令与状态

<!-- COVERAGE_META
id: COV.PQC.CMD.001
name: cov_command_states
type: functional
description: 覆盖八个 opcode、顶层 FSM 全部状态与合法/非法组合
feature_ref:
- FL.PQC.CMD
design_ref:
- LLD.FSM.PQC.TOP.MAIN
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- opcode 全部取值（含保留值）；
- FSM 状态 IDLE/VALIDATE/FETCH/EXECUTE/COMMIT/COMPLETE/ZEROIZE/LOCKED；
- 校验失败在访问秘密前终止的组合。

---

### COV.PQC.APB.001 总线访问

<!-- COVERAGE_META
id: COV.PQC.APB.001
name: cov_apb_access
type: functional
description: 覆盖读写、字节使能、非法地址与 BUSY 写保护
feature_ref:
- FL.PQC.APB
design_ref:
- LLD.IF.PQC.FE.APB
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- 读/写；
- pstrb 各字节组合；
- 未映射地址；
- BUSY 期间写受保护字段。

---

### COV.PQC.REG.001 寄存器属性

<!-- COVERAGE_META
id: COV.PQC.REG.001
name: cov_register_attrs
type: functional
description: 覆盖 RO/W1C/BUSY 锁定字段的访问组合
feature_ref:
- FL.PQC.REG
design_ref:
- LLD.REG.PQC.INTR_STATE
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- RO 读 + 写（无副作用）；
- W1C 各位置位与清除；
- 复位后读回。

---

### COV.PQC.CT.001 常数时间路径

<!-- COVERAGE_META
id: COV.PQC.CT.001
name: cov_constant_time
type: functional
description: 覆盖 KEM 合法/非法密文、Sign 拒绝 0/1/多次
feature_ref:
- FL.PQC.CT
design_ref:
- LLD.SAFE.PQC.CT_SELECT
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- Decaps 合法与非法密文；
- Sign attempt 拒绝 0 次、1 次、多次；
- 达到 attempt 上限（retry exhausted）。

---

### COV.PQC.KEY.001 密钥权限

<!-- COVERAGE_META
id: COV.PQC.KEY.001
name: cov_key_permission
type: functional
description: 覆盖特权/非特权、有效/失效 handle、destroy/lifecycle
feature_ref:
- FL.PQC.KEY
design_ref:
- LLD.REG.PQC.SLOT_CTRL
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- 特权与非特权访问；
- 有效/失效 generation；
- 类型与 usage 不匹配；
- destroy 与 lifecycle 变化。

---

### COV.PQC.DMA.001 DMA 边界

<!-- COVERAGE_META
id: COV.PQC.DMA.001
name: cov_dma_boundary
type: functional
description: 覆盖 4 KiB 拆分、尾部不满 beat、错误响应
feature_ref:
- FL.PQC.DMA
design_ref:
- LLD.TIMING.PQC.DMA.SPLIT
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- 起点/长度组合跨与不跨 4 KiB；
- 尾部 keep；
- AXI 错误响应；
- 分段与连续等价。

---

### COV.PQC.RESET.001 故障与零化

<!-- COVERAGE_META
id: COV.PQC.RESET.001
name: cov_fault_zeroize
type: functional
description: 覆盖五类故障源与零化完成
feature_ref:
- FL.PQC.RESET
design_ref:
- LLD.RST.PQC.ZEROPATH
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- tamper / fatal ECC / self-test fail / lifecycle / DMA error / timeout / RNG；
- 从各 FSM 状态发起 zeroize；
- 零化完成与 locked。

---

### COV.PQC.INTEGRITY.001 完整性异常

<!-- COVERAGE_META
id: COV.PQC.INTEGRITY.001
name: cov_integrity
type: functional
description: 覆盖非法状态编码与计数器奇偶错误
feature_ref:
- FL.PQC.INTEGRITY
design_ref:
- LLD.SAFE.PQC.CTRL_SPARSE
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- 单 bit 与多 bit 状态损坏；
- 计数器奇偶错误；
- 检测后进入 ZEROIZE。

---

## 代码覆盖率

### COV.PQC.CODE.001 RTL 结构覆盖

<!-- COVERAGE_META
id: COV.PQC.CODE.001
name: cov_rtl_structural
type: code
description: line/toggle/branch/FSM 覆盖率收集与门限
feature_ref:
- FL.PQC.CONS
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverage Intent

对全 DUT 收集 line/toggle/branch/FSM 覆盖率，安全关键 FSM 与 error path 要求 100%。
不用手写 RTL 覆盖率替代全 DUT 覆盖。

## 配置覆盖率

### COV.PQC.CFG.001 配置空间覆盖

<!-- COVERAGE_META
id: COV.PQC.CFG.001
name: cov_config_space
type: functional
description: 覆盖三档命名配置与参数边界
feature_ref:
- FL.PQC.CFG
applicability:
  expr: 'true'
END_COVERAGE_META -->

#### Coverpoints

- CFG_TINY / CFG_BALANCED / CFG_THROUGHPUT；
- 每个参数的 MIN/MAX 边界。

## 采样与分母

功能 bins 从实际接受/完成的 monitor 事务采样，不能在 sequence 随机生成时计为覆盖。
每 bin 记录 testcase/config/seed/vector 和检查结果；失败回归的数据可供调试，不算
通过需求的证据。跨配置覆盖分别报告合法分母及命中，不把 elaboration 算功能命中。
当前没有批准的排除或 waiver。line/branch/toggle/FSM 分母分开，全 DUT（含 CSR）
纳入；安全关键状态/转换及错误恢复必须100%。断言报告激活及 vacuous，目标为所有
必需属性至少一次有效激活、零失败；不能把静默或未编译 SVA 算 assertion100%。

代码覆盖开关、功能 covergroup、SVA 编译和 URG 导出/merge 命令进入 manifest。
不同参数 elaboration 不直接合并 VDB；缺工具报告为 unavailable，不能填0或100。
完整结果由15 owner生成，绑定full regression JUnit与原始数据库，最后16生成closure RTM。
