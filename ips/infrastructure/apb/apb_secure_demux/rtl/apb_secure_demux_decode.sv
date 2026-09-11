// Implements LLD.MOD.APB_SECURE_DEMUX.DECODE. Full-width, non-priority decode.
module apb_secure_demux_decode #(
    parameter int unsigned NUM_PORTS = 8,
    parameter int unsigned ADDR_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] PORT_BASE [NUM_PORTS] = '{default:'0},
    parameter logic [ADDR_WIDTH:0] PORT_SIZE [NUM_PORTS] = '{default:'0},
    parameter logic [ADDR_WIDTH-1:0] CSR_BASE = '0,
    localparam int unsigned PORT_W = (NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1,
    localparam int unsigned COUNT_W = $clog2(NUM_PORTS + 2),
    localparam logic [ADDR_WIDTH:0] CSR_SIZE = (ADDR_WIDTH+1)'(32'h1000 + NUM_PORTS*32'h400)
) (
    input  logic [ADDR_WIDTH-1:0] address_i,
    output logic [NUM_PORTS-1:0] port_hits_o,
    output logic csr_hit_o,
    output logic [PORT_W-1:0] port_o,
    output logic port_valid_o,
    output logic [7:0] reason_o
);
    logic [COUNT_W-1:0] hit_count;
    logic [ADDR_WIDTH:0] address_ext;
    assign address_ext = {1'b0, address_i};
    for (genvar p=0; p<NUM_PORTS; p++) begin : g_range
        localparam logic [ADDR_WIDTH+1:0] END_EXCLUSIVE =
            {2'b00, PORT_BASE[p]} + {1'b0, PORT_SIZE[p]};
        assign port_hits_o[p] = (PORT_SIZE[p] != '0) &&
            (address_ext >= {1'b0, PORT_BASE[p]}) &&
            ({1'b0,address_ext} < END_EXCLUSIVE);
    end
    assign csr_hit_o = (address_ext >= {1'b0, CSR_BASE}) &&
        ({1'b0,address_ext} < ({2'b00,CSR_BASE} + {1'b0,CSR_SIZE}));
    always_comb begin
        hit_count = COUNT_W'(csr_hit_o);
        port_o = '0;
        for (int unsigned p=0; p<NUM_PORTS; p++) begin
            hit_count = hit_count + COUNT_W'(port_hits_o[p]);
            if (port_hits_o[p]) port_o = PORT_W'(p);
        end
        port_valid_o = (hit_count == COUNT_W'(1)) && !csr_hit_o;
        if (!port_valid_o) port_o = '0;
        reason_o = 8'h00;
        if (hit_count == '0) reason_o = 8'h01;
        else if (hit_count > COUNT_W'(1)) reason_o = 8'h02;
    end
endmodule
