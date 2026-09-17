`timescale 1ns/1ps
module ut_pqc_masked_random_path;
 logic clk=0;always #5 clk=~clk;
 logic rst_n=0,clear=0,req_valid=0,req_ready,entropy_valid=1,entropy_ready;
 logic [63:0] entropy_data=64'h123456789abcdef0;
 logic [4:0] cv,cr;
 logic [4:0][4799:0] data;
 logic [31:0] epoch,primitive_id,lease,index;
 wire release_valid;
 logic clear_done,rng_fault,round_fault,round_clear;
 logic [31:0] clear_epoch=0;
 logic [4:0][31:0] ack_epoch='0;
 logic [4:0] ack=31;
 logic iv=0,ir,ov,orr=0,rr;
 logic [1599:0] s0,s1,o0,o1;
 logic [95:0] token=96'h000000010000000700000000;
 logic [63:0] rc=1;
 int beats=0,consumes=0,releases=0;
 assign cr={4'b0,rr};
 pqc_random_service rng_service(
   .clk(clk),.rst_n(rst_n),.trusted_epoch(32'd1),.trusted_domain(8'h12),
   .req_valid(req_valid),.req_ready(req_ready),.req_consumer(3'd0),.req_purpose(3'd1),
   .req_epoch(32'd1),.req_primitive(32'd7),.req_quota_bits(32'd9600),.req_wait_limit(32'd1000),
   .req_chunk_bits(13'd4800),.entropy_valid(entropy_valid),.entropy_ready(entropy_ready),
   .entropy_data(entropy_data),.entropy_domain(8'h12),.entropy_health_ok(1'b1),
   .chunk_valid(cv),.chunk_ready(cr),.chunk_data(data),.chunk_epoch(epoch),.chunk_primitive(primitive_id),
   .chunk_lease(lease),.chunk_index(index),.release_valid(release_valid),.release_consumer(3'd0),
   .release_epoch(epoch),.release_primitive(primitive_id),.release_lease(lease),.release_index(index),
   .next_chunk_bits(13'd4800),.clear_req(clear),.clear_epoch(clear_epoch),
   .consumer_clear_done(ack),.consumer_clear_epoch(ack_epoch),.clear_done(clear_done),.fault(rng_fault));
 pqc_keccak_masked_round round_dut(
   .clk(clk),.rst_n(rst_n),.in_valid(iv),.in_ready(ir),.in_share0(s0),.in_share1(s1),
   .round_constant(rc),.in_token(token),.random_valid(cv[0]),.random_ready(rr),
   .random_r(data[0][1599:0]),.random_s(data[0][3199:1600]),.random_m(data[0][4799:3200]),
   .random_token({epoch,primitive_id,index}),.random_release(release_valid),
   .out_valid(ov),.out_ready(orr),.out_share0(o0),.out_share1(o1),
   .zeroize_req(clear),.zeroize_done(round_clear),.fault(round_fault));
 always @(posedge clk)if(rst_n)begin
   if(entropy_valid&&entropy_ready)begin
     entropy_data<={entropy_data[62:0],entropy_data[63]^entropy_data[62]^entropy_data[60]^entropy_data[59]};beats++;
   end
   if(cv[0]&&rr)consumes++;
   if(release_valid)releases++;
   if(data[4:1]!='0||cv[4:1]!=0)$fatal(1,"FAIL random broadcast");
 end
 task automatic tick;@(posedge clk);#1;endtask
 task automatic begin_lease;
   @(negedge clk);req_valid=1;#1;if(!req_ready)$fatal(1,"FAIL request blocked");
   tick();@(negedge clk);req_valid=0;
 endtask
 task automatic submit_round(input int n);
   @(negedge clk);iv=1;token[31:0]=32'(n);rc=64'(n+1);
   // Two equal nonzero shares encode the zero state.
   s0={25{64'h35eabcdc91827364}};s1=s0;#1;
   if(!ir)$fatal(1,"FAIL round blocked");tick();@(negedge clk);iv=0;
 endtask
 initial begin
   s0='0;s1='0;repeat(3)tick();@(negedge clk);rst_n=1;repeat(3)tick();
   begin_lease();
   for(int n=0;n<2;n++)begin
     submit_round(n);
     wait(ov);#1;
     if((o0^o1)!=={1536'd0,64'(n+1)}||beats!=75*(n+1)||consumes!=n+1||releases!=n+1)
       $fatal(1,"FAIL round/cache path counts beats=%0d consumes=%0d releases=%0d",beats,consumes,releases);
     repeat(4)tick();@(negedge clk);orr=1;tick();@(negedge clk);orr=0;
   end
   if(!req_ready||rng_fault||round_fault)$fatal(1,"FAIL lease completion");
   begin_lease();submit_round(0);
   wait(cv[0]&&rr);tick();
   @(negedge clk);clear=1;clear_epoch=9;ack=0;#1;
   if(ov||cv||rr||entropy_ready||release_valid)$fatal(1,"FAIL cancel priority across modules");
   tick();if(!round_clear||rng_service.cache!='0)$fatal(1,"FAIL local wipe");
   ack=31;repeat(2)tick();if(clear_done)$fatal(1,"FAIL old ACK accepted");
   for(int i=0;i<5;i++)ack_epoch[i]=9;
   #1;if(!clear_done)$fatal(1,"FAIL current ACK rejected");
   if(rng_fault||round_fault)$fatal(1,"FAIL clear caused fault");
   $display("UT_pqc_masked_random_path: PASS (errors=0)");$finish;
 end
 initial begin #30000;$fatal(1,"TIMEOUT");end
endmodule
