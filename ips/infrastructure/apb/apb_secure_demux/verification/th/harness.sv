`ifndef HARNESS__SV
`define HARNESS__SV
`timescale 1ns/1ps
module harness;
  import uvm_pkg::*;
  import apb_types_pkg::*;
  import apb_secure_demux_instance_pkg::*;
  import apb_secure_demux_env_package::*;
  import tc_package::*;
  localparam int NP=int'(C_NUM_PORTS), AW=int'(C_ADDR_WIDTH), IW=int'(C_MASTER_ID_WIDTH);
  logic clk=0;
  always #5ns clk=~clk;
  apb_secure_demux_control_if control(clk);
  apb_if upstream(clk,control.reset_n,1'b0);
  wire [AW-1:0] maddr[NP];
  wire [31:0] mwdata[NP],mrdata[NP];
  wire [3:0] mstrb[NP];
  wire [2:0] mprot[NP];
  wire [IW-1:0] mid[NP];
  wire [NP-1:0] msel,men,mwrite,mready,merror,mvalid;
  wire [31:0] upstream_rdata;
  wire upstream_ready,upstream_error;
  always @* begin
    upstream.prdata=upstream_rdata;
    upstream.pready=upstream_ready;
    upstream.pslverr=upstream_error;
  end
  apb_secure_demux dut(
    .pclk(clk),.preset_ni(control.reset_n),
    .s_paddr(upstream.paddr[AW-1:0]),.s_psel(upstream.psel[0]),.s_penable(upstream.penable),
    .s_pwrite(upstream.pwrite),.s_pwdata(upstream.pwdata),.s_pstrb(upstream.pstrb_w),
    .s_pprot(upstream.pprot_w),.s_prdata(upstream_rdata),.s_pready(upstream_ready),
    .s_pslverr(upstream_error),.master_id_i(control.master_id),
    .master_id_valid_i(control.master_valid),.dfx_authorized_i(control.authorized),
    .m_paddr(maddr),.m_psel(msel),.m_penable(men),.m_pwrite(mwrite),.m_pwdata(mwdata),
    .m_pstrb(mstrb),.m_pprot(mprot),.m_prdata(mrdata),.m_pready(mready),.m_pslverr(merror),
    .m_master_id_o(mid),.m_master_id_valid_o(mvalid),
    .irq_o(control.irq),.security_alert_o(control.alert),.busy_o(control.busy),
    .active_port_valid_o(control.port_valid),.active_port_o(control.active_port),
    .wait_threshold_o(control.wait_hit));
  assign control.s_addr=upstream.paddr;
  assign control.s_sel=upstream.psel[0],control.s_en=upstream.penable;
  assign control.s_write=upstream.pwrite,control.s_wdata=upstream.pwdata;
  assign control.s_strb=upstream.pstrb_w,control.s_prot=upstream.pprot_w;
  assign control.s_ready=upstream.pready,control.s_error=upstream.pslverr;
  assign control.s_rdata=upstream.prdata;
  assign control.m_sel=msel,control.m_en=men,control.m_write=mwrite;
  assign control.m_ready=mready,control.m_error=merror,control.m_valid=mvalid;
  for(genvar p=0;p<NP;p++) begin: ports
    // VIP owns response timing/error. Its SETUP-updated memory is not the
    // architectural side-effect model; observed sees completion-updated data.
    apb_if responder(clk,control.reset_n,1'b0);
    apb_if observed(clk,control.reset_n,1'b0);
    wire [31:0] target_data;
    always @* begin
      responder.paddr=32'(maddr[p]);responder.psel[0]=msel[p];responder.penable=men[p];
      responder.pwrite=mwrite[p];responder.pwdata=mwdata[p];
      responder.pstrb_w=mstrb[p];responder.pprot_w=apb_protection'(mprot[p]);
      observed.paddr=32'(maddr[p]);observed.psel[0]=msel[p];observed.penable=men[p];
      observed.pwrite=mwrite[p];observed.pwdata=mwdata[p];
      observed.pstrb_w=mstrb[p];observed.pprot_w=apb_protection'(mprot[p]);
      observed.pready=responder.pready;observed.pslverr=responder.pslverr;
      observed.prdata=target_data;
    end
    apb_secure_demux_target_model #(.BASE(C_PORT_BASE[p])) target_model(
      .clk(clk),.reset_n(control.reset_n && control.peripheral_reset_n[p]),
      .sel(msel[p]),.en(men[p]),.write(mwrite[p]),
      .ready(mready[p]),.error(merror[p]),.addr(32'(maddr[p])),.wdata(mwdata[p]),
      .strb(mstrb[p]),.rdata(target_data));
    assign mready[p]=responder.pready,merror[p]=responder.pslverr,mrdata[p]=target_data;
    assign control.m_addr[p]=32'(maddr[p]),control.m_wdata[p]=mwdata[p],control.m_rdata[p]=mrdata[p];
    assign control.m_strb[p]=mstrb[p],control.m_prot[p]=mprot[p],control.m_id[p]=mid[p];
    initial begin
      uvm_config_db#(virtual apb_if)::set(null,$sformatf("uvm_test_top.env.downstream_%0d*",p),"vif",responder);
      uvm_config_db#(virtual apb_if)::set(null,$sformatf("uvm_test_top.env.downstream_monitor_%0d",p),"vif",observed);
    end
  end
  initial begin
    uvm_config_db#(virtual apb_if)::set(null,"uvm_test_top.env.upstream*","vif",upstream);
    uvm_config_db#(virtual apb_secure_demux_control_if)::set(null,"uvm_test_top.env*","control",control);
    run_test();
  end
  initial begin
    repeat(5) @(negedge clk);
    control.reset_n=1;
  end
endmodule

`endif // HARNESS__SV
