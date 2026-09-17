`timescale 1ns/1ps
module ut_pqc_sram_byte_access;
  logic clk=0;always #5 clk=~clk;
  logic rst_n=0,cq=0,cw=0,cy,dq=0,dw=0,dy,denied,ded,ued;
  logic [15:0] ca=0,da=0,inj_addr=0;
  logic [31:0] cd=0,cr,dd=0,dr;
  logic [3:0] strb=0;
  logic tw=0,secret=0,tvalid=1,inj=0;
  logic [38:0] inj_mask=0;
  logic saw_ded;
  pqc_secure_sram_ctrl #(.SIM_WORDS(512),.NUM_PAGES(2)) ram(
    .clk(clk),.rst_n(rst_n),.c0_req(cq),.c0_we(cw),.c0_addr(ca),.c0_wdata(cd),.c0_rdata(cr),.c0_ready(cy),
    .c1_req(1'b0),.c1_we(1'b0),.c1_addr(16'd0),.c1_wdata(32'd0),
    .d_req(dq),.d_we(dw),.d_addr(da),.d_wdata(dd),.d_wstrb(strb),.d_rdata(dr),.d_ready(dy),
    .tag_we(tw),.tag_page(8'd0),.tag_rep(4'd0),.tag_algo(4'd0),.tag_pset(4'd0),
    .tag_secret(secret),.tag_valid(tvalid),.tag_check_req(1'b0),.tag_check_page(8'd0),
    .access_denied(denied),.ecc_ded(ded),.ecc_ued(ued),
    .ecc_inject_en(inj),.ecc_inject_idx(inj_addr),.ecc_inject_mask(inj_mask),.zeroize_req(1'b0));

  task automatic compute_write(input logic[15:0] addr,input logic[31:0] data);
    int g;
    @(negedge clk);cq=1;cw=1;ca=addr;cd=data;g=0;
    do begin @(negedge clk);g++;end while(!cy && g<20);
    if(!cy) $fatal(1,"compute write did not complete");
    @(negedge clk);cq=0;cw=0;@(negedge clk);
  endtask
  task automatic dma_write(input logic[15:0] addr,input logic[31:0] data,input logic[3:0] keep);
    int g;
    @(negedge clk);dq=1;dw=1;da=addr;dd=data;strb=keep;g=0;saw_ded=0;
    do begin @(negedge clk);g++;saw_ded|=ded;end while(!dy && !denied && g<20);
    if(!dy || denied || ued) $fatal(1,"DMA masked write did not complete addr=%0d strb=%h",addr,keep);
    @(negedge clk);dq=0;dw=0;strb=0;@(negedge clk);
  endtask
  task automatic dma_read_check(input logic[15:0] addr,input logic[31:0] expected_data);
    int g;
    @(negedge clk);dq=1;dw=0;da=addr;g=0;
    do begin @(negedge clk);g++;end while(!dy && !denied && g<20);
    if(!dy || denied || dr!==expected_data || ded || ued)
      $fatal(1,"DMA read addr=%0d got=%h expected=%h",addr,dr,expected_data);
    @(negedge clk);dq=0;@(negedge clk);
  endtask
  task automatic set_tag(input bit is_secret);
    @(negedge clk);tw=1;secret=is_secret;
    @(negedge clk);tw=0;@(negedge clk);
  endtask
  task automatic inject(input logic[38:0] mask);
    @(negedge clk);inj=1;inj_mask=mask;
    @(negedge clk);inj=0;inj_mask=0;@(negedge clk);
  endtask
  task automatic deny_dma(input bit write_op,input bit check_ecc);
    logic[38:0] saved;
    saved=ram.u_store.mem[0];
    @(negedge clk);dq=1;dw=write_op;da=0;dd=32'h12345678;strb=4'h1;
    repeat(4)begin
      @(negedge clk);
      if(dy || dr!==0 || !denied || (check_ecc && !ued))
        $fatal(1,"denied DMA access leaked or lacked error write=%0d",write_op);
      if(ram.u_store.mem[0]!==saved) $fatal(1,"denied DMA access changed stored codeword");
    end
    dq=0;dw=0;strb=0;repeat(2) @(negedge clk);
  endtask

  initial begin
    logic[31:0] expected_data;
    repeat(3) @(negedge clk);rst_n=1;
    for(int mask=0;mask<16;mask++)begin
      compute_write(0,32'hdeadbeef);
      dma_write(0,32'h12345678,4'(mask));
      expected_data=32'hdeadbeef;
      for(int b=0;b<4;b++)if(mask & (1<<b))expected_data[b*8+:8]=8'(32'h12345678>>(b*8));
      dma_read_check(0,expected_data);
    end
    dma_write(4,32'hffffffff,0);
    if(ram.word_valid[4]) $fatal(1,"zero strobe published an uninitialized word");
    dma_write(4,32'h12345678,4'b0101);
    dma_read_check(4,32'h00340078);

    // Every single-bit position, including parity bits, must be corrected before
    // preserving old byte lanes. The newly encoded word must then read cleanly.
    for(int bit_index=0;bit_index<39;bit_index++)begin
      compute_write(0,32'hdeadbeef);inject(39'd1<<bit_index);
      dma_write(0,32'h000000aa,1);
      if(!saw_ded) $fatal(1,"partial write failed to report corrected ECC bit=%0d",bit_index);
      dma_read_check(0,32'hdeadbeaa);
    end
    compute_write(0,32'hdeadbeef);inject(39'd3);
    deny_dma(1,1);
    compute_write(0,32'hdeadbeef); // Full overwrite does not depend on damaged old data.
    dma_read_check(0,32'hdeadbeef);
    set_tag(1);deny_dma(0,0);deny_dma(1,0);
    set_tag(0);dma_read_check(0,32'hdeadbeef);

    // A tag update cannot race a fresh DMA write into a newly secret page.
    @(negedge clk);dq=1;dw=1;da=0;dd=32'h11111111;strb=15;tw=1;secret=1;
    #1;if(!denied || dy) $fatal(1,"same-cycle secret publication did not reject DMA");
    @(negedge clk);dq=0;tw=0;dw=0;
    set_tag(0);dma_read_check(0,32'hdeadbeef);

    // Revoke an already registered public read before the consumer can use it.
    @(negedge clk);dq=1;dw=0;da=0;
    @(negedge clk);
    if(!dy || dr!==32'hdeadbeef) $fatal(1,"public read setup failed");
    tw=1;secret=1;dq=0;#1;
    if(dy || dr!==0) $fatal(1,"tag revocation did not gate pending DMA response");
    @(negedge clk);tw=0;
    if(ram.rd_data!==0 || ram.acc_valid) $fatal(1,"revoked response not physically cleared");
    $display("UT_pqc_sram_byte_access: PASS (errors=0)");$finish;
  end
  initial begin #200000;$fatal(1,"SRAM byte access watchdog");end
endmodule
