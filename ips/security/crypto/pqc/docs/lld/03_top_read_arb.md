# TOP 共享 AXI 读事务仲裁（draft）

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.TOP.READ_ARB
name: pqc_axi_read_arb
parent_ref: LLD.MOD.PQC.TOP
hld_ref: [HLD.MOD.PQC.TOP]
req_ref: [LRS.INTF.PQC.DMA.001]
applicability: {expr: 'true'}
rtl_intent: {separate_module: true, suggested_name: pqc_axi_read_arb}
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
END_LLD_MODULE_META -->

从 TOP 拆出共享读通道胶水，两个客户端分别是 descriptor（0）和 payload DMA（1）。
公共 AXI 端口保持原定义，不新增 ID 或 outstanding。读仲裁只保存 owner 和 AR 请求，
不缓存 R 数据；客户端负责长度/RLAST/错误及取消后的数据丢弃。

IDLE 检测请求时固定优先 client0，同时锁存 addr/len/prot/owner，下一拍展示外部 AR。
客户端 ready 仅在自己的外部 AR 真正握手时返回，因此客户端仍须保持 valid 到 ready。
从首次提供 AR 起直到最后 R 握手独占事务；后来更高优先级请求不得切换地址，READ
期间不得接受第二个 AR。没有预取队列，最后 R 退休后下一拍才能仲裁下一个请求。

RVALID/RREADY 只接到 READ 的 owner；空闲和尚未接受 AR 时两客户端 RVALID 均为零，
外部 RREADY=0。不将一个 R beat 广播为两个客户端的有效数据。取消不复位仲裁器，
客户端持续保持已提供 AR、接收并丢弃 R，直到事务排空；不能通过 zeroize 清 owner
伪造总线退休。冷复位低有效异步置位，系统保证对端无遗留事务；同步释放后 IDLE。

<!-- LLD_FSM_META
id: LLD.FSM.PQC.TOP.READ_ARB
module_ref: LLD.MOD.PQC.TOP.READ_ARB
encoding: onehot
reset_state: IDLE
states: [IDLE, ADDRESS, READ]
illegal_state_handling: fatal
req_ref: [LRS.INTF.PQC.DMA.001]
applicability: {expr: 'true'}
transitions:
- {source: IDLE, destination: ADDRESS, condition: client_request_captured}
- {source: ADDRESS, destination: READ, condition: external_ar_fire}
- {source: READ, destination: IDLE, condition: external_last_r_fire}
END_LLD_FSM_META -->

非法状态阻止新 AR/R 握手并锁存 fault，只能冷复位恢复，不能默认 IDLE 释放未知未决
事务。fault 交 TOP/FAULT，实际全局故障清除仍不得伪造 AXI 排空。
面积为地址/长度/属性/owner 的寄存器和窄 mux；AR 增加一拍，功能正确优先，性能优化
可延期。单元测试必须覆盖低优先级 AR 背压期间高优先级到来、多 beat R 背压、串行
交接及空闲伪响应；同时运行 TOP descriptor 集成用例。

<!-- RTL_MAP_META
id: RTL.PQC.READ_ARB
rtl_file: rtl/pqc_axi_read_arb.sv
rtl_module: pqc_axi_read_arb
implements: [LLD.MOD.PQC.TOP.READ_ARB, LLD.FSM.PQC.TOP.READ_ARB]
generated: false
generator_ref: null
END_RTL_MAP_META -->
