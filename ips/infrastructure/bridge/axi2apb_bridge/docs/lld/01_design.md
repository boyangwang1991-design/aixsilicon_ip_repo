# LLD 设计 - X2P 模块微架构

> 本文档是 LLD 文档的一部分，[主索引](index.md)。

---

## 1. 模块总体概述

X2P 由 7 个 L1 微架构模块组成（与 HLD 一一对应）：

| LLD 模块 | HLD 引用 | 时钟域 | 复位域 |
|---|---|---|---|
| LLD.MOD.X2P.FE | HLD.MOD.L1.X2P.FE | clk_axi | rst_axi_n |
| LLD.MOD.X2P.QB | HLD.MOD.L1.X2P.QB | clk_axi | rst_axi_n |
| LLD.MOD.X2P.SCH | HLD.MOD.L1.X2P.SCH | clk_axi | rst_axi_n |
| LLD.MOD.X2P.TE | HLD.MOD.L1.X2P.TE | clk_axi | rst_axi_n |
| LLD.MOD.X2P.CDC | HLD.MOD.L1.X2P.CDC | clk_axi/clk_apb | rst_axi_n/rst_apb_n |
| LLD.MOD.X2P.APB | HLD.MOD.L1.X2P.APB | clk_apb | rst_apb_n |
| LLD.MOD.X2P.RSP | HLD.MOD.L1.X2P.RSP | clk_axi | rst_axi_n |

## 2. 全局设计约束

- **协议**：AXI4/AXI4-Lite（slave）、APB3/APB4（master），参数化裁剪。
- **CDC 约束**：ASYNC 模式跨域仅使用 async FIFO（请求/响应两条路径），
  SYNC 模式 generate-out CDC。
- **Atomicity**：一个 AXI Beat 的 APB sub-transfers 不可切分。
- **复位**：AXI 域 rst_axi_n、APB 域 rst_apb_n 均为低有效异步置位、同步释放。

---

## 3. 模块详细设计

### 3.1 FE AXI Frontend

负责 AXI 通道捕获与协议状态管理。

<!-- LLD_META
module_id: LLD.MOD.X2P.FE
hld_ref: HLD.MOD.L1.X2P.FE
datapath:
  - id: LLD.DP.X2P.FE.CAPTURE
    name: AW/W/AR Capture
    description: 捕获 AW/W/AR 通道数据与元数据，送入队列
  - id: LLD.DP.X2P.FE.RSP_HANDSHAKE
    name: B/R Response Handshake
    description: 管理 B/R 通道 VALID/READY，输出响应
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：
- AW 捕获：AWVALID 且 AWREADY 时捕获 AWID/ADDR/LEN/SIZE/BURST/PROT。
- W 捕获：WVALID 且 WREADY 时捕获 WDATA/WSTRB/WLAST。
- AR 捕获：ARVALID 且 ARREADY 时捕获 ARID/ADDR/LEN/SIZE/BURST/PROT。
- AXI4-Lite 裁剪 ID/burst 逻辑。

### 3.2 QB Request Buffers

读写队列 + AW/W 配对 + 背压。

<!-- LLD_META
module_id: LLD.MOD.X2P.QB
hld_ref: HLD.MOD.L1.X2P.QB
datapath:
  - id: LLD.DP.X2P.QB.RD_QUEUE
    name: Read Request Queue
    description: 深度 READ_REQUEST_DEPTH 的读请求队列（含 metadata）
  - id: LLD.DP.X2P.QB.WR_QUEUE
    name: Write Request Queue
    description: 深度 WRITE_REQUEST_DEPTH 的写请求队列（含 metadata）
  - id: LLD.DP.X2P.QB.AW_W_PAIR
    name: AW/W Pairing
    description: AW 描述符与 W 数据配对（AW before/W before/same cycle）
  - id: LLD.DP.X2P.QB.BACKPRESSURE
    name: Backpressure
    description: 队列满时通过 AWREADY/WREADY/ARREADY 反压
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：
- AW/W 独立留存，按 AXI Write Ordering 配对。
- 满标志：`aw_full` / `w_full` / `ar_full`；禁止溢出/下溢。

### 3.3 SCH Scheduler

R/W 仲裁，策略 + 粒度。

<!-- LLD_META
module_id: LLD.MOD.X2P.SCH
hld_ref: HLD.MOD.L1.X2P.SCH
fsm:
  - id: LLD.FSM.X2P.SCH.ARB
    name: Arbitration FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
        description: 等待读写请求
      - name: GRANT_RD
        description: 放行读
      - name: GRANT_WR
        description: 放行写
    transitions:
      - from: IDLE
        to: GRANT_RD
        condition: rd_avail && arb_select==RD
      - from: IDLE
        to: GRANT_WR
        condition: wr_avail && arb_select==WR
      - from: GRANT_RD
        to: GRANT_WR
        condition: beat_atomic_done && policy_rr && wr_avail
      - from: GRANT_WR
        to: GRANT_RD
        condition: beat_atomic_done && policy_rr && rd_avail
    illegal_state_handling: return_to_reset
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：
- 三策略：ROUND_ROBIN（轮转指针）/ READ_PRIORITY / WRITE_PRIORITY。
- 两粒度：AXI_BEAT（默认，Beat 后重新仲裁）/ AXI_TRANSACTION（整事务后切换）。
- Beat 原子性：一个 AXI Beat 拆分的 sub-transfers 连续执行，中途不切走。
- ROUND_ROBIN 无永久饥饿（每次 grant 后轮转）。

### 3.4 TE Transfer Engine

核心：Burst 跟踪、地址生成、Narrow/宽度转换、子传输生成。

<!-- LLD_META
module_id: LLD.MOD.X2P.TE
hld_ref: HLD.MOD.L1.X2P.TE
fsm:
  - id: LLD.FSM.X2P.TE.BURST
    name: Burst FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
        description: 等待调度请求
      - name: ISSUE_SUB
        description: 生成 APB 子传输
      - name: WAIT_RSP
        description: 等待子传输完成
      - name: NEXT_BEAT
        description: 推进到下一 beat
    transitions:
      - from: IDLE
        to: ISSUE_SUB
        condition: req_valid
      - from: ISSUE_SUB
        to: WAIT_RSP
        condition: apb_req_ready
      - from: WAIT_RSP
        to: NEXT_BEAT
        condition: apb_rsp_valid
      - from: NEXT_BEAT
        to: IDLE
        condition: last_beat_done || txn_done
    illegal_state_handling: return_to_reset
datapath:
  - id: LLD.DP.X2P.TE.ADDR_GEN
    name: Burst Address Generator
    description: INCR/FIXED/WRAP 地址计算，4KB 边界检查
  - id: LLD.DP.X2P.TE.LANE
    name: Narrow Lane Engine
    description: 基于 AxSIZE/地址/WSTRB 计算有效 Byte Lane
  - id: LLD.DP.X2P.TE.WIDTH
    name: Width Engine
    description: Wide-to-Narrow 拆解、Narrow-to-Wide lane 映射
  - id: LLD.DP.X2P.TE.STB
    name: Strobe Generator
    description: WSTRB→PSTRB 转换（APB4）
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：

WRAP 地址算法：

```text
number_bytes = 1 << AxSIZE
burst_bytes  = number_bytes * (AxLEN + 1)
wrap_base    = floor(start_addr / burst_bytes) * burst_bytes
wrap_limit   = wrap_base + burst_bytes
next_addr    = (cur_addr + number_bytes == wrap_limit) ? wrap_base : cur_addr + number_bytes
```

Wide-to-Narrow 拆解（如 AXI128→APB32）：

```text
subbeat_idx = 0..N-1
N = AXI_TRANSFER_BYTES / APB_DATA_BYTES
实际 APB 数结合 AxSIZE / addr offset / WSTRB 决定
apb_addr = axi_beat_addr + subbeat_offset
```

APB3 partial write：不能表示完整 Word 的写返回 SLVERR，不发起 APB access。

### 3.5 CDC CDC Layer

ASYNC 模式下的异步 FIFO 跨域。

<!-- LLD_META
module_id: LLD.MOD.X2P.CDC
hld_ref: HLD.MOD.L1.X2P.CDC
cdc:
  - signal: req_fifo
    source_domain: clk_axi
    target_domain: clk_apb
    strategy: async_fifo
    description: APB 请求异步 FIFO（深度 CDC_REQ_DEPTH）
  - signal: rsp_fifo
    source_domain: clk_apb
    target_domain: clk_axi
    strategy: async_fifo
    description: APB 响应异步 FIFO（深度 CDC_RSP_DEPTH）
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
    domain: clk_axi
  - signal: rst_apb_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
    domain: clk_apb
END_LLD_META -->

**功能要点**：
- Transaction Level：跨域传递完整 request/response 载荷（addr/write/wdata/strb/prot + metadata）。
- 深度与 outstanding 协同，不得事务丢失。
- Reset 安全：指针复位安全 + 复位释放不产生伪 valid；同步模式整模块 generate-out。

### 3.6 APB APB Engine

APB FSM + Wait-State + Timeout + back-to-back。

<!-- LLD_META
module_id: LLD.MOD.X2P.APB
hld_ref: HLD.MOD.L1.X2P.APB
fsm:
  - id: LLD.FSM.X2P.APB.PROTO
    name: APB Protocol FSM
    encoding_style: auto
    reset_state: IDLE
    states:
      - name: IDLE
        description: 等待请求
      - name: SETUP
        description: PSEL=1, PENABLE=0
      - name: ACCESS
        description: PSEL=1, PENABLE=1, 等待 PREADY
      - name: TIMEOUT
        description: 超时错误
    transitions:
      - from: IDLE
        to: SETUP
        condition: req_avail
      - from: SETUP
        to: ACCESS
        condition: always_1_cycle
      - from: ACCESS
        to: IDLE
        condition: PREADY=1
      - from: ACCESS
        to: TIMEOUT
        condition: timeout_count==TIMEOUT_CYCLES
      - from: TIMEOUT
        to: IDLE
        condition: rsp_sent
    illegal_state_handling: return_to_reset
reset:
  - signal: rst_apb_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：
- Wait-State：PREADY=0 时保持 ACCESS 与 PADDR/PSEL/PENABLE/PWRITE/PWDATA/PSTRB/PPROT 稳定。
- Timeout：进入 ACCESS 计数 PREADY=0 周期，达 TIMEOUT_CYCLES 转 TIMEOUT，返回 SLVERR，
  FSM 回 IDLE，恢复处理后续请求，不锁死。
- Back-to-back：COMPLETE 后若有下一请求直接进入下一 SETUP，避免 IDLE bubble。
- APB_OUTPUT_REG=1 时用 FSM 控制的 registered output（不破坏 SETUP/ACCESS 相位）。

### 3.7 RSP Response Engine

Read Assembly + Error Aggregation + ID Restore + R/B 输出。

<!-- LLD_META
module_id: LLD.MOD.X2P.RSP
hld_ref: HLD.MOD.L1.X2P.RSP
datapath:
  - id: LLD.DP.X2P.RSP.READ_ASSEM
    name: Read Assembler
    description: 收集 APB PRDATA 组装完整 AXI RDATA（仅完整 Beat 后 RVALID）
  - id: LLD.DP.X2P.RSP.ERR_AGG
    name: Error Aggregator
    description: beat_error=OR(sub errors); write_txn_error=OR(beat errors)
  - id: LLD.DP.X2P.RSP.ID_RESTORE
    name: ID Restore
    description: BID/RID 还原
  - id: LLD.DP.X2P.RSP.RB_OUT
    name: R/B Output
    description: R/B 通道 backpressure 稳定输出
reset:
  - signal: rst_axi_n
    polarity: active_low
    reset_value: 0
    reset_type: async_assert_sync_release
END_LLD_META -->

**功能要点**：
- Read Assembly：如 AXI64←APB32，PRDATA[31:0]→buff[31:0]、PRDATA[63:32]→buff[63:32]，完整后 RVALID=1。
- Error：PSLVERR=1 → SLVERR；Write 任一子传输出错 BRESP=SLVERR；无 rollback。
- Ordering：同 ID transaction 按协议顺序返回；APB 串行执行保证无 out-of-order。
- R/B backpressure：RVALID=1/RREADY=0 与 BVALID=1/BREADY=0 时输出保持稳定。

---

## 4. 内部事务接口（概念）

```text
x2p_req { txn_id, is_write, addr, burst_type, burst_len, burst_size,
          beat_idx, data, strb, prot, first, last }
x2p_apb_req { txn_id, addr, write, wdata, strb, prot,
              axi_beat_idx, subbeat_idx, axi_beat_last, axi_txn_last }
x2p_rsp { txn_id, axi_beat_idx, rdata, error, beat_last, txn_last }
```

不暴露为顶层端口，仅在模块间传递。