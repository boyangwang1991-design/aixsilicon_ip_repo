`timescale 1ns/1ps
module ut_pqc_kem_select;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,start=0,zeroize_req=0;
  logic [1:0] op=2,rank=0;
  logic busy,done,op_error,prim_start,prim_domain;
  logic [3:0] prim_op;
  logic prim_busy=0,prim_done=0;
  logic [7:0] poly_src_page,poly_src2_page,poly_dst_page;
  logic [15:0] ct_bytes=768,ct_read_addr,ct_calc_addr,ss_addr,ct_len;
  logic [7:0] ct_read_data,ct_calc_data,kprime_data,kbar_data,ss_wdata,verify_mask;
  logic ss_we;
  int mismatch=-1,errors=0,writes=0,compares=0,elapsed=0,base_elapsed=0;
  bit monitor=0;
  function automatic logic [7:0] ciphertext(input logic [15:0] a);
    return 8'((int'(a)*137) ^ (int'(a)>>3));
  endfunction
  function automatic logic [7:0] secret_byte(input int a,input bit reject);
    return 8'(a*29+(reject?93:17));
  endfunction
  assign ct_read_data=ciphertext(ct_read_addr);
  assign ct_calc_data=ciphertext(ct_calc_addr) ^ (int'(ct_calc_addr)==mismatch?8'h80:8'h00);
  assign kprime_data=secret_byte(int'(ss_addr),0);
  assign kbar_data=secret_byte(int'(ss_addr),1);
  pqc_kem_seq dut(.*);
  always @(posedge clk)begin
    if(!rst_n)prim_done<=0;else prim_done<=prim_start;
    if(monitor)begin
      if(dut.qstate==dut.Q_COMPARE)begin
        if(ct_read_addr!=compares || ct_calc_addr!=compares)$fatal(1,"FAIL compare address");
        compares++;
      end
      if(ss_we)begin
        if(ss_addr!=writes || ss_wdata!==secret_byte(writes,mismatch>=0))
          $fatal(1,"FAIL select byte %0d addr=%0d data=%h expected=%h",writes,ss_addr,ss_wdata,secret_byte(writes,mismatch>=0));
        writes++;
      end
    end
  end
  task automatic run_case(input int n,input int bad);
    @(negedge clk);ct_bytes=16'(n);mismatch=bad;writes=0;compares=0;monitor=1;start=1;
    @(negedge clk);start=0;elapsed=0;
    while(!done&&elapsed<2*n+100)begin @(negedge clk);elapsed++;end
    if(!done||op_error)$fatal(1,"FAIL completion");
    repeat(2)@(negedge clk);
    if(writes!=32||compares!=n)$fatal(1,"FAIL transaction counts writes=%0d compares=%0d",writes,compares);
    if(bad==-1)base_elapsed=elapsed;
    else if(elapsed!=base_elapsed)$fatal(1,"FAIL data-dependent latency n=%0d bad=%0d cycles=%0d baseline=%0d",n,bad,elapsed,base_elapsed);
    monitor=0;
  endtask
  initial begin
    repeat(3)@(negedge clk);rst_n=1;
    for(int p=0;p<3;p++)begin
      int n;
      rank=2'(p);case(p)0:n=768;1:n=1088;default:n=1568;endcase
      run_case(n,-1);
      for(int bad=0;bad<n;bad++)run_case(n,bad);
    end
    // Revoke during a pending secret write: no side effect on that edge.
    @(negedge clk);start=1;mismatch=-1;
    @(negedge clk);start=0;
    wait(dut.qstate==dut.Q_SELECT);
    @(negedge clk);zeroize_req=1;#1;
    if(ss_we||prim_start||done)$fatal(1,"FAIL zeroize must immediately revoke output");
    @(negedge clk);zeroize_req=0;repeat(3)@(negedge clk);
    if(ss_we||busy)$fatal(1,"FAIL zeroize did not drain");
    $display("UT_pqc_kem_select: PASS (errors=0)");$finish;
  end
  initial begin #200000000;$fatal(1,"TIMEOUT");end
endmodule
