// x2p_axi_frontend.sv - AXI 通道捕获（AW/W/AR）
// 职责：捕获 AXI 请求通道数据与元数据，产生 push 供 req_mgr 入队
// 响应通道（R/B）由 x2p_rsp_mgr 处理。本模块纯组合捕获，无状态。
module x2p_axi_frontend #(
  parameter int unsigned AXI_ADDR_WIDTH = 32,
  parameter int unsigned AXI_DATA_WIDTH = 64,
  parameter int unsigned AXI_ID_WIDTH   = 4
) (
  input  logic clk,
  input  logic rst_n,

  // AW
  input  logic                        awvalid,
  output logic                        awready,
  input  logic [AXI_ID_WIDTH-1:0]     awid,
  input  logic [AXI_ADDR_WIDTH-1:0]   awaddr,
  input  logic [7:0]                  awlen,
  input  logic [2:0]                  awsize,
  input  logic [1:0]                  awburst,
  input  logic [2:0]                  awprot,

  // W
  input  logic                        wvalid,
  output logic                        wready,
  input  logic [AXI_DATA_WIDTH-1:0]   wdata,
  input  logic [AXI_DATA_WIDTH/8-1:0] wstrb,
  input  logic                        wlast,

  // AR
  input  logic                        arvalid,
  output logic                        arready,
  input  logic [AXI_ID_WIDTH-1:0]     arid,
  input  logic [AXI_ADDR_WIDTH-1:0]   araddr,
  input  logic [7:0]                  arlen,
  input  logic [2:0]                  arsize,
  input  logic [1:0]                  arburst,
  input  logic [2:0]                  arprot,

  // -> req_mgr
  output logic                        aw_push,
  output logic [AXI_ID_WIDTH-1:0]     aw_id_o,
  output logic [AXI_ADDR_WIDTH-1:0]   aw_addr_o,
  output logic [7:0]                  aw_len_o,
  output logic [2:0]                  aw_size_o,
  output logic [1:0]                  aw_burst_o,
  output logic [2:0]                  aw_prot_o,

  output logic                        w_push,
  output logic [AXI_DATA_WIDTH-1:0]   w_data_o,
  output logic [AXI_DATA_WIDTH/8-1:0] w_strb_o,
  output logic                        w_last_o,

  output logic                        ar_push,
  output logic [AXI_ID_WIDTH-1:0]     ar_id_o,
  output logic [AXI_ADDR_WIDTH-1:0]   ar_addr_o,
  output logic [7:0]                  ar_len_o,
  output logic [2:0]                  ar_size_o,
  output logic [1:0]                  ar_burst_o,
  output logic [2:0]                  ar_prot_o
);

  // AXI4-Lite 时 burst=00(FIXED)/len=0 的语义由顶层参数约束，
  // 本模块仅透传元数据。

  assign aw_push   = awvalid && awready;
  assign aw_id_o   = awid;
  assign aw_addr_o = awaddr;
  assign aw_len_o  = awlen;
  assign aw_size_o = awsize;
  assign aw_burst_o= awburst;
  assign aw_prot_o = awprot;

  assign w_push    = wvalid && wready;
  assign w_data_o  = wdata;
  assign w_strb_o  = wstrb;
  assign w_last_o  = wlast;

  assign ar_push   = arvalid && arready;
  assign ar_id_o   = arid;
  assign ar_addr_o = araddr;
  assign ar_len_o  = arlen;
  assign ar_size_o = arsize;
  assign ar_burst_o= arburst;
  assign ar_prot_o = arprot;

endmodule : x2p_axi_frontend