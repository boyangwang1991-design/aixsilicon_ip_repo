`timescale 1ns/1ps
module ut_pqc_seq_dispatch;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,start=0,clear=0;
 logic [1:0] kop=0,dop=1,rank=0;
 logic [2:0] pset=4;
 logic [15:0] ct_bytes=768;
 wire ks,ds,kdone,ddone,kerror,kbusy,dbusy,kwe;
 wire [15:0] clen,slen;
 logic engine_busy=1,kpd=0,dpd=0;
 int kissued=0,dissued=0;
 pqc_kem_seq kem(.clk(clk),.rst_n(rst_n),.start(start),.op(kop),.rank(rank),
   .busy(kbusy),.done(kdone),.op_error(kerror),.prim_start(ks),.prim_busy(engine_busy),.prim_done(kpd),
   .ct_bytes(ct_bytes),.ct_len(clen),.ct_read_data(8'd0),.ct_calc_data(8'd0),
   .kprime_data(8'd0),.kbar_data(8'd0),.ss_we(kwe),.zeroize_req(clear));
 pqc_dsa_seq dsa(.clk(clk),.rst_n(rst_n),.start(start),.op(dop),.pset(pset),
   .busy(dbusy),.done(ddone),.prim_start(ds),.prim_busy(engine_busy),.prim_done(dpd),
   .norm_z_ok(1'b1),.norm_r0_ok(1'b1),.hint_weight_ok(1'b1),
   .stage_rdata(8'd0),.stage_ready(1'b0),.sig_len(slen),.ct_calc_we(1'b0),.ct_calc_byte(8'd0),
   .ct_ref_we(1'b0),.ct_ref_byte(8'd0),.ct_clear(1'b0),.zeroize_req(clear));
 always @(posedge clk)begin if(ks)kissued++;if(ds)dissued++;end
 task automatic tick;@(posedge clk);#1;endtask
 task automatic launch;
   @(negedge clk);start=1;tick();@(negedge clk);start=0;
 endtask
 initial begin
   repeat(3)tick();@(negedge clk);rst_n=1;launch();repeat(3)tick();
   if(ks||ds||kissued||dissued)$fatal(1,"FAIL dispatch while busy");
   // Completion before a request was accepted must not retire an operation.
   @(negedge clk);kpd=1;dpd=1;repeat(3)tick();
   if(kdone||ddone||dsa.astate!=dsa.A_EXPAND_Y)$fatal(1,"FAIL stale completion retired operation");
   @(negedge clk);kpd=0;dpd=0;engine_busy=0;tick();
   if(kissued!=1||dissued!=1)$fatal(1,"FAIL first dispatch");
   // Poison live command inputs: the accepted operation and lengths must persist.
   @(negedge clk);kop=3;dop=2;pset=6;ct_bytes=0;
   repeat(7)tick();
   if(ks||ds||kissued!=1||dissued!=1||clen!=768||slen!=2420)
     $fatal(1,"FAIL duplicate dispatch or mutable command");
   @(negedge clk);kpd=1;dpd=1;tick();
   if(!kdone||kerror)$fatal(1,"FAIL matching completion");
   @(negedge clk);kpd=0;dpd=0;engine_busy=1;repeat(3)tick();
   if(ds||dissued!=1)$fatal(1,"FAIL next primitive ignored busy");
   @(negedge clk);engine_busy=0;tick();
   if(dissued!=2)$fatal(1,"FAIL second dispatch");
   @(negedge clk);clear=1;#1;
   if(ks||ds||kdone||ddone)$fatal(1,"FAIL cancel priority");
   tick();@(negedge clk);clear=0;repeat(3)tick();
   // Every malformed KEM length/operation is rejected without side effects.
   for(int c=0;c<4;c++)begin
     kop=(c==0)?3:2;rank=(c==1)?3:0;ct_bytes=(c==2)?0:128;
     launch();
     if(!kdone||!kerror||ks||kwe)$fatal(1,"FAIL malformed KEM command accepted");
     repeat(3)tick();
   end
   $display("UT_pqc_seq_dispatch: PASS (errors=0)");$finish;
 end
 initial begin #20000;$fatal(1,"TIMEOUT");end
endmodule
