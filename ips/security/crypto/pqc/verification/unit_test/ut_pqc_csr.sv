// Direct APB verification of the generated CSR contract; no substitute decoder.
`timescale 1ns/1ps
module ut_pqc_csr;
  import pqc_csr_pkg::*;
  logic clk=0; always #5 clk=~clk;
  logic rst_n=0, psel=0, penable=0, pwrite=0;
  logic [9:0] paddr=0;
  logic [31:0] pwdata=0, prdata;
  logic [3:0] pstrb=0;
  logic pready, pslverr;
  pqc_csr__in_t hwif_in;
  pqc_csr__out_t hwif_out;
  logic writes_enabled=1, events=0, perf_update=0;
  logic [31:0] perf_next=0;
  int errors=0, pulses[13];
  logic [12:0] pulse_bus;
  pqc_csr dut(.clk(clk),.arst_n(rst_n),.s_apb_psel(psel),.s_apb_penable(penable),
    .s_apb_pwrite(pwrite),.s_apb_pprot(3'b001),.s_apb_paddr(paddr),
    .s_apb_pwdata(pwdata),.s_apb_pstrb(pstrb),.s_apb_pready(pready),
    .s_apb_prdata(prdata),.s_apb_pslverr(pslverr),.hwif_in(hwif_in),.hwif_out(hwif_out));
  assign pulse_bus={hwif_out.KEY_SLOT_CTRL.lock_req.value,
    hwif_out.KEY_SLOT_CTRL.export_req.value,hwif_out.KEY_SLOT_CTRL.destroy_req.value,
    hwif_out.KEY_SLOT_CTRL.import_req.value,hwif_out.INTR_TEST.self_test_fail_test.value,
    hwif_out.INTR_TEST.tamper_test.value,hwif_out.INTR_TEST.rng_fault_test.value,
    hwif_out.INTR_TEST.error_test.value,hwif_out.INTR_TEST.done_test.value,
    hwif_out.DOORBELL.doorbell.value,hwif_out.CTRL.self_test.value,
    hwif_out.CTRL.zeroize.value,hwif_out.CTRL.abort.value};
  always @(posedge clk) begin
    #1;
    if(rst_n) for(int i=0;i<13;i++) if(pulse_bus[i]) pulses[i]++;
  end
  always_comb begin
    hwif_in='{default:'0};
    hwif_in.CTRL.enable.swwe=writes_enabled;
    hwif_in.COMMAND.opcode.swwe=writes_enabled;
    hwif_in.COMMAND.parameter_set.swwe=writes_enabled;
    hwif_in.COMMAND.flags.swwe=writes_enabled;
    hwif_in.COMMAND.abi.swwe=writes_enabled;
    hwif_in.SRC0_ADDR_LO.src0_addr_lo.swwe=writes_enabled;
    hwif_in.SRC0_ADDR_HI.src0_addr_hi.swwe=writes_enabled;
    hwif_in.SRC0_LEN_LO.src0_len_lo.swwe=writes_enabled;
    hwif_in.SRC0_LEN_HI.src0_len_hi.swwe=writes_enabled;
    hwif_in.SRC1_ADDR_LO.src1_addr_lo.swwe=writes_enabled;
    hwif_in.SRC1_ADDR_HI.src1_addr_hi.swwe=writes_enabled;
    hwif_in.SRC1_LEN_LO.src1_len_lo.swwe=writes_enabled;
    hwif_in.SRC1_LEN_HI.src1_len_hi.swwe=writes_enabled;
    hwif_in.CONTEXT_ADDR_LO.context_addr_lo.swwe=writes_enabled;
    hwif_in.CONTEXT_ADDR_HI.context_addr_hi.swwe=writes_enabled;
    hwif_in.ENTROPY_POLICY.entropy_policy.swwe=writes_enabled;
    hwif_in.DST0_ADDR_LO.dst0_addr_lo.swwe=writes_enabled;
    hwif_in.DST0_ADDR_HI.dst0_addr_hi.swwe=writes_enabled;
    hwif_in.DST0_CAPACITY_LO.dst0_capacity_lo.swwe=writes_enabled;
    hwif_in.DST0_CAPACITY_HI.dst0_capacity_hi.swwe=writes_enabled;
    hwif_in.DST1_ADDR_LO.dst1_addr_lo.swwe=writes_enabled;
    hwif_in.DST1_ADDR_HI.dst1_addr_hi.swwe=writes_enabled;
    hwif_in.DST1_CAPACITY_LO.dst1_capacity_lo.swwe=writes_enabled;
    hwif_in.DST1_CAPACITY_HI.dst1_capacity_hi.swwe=writes_enabled;
    hwif_in.COMPLETION_ADDR_LO.completion_addr_lo.swwe=writes_enabled;
    hwif_in.COMPLETION_ADDR_HI.completion_addr_hi.swwe=writes_enabled;
    hwif_in.TIMEOUT_HINT.timeout_hint.swwe=writes_enabled;
    hwif_in.DESCRIPTOR_CRC.descriptor_crc.swwe=writes_enabled;
    hwif_in.KEY_HANDLE.slot_id.swwe=writes_enabled;
    hwif_in.KEY_HANDLE.owner.swwe=writes_enabled;
    hwif_in.KEY_HANDLE.generation.swwe=writes_enabled;
    hwif_in.CONTEXT_LEN.context_len.swwe=writes_enabled;
    hwif_in.DESC_ADDR_LO.desc_addr_lo.swwe=writes_enabled;
    hwif_in.DESC_ADDR_HI.desc_addr_hi.swwe=writes_enabled;
    hwif_in.INTR_STATE.done.hwset=events;
    hwif_in.INTR_STATE.error.hwset=events;
    hwif_in.INTR_STATE.rng_fault.hwset=events;
    hwif_in.INTR_STATE.tamper.hwset=events;
    hwif_in.INTR_STATE.self_test_fail.hwset=events;
    hwif_in.ALERT_RECOVERABLE.ecc_ded.hwset=events;
    hwif_in.ALERT_RECOVERABLE.dma_retry.hwset=events;
    hwif_in.ALERT_RECOVERABLE.perf_saturated.hwset=events;
    hwif_in.ALERT_FATAL.ecc_ued.hwset=events;
    hwif_in.ALERT_FATAL.tamper_fatal.hwset=events;
    hwif_in.ALERT_FATAL.selftest_fatal.hwset=events;
    hwif_in.ALERT_FATAL.integrity_fatal.hwset=events;
    hwif_in.ALERT_FATAL.retry_exhausted.hwset=events;
    hwif_in.PERF_TOTAL_CYCLES.total_cycles.next=perf_next;
    hwif_in.PERF_TOTAL_CYCLES.total_cycles.we=perf_update;
    hwif_in.PERF_TOTAL_CYCLES.total_cycles.swwe=writes_enabled;
    hwif_in.KEY_SLOT_GEN.generation.next=16'hf3a5;
    hwif_in.KEY_SLOT_DOMAIN.domain.next=8'hb7;
    for(int i=0;i<32;i++) begin
      hwif_in.KEY_SLOT_MIRROR[i].slot_owner.next=8'(i+64);
      hwif_in.KEY_SLOT_MIRROR[i].slot_valid.next=1;
    end
  end
  task automatic check(input logic [31:0] got, expected, input string label);
    if(got !== expected) begin
      $display("FAIL: %s got=%h expected=%h",label,got,expected); errors++;
    end
  endtask
  task automatic access(input bit wr, input logic [9:0] addr,
    input logic [31:0] data, input logic [3:0] strb,
    output logic [31:0] value, input bit expect_error=0);
    int waits;
    @(negedge clk); psel=1;penable=0;pwrite=wr;paddr=addr;pwdata=data;pstrb=strb;
    @(negedge clk);penable=1;
    waits=0; #1;
    while(!pready && waits<20) begin @(negedge clk);#1;waits++;end
    if(!pready) $fatal(1,"APB TIMEOUT addr=%h",addr);
    value=prdata;
    check(pslverr,expect_error,"APB response");
    @(negedge clk);psel=0;penable=0;pstrb=0;
  endtask
  task automatic wr(input logic [9:0] addr,input logic [31:0] value,input logic[3:0] strb=15);
    logic[31:0] unused;access(1,addr,value,strb,unused);
  endtask
  task automatic rd(input logic [9:0] addr,input logic [31:0] expected);
    logic[31:0] value;access(0,addr,0,0,value);check(value,expected,$sformatf("read %h",addr));
  endtask
  function automatic logic[31:0] mask_at(input int addr);
    case(addr)
      'h24,'h34,'h44,'h50,'h60,'h70,'h80,'h1d8: return 'hff;
      'h48:return 3;
      default:return '1;
    endcase
  endfunction
  logic [31:0] value,expected,bytemask;
  initial begin
    foreach(pulses[i]) pulses[i]=0;
    repeat(4) @(negedge clk);rst_n=1;
    rd('h000,32'h01100001);rd('h018,32'h01000000);rd('h048,2);
    rd('h010,0);rd('h07c,0);rd('h094,0);rd('h100,0);
    // All shadow words; readback masks are independent contract expectations.
    for(int index=0;index<28;index++) begin
      int addr;
      addr=(index==0)?'h18:((index<26)?'h20+4*(index-1):'h1d4+4*(index-26));
      expected=32'hb7c35a19 & mask_at(addr);
      wr(10'(addr),32'hb7c35a19);rd(10'(addr),expected);
      writes_enabled=0;wr(10'(addr),'1);rd(10'(addr),expected);writes_enabled=1;
      for(int b=0;b<4;b++) begin
        bytemask=32'hff<<(8*b);
        wr(10'(addr),32'h693ce7a4,4'(1<<b));
        expected=((expected & ~bytemask)|(32'h693ce7a4 & bytemask)) & mask_at(addr);
        rd(10'(addr),expected);
      end
      wr(10'(addr),0,0);rd(10'(addr),expected);
    end
    wr('h07c,32'hfedcba98);check(hwif_out.KEY_HANDLE.generation.value,'hfedc,"full generation");
    check(hwif_out.KEY_HANDLE.owner.value,'hba,"full owner");
    wr('h010,1);repeat(5) @(negedge clk);rd('h010,1);
    writes_enabled=0;wr('h010,0);rd('h010,1);writes_enabled=1;
    wr('h010,'hf);wr('h1d0,1);wr('h098,'h1f);wr('h200,'h7b25);
    repeat(5) @(negedge clk);
    for(int i=0;i<13;i++) check(pulses[i],1,$sformatf("one pulse %0d",i));
    rd('h010,1);rd('h1d0,0);rd('h098,0);rd('h200,'h325);
    wr('h010,1);wr('h1d0,0);wr('h098,0);wr('h200,'h325);
    wr('h010,'hf,0);wr('h1d0,1,0);wr('h098,'h1f,0);wr('h200,'h7b25,1);
    repeat(5) @(negedge clk);
    for(int i=0;i<13;i++) check(pulses[i],1,"zero/unselected write cannot pulse");
    for(int group_id=0;group_id<3;group_id++) begin
      int addr,mask;
      addr=(group_id==0)?'h90:((group_id==1)?'ha0:'ha4);
      mask=(group_id==1)?7:31;
      events=1;repeat(3) @(negedge clk);events=0;
      rd(10'(addr),32'(mask));wr(10'(addr),0);rd(10'(addr),32'(mask));
      wr(10'(addr),'1,14);rd(10'(addr),32'(mask));
      for(int b=0;b<5;b++) if(mask & (1<<b)) begin
        wr(10'(addr),32'(1<<b)); mask &= ~(1<<b);rd(10'(addr),32'(mask));
      end
      events=1;wr(10'(addr),'1);events=0;
      rd(10'(addr),(group_id==1)?7:31);wr(10'(addr),'1);rd(10'(addr),0);
    end
    perf_next=32'hdeadbeef;perf_update=1;repeat(3) @(negedge clk);perf_update=0;
    rd('h100,32'hdeadbeef);wr('h100,0,3);rd('h100,32'hdead0000);
    writes_enabled=0;wr('h100,0);rd('h100,32'hdead0000);writes_enabled=1;
    perf_update=1;wr('h100,0);perf_update=0;rd('h100,0);
    rd('h208,'hf3a5);rd('h20c,'hb7);
    for(int i=0;i<32;i++) rd(10'('h210+4*i),32'('h140+i));
    access(0,'h00c,0,0,value,1);access(1,'h08c,'1,15,value,1);
    access(0,'h290,0,0,value,1);access(1,'h3fc,'1,15,value,1);
    // Reset after writes must restore storage, including nonzero ABI/policy.
    @(negedge clk);rst_n=0;repeat(3) @(negedge clk);rst_n=1;
    rd('h018,'h01000000);rd('h048,2);rd('h07c,0);rd('h010,0);rd('h100,0);
    if(errors) $fatal(1,"UT_pqc_csr: FAIL (errors=%0d)",errors);
    $display("UT_pqc_csr: PASS (errors=0)");$finish;
  end
  initial begin #200000; $fatal(1,"TIMEOUT");end
endmodule
