`ifndef APB_SECURE_DEMUX_ENV_DEC__SV
`define APB_SECURE_DEMUX_ENV_DEC__SV
localparam int ASD_NP=int'(C_NUM_PORTS), ASD_NM=int'(C_NUM_MASTERS);
typedef struct packed {
  logic [31:0] addr,data;
  logic [3:0] strb;
  logic [2:0] prot;
  logic write,valid;
  logic [31:0] master;
} asd_request_t;
typedef struct packed {
  logic ready,error;
  logic [31:0] data;
  int port;
  byte reason;
} asd_prediction_t;
`uvm_analysis_imp_decl(_act)
`uvm_analysis_imp_decl(_exp)

`endif // APB_SECURE_DEMUX_ENV_DEC__SV
