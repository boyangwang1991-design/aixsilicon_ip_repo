# PQC 加速器逻辑详细设计：FSM、数据通路与流水

## 数据通路



### LLD.DP.PQC.CODEC.BITPACK

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.CODEC.BITPACK
module_ref: LLD.MOD.PQC.CODEC
width: 32
operators:
- pack
- unpack
- compress
- decompress
- power2round
- decompose
- make_hint
- use_hint
- norm_check
representation: PACKED_to_COEFF_STD
notes: 任意 bit offset 的 little-endian bit packing；解码输出 canonical_ok 但始终
  消费配置长度；norm check 遍历全部系数并 OR-reduce violation，不在首个违例处停止。
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_VERIFY.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 流水线



## 缓冲与 FIFO

### LLD.BUF.PQC.SAMPLER.SQZ

<!-- LLD_BUFFER_META
id: LLD.BUF.PQC.SAMPLER.SQZ
module_ref: LLD.MOD.PQC.SAMPLER
type: fifo
depth: 64
width: 64
purpose: 吸收 Keccak squeeze 抖动，支持自动续块
overflow_policy: 反压 Keccak，不丢弃字节
underflow_policy: 等待 squeeze，不返回占位数据
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
applicability:
  expr: 'true'
END_LLD_BUFFER_META -->

### LLD.BUF.PQC.DSASEQ.STAGE

<!-- LLD_BUFFER_META
id: LLD.BUF.PQC.DSASEQ.STAGE
module_ref: LLD.MOD.PQC.DSASEQ
type: staging_buffer
depth: 4627
width: 8
purpose: 候选签名的不可见 staging，全部检查通过后一次性 commit
overflow_policy: 超过最大签名长度视为内部错误并在 commit 前终止
underflow_policy: n/a
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x38'
END_LLD_BUFFER_META -->

### LLD.BUF.PQC.FE.DESC

<!-- LLD_BUFFER_META
id: LLD.BUF.PQC.FE.DESC
module_ref: LLD.MOD.PQC.FE
type: register_shadow
depth: 128
width: 8
purpose: descriptor 原子抓取 shadow，保证抓取后软件内存修改不影响当前命令
overflow_policy: n/a（定长）
underflow_policy: n/a
req_ref:
- LRS.FUNC.PQC.CMD.002
applicability:
  expr: 'true'
END_LLD_BUFFER_META -->

## 仲裁

### LLD.ARB.PQC.SRAM.BANK

<!-- LLD_ARB_META
id: LLD.ARB.PQC.SRAM.BANK
module_ref: LLD.MOD.PQC.SRAM
policy: static_reservation_then_round_robin
ports: 3
fairness_required: false
notes: POLY 的六 slot 调度先预留读写 bank；剩余端口由公开请求 round-robin 仲裁，
  grant_ack 仅对应真实接受。DMA 和 ECC scrub 不抢占预留端口；同地址读写禁止同拍接受。
  向量访问组、返回 credit 与双域原子授权见 03_sram.md；仲裁不检查系数值。
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.SEC.PQC.CT.001
applicability:
  expr: 'true'
END_LLD_ARB_META -->

### LLD.ARB.PQC.PRIM.SCOREBOARD

<!-- LLD_ARB_META
id: LLD.ARB.PQC.PRIM.SCOREBOARD
module_ref: LLD.MOD.PQC.KEMSEQ
policy: static_dependency_token
ports: 4
fairness_required: false
notes: 管理 KECCAK/NTT/SAMPLER_CODEC/DMA 四类资源；仅允许静态白名单内的重叠。
req_ref:
- LRS.PERF.PQC.OVERLAP.001
applicability:
  expr: 'true'
END_LLD_ARB_META -->

## 定序与背压

### LLD.ORDER.PQC.GLOBAL

<!-- LLD_ORDER_META
id: LLD.ORDER.PQC.GLOBAL
model: in_order
notes: 单上下文执行；同一命令内部 primitive 按依赖 token 定序；同一 buffer 的 DMA
  传输保序；不同 buffer 允许 outstanding 但不得重排同一 buffer 的写。
ordering_boundary: per_command_and_per_buffer
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.FUNC.PQC.CMD.006
applicability:
  expr: 'true'
END_LLD_ORDER_META -->

## 时序场景

### LLD.TIMING.PQC.APB.RW

<!-- LLD_TIMING_META
id: LLD.TIMING.PQC.APB.RW
interface_ref: HLD.IF.EXT.PQC.APB
scenario: APB4 单次读/写，含 PREADY 反压
cycles: setup 1 + access 1..N
notes: 写 BUSY 锁定的配置字段时返回 pslverr 且字段值不变；读 reserved 返回 0。
req_ref:
- LRS.INTF.PQC.APB.001
- LRS.FUNC.PQC.CMD.004
applicability:
  expr: 'true'
END_LLD_TIMING_META -->

### LLD.TIMING.PQC.DMA.SPLIT

<!-- LLD_TIMING_META
id: LLD.TIMING.PQC.DMA.SPLIT
interface_ref: HLD.IF.EXT.PQC.DMA
scenario: 跨 4 KiB 边界自动拆分为多个 INCR burst
cycles: 取决于长度与从端反压
notes: 拆分不改变字节顺序；尾部不满 beat 使用 WSTRB/keep 掩码。
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.003
applicability:
  expr: 'true'
END_LLD_TIMING_META -->
