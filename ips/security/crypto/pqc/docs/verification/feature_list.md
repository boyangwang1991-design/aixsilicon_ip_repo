# PQC 验证功能列表

### FL.PQC.CFG — 配置空间与档位

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

#### Verification Intent

证明合法配置可 elaboration 且 CAPABILITY 与实现一致，非法配置被拒绝。

#### Verification Objects

- `CAPABILITY0`、`CAPABILITY1` 寄存器；
- elaboration 参数检查；
- 命名配置 CFG_TINY / CFG_BALANCED / CFG_THROUGHPUT。

#### Key Risk

- 裁剪后 CAPABILITY 与实际可执行命令不一致；
- 非法参数静默接受。

---

### FL.PQC.APB — APB4 控制接口

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

#### Verification Intent

证明合法读写正确、非法地址返回 pslverr 且无副作用、BUSY 写保护生效。

#### Verification Objects

- `pqc_apb_if` / `pqc_csr`；
- `swwe` 受保护字段；
- pslverr 生成逻辑。

#### Key Risk

- 非法地址被静默接受；
- BUSY 期间写入改变当前命令。

---

### FL.PQC.DMA — AXI4 数据接口

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

#### Verification Intent

证明 burst 不跨 4 KiB、越界在写入前被拒绝、分段与连续输入等价、属性随请求携带。

#### Verification Objects

- `pqc_dma` 地址拆分与范围检查；
- 安全/特权属性字段。

#### Key Risk

- 4 KiB 违规；
- 容量不足导致越界写。

---

### FL.PQC.ENTROPY — 熵接口

<!-- FEATURE_META
id: FL.PQC.ENTROPY
name: entropy_interface
description: valid/ready 握手、health、domain tag、授权策略
priority: must
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.RESET.PQC.CLK.001
design_ref:
- LLD.CDC.PQC.ENTROPY
- LLD.ERR.PQC.RNG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

#### Verification Intent

证明熵请求仅在授权策略下发出、health 异常时停止、tag 与命令匹配。

#### Verification Objects

- entropy 握手与 tag 比较；
- RNG_FAULT 上报路径。

#### Key Risk

- health 异常后继续消费随机数。

---

### FL.PQC.SIDEBAND — 旁带与中断接口

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

#### Verification Intent

证明五类中断可独立置位/屏蔽/清除/测试，tamper 与 zeroize_req 触发安全行为。

#### Verification Objects

- `INTR_STATE`/`INTR_ENABLE`/`INTR_TEST`；
- `ALERT_RECOVERABLE`/`ALERT_FATAL`；
- 异步输入同步化。

#### Key Risk

- W1C 与 HW set 同拍丢事件；
- tamper 未触发锁定。

---

### FL.PQC.CLKRESET — 时钟与复位接口

<!-- FEATURE_META
id: FL.PQC.CLKRESET
name: clock_reset_interface
description: 单时钟域、低有效异步复位、复位释放行为
priority: must
req_ref:
- LRS.INTF.PQC.CLKRESET.001
- LRS.RESET.PQC.CLK.001
design_ref:
- LLD.RST.PQC.MAIN
applicability:
  expr: 'true'
proof_methods:
- static
- simulation
END_FEATURE_META -->

#### Verification Intent

证明单时钟域、复位极性正确、复位后进入 DISABLED。

#### Verification Objects

- `rst_n` / `clk`；
- 复位同步器。

#### Key Risk

- 未声明跨时钟路径。

---

### FL.PQC.CMD — 命令集合与语义

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

#### Verification Intent

证明命令集合完整、非法参数在访问秘密前终止、BUSY 锁定、完成写序正确、abort 安全收尾。

#### Verification Objects

- descriptor shadow 与校验链；
- 顶层 FSM；
- completion 发布顺序。

#### Key Risk

- 部分结果在 COMMIT 前可见；
- 非法参数进入执行阶段。

---

### FL.PQC.REG — 寄存器能力与字段行为

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

#### Verification Intent

证明复位值正确、RO/W1C 属性正确、tag 原样回写、错误类别不含秘密信息。

#### Verification Objects

- 全部 26 个 `LLD_REG_META` 对象；
- `pqc_csr` 生成 RTL。

#### Key Risk

- RW 字段复位后为 X；
- 错误码泄露 KEM 有效性。

---

### FL.PQC.PERF — 性能需求

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

#### Verification Intent

证明公开重叠存在、无算法级软件回退、性能计数器可用且不泄露秘密事件。

#### Verification Objects

- PERF 计数器；
- cycle model 与 RTL 测量对比。

#### Key Risk

- 计数器暴露签名尝试次数。

---

### FL.PQC.RESET — 复位与安全收尾

<!-- FEATURE_META
id: FL.PQC.RESET
name: reset_and_safe_shutdown
description: 冷复位自检门控、warm reset key 保持、故障统一收尾、掉电收尾
priority: must
req_ref:
- LRS.RESET.PQC.COLD.001
- LRS.RESET.PQC.WARM.001
- LRS.RESET.PQC.SAFE.001
- LRS.RESET.PQC.POWERDOWN.001
design_ref:
- LLD.RST.PQC.MAIN
- LLD.RST.PQC.WARM
- LLD.RST.PQC.ZEROPATH
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

#### Verification Intent

证明自检成功前拒绝密码命令、warm reset 清除 ephemeral、五类故障进入同一收尾序列。

#### Verification Objects

- 顶层 FSM 复位路径；
- fault_ctrl 汇聚。

#### Key Risk

- 自检失败后仍可执行密码命令。

---

### FL.PQC.CT — 常数时间与访问模式

<!-- FEATURE_META
id: FL.PQC.CT
name: constant_time_security
description: 秘密不控制可观察行为、禁止秘密门控、确定性本地存储
priority: must
req_ref:
- LRS.SEC.PQC.CT.001
- LRS.SEC.PQC.CT.002
- LRS.SEC.PQC.CT.003
- LRS.FUNC.PQC.KEM_DECAPS.002
design_ref:
- LLD.SAFE.PQC.CT_SELECT
- LLD.SAFE.PQC.NO_SECRET_GATING
applicability:
  expr: 'true'
proof_methods:
- formal
- static
END_FEATURE_META -->

#### Verification Intent

形式/静态证明 secret-tainted 信号不控制外部错误码、DMA 地址与授权可见状态，门控仅来自公开状态。

#### Verification Objects

- `pqc_kem_seq` compare/select；
- 全 RTL 门控点。

#### Key Risk

- 比较结果参与地址或错误码生成。

---

### FL.PQC.INTEGRITY — 控制与计数器完整性

<!-- FEATURE_META
id: FL.PQC.INTEGRITY
name: control_integrity
description: 稀疏编码、字段完整性、冗余计数器、verify 双轨
priority: must
req_ref:
- LRS.SEC.PQC.INTEGRITY.001
- LRS.SEC.PQC.VERIFY.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.LOCK.001
design_ref:
- LLD.SAFE.PQC.CTRL_SPARSE
- LLD.SAFE.PQC.COUNTER_PARITY
- LLD.SAFE.PQC.VERIFY_DUAL
applicability:
  expr: 'true'
proof_methods:
- simulation
- formal
END_FEATURE_META -->

#### Verification Intent

证明单点翻转可被检测并进入锁定、verify 判定不因单点故障翻转、zeroize 有界完成。

#### Verification Objects

- fault_ctrl 完整性检查；
- zeroize 计数器。

#### Key Risk

- 非法状态进入 EXECUTE。

---

### FL.PQC.KEY — 密钥槽与权限

<!-- FEATURE_META
id: FL.PQC.KEY
name: key_slot_and_permissions
description: slot 元数据、私钥不可导出、generation 失效、debug/lifecycle 约束
priority: must
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.004
design_ref:
- LLD.REG.PQC.SLOT_CTRL
- LLD.REG.PQC.SLOT_META
- LLD.REG.PQC.SLOT_DESTROY
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

#### Verification Intent

证明元数据校验生效、私钥不可读、stale handle 失败、debug 解锁不开放 key RAM。

#### Verification Objects

- `pqc_key_slots`；
- KEY_SLOT_CTRL/META 窗口。

#### Key Risk

- 私钥经普通读路径泄露；
- 并发 destroy 破坏执行中操作。

---

### FL.PQC.DFX — 可测性与可观测性

<!-- FEATURE_META
id: FL.PQC.DFX
name: dfx_observability
description: scan 排除、MBIST 安全、受限 debug、故障注入、性能计数
priority: must
req_ref:
- LRS.DFX.PQC.SCAN.001
- LRS.DFX.PQC.MBIST.001
- LRS.DFX.PQC.DEBUG.001
- LRS.DFX.PQC.FI.001
- LRS.DFX.PQC.PERFCNT.001
design_ref:
- HLD.SAFETY.PQC.DFXTEST
applicability:
  expr: 'true'
proof_methods:
- static
- review
END_FEATURE_META -->

#### Verification Intent

证明秘密不进 scan chain、MBIST 前后清零、trace 只含公开对象、公开路径注错可触发检测。

#### Verification Objects

- scan 排除清单；
- debug 可观察信号清单；
- 故障注入端口。

#### Key Risk

- 秘密对象进入 trace。

---

### FL.PQC.CONS — 集成与交付约束

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

#### Verification Intent

证明 RTL 为可综合 SV、core 可解析、RDL 为唯一寄存器源、交付件齐全、API 语义不含 oracle。

#### Verification Objects

- FuseSoC core；
- filelist；
- 交付清单。

#### Key Risk

- 派生寄存器文件被手工修改。

---

### FL.PQC.ALGO — 算法正确性（软件证明）

<!-- FEATURE_META
id: FL.PQC.ALGO
name: algorithm_correctness
description: 六参数集 KEM/DSA 完整算法的字节级正确性与负向行为
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

#### Verification Intent

以可执行软件证明验证六个标准参数集的算法级正确性、隐式拒绝与拒绝采样行为。

#### Verification Objects

- `pqc_accel_model` Python 参考模型；
- 独立算法实现交叉验证。

#### Key Risk

- 隐式拒绝存在 oracle；
- 拒绝轮次输出部分签名。