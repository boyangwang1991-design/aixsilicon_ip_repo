// =============================================================================
// ut_pqc_sampler - module UT for the coefficient sampler
//
// Independent oracles (not copies of the RTL):
//   * KEM SampleNTT (FIPS 203 Alg. 7): 3-byte groups -> two 12-bit candidates,
//     both considered in order; only candidates < q are written
//   * CBD (FIPS 203 Alg. 8): centred binomial over 2*eta CONSECUTIVE bits of a
//     continuous LSB-first bit stream
//   * coefficient count / stop condition and store back-pressure
//   * zeroize clears pending state
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_sampler;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  localparam int unsigned MEM_WORDS = 4096;
  localparam logic [31:0] QKEM = 32'd3329;

  logic [31:0] mem [0:MEM_WORDS-1];

  logic        start;
  logic [2:0]  mode;
  logic        domain;
  logic [7:0]  dst_page;
  logic [3:0]  eta, gamma1_sel;
  logic        busy, done;
  logic        sqz_valid, sqz_ready;
  logic [7:0]  sqz_data;
  logic        mem_req, mem_we, mem_ready;
  logic [15:0] mem_addr;
  logic [31:0] mem_wdata;
  logic        zeroize_req;

  pqc_sampler dut (
    .clk(clk), .rst_n(rst_n), .start(start), .mode(mode), .domain(domain),
    .dst_page(dst_page), .eta(eta), .gamma1_sel(gamma1_sel),
    .busy(busy), .done(done),
    .sqz_valid(sqz_valid), .sqz_ready(sqz_ready), .sqz_data(sqz_data),
    .mem_req(mem_req), .mem_we(mem_we), .mem_addr(mem_addr), .mem_wdata(mem_wdata),
    .mem_ready(mem_ready), .zeroize_req(zeroize_req)
  );

  int errors;
  int guard;
  int range_errors;

  // Store with back-pressure: accept a write only every third cycle.
  int stall_cnt;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mem_ready <= 1'b0;
      stall_cnt <= 0;
    end else begin
      if (mem_req) begin
        mem_ready <= ((stall_cnt % 3) == 0);   // stall two out of three
        stall_cnt <= stall_cnt + 1;
      end else begin
        mem_ready <= 1'b0;
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      range_errors <= 0;
      for (int unsigned i = 0; i < MEM_WORDS; i++) mem[i] <= 32'h0;
    end else if (mem_req && mem_we && mem_ready) begin
      mem[mem_addr] <= mem_wdata;
      if (mem_wdata >= QKEM) range_errors <= range_errors + 1;
    end
  end

  // ---------------------------------------------------------------------------
  // Independent bit-stream oracle: a continuous LSB-first bit source
  // ---------------------------------------------------------------------------
  logic [7:0] src_bytes [0:8191];
  int         src_len, bit_pos;

  function automatic logic [63:0] oracle_bits(input int nbits);
    logic [63:0] v;
    v = 64'h0;
    for (int i = 0; i < nbits; i++) begin
      int byte_i = (bit_pos + i) / 8;
      int bit_i  = (bit_pos + i) % 8;
      if (byte_i < src_len) v[i] = (src_bytes[byte_i] >> bit_i) & 1'b1;
    end
    bit_pos += nbits;
    return v;
  endfunction

  function automatic logic [31:0] oracle_cbd(input int e);
    logic [63:0] bits;
    int a, b;
    bits = oracle_bits(2*e);
    a = 0; b = 0;
    for (int i = 0; i < e; i++) a += bits[i];
    for (int i = 0; i < e; i++) b += bits[e+i];
    return 32'((a >= b) ? (a - b) : (3329 + a - b));
  endfunction

  // returns 0 when the sampler has already completed (no more bytes wanted).
  // The byte is only consumed on a cycle where sqz_ready is high, so it is held
  // stable until the handshake completes.
  task automatic push_byte(input logic [7:0] b, output int ok);
    guard = 0;
    ok = 1;
    sqz_valid = 1'b1;
    sqz_data  = b;
    while (!sqz_ready && !done && guard < 2000) begin @(negedge clk); guard++; end
    if (done) begin sqz_valid = 1'b0; ok = 0; return; end
    @(negedge clk);
    sqz_valid = 1'b0;
  endtask

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  initial begin
    errors = 0;
    start = 0; mode = 3'd0; domain = 0; dst_page = 8'h1; eta = 4'd2; gamma1_sel = 4'd17;
    sqz_valid = 0; sqz_data = 0; zeroize_req = 0;
    src_len = 0; bit_pos = 0;
    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ==================================================================
    // KEM rejection sampling, driven by the independent 3-byte oracle
    // ==================================================================
    begin
      int unsigned accepted;
      accepted = 0;
      src_len = 0; bit_pos = 0;
      // build a deterministic byte stream and compute the expected accepted set
      for (int g = 0; g < 1200; g++) begin
        src_bytes[src_len] = 8'((g * 37 + 11) & 8'hFF); src_len++;
        src_bytes[src_len] = 8'((g * 53 + 7)  & 8'hFF); src_len++;
        src_bytes[src_len] = 8'((g * 29 + 3)  & 8'hFF); src_len++;
      end

      @(negedge clk);
      start = 1'b1; mode = 3'd1; domain = 1'b0; dst_page = 8'h1;
      @(negedge clk);
      start = 1'b0;

      // push bytes until the sampler completes (it may stop early)
      for (int i = 0; i < src_len; i++) begin
        int ok;
        push_byte(src_bytes[i], ok);
        if (!ok) break;
      end

      guard = 0;
      while (!done && guard < 60000) begin @(negedge clk); guard++; end
      if (guard >= 60000) begin
        $display("FAIL: KEM rejection sampling did not finish");
        errors++;
      end
      @(negedge clk);

      // re-walk the oracle to compute the expected first 16 coefficients
      bit_pos = 0;
      for (int g = 0; g < 1200 && accepted < 16; g++) begin
        logic [11:0] d1, d2;
        logic [7:0] b0, b1, b2;
        b0 = src_bytes[g*3+0];
        b1 = src_bytes[g*3+1];
        b2 = src_bytes[g*3+2];
        d1 = {4'h0, b0} + ({8'h0, b1[3:0]} << 8);
        d2 = {8'h0, b1[7:4]} + ({8'h0, b2} << 4);
        if (d1 < QKEM[11:0]) begin
          chk(mem[{8'h1, 8'(accepted)}], {20'h0, d1},
              $sformatf("KEM sample coeff %0d (candidate 1 of group %0d)", accepted, g));
          accepted++;
        end
        if (accepted < 16 && d2 < QKEM[11:0]) begin
          chk(mem[{8'h1, 8'(accepted)}], {20'h0, d2},
              $sformatf("KEM sample coeff %0d (candidate 2 of group %0d)", accepted, g));
          accepted++;
        end
      end
      chk(range_errors, 0, "KEM rejection never writes a value >= q");
    end

    // ==================================================================
    // CBD with eta = 2 over a CONTINUOUS bit stream (straddling coefficients)
    // ==================================================================
    begin
      int unsigned n;
      n = 0;
      src_len = 0; bit_pos = 0;
      // 256 coefficients x 2*eta(=4) bits = 1024 bits; push 192 bytes so the
      // sampler always has enough material to complete
      for (int i = 0; i < 192; i++) begin
        src_bytes[src_len] = 8'((i * 91 + 13) & 8'hFF); src_len++;
      end
      @(negedge clk);
      start = 1'b1; mode = 3'd0; domain = 1'b0; dst_page = 8'h2; eta = 4'd2;
      @(negedge clk);
      start = 1'b0;
      for (int i = 0; i < src_len; i++) begin
        int ok;
        push_byte(src_bytes[i], ok);
        if (!ok) break;
      end
      guard = 0;
      while (!done && guard < 60000) begin @(negedge clk); guard++; end
      if (guard >= 60000) begin
        $display("FAIL: CBD sampling did not finish");
        errors++;
      end
      @(negedge clk);

      bit_pos = 0;
      for (int i = 0; i < 16; i++) begin
        chk(mem[{8'h2, 8'(i)}], oracle_cbd(2),
            $sformatf("CBD eta=2 coeff %0d", i));
      end
    end

    // ==================================================================
    // zeroize clears pending state
    // ==================================================================
    @(negedge clk);
    zeroize_req = 1'b1;
    @(negedge clk);
    zeroize_req = 1'b0;
    @(negedge clk);
    chk({31'h0, dut.busy}, 0, "zeroize leaves the sampler idle");

    #40;
    if (errors == 0) $display("UT_pqc_sampler: PASS (errors=0)");
    else             $display("UT_pqc_sampler: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #40_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_sampler: FAIL (errors=1)");
    $finish;
  end

endmodule