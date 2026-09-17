# PQC 加速器逻辑详细设计：复位、CDC、错误、中断与安全机制

## 复位

### LLD.RST.PQC.MAIN

<!-- LLD_RESET_META
id: LLD.RST.PQC.MAIN
module_ref: LLD.MOD.PQC.TOP
reset_domain: HLD.DOM.RST.PQC.MAIN
type: async_low
synchronizer: 2FF 同步释放
scope: TOP 负责 reset 同步释放与分发；模块数据清除按各自 FSM 执行
notes: 控制 valid 异步清除、同步释放；SRAM 不推导异步全阵列复位。FE 保持 DISABLED，所有擦除完成后由 enable 触发 SELFTEST。
req_ref:
- LRS.INTF.PQC.CLKRESET.001
- LRS.RESET.PQC.COLD.001
applicability:
  expr: 'true'
END_LLD_RESET_META -->

### LLD.RST.PQC.WARM

<!-- LLD_RESET_META
id: LLD.RST.PQC.WARM
module_ref: LLD.MOD.PQC.FAULT
reset_domain: HLD.DOM.RST.PQC.MAIN
type: warm
synchronizer: 复用主复位同步器
scope: 所有工作材料、流水/随机数、ephemeral slot；persistent 仅指授权元数据
notes: warm reset 无条件清除内部 Key RAM 材料和所有临时值；外部策略只决定 persistent slot 元数据保持。重新使用仍须 Key Manager 重新授权/导入。
req_ref:
- LRS.RESET.PQC.WARM.001
applicability:
  expr: 'true'
END_LLD_RESET_META -->

### LLD.RST.PQC.ZEROPATH

<!-- LLD_RESET_META
id: LLD.RST.PQC.ZEROPATH
module_ref: LLD.MOD.PQC.FAULT
reset_domain: HLD.DOM.RST.PQC.MAIN
type: functional_clear
synchronizer: n/a（独立同步路径，不依赖主 FSM）
scope: 双域 SRAM/Key RAM、Keccak 两 context、全部 gadget/转换/采样寄存器、随机 cache、staging 和待响应流水
notes: 由 zeroize_req 或 fatal 事件触发；使用独立计数器，有界完成，从任意状态均可
  进入。
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
- LRS.RESET.PQC.SAFE.001
applicability:
  expr: 'true'
END_LLD_RESET_META -->

## CDC

### LLD.CDC.PQC.SIDEBAND

<!-- LLD_CDC_META
id: LLD.CDC.PQC.SIDEBAND
module_ref: LLD.MOD.PQC.TOP
source_domain: async_external
destination_domain: HLD.DOM.CLK.PQC.CORE
information_type: level
implementation: 2FF synchronizer per bit; zeroize_req 另走独立同步路径
notes: lifecycle/tamper 为电平信号，同步化后参与布尔汇聚；zeroize_req 不得经过主 FSM。
req_ref:
- LRS.INTF.PQC.SIDEBAND.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
END_LLD_CDC_META -->

### LLD.CDC.PQC.ENTROPY

<!-- LLD_CDC_META
id: LLD.CDC.PQC.ENTROPY
module_ref: LLD.MOD.PQC.TOP
source_domain: HLD.DOM.CLK.PQC.CORE
destination_domain: HLD.DOM.CLK.PQC.CORE
information_type: stream
implementation: 核心时钟域内 valid/ready + domain tag 检查，跨域完整 stream CDC 由 SoC 负责
notes: entropy_data/valid/tag 必须在核心时钟域同时稳定；异步源必须在 SoC 边界使用
  完整异步 FIFO/握手桥，不能只同步 valid 或按 bit 同步随机数据。
req_ref:
- LRS.INTF.PQC.ENTROPY.001
applicability:
  expr: 'true'
END_LLD_CDC_META -->

## 错误处理

### LLD.ERR.PQC.CONFIG

<!-- LLD_ERROR_META
id: LLD.ERR.PQC.CONFIG
detection: descriptor 校验失败（opcode/参数集/ABI/reserved/CRC/对齐/长度/capability/权限）
response: 在任何秘密访问前终止，返回 CONFIG_ERROR
propagation: completion status + ERROR_CODE
recovery: 命令级恢复，回到 IDLE，可重新提交
req_ref:
- LRS.FUNC.PQC.CMD.003
- LRS.FUNC.PQC.CMD.005
END_LLD_ERROR_META -->

### LLD.ERR.PQC.DMA

<!-- LLD_ERROR_META
id: LLD.ERR.PQC.DMA
detection: AXI 响应错误、超时、4 KiB 违规尝试、容量越界
response: 终止命令，进入统一安全收尾；已写数据不得作为有效输出使用
propagation: completion status + DMA_ERROR + ALERT
recovery: 清零后回到 IDLE
req_ref:
- LRS.RESET.PQC.SAFE.001
- LRS.SEC.PQC.SLOT.005
END_LLD_ERROR_META -->

### LLD.ERR.PQC.RNG

<!-- LLD_ERROR_META
id: LLD.ERR.PQC.RNG
detection: entropy valid 长时间无效、health 异常、domain tag 不匹配
response: 停止命令并清零，不降级为常数或重复随机数
propagation: RNG_FAULT 中断 + completion status
recovery: 熵恢复后重新提交
req_ref:
- LRS.INTF.PQC.ENTROPY.001
END_LLD_ERROR_META -->

### LLD.ERR.PQC.SELFTEST

<!-- LLD_ERROR_META
id: LLD.ERR.PQC.SELFTEST
detection: 上电/按需 KAT 结果不匹配
response: 进入 LOCKED，拒绝密码命令
propagation: SELF_TEST_FAIL 中断 + ALERT_FATAL
recovery: 需显式恢复流程
req_ref:
- LRS.RESET.PQC.COLD.001
END_LLD_ERROR_META -->

### LLD.ERR.PQC.INTERNAL

<!-- LLD_ERROR_META
id: LLD.ERR.PQC.INTERNAL
detection: page tag mismatch、representation 混用、ECC UE、retry exhausted
response: fatal 内部错误，清除候选值，进入安全收尾
propagation: completion status=FATAL 或 INTERNAL_RETRY_EXHAUSTED
recovery: 清零后回到 IDLE（retry exhausted）或 LOCKED（完整性错误）
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
- LRS.SEC.PQC.INTEGRITY.001
END_LLD_ERROR_META -->

## 中断

### LLD.IRQ.PQC.DONE

<!-- LLD_IRQ_META
id: LLD.IRQ.PQC.DONE
module_ref: LLD.MOD.PQC.APB
source: completion 发布完成
trigger: completion record 写入且 DMA 输出完成
level_or_pulse: level
clear: W1C on INTR_STATE
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_IRQ_META -->

### LLD.IRQ.PQC.ERROR

<!-- LLD_IRQ_META
id: LLD.IRQ.PQC.ERROR
module_ref: LLD.MOD.PQC.APB
source: LLD.ERR.PQC.CONFIG / DMA / INTERNAL
trigger: 错误完成
level_or_pulse: level
clear: W1C on INTR_STATE
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_IRQ_META -->

### LLD.IRQ.PQC.RNG

<!-- LLD_IRQ_META
id: LLD.IRQ.PQC.RNG
module_ref: LLD.MOD.PQC.APB
source: LLD.ERR.PQC.RNG
trigger: 熵 health 异常
level_or_pulse: level
clear: W1C on INTR_STATE
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_IRQ_META -->

### LLD.IRQ.PQC.TAMPER

<!-- LLD_IRQ_META
id: LLD.IRQ.PQC.TAMPER
module_ref: LLD.MOD.PQC.APB
source: tamper 输入同步化后置位
trigger: tamper 电平有效
level_or_pulse: level
clear: W1C on INTR_STATE
req_ref:
- LRS.INTF.PQC.SIDEBAND.001
END_LLD_IRQ_META -->

### LLD.IRQ.PQC.SELFTEST

<!-- LLD_IRQ_META
id: LLD.IRQ.PQC.SELFTEST
module_ref: LLD.MOD.PQC.APB
source: LLD.ERR.PQC.SELFTEST
trigger: KAT 失败
level_or_pulse: level
clear: W1C on INTR_STATE
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_IRQ_META -->

## 全局对象的所有权与本地实现边界

TOP 只生成和分发复位/异步旁带同步结果；FAULT 汇聚独立清除请求与完成应答。
上面的 reset 对象不能替代各模块的逐寄存器清除时序。APB/CSR 持有中断 pending，
事件源来自 FE/FAULT/TOP；同拍 W1C 与新事件采用置位优先。屏蔽只影响 IRQ 输出，
不得丢弃 pending 或阻止故障清除。连续 tamper 电平应在清除后重新置位。

核心 reset 同步器的两个寄存器异步置零；同步释放需要两个核心时钟沿。异步输入的
单 bit 持续电平可用两级同步，必须由系统保证最小保持时间；多 bit 生命周期编码
不能直接逐位采样成授权，必须在稳定窗口或 SoC 提供的原子握手后锁存并校验编码。
任何未确认/非法生命周期编码采用关闭权限。entropy stream 本身不跨本 IP 时钟域。

## 计算引擎取消沿

KECCAK、POLY、CODEC、SAMPLER 和 DSA 的内部 ready/valid/request/write/commit/done
在 `!rst_n || zeroize_req` 时组合关闭；不能等待下一沿修改 FSM 才撤销待提交副作用。
存储清除仍按各模块的数据状态完成，接口关闭本身不能当作清除应答。
外部 AXI 已展示事务按 DMA/读仲裁合同继续排空，不使用本条撤回总线 valid。
