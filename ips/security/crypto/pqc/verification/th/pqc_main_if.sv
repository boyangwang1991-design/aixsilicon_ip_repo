// PQC reduced AXI adapter, single outstanding burst. Full AXI VIP qualification
// remains separate; this responder supplies real byte-addressed external memory.
interface pqc_main_if(input logic clk,input logic rst_n);
  logic arvalid,arready,rvalid,rready,rlast,awvalid,awready,wvalid,wready,wlast,bvalid,bready;
  logic [39:0] araddr,awaddr;
  logic [7:0] arlen,awlen;
  logic [127:0] rdata,wdata;
  logic [15:0] wstrb;
  logic [1:0] rresp,bresp;
  logic irq,entropy_ready;
  logic sign_attempt_boundary;
  logic [31:0] sign_attempt_cycles;
  logic entropy_enable=0;
  logic [7:0] entropy_tag=8'h11;
  byte unsigned mem[0:262143];
  byte unsigned entropy_bytes[0:63];
  int unsigned entropy_index,read_addr,read_left,write_addr,write_left,b_wait,cycles;
  int unsigned response_delay=17;
  bit stalls_enabled=1;
  logic reading,writing,pending_b;
  int unsigned entropy_words=4;
  logic [63:0] entropy_data;
  // Trusted Key Manager sideload (import of a complete private key). The test
  // drives km_begin once and streams words while km_ready; the DUT responds
  // with km_done when the key is stored and verified.
  logic km_begin=0,km_valid=0,km_last=0;
  logic [31:0] km_handle=0;
  logic [3:0] km_algo=1,km_pset=1;
  logic [7:0] km_usage=0;
  logic [15:0] km_bytes=0;
  logic [31:0] km_data=0;
  logic km_begin_ready,km_ready,km_done,km_error;
  byte unsigned km_payload[0:8191];
  int unsigned km_index;
  logic km_loading;

  logic [31:0] km_generated_handle=0,km_generated_epoch=1;
  logic [7:0] km_generated_owner=0,km_generated_domain=0;
  logic km_custody_header_valid,km_custody_header_ready=0;
  logic [31:0] km_custody_transaction,km_custody_epoch,km_custody_handle;
  logic [7:0] km_custody_owner,km_custody_domain;
  logic [3:0] km_custody_algo,km_custody_pset;
  logic [15:0] km_custody_bytes;
  logic km_custody_valid,km_custody_ready=0,km_custody_last;
  logic [31:0] km_custody_data;
  logic km_custody_ack_valid=0,km_custody_ack_ready;
  logic [31:0] km_custody_ack_transaction=0,km_custody_ack_epoch=0,km_custody_ack_handle=0;
  logic [7:0] km_custody_ack_owner=0,km_custody_ack_domain=0;
  logic [15:0] km_custody_ack_bytes=0;
  logic km_custody_ack_success=0;

  always_comb begin
    for(int i=0;i<8;i++) entropy_data[8*i+:8]=entropy_bytes[8*entropy_index+i];
    arready=!reading && (!stalls_enabled || cycles%7!=0);
    awready=!writing && !pending_b && !bvalid && (!stalls_enabled || cycles%5!=0);
    wready=writing && (!stalls_enabled || cycles%3!=0);
    rresp=0;bresp=0;
  end
  always @(posedge clk) begin
    if(!rst_n) begin
      reading<=0;writing<=0;pending_b<=0;bvalid<=0;rvalid<=0;rlast<=0;
      rdata<=0;read_addr<=0;read_left<=0;write_addr<=0;write_left<=0;b_wait<=0;cycles<=0;entropy_index<=0;
      km_index<=0;km_loading<=0;
    end else begin
      cycles<=cycles+1;
      // KM sideload: once km_begin is asserted, stream one 32-bit word per
      // accepted cycle until all bytes of the private key are delivered.
      if(km_begin && km_begin_ready && !km_loading) begin
        km_loading<=1;km_index<=0;
      end
      if(km_loading && km_ready && !km_done && !km_error) begin
        km_data<={km_payload[4*km_index+3],km_payload[4*km_index+2],
                  km_payload[4*km_index+1],km_payload[4*km_index+0]};
        km_valid<=1;
        km_last<=(4*(km_index+1)>=km_bytes);
        if(4*(km_index+1)>=km_bytes) km_loading<=0;
        else km_index<=km_index+1;
      end else if(km_valid && !km_ready) begin
        // hold the word while back-pressured
      end else begin
        km_valid<=0;km_last<=0;
      end
      if(entropy_enable && entropy_ready) entropy_index<=(entropy_index+1)%entropy_words;
      if(arvalid && arready) begin
        reading<=1;read_addr<=int'(araddr);read_left<=int'(arlen)+1;
        if(araddr>=$size(mem) || araddr+16*(int'(arlen)+1)>$size(mem)) $fatal(1,"AXI read outside test memory");
      end
      if(reading && !rvalid && (!stalls_enabled || cycles%4!=0)) begin
        for(int i=0;i<16;i++) rdata[8*i+:8]<=mem[read_addr+i];
        rvalid<=1;rlast<=read_left==1;
      end
      if(rvalid && rready) begin
        rvalid<=0;read_addr<=read_addr+16;read_left<=read_left-1;
        if(read_left==1) reading<=0;
      end
      if(awvalid && awready) begin
        writing<=1;write_addr<=int'(awaddr);write_left<=int'(awlen)+1;
        if(awaddr>=$size(mem) || awaddr+16*(int'(awlen)+1)>$size(mem)) $fatal(1,"AXI write outside test memory");
      end
      if(wvalid && wready) begin
        for(int i=0;i<16;i++) if(wstrb[i]) mem[write_addr+i]<=wdata[8*i+:8];
        if(wlast !== (write_left==1)) $fatal(1,"AXI WLAST mismatch");
        write_addr<=write_addr+16;write_left<=write_left-1;
        if(write_left==1) begin writing<=0;pending_b<=1;b_wait<=response_delay;end
      end
      if(pending_b) begin
        if(b_wait==0) begin bvalid<=1;pending_b<=0;end else b_wait<=b_wait-1;
      end
      if(bvalid && bready) bvalid<=0;
    end
  end
endinterface
