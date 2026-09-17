`timescale 1ns/1ps
// Cancellation is asserted with real stalled transactions, without forcing
// internal state. No downstream memory or consumer may accept on the clear edge.
module ut_pqc_engine_cancel;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,start=0,clear=0;
  wire cr,cw,cd,pr,pw,pd,sr,sw,sd,sready,hir,hov,hd,dsr,dsw,dd,commit;
  wire dpstart;
  logic dpdone=0;
  int writes=0,errors=0;
  pqc_codec codec(.clk(clk),.rst_n(rst_n),.start(start),.op(4'd2),.domain(1'b0),
    .d_comp(5'd10),.gamma2_sel(2'd0),.src_page(8'd0),.src2_page(8'd1),.dst_page(8'd2),
    .bound(32'd100),.done(cd),.mem_req(cr),.mem_we(cw),.mem_rdata(32'd19),
    .mem_ready(!cw),.zeroize_req(clear));
  pqc_poly_engine poly(.clk(clk),.rst_n(rst_n),.start(start),.prim(4'd4),.domain(1'b0),
    .src_page(8'd0),.src2_page(8'd1),.dst_page(8'd2),.done(pd),.mem_req(pr),.mem_we(pw),
    .mem_rdata(32'd17),.mem_ready(!pw),.zeroize_req(clear));
  pqc_sampler sampler(.clk(clk),.rst_n(rst_n),.start(start),.mode(3'd0),.domain(1'b0),
    .dst_page(8'd2),.eta(4'd2),.tau(7'd39),.gamma1_sel(5'd17),.done(sd),
    .sqz_valid(1'b1),.sqz_ready(sready),.sqz_data(8'h59),.mem_req(sr),.mem_we(sw),
    .mem_ready(1'b0),.zeroize_req(clear));
  pqc_keccak hash(.clk(clk),.rst_n(rst_n),.start(start),.function_id(3'd0),.ctx_sel(1'b0),
    .out_len(32'd32),.in_valid(1'b0),.in_ready(hir),.in_last(1'b1),.in_data(8'd0),
    .out_valid(hov),.out_ready(1'b0),.done(hd),.zeroize_req(clear));
  pqc_dsa_seq dsa(.clk(clk),.rst_n(rst_n),.start(start),.op(2'd1),.pset(3'd4),
    .done(dd),.prim_start(dpstart),.prim_busy(1'b0),.prim_done(dpdone),
    .norm_z_ok(1'b1),.norm_r0_ok(1'b1),.hint_weight_ok(1'b1),
    .stage_req(dsr),.stage_we(dsw),.stage_rdata(8'h97),.stage_ready(1'b0),
    .commit_valid(commit),.ct_calc_we(1'b0),.ct_calc_byte(8'd0),
    .ct_ref_we(1'b0),.ct_ref_byte(8'd0),.ct_clear(1'b0),.zeroize_req(clear));
  always @(posedge clk) dpdone<=rst_n&&dpstart;
  task automatic check_clear;
    if(cr||cw||cd||pr||pw||pd||sr||sw||sd||sready||hir||hov||hd||dsr||dsw||dd||commit||dpstart)
      $fatal(1,"FAIL clear permitted handshake codec=%b%b poly=%b%b sampler=%b%b hash=%b%b dsa=%b%b",cr,cw,pr,pw,sr,sw,hir,hov,dsr,dsw);
  endtask
  initial begin
    repeat(3)@(negedge clk);rst_n=1;start=1;
    @(negedge clk);start=0;
    wait(cr&&cw&&pr&&pw&&sr&&sw&&hov&&dsr&&dsw);
    @(negedge clk);clear=1;#1;check_clear();
    repeat(3)begin @(negedge clk);check_clear();end
    clear=0;repeat(3)@(negedge clk);
    if(cr||pr||sr||hov||dsr||commit)$fatal(1,"FAIL canceled transaction resumed");
    // Start again after clear to ensure the gate did not permanently disable engines.
    start=1;@(negedge clk);start=0;
    wait(cr&&cw&&pr&&pw&&sr&&sw&&hov&&dsr&&dsw);
    @(negedge clk);rst_n=0;#1;check_clear();
    $display("UT_pqc_engine_cancel: PASS (errors=0)");$finish;
  end
  initial begin #20000;$fatal(1,"TIMEOUT");end
endmodule
