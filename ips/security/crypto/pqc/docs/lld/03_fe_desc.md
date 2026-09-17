# PQC 描述符抓取子模块（draft）

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.FE.DESC_FETCH
name: pqc_desc_fetch
parent_ref: LLD.MOD.PQC.FE
hld_ref:
- HLD.MOD.PQC.FE
req_ref:
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.004
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_desc_fetch
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 职责与存储唯一归属

FE 负责接受命令、128 B shadow、CRC/ABI/地址与授权校验、最终完成发布。
DESC_FETCH 只负责固定长度 AXI 读、逐字节解包、总线错误及排空；不解释 opcode，
不发 payload 写，不拥有私钥或 shadow 的第二份副本。DMA 负责一般 payload 传输。
TOP 实例化本模块（逻辑归属 FE），通过读仲裁连接 AXI；层级归属不要求物理嵌套实例。

抓取入口由 DESC_FETCH 在 IDLE 接受 start 时校验：地址为 128 B 对齐、128 B 范围
不溢出且位于 WIN_BASE/WIN_LIMIT 可信读窗口。无效入口直接 ERROR，不能提供 AR；
TOP 的抓取窗口和 payload DMA 同为 0..0xffffffff。抓取后
才校验 descriptor 内的 payload 地址。总线宽度 64/128/256，分别读 16/8/4 beat，
ARLEN=NBEATS-1。持有寄存器宽度等于总线宽度，仅一份；little-endian 字节流每拍一字节。
这避免额外 128 B 镜像，代价是每 beat 接收后暂停 R 通道 STRB_W 拍完成输出。

| 接口 | 所有权及逐拍规则 |
|---|---|
| start / addr | FE 仅 IDLE 发 start；沿采样 addr，结束后须撤销 start 才能重入 |
| AR | 本模块持有 valid/address/len/prot，直到 ready；取消也不能撤回已提供的 valid |
| R | 仅 RX/DRAIN ready；每次握手核对 resp 与预期 RLAST |
| desc_data / idx / valid | EMIT 每拍一字节，索引 0..127；FE 必须无背压接收 |
| done / error | 终态保持至 start 撤销；FE 只在完整 done 且无取消时允许 shadow 校验 |
| zeroize_req / done | 立即屏蔽字节发布，完成总线排空和本地清除后才应答 |

<!-- LLD_FSM_META
id: LLD.FSM.PQC.FE.DESC_FETCH
module_ref: LLD.MOD.PQC.FE.DESC_FETCH
encoding: onehot
reset_state: IDLE
states: [IDLE, AR, RX, EMIT, DONE, ERROR, DRAIN, CLEAR, LOCKED]
illegal_state_handling: fatal
req_ref:
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.004
applicability:
  expr: 'true'
transitions:
- {source: IDLE, destination: AR, condition: start_and_entry_range_valid_and_no_clear}
- {source: IDLE, destination: ERROR, condition: start_and_entry_range_invalid_and_no_clear}
- {source: AR, destination: RX, condition: ar_fire_and_no_cancel}
- {source: RX, destination: EMIT, condition: r_fire_and_resp_ok_and_last_position_correct}
- {source: RX, destination: ERROR, condition: r_fire_and_malformed_and_rlast}
- {source: RX, destination: DRAIN, condition: r_fire_and_malformed_and_not_rlast}
- {source: EMIT, destination: RX, condition: last_byte_of_nonfinal_beat}
- {source: EMIT, destination: DONE, condition: byte_127_published}
- {source: DONE, destination: IDLE, condition: start_deasserted_and_no_clear}
- {source: ERROR, destination: IDLE, condition: start_deasserted_and_no_clear}
- {source: IDLE, destination: CLEAR, condition: clear_priority}
- {source: AR, destination: DRAIN, condition: ar_fire_and_cancel_latched_priority}
- {source: RX, destination: DRAIN, condition: cancel_priority_and_no_final_r_fire}
- {source: RX, destination: CLEAR, condition: cancel_priority_and_final_r_fire}
- {source: EMIT, destination: DRAIN, condition: cancel_priority_and_more_beats_outstanding}
- {source: EMIT, destination: CLEAR, condition: cancel_priority_and_final_beat_already_received}
- {source: DONE, destination: CLEAR, condition: clear_priority}
- {source: ERROR, destination: CLEAR, condition: clear_priority}
- {source: DRAIN, destination: CLEAR, condition: final_r_fire_and_cancel_latched}
- {source: DRAIN, destination: ERROR, condition: final_r_fire_and_not_cancel_latched}
- {source: CLEAR, destination: IDLE, condition: local_wipe_complete_and_clear_deasserted_and_start_deasserted}
- {source: AR, destination: LOCKED, condition: bus_wait_timeout}
- {source: RX, destination: LOCKED, condition: bus_wait_timeout}
- {source: DRAIN, destination: LOCKED, condition: drain_timeout}
END_LLD_FSM_META -->

未列条件自环，clear/cancel 优先于正常输出；AR 等待时锁存 cancel，保持原 AR。
RX 同沿取消和最后一个 R 握手直接进入 CLEAR，不再等待已消费的 RLAST。
EMIT 取消丢弃剩余字节；尚有总线 beat 时进入 DRAIN，仅丢弃到最后 RLAST。
CLEAR 清 hold、地址、游标、计数及有效标记，下一拍 ack；FAULT 的清除事务身份
由 TOP 绑定，本模块只能有一个未完成清除。reset 为低有效异步置位、CORE 同步释放，
本地状态及存储归零；系统须保证冷复位时 AXI 对端亦无遗留事务。

LOCKED 是功能锁定而非撤销 AXI：保持未握手的 AR；一旦握手继续接收并丢弃 R，
直至 RLAST；仍保持 locked，只有确实无未决事务且本地清除后才能报告清除 ack。
不得以超时伪造 ack。timeout 数值服从系统等待预算，预算未冻结前不填任意常数。

## 集成约束与现有实现差距

TOP 读仲裁必须从 AR 首次提供起锁定 owner，直至相应最后 R 握手才释放；背压时
不能因 descriptor 优先级改变已提供地址，也不能在旧读未退休时接受第二个 AR。
这属于共享 AXI 接口仲裁，不归 DESC_FETCH 内部处理。TOP 已改接独立 READ_ARB，
替换原先 df_ar_valid 组合选择和历史选择位；模块协议 UT 已通过，顶层回归继续验收。

现有 `rtl/pqc_desc_fetch.sv` 具有抓取/解包骨架，但编码、超时锁定、本地完整清除
和 FAULT 连接尚待对齐；TOP 的 error/done 已接入 FE，FE 要求完整 shadow 与 done
同时满足，并优先处理 error；局部取消清除也已覆盖地址/计数/hold，仍须全量回归。
P0：实现上述差距及取消时序后，验证末 beat 同沿取消、AR 背压、错误排空、超时
不伪造 ack，以及部分 shadow 绝不触发执行。本册是设计合同，不是 RTL 验证证据。

<!-- RTL_MAP_META
id: RTL.PQC.DESC_FETCH
rtl_file: rtl/pqc_desc_fetch.sv
rtl_module: pqc_desc_fetch
implements:
- LLD.MOD.PQC.FE.DESC_FETCH
- LLD.FSM.PQC.FE.DESC_FETCH
generated: false
generator_ref: null
END_RTL_MAP_META -->
