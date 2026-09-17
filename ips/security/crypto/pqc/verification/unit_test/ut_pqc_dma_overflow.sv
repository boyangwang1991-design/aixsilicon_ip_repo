`timescale 1ns/1ps
module ut_pqc_dma_overflow;
logic clk=0;always #5 clk=~clk;logic rst_n=0,req=0,err,ar;logic [2:0] prot;
pqc_dma #(.ADDR_WIDTH(40)) dut(.clk(clk),.rst_n(rst_n),.xfer_req(req),.xfer_we(1'b0),.xfer_addr(40'b0),.xfer_len(64'h0000020000000010),.xfer_secure(1'b0),.xfer_priv(1'b0),.xfer_error(err),.buf_ready(1'b1),.buf_rdata(32'b0),.m_ar_valid(ar),.m_ar_ready(1'b0),.m_ar_prot(prot),.m_r_valid(1'b0),.m_r_data(128'b0),.m_r_resp(2'b0),.m_r_last(1'b0),.m_aw_ready(1'b0),.m_w_ready(1'b0),.m_b_valid(1'b0),.m_b_resp(2'b0),.zeroize_req(1'b0));
initial begin repeat(4) @(negedge clk);rst_n=1;req=1;repeat(8) @(negedge clk);
$display("CHECK DMA oversized len=2^41+16 arvalid=%b error=%b expected=0,1; nonsecure unpriv PROT=%b expected=010",ar,err,prot);if(ar !== 0 || err !== 1 || prot !== 3'b010) $fatal(1,"DMA range/protection");$display("UT_pqc_dma_overflow: PASS (errors=0)");$finish;end

 initial begin #2000000; $fatal(1,"watchdog");end
endmodule
