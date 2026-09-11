// Native generated CSR interface probe. This is not the IP behavior/RM testbench.
module csr_interface_probe;
  import apb_secure_demux_csr_pkg::*;
  bit clk=0;
  always #5 clk=~clk;
  logic arst_n, psel, penable, pwrite;
  logic [13:0] paddr;
  logic [31:0] pwdata, prdata;
  logic [3:0] pstrb;
  logic pready, pslverr;
  apb_secure_demux__in_t hwif_in;
  apb_secure_demux__out_t hwif_out;
  apb_secure_demux_csr_regblock dut(.clk, .arst_n, .s_apb_psel(psel), .s_apb_penable(penable),
    .s_apb_pwrite(pwrite), .s_apb_pprot(3'b001), .s_apb_paddr(paddr),
    .s_apb_pwdata(pwdata), .s_apb_pstrb(pstrb), .s_apb_prdata(prdata),
    .s_apb_pready(pready), .s_apb_pslverr(pslverr), .hwif_in, .hwif_out);
  always_comb begin
    hwif_in = '{default:'0};
    hwif_in.IP_ID.rd_ack = hwif_out.IP_ID.req && !hwif_out.IP_ID.req_is_wr;
    hwif_in.IP_ID.rd_data.value = 32'h41534458;
    hwif_in.INTR_RAW.rd_ack = hwif_out.INTR_RAW.req && !hwif_out.INTR_RAW.req_is_wr;
    hwif_in.INTR_RAW.wr_ack = hwif_out.INTR_RAW.req && hwif_out.INTR_RAW.req_is_wr;
    hwif_in.INTR_RAW.rd_data = 32'h1a5;
    hwif_in.COMMIT_MASK.wr_ack = hwif_out.COMMIT_MASK.req && hwif_out.COMMIT_MASK.req_is_wr;
  end
  task automatic transfer(input bit wr, input logic [13:0] addr,
                          input logic [31:0] data, input bit err,
                          input logic [31:0] expected);
    @(negedge clk); psel=1; penable=0; pwrite=wr; paddr=addr; pwdata=data; pstrb=4'hf;
    @(negedge clk); penable=1;
    #1;
    if (pready !== 1'b1) $fatal(1,"CSR first ACCESS has a wait at addr %h",addr);
    if (pslverr !== err) $fatal(1,"CSR error mismatch at %h: %b expected %b",addr,pslverr,err);
    if (!wr && !err && prdata !== expected) $fatal(1,"CSR read mismatch at %h",addr);
    if (wr && addr==14'h01c && hwif_out.COMMIT_MASK.wr_data.ports !== data)
      $fatal(1,"external command write payload mismatch");
    @(posedge clk); #1;
  endtask
  initial begin
    arst_n=0; psel=0; penable=0; pwrite=0; paddr=0; pwdata=0; pstrb=0;
    repeat(2) @(negedge clk); arst_n=1;
    transfer(0,14'h000,0,0,32'h41534458);
    transfer(1,14'h01c,32'h5,0,0);
    transfer(0,14'h030,0,0,32'h1a5);
    transfer(1,14'h030,32'h1a5,0,0);
    transfer(1,14'h000,0,1,0); // RO write
    transfer(0,14'h01c,0,1,0); // WO read
    transfer(0,14'h068,0,1,0); // hole
    transfer(0,14'hfff,0,1,0); // native adapter aligns address; wrapper must check alignment
    transfer(0,14'h000,0,0,32'h41534458);
    @(negedge clk); psel=0; penable=0;
    $display("CSR_INTERFACE_PROBE PASS"); $finish;
  end
  initial begin #2000; $fatal(1,"probe timeout"); end
endmodule
