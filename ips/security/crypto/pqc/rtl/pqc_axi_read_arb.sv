// Single-outstanding AXI read ownership, LLD.FSM.PQC.TOP.READ_ARB.
// Client 0 has priority only when choosing a NEW transaction.
module pqc_axi_read_arb #(
  parameter int unsigned ADDR_WIDTH = 40,
  parameter int unsigned DATA_WIDTH = 128
) (
  input logic clk, rst_n,
  input logic [1:0] s_ar_valid,
  output logic [1:0] s_ar_ready,
  input logic [1:0][ADDR_WIDTH-1:0] s_ar_addr,
  input logic [1:0][7:0] s_ar_len,
  input logic [1:0][2:0] s_ar_prot,
  output logic [1:0] s_r_valid,
  input logic [1:0] s_r_ready,
  output logic [DATA_WIDTH-1:0] s_r_data,
  output logic [1:0] s_r_resp,
  output logic s_r_last,
  output logic m_ar_valid,
  input logic m_ar_ready,
  output logic [ADDR_WIDTH-1:0] m_ar_addr,
  output logic [7:0] m_ar_len,
  output logic [2:0] m_ar_prot,
  input logic m_r_valid,
  output logic m_r_ready,
  input logic [DATA_WIDTH-1:0] m_r_data,
  input logic [1:0] m_r_resp,
  input logic m_r_last,
  output logic fault
);
  typedef enum logic [2:0] {IDLE=3'b001, ADDRESS=3'b010, READ=3'b100} state_t;
  state_t state;
  logic owner;
  logic chosen;
  assign chosen = !s_ar_valid[0];
  assign m_ar_valid = rst_n && !fault && state == ADDRESS;
  assign m_r_ready = rst_n && !fault && state == READ && s_r_ready[owner];
  assign s_r_data = m_r_data;
  assign s_r_resp = m_r_resp;
  assign s_r_last = m_r_last;
  always_comb begin
    s_ar_ready = 2'b00;
    s_r_valid = 2'b00;
    if (rst_n && !fault) begin
      if (state == ADDRESS) s_ar_ready[owner] = m_ar_ready;
      if (state == READ) s_r_valid[owner] = m_r_valid;
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE; owner <= 1'b0; fault <= 1'b0;
      m_ar_addr <= '0; m_ar_len <= '0; m_ar_prot <= '0;
    end else if (!fault) begin
      case (state)
        IDLE: if (|s_ar_valid) begin
          owner <= chosen;
          m_ar_addr <= s_ar_addr[chosen];
          m_ar_len <= s_ar_len[chosen];
          m_ar_prot <= s_ar_prot[chosen];
          state <= ADDRESS;
        end
        ADDRESS: if (m_ar_ready) state <= READ;
        READ: if (m_r_valid && m_r_ready && m_r_last) state <= IDLE;
        default: fault <= 1'b1;
      endcase
    end
  end
endmodule
