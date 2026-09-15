`ifndef APB_SECURE_DEMUX_CONTROL_IF__SV
`define APB_SECURE_DEMUX_CONTROL_IF__SV
// Sideband and passive cycle observation; APB handshake is owned by VIP.
interface apb_secure_demux_control_if(input logic pclk);
  import apb_secure_demux_instance_pkg::*;
  localparam int NP=int'(C_NUM_PORTS), IW=int'(C_MASTER_ID_WIDTH);
  logic reset_n=0, authorized=1, master_valid=1;
  logic [IW-1:0] master_id='0;
  logic [NP-1:0] peripheral_reset_n='1;
  logic decode_fault=0,fault_active=0,fault_data=0;
  int unsigned fault_kind=0,fault_port=0,fault_master=0,fault_bit=0;
  wire s_sel,s_en,s_write,s_ready,s_error;
  wire [31:0] s_addr,s_wdata,s_rdata;
  wire [3:0] s_strb;
  wire [2:0] s_prot;
  wire [NP-1:0] m_sel,m_en,m_write,m_ready,m_error,m_valid;
  wire [31:0] m_addr[NP],m_wdata[NP],m_rdata[NP];
  wire [3:0] m_strb[NP];
  wire [2:0] m_prot[NP];
  wire [IW-1:0] m_id[NP];
  wire irq,alert,busy,port_valid,wait_hit;
  wire [4:0] active_port;
  clocking drive_cb @(posedge pclk);
    default output #1ns;
    output master_id,master_valid;
  endclocking
  clocking cb @(posedge pclk);
    default input #1step;
    input reset_n,authorized,master_valid,master_id;
    input decode_fault,fault_active,fault_data,fault_kind,fault_port,fault_master,fault_bit;
    input s_sel,s_en,s_write,s_ready,s_error,s_addr,s_wdata,s_rdata,s_strb,s_prot;
    input m_sel,m_en,m_write,m_ready,m_error,m_valid,m_addr,m_wdata,m_rdata,m_strb,m_prot,m_id;
    input irq,alert,busy,port_valid,wait_hit,active_port;
  endclocking
endinterface

`endif // APB_SECURE_DEMUX_CONTROL_IF__SV
