// LLD.MOD.GPIO.FIFO: balanced event selection; full exchange and flush loss accounting.
module gpio_event_fifo #(
  parameter int N_GPIO=32, DEPTH=16,
  localparam int STORAGE_DEPTH=DEPTH>0 ? DEPTH : 1,
  localparam int PTR_W=STORAGE_DEPTH>1 ? $clog2(STORAGE_DEPTH) : 1,
  localparam int LEAVES=2**$clog2(N_GPIO)
) (
  input logic clk_i, rst_ni,
  input logic [N_GPIO-1:0] event_i, rising_i, event_enable_i,
  input logic record_enable_i, dma_enable_i, pop_i, flush_i, clear_lost_i, clear_overflow_i,
  input logic [6:0] watermark_i,
  input logic timestamp_low_read_i,
  output logic [127:0] head_o,
  output logic [6:0] level_o,
  output logic [31:0] lost_o, timestamp_low_o, timestamp_high_o,
  output logic overflow_o, watermark_o, dma_req_o
);
  logic [63:0] timestamp_q;
  logic [127:0] memory_q [STORAGE_DEPTH];
  logic [PTR_W-1:0] read_q, write_q;
  logic [2*LEAVES-1:1] tree_valid;
  logic [6:0] tree_pin [2*LEAVES];
  logic [7:0] tree_count [2*LEAVES];
  logic pop, push;
  logic [7:0] dropped;
  logic [32:0] lost_sum;
  for (genvar i=0; i<LEAVES; i++) begin : g_leaf
    if (i<N_GPIO) begin : g_real
      assign tree_valid[LEAVES+i] = event_i[i] && event_enable_i[i] && record_enable_i && (DEPTH>0);
    end else begin : g_pad
      assign tree_valid[LEAVES+i] = 1'b0;
    end
    assign tree_pin[LEAVES+i]=7'(i);
    assign tree_count[LEAVES+i]={7'b0,tree_valid[LEAVES+i]};
  end
  for (genvar i=1; i<LEAVES; i++) begin : g_tree
    assign tree_valid[i]=tree_valid[2*i] || tree_valid[2*i+1];
    assign tree_pin[i]=tree_valid[2*i] ? tree_pin[2*i] : tree_pin[2*i+1];
    assign tree_count[i]=tree_count[2*i]+tree_count[2*i+1];
  end
  assign pop=(DEPTH>0) && pop_i && level_o!=0 && !flush_i;
  assign push=tree_valid[1] && !flush_i && (level_o<7'(DEPTH) || pop);
  assign dropped=tree_count[1] - {7'b0,push};
  assign lost_sum={1'b0,(clear_lost_i ? 32'd0 : lost_o)} + {25'b0,dropped};
  assign head_o=level_o!=0 ? memory_q[read_q] : 128'd0;
  assign dma_req_o=(DEPTH>0) && dma_enable_i && level_o!=0;
  assign watermark_o=(DEPTH>0) && level_o>=watermark_i;
  assign timestamp_low_o=DEPTH>0 ? timestamp_q[31:0] : 32'd0;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      timestamp_q<='0; timestamp_high_o<='0; read_q<='0; write_q<='0;
      level_o<='0; lost_o<='0; overflow_o<=1'b0;
    end else if (DEPTH>0) begin
      timestamp_q<=timestamp_q+64'd1;
      if (timestamp_low_read_i) timestamp_high_o<=timestamp_q[63:32];
      if (flush_i) begin read_q<='0; write_q<='0; level_o<='0; end
      else begin
        if (pop) read_q<=read_q+1'b1;
        if (push) write_q<=write_q+1'b1;
        case ({push,pop})
          2'b10: level_o<=level_o+7'd1;
          2'b01: level_o<=level_o-7'd1;
          default: level_o<=level_o;
        endcase
      end
      lost_o<=lost_sum[32] ? 32'hffffffff : lost_sum[31:0];
      overflow_o<=(overflow_o && !clear_lost_i && !clear_overflow_i) || dropped!=0;
    end
  end
  always_ff @(posedge clk_i) begin
    if (rst_ni && push)
      memory_q[write_q]<={32'd0,timestamp_q,23'd0,rising_i[tree_pin[1]],1'b0,tree_pin[1]};
  end
endmodule
