`timescale 1ns/1ps
module ut_apb_secure_demux_decode;
    logic [15:0] address;
    wire [2:0] hits;
    wire csr, valid;
    wire [1:0] port;
    wire [7:0] reason;
    wire [2:0] overlap_hits;
    wire overlap_csr, overlap_valid;
    wire [1:0] overlap_port;
    wire [7:0] overlap_reason;
    logic [31:0] high_address;
    wire [0:0] high_hits, high_port;
    wire high_csr, high_valid;
    wire [7:0] high_reason;
    int errors=0;
    int checks=0;
    int n;
    logic [2:0] expected_hits;
    logic expected_csr;
    apb_secure_demux_decode #(.NUM_PORTS(3),.ADDR_WIDTH(16),
        .PORT_BASE('{16'h1000,16'h2340,16'hfff0}),
        .PORT_SIZE('{17'h14,17'h2c,17'h10}),.CSR_BASE(16'h8000)) dut (
        .address_i(address),.port_hits_o(hits),.csr_hit_o(csr),
        .port_o(port),.port_valid_o(valid),.reason_o(reason));
    apb_secure_demux_decode #(.NUM_PORTS(3),.ADDR_WIDTH(16),
        .PORT_BASE('{16'h8000,16'h8000,16'h8000}),
        .PORT_SIZE('{17'h10,17'h10,17'h10}),.CSR_BASE(16'h8000)) overlap (
        .address_i(address),.port_hits_o(overlap_hits),.csr_hit_o(overlap_csr),
        .port_o(overlap_port),.port_valid_o(overlap_valid),.reason_o(overlap_reason));
    apb_secure_demux_decode #(.NUM_PORTS(1),.ADDR_WIDTH(32),
        .PORT_BASE('{32'hfffffff0}),.PORT_SIZE('{33'h10}),.CSR_BASE(32'h80000000)) high (
        .address_i(high_address),.port_hits_o(high_hits),.csr_hit_o(high_csr),
        .port_o(high_port),.port_valid_o(high_valid),.reason_o(high_reason));
    task automatic check(input bit ok);
        checks++;
        if (!ok) begin errors++; if(errors<10) $display("decode mismatch addr=%h",address); end
    endtask
    initial begin
        address=0; high_address=0;
        for (int a=0;a<65536;a++) begin
            address=16'(a); #1;
            expected_hits[0]=(a>=4096 && a<4116);
            expected_hits[1]=(a>=9024 && a<9068);
            expected_hits[2]=(a>=65520);
            expected_csr=(a>=32768 && a<39936);
            n=int'(expected_hits[0])+int'(expected_hits[1])+int'(expected_hits[2])+int'(expected_csr);
            check(hits===expected_hits && csr===expected_csr);
            check(reason===((n==0)?8'h01:8'h00));
            check(valid===((n==1)&&!expected_csr));
            if(valid) check(port==((a>=65520)?2:((a>=9024)?1:0)));
            if (a>=32768 && a<32784) check(overlap_reason===8'h02 && !overlap_valid && overlap_port==0 && &overlap_hits && overlap_csr);
        end
        high_address=32'hffffffff; #1; check(high_valid && high_hits==1 && high_reason==0 && high_port==0);
        high_address=32'h00000000; #1; check(!high_valid && high_reason==1);
        high_address=32'h800013ff; #1; check(high_csr && !high_valid && high_reason==0);
        high_address=32'h80001400; #1; check(!high_csr && high_reason==1);
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_DECODE: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_DECODE: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_DECODE: PASS (errors=0)"); $finish;
    end
    initial begin #100000; $fatal(1,"decode timeout"); end
endmodule
