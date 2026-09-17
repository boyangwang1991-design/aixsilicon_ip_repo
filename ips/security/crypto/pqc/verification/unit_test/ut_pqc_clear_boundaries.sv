`timescale 1ns/1ps
module ut_pqc_clear_boundaries;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,zeroize_req=0;
  logic c0_req=0,c0_we=0,c0_ready,c1_ready,d_ready;
  logic[31:0] c0_rdata,c1_rdata,d_rdata;
  logic tag_we=0,tag_valid=0,tag_check_ok,access_denied,ecc_ded,ecc_ued,zeroize_done;
  pqc_secure_sram_ctrl #(.SIM_WORDS(16),.NUM_PAGES(1)) mem(
    .clk(clk),.rst_n(rst_n),.c0_req(c0_req),.c0_we(c0_we),.c0_addr(16'd0),
    .c0_wdata(32'hdeadcafe),.c0_rdata(c0_rdata),.c0_ready(c0_ready),
    .c1_req(1'b0),.c1_we(1'b0),.c1_addr(16'd0),.c1_wdata(32'd0),.c1_rdata(c1_rdata),.c1_ready(c1_ready),
    .d_req(1'b0),.d_we(1'b0),.d_addr(16'd0),.d_wdata(32'd0),.d_wstrb(4'hf),.d_rdata(d_rdata),.d_ready(d_ready),
    .tag_we(tag_we),.tag_page(8'd0),.tag_rep(4'd1),.tag_algo(4'd1),.tag_pset(4'd1),
    .tag_secret(1'b1),.tag_valid(tag_valid),.tag_check_req(1'b1),.tag_check_page(8'd0),
    .tag_check_ok(tag_check_ok),.access_denied(access_denied),.ecc_ded(ecc_ded),.ecc_ued(ecc_ued),
    .ecc_inject_en(1'b0),.ecc_inject_idx(16'd0),.ecc_inject_mask(39'd0),
    .zeroize_req(zeroize_req),.zeroize_done(zeroize_done));
  logic start=0,prim_start,prim_done=0,done,busy,verify_valid,retry_exhausted,op_error;
  logic [1:0] op=2;
  logic [2:0] pset=6;
  logic stage_req,commit_valid;
  logic ct_calc_we=0,ct_ref_we=0,ct_clear=0;
  logic [7:0] ct_calc_byte=0,ct_ref_byte=0;
  pqc_dsa_seq dsa(.clk(clk),.rst_n(rst_n),.start(start),.op(op),.pset(pset),
    .busy(busy),.done(done),.verify_valid(verify_valid),.retry_exhausted(retry_exhausted),.op_error(op_error),
    .prim_start(prim_start),.prim_op(),.prim_domain(),.prim_busy(1'b0),.prim_done(prim_done),
    .poly_src_page(),.poly_src2_page(),.poly_dst_page(),
    .norm_z_ok(1'b1),.norm_r0_ok(1'b1),.hint_weight_ok(1'b1),
    .stage_req(stage_req),.stage_we(),.stage_addr(),.stage_wdata(),.stage_rdata(8'd0),.stage_ready(1'b1),
    .commit_valid(commit_valid),.sig_len(),.ct_calc_we(ct_calc_we),.ct_calc_byte(ct_calc_byte),
    .ct_ref_we(ct_ref_we),.ct_ref_byte(ct_ref_byte),.ct_clear(ct_clear),.zeroize_req(zeroize_req));
  always @(posedge clk) if(!rst_n||zeroize_req)prim_done<=0;else prim_done<=prim_start;
  int errors=0;
  task automatic ck(input bit ok,input string msg);
    if(!ok)begin $display("FAIL: %s",msg);errors++;end
  endtask
  task automatic bank_empty;
    for(int i=0;i<64;i++)
      ck(dsa.ct_calc_rf[i]===8'd0 && dsa.ct_ref_rf[i]===8'd0,$sformatf("digest physical wipe byte %0d",i));
  endtask
  task automatic fill_digest;
    @(negedge clk);ct_calc_we=1;ct_ref_we=1;
    for(int i=0;i<64;i++)begin ct_calc_byte=8'(i+1);ct_ref_byte=8'(i+1);@(negedge clk);end
    ct_calc_we=0;ct_ref_we=0;
  endtask
  initial begin
    repeat(3)@(negedge clk);rst_n=1;
    @(negedge clk);c0_req=1;c0_we=1;
    @(negedge clk);ck(c0_ready && c0_rdata==32'hdeadcafe,"setup response before cancellation");
    zeroize_req=1;#1;
    ck(!c0_ready&&!c1_ready&&!d_ready&&!tag_check_ok,"clear immediately suppresses ready and tag authorization");
    ck(c0_rdata==0&&c1_rdata==0&&d_rdata==0,"clear immediately hides previous response");
    @(negedge clk);c0_req=0;zeroize_req=0;tag_we=1;tag_valid=1;
    repeat(5)@(negedge clk);tag_we=0;
    repeat(20)@(negedge clk);ck(!tag_check_ok,"tag write during physical sweep rejected");
    // Invalid op/pset is a command error, never a successful empty signature.
    for(int cmd=0;cmd<4;cmd++) for(int set_id=0;set_id<8;set_id++)
      if(cmd==3 || set_id<4 || set_id>6)begin
        @(negedge clk);op=2'(cmd);pset=3'(set_id);start=1;
        @(negedge clk);start=0;
        ck(done&&op_error&&!prim_start&&!stage_req&&!commit_valid&&!verify_valid,"invalid DSA configuration fails before side effects");
        repeat(2)@(negedge clk);
      end
    op=2;pset=6;
    fill_digest();ct_clear=1;ct_calc_we=1;ct_ref_we=1;
    @(negedge clk);ct_clear=0;ct_calc_we=0;ct_ref_we=0;bank_empty();
    fill_digest();zeroize_req=1;ct_calc_we=1;ct_ref_we=1;
    @(negedge clk);bank_empty();ck(dsa.v_norm_ok_q==0,"latched checks cleared");
    zeroize_req=0;ct_calc_we=0;ct_ref_we=0;repeat(3)@(negedge clk);
    fill_digest();start=1;@(negedge clk);start=0;
    wait(done);@(negedge clk);ck(verify_valid,"valid fixture verify");
    zeroize_req=1;#1;ck(!verify_valid&&!done&&!retry_exhausted&&!op_error,"result outputs immediately revoked");
    @(negedge clk);bank_empty();zeroize_req=0;
    repeat(3)@(negedge clk);fill_digest();
    rst_n=0;ct_calc_we=1;ct_ref_we=1;repeat(3)@(negedge clk);bank_empty();
    ck(c0_rdata==0&&!c0_ready&&!tag_check_ok,"reset output isolation");
    if(errors)$fatal(1,"UT_pqc_clear_boundaries: FAIL (errors=%0d)",errors);
    $display("UT_pqc_clear_boundaries: PASS (errors=0)");$finish;
  end
  initial begin #20000;$fatal(1,"TIMEOUT");end
endmodule
