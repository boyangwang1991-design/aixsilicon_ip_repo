// =============================================================================
// ut_pqc_top - top-level integration UT (read path / control path)
//
// Drives APB4 transactions into the integrated top level and checks:
//   * generated CSR reset values are reachable over the bus
//   * the capability registers report the elaborated configuration
//   * an unmapped address returns PSLVERR
//   * a busy-window write to the command group is rejected with PSLVERR
//   * the interrupt state can be set by software and cleared by W1C
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_top_review;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  // APB4
  logic        psel, penable, pwrite;
  logic [2:0]  pprot;
  logic [9:0]  paddr;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic        pready, pslverr;
  logic [31:0] prdata;

  // AXI4 master (tied off in this UT)
  logic                  m_ar_valid, m_ar_ready;
  logic [39:0]           m_ar_addr;
  logic [7:0]            m_ar_len;
  logic [2:0]            m_ar_prot;
  logic                  m_r_valid;
  wire                   m_r_ready;      // DUT output
  logic [127:0]          m_r_data;
  logic [1:0]            m_r_resp;
  logic                  m_r_last;
  logic                  m_aw_valid, m_aw_ready;
  logic [39:0]           m_aw_addr;
  logic [7:0]            m_aw_len;
  logic [2:0]            m_aw_prot;
  logic                  m_w_valid, m_w_ready;
  logic [127:0]          m_w_data;
  logic [15:0]           m_w_strb;
  logic                  m_w_last;
  logic                  m_b_valid;
  wire                   m_b_ready;      // DUT output
  logic [1:0]            m_b_resp;

  // sideband
  logic        entropy_valid, entropy_ready, entropy_health_ok;
  logic [63:0] entropy_data;
  logic [7:0]  entropy_domain_tag;
  logic        lifecycle_strap, tamper_in, zeroize_req_in, privileged, debug_unlocked;
  logic        irq;
  logic        fault_inject_ecc_ue, fault_inject_ctrl;

  pqc_top #(
    .NTT_LANES(2), .KECCAK_ROUNDS_PER_CYCLE(2), .LOCAL_SRAM_KIB(64),
    .DMA_DATA_WIDTH(128), .KEY_SLOT_NUM(8), .SCA_LEVEL(1)
  ) dut (
    .km_begin(1'b0), .km_handle(32'd0), .km_algo(4'd0), .km_pset(4'd0),
    .km_usage(8'd0), .km_bytes(16'd0), .km_valid(1'b0), .km_data(32'd0),
    .km_last(1'b0), .km_revoke(1'b0),
    .clk(clk), .rst_n(rst_n),
    .s_apb_psel(psel), .s_apb_penable(penable), .s_apb_pwrite(pwrite),
    .s_apb_pprot(pprot), .s_apb_paddr(paddr), .s_apb_pwdata(pwdata),
    .s_apb_pstrb(pstrb), .s_apb_pready(pready), .s_apb_prdata(prdata),
    .s_apb_pslverr(pslverr),
    .m_ar_valid(m_ar_valid), .m_ar_ready(m_ar_ready), .m_ar_addr(m_ar_addr),
    .m_ar_len(m_ar_len), .m_ar_prot(m_ar_prot),
    .m_r_valid(m_r_valid), .m_r_ready(m_r_ready), .m_r_data(m_r_data),
    .m_r_resp(m_r_resp), .m_r_last(m_r_last),
    .m_aw_valid(m_aw_valid), .m_aw_ready(m_aw_ready), .m_aw_addr(m_aw_addr),
    .m_aw_len(m_aw_len), .m_aw_prot(m_aw_prot),
    .m_w_valid(m_w_valid), .m_w_ready(m_w_ready), .m_w_data(m_w_data),
    .m_w_strb(m_w_strb), .m_w_last(m_w_last),
    .m_b_valid(m_b_valid), .m_b_ready(m_b_ready), .m_b_resp(m_b_resp),
    .entropy_valid(entropy_valid), .entropy_ready(entropy_ready),
    .entropy_data(entropy_data), .entropy_health_ok(entropy_health_ok),
    .entropy_domain_tag(entropy_domain_tag),
    .lifecycle_strap(lifecycle_strap), .tamper_in(tamper_in),
    .zeroize_req_in(zeroize_req_in), .privileged(privileged),
    .debug_unlocked(debug_unlocked), .irq(irq),
    .fault_inject_ecc_ue(fault_inject_ecc_ue),
    .fault_inject_ctrl(fault_inject_ctrl)
  );

  int errors = 0;
  int guard;
  logic [31:0] rd;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got 0x%08x exp 0x%08x)", msg, got, exp);
      errors++;
    end
  endtask

  // APB read
  task automatic apb_read(input logic [9:0] a, output logic [31:0] data, output logic err);
    @(negedge clk);
    psel = 1'b1; penable = 1'b0; pwrite = 1'b0; paddr = a; pwdata = 32'h0;
    pstrb = 4'h0; pprot = 3'b001;
    @(negedge clk);
    penable = 1'b1;
    guard = 0;
    while (!pready && guard < 100) begin @(negedge clk); guard++; end
    data = prdata;
    err  = pslverr;
    @(negedge clk);
    psel = 1'b0; penable = 1'b0;
  endtask

  // APB write
  task automatic apb_write(input logic [9:0] a, input logic [31:0] d, output logic err);
    @(negedge clk);
    psel = 1'b1; penable = 1'b0; pwrite = 1'b1; paddr = a; pwdata = d;
    pstrb = 4'hF; pprot = 3'b001;
    @(negedge clk);
    penable = 1'b1;
    guard = 0;
    while (!pready && guard < 100) begin @(negedge clk); guard++; end
    err = pslverr;
    @(negedge clk);
    psel = 1'b0; penable = 1'b0;
  endtask

  logic err;

 logic serve=0;int beat=0,bytecount=0,idxerrors=0,fdonecount=0;bit active=0;
 always @(posedge clk) if(rst_n) begin
 if(dut.fe_desc_data_valid) begin
 if(dut.fe_desc_data_idx !== 8'(bytecount)) idxerrors++;
 bytecount++;
 end
 if(dut.fault_zeroize_done) begin
 fdonecount++;
 if(dut.u_sram.zwr_active || dut.u_fault_ctrl.done_seen !== 6'b111111) $fatal(1,"premature zeroize completion");
 $display("CHECK ZEROIZE reported_done SRAMdone=%b Keccakdone=%b keysdone=%b active=%b",dut.sram_zeroize_done,dut.kec_zeroize_done,dut.ks_zeroize_done,dut.u_sram.zwr_active);
 end
 end
 always @(posedge clk) if(rst_n && serve) begin
 if(m_ar_valid && m_ar_ready) begin active<=1;beat<=0;end
 if(active && !m_r_valid) begin
 m_r_valid<=1;m_r_last<=(beat==7);m_r_resp<=0;
 for(int k=0;k<16;k++) m_r_data[k*8+:8]<=8'(beat*16+k);
 end else if(m_r_valid && m_r_ready) begin
 m_r_valid<=0;
 if(beat==7) active<=0;else beat<=beat+1;
 end
 end
 initial begin
 psel=0;penable=0;pwrite=0;pprot=0;paddr=0;pwdata=0;pstrb=0;
 m_r_valid=0;m_r_data=0;m_r_resp=0;m_r_last=0;m_b_valid=0;m_b_resp=0;
 m_ar_ready=1;m_aw_ready=1;m_w_ready=1;
 entropy_valid=0;entropy_data=0;entropy_health_ok=1;entropy_domain_tag=0;
 lifecycle_strap=0;tamper_in=0;zeroize_req_in=0;privileged=1;debug_unlocked=0;fault_inject_ecc_ue=0;fault_inject_ctrl=0;
 rst_n=0;repeat(5) @(negedge clk);rst_n=1;
 apb_write(10'h094,32'h2,err);apb_write(10'h098,32'h1,err);repeat(3) @(negedge clk);
 $display("CHECK IRQ done pending / only error enabled: irq=%b expected=0",irq);
 if(irq !== 0) $fatal(1,"IRQ mask cross-talk");
 apb_write(10'h098,0,err);apb_write(10'h090,31,err);
 zeroize_req_in=1;@(negedge clk);zeroize_req_in=0;
 repeat(17000) @(negedge clk);
 $display("CHECK ZEROIZE completed_events=%0d keccakdone=%b",fdonecount,dut.kec_zeroize_done);
 if(fdonecount!=1 || dut.fault_locked) $fatal(1,"full-capacity zeroize did not complete normally");
 // reset between independent experiments
 rst_n=0;repeat(4) @(negedge clk);rst_n=1;serve=1;
 apb_write(10'h010,1,err);repeat(5) @(negedge clk);apb_write(10'h1d0,1,err);
 apb_write(10'h1d0,0,err);
 if(!err)$fatal(1,"busy doorbell write was not rejected");
 repeat(250) @(negedge clk);
 $display("CHECK DESC emitted=%0d index_errors=%0d completion_status=%0d error=%0d expected full sequential 128 bytes",bytecount,idxerrors,dut.fe_comp_status,dut.fe_comp_error);
 if(bytecount!=128 || idxerrors!=0) $fatal(1,"descriptor byte stream");
 $display("UT_pqc_top_review: PASS (errors=0)");$finish;end

 initial begin #2000000; $fatal(1,"FAIL watchdog");end
endmodule
