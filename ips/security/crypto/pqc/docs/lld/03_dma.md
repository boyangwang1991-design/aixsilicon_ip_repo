# PQC DMA 事务、响应与取消微架构

### LLD.MOD.PQC.DMA

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.DMA
name: pqc_dma
parent_ref: HLD.MOD.PQC.DMA
hld_ref:
- HLD.MOD.PQC.DMA
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.003
- LRS.SEC.PQC.SLOT.005
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_dma
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 请求资格与字节计数

DMA 只搬运已授权的公开输入/输出或经过 commit 的公开结果。私钥导入、share、
KeyGen 托管不接普通 DMA；使用 WORKKEY 专用端口。请求包含 direction、40-bit
address、64-bit length/capacity、内部 allocation_id、command_epoch、request_id
及可信 secure/privileged 属性，E0 的 req_valid && req_ready 锁存完整请求。
单方向单 burst 在途，request 未完成前不接第二个，避免引入未预算的 reorder buffer。

CHECK 先做 65-bit 地址加法 `end=address+length`，拒绝溢出、超过 40-bit 空间、
不在闭区间 WIN_BASE..WIN_LIMIT、容量不足和内部逻辑存储越界；地址按 AXI beat
对齐，不支持非对齐首地址。length=0 走无总线访问完成，不计算 length-1。
权限/范围检查先于任何 AR/AW；运行期间的配置变化不修改已锁存请求。

设 B=DMA_DATA_WIDTH/8，下一 burst 的有效字节数为
`min(remaining,4096-(address mod 4096),256*B)`，beat 数为 ceil(bytes/B)。
每 beat 有效 byte 数为 min(B,burst_remaining)，尾拍 WSTRB 为相应连续低位 1；
高位 data 置零。长度、外部地址和内部指针只在相应握手时推进，不在 valid 单独
为 1 时推进。little-endian 字节流在 64/128/256-bit AXI 与 32-bit 内部 word 间
分拆/聚合；内部最后不足 word 的字节使用 byte-enable，不污染相邻对象。

标量内部接口 `buf_wstrb[WORD_WIDTH/8-1:0]` 与 buf_req/we/address/data 一起保持到
buf_ready。每次读 beat 拆包时只对实际存在的字节置 1；取消、复位和非写请求时为零。
SRAM 原子合并尾字节并重新计算 ECC，不能把填零的无效 lane 当作有效写。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.DMA.BYTE_STREAM
module_ref: LLD.MOD.PQC.DMA
input_width: 256
output_width: 32
operators:
- extended_range_check
- boundary_limited_burst
- little_endian_split_assemble
- tail_byte_enable
representation: authorized_packed_bytes
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.003
- LRS.SEC.PQC.SLOT.005
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## FSM 与总线保序

<!-- LLD_FSM_META
id: LLD.FSM.PQC.DMA.TRANSFER
module_ref: LLD.MOD.PQC.DMA
encoding: onehot
reset_state: IDLE
states: [IDLE, CHECK, READ_ADDR, READ_BEAT, READ_STORE, WRITE_LOAD, WRITE_ADDR, WRITE_BEAT, WRITE_RESP, FINISH, DRAIN, CLEAR, LOCKED]
illegal_state_handling: fatal
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.RESET.PQC.SAFE.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
transitions:
- {source: IDLE, destination: CHECK, condition: request_fire}
- {source: CHECK, destination: FINISH, condition: invalid_or_zero_length_with_error_if_invalid}
- {source: CHECK, destination: READ_ADDR, condition: legal_read}
- {source: CHECK, destination: WRITE_LOAD, condition: legal_write}
- {source: READ_ADDR, destination: READ_BEAT, condition: ar_fire}
- {source: READ_BEAT, destination: READ_STORE, condition: valid_r_fire_with_expected_last_and_resp}
- {source: READ_STORE, destination: READ_BEAT, condition: last_internal_write_response_and_more_beats}
- {source: READ_STORE, destination: READ_ADDR, condition: burst_committed_and_more_bursts}
- {source: READ_STORE, destination: FINISH, condition: all_bytes_committed}
- {source: WRITE_LOAD, destination: WRITE_ADDR, condition: first_beat_assembled}
- {source: WRITE_ADDR, destination: WRITE_BEAT, condition: aw_fire}
- {source: WRITE_BEAT, destination: WRITE_LOAD, condition: w_fire_and_more_beats}
- {source: WRITE_LOAD, destination: WRITE_BEAT, condition: later_beat_assembled}
- {source: WRITE_BEAT, destination: WRITE_RESP, condition: last_w_fire}
- {source: WRITE_RESP, destination: WRITE_LOAD, condition: b_ok_fire_and_more_bursts}
- {source: WRITE_RESP, destination: FINISH, condition: b_ok_fire_and_all_bytes_done}
- {source: FINISH, destination: IDLE, condition: response_fire}
- {source: DRAIN, destination: CLEAR, condition: no_offered_or_outstanding_axi_and_internal_requests}
- {source: CLEAR, destination: IDLE, condition: local_data_and_tokens_cleared_and_no_clear_request}
- {source: DRAIN, destination: LOCKED, condition: drain_timeout_or_protocol_integrity_failure}
- {source: IDLE, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: CHECK, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: READ_ADDR, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: READ_BEAT, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: READ_STORE, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: WRITE_LOAD, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: WRITE_ADDR, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: WRITE_BEAT, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: WRITE_RESP, destination: DRAIN, condition: clear_revoke_or_error_priority}
- {source: FINISH, destination: DRAIN, condition: clear_revoke_or_error_priority}
END_LLD_FSM_META -->

任一正常状态遇 clear/revoke/error 优先进入 DRAIN；没有已展示或已受理事务时可
下一拍进入 CLEAR。该全状态优先转移在抽取元数据中逐项列出，未列条件保持。
FINISH 的 done/error/token 在响应背压期间保持；FE 必须等成功写响应再提交 completion，
不能把 WLAST 握手当作写完成。每个内部 SRAM 请求也区分 request 接受和 response
退休，不能用一个持续 buf_req 在返回周期再次发起同一个 word。

读 beat 先锁存，再按内部容量分拆，未取得所有 word 写确认前不接受下一 R beat。
写 beat 先读齐内部 word 再展示 WVALID，AW 在本 burst 首 beat 准备后展示。
AR/AW/W 的 valid 一旦展示，即使 ready=0、发生取消也必须保持 valid/payload，
直到握手；正常状态保持 token、LEN、PROT、WSTRB 和 LAST。响应只归属所锁存请求。

## 取消和不可撤回事务

DRAIN 记录已展示但尚未握手的 AR/AW/W，以及已接受的 burst、剩余 beat 和 B/R
响应义务。禁止新 burst、禁止向 SRAM 发布取消后的读数据，继续接受并丢弃已欠
R 响应。已有 AW 义务的 W 必须补齐：已展示 W beat 保持原 data/strb/last，尚未
展示的后续 beat 送 data=0、strb=0，并保持正确 LAST；随后等待 B。
这会保留取消前已经展示/写入的部分公开输出，因此软件只能依据最终成功 completion
使用结果，不能把取消解释为撤回外部写。私钥/秘密 staging 从源端就不允许进入 DMA。

内部已接受请求也等其响应，丢弃结果；只有本地暂存全清、所有协议义务均排空才发
zeroize_done。AXI 永久背压时保持协议信号并报告 timeout/LOCKED，不能伪造 done。
错误 RLAST、非 OKAY RRESP/BRESP 使事务失败；若错误令 burst 长度无法可靠判断，
锁定并依赖系统总线复位恢复，不能假定读取一拍就排空。ACK 必须匹配 clear_epoch。
冷复位可复位控制，但 SoC 必须同步取消总线 outstanding；warm/功能 clear 使用上述
排空机制，不直接复位 AXI valid。

## 资源与实现交接

一份 B-byte 接收暂存、一份 B-byte 写暂存和一个 32-bit word 拼接寄存器；响应保存
64-bit 字节计数及 token。背压只延长时间，不增加容量；内部 SRAM 仲裁等待计入
内部预算，外部 AXI 等待单独计量。burst 几何可穷举三种宽度的页内对齐地址和边界
长度检查；这不证明 AXI RTL 握手或取消已符合设计。

RTL TODO：`rtl/pqc_dma.sv` 对齐 request/response 身份、byte-enable、取消期间
已展示 valid 的稳定性与 clear_epoch；`rtl/pqc_top.sv` 将 descriptor fetch 与 payload
访问所有权显式仲裁，全部输出写响应完成后才准许 completion。
