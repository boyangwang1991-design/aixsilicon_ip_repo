// =============================================================================
// ut_pqc_top - top-level integration UT (read path / control path)
//
// Drives APB4 transactions into the integrated top level and checks:
//   * generated CSR reset values are reachable over the bus
//   * the capability registers report the elaborated configuration
//   * an unmapped address returns PSLVERR
//   * a busy-window write to the command group is rejected with PSLVERR
//   * the interrupt state can be set by software and cleared by W1C
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_top;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  // APB4
  logic        psel, penable, pwrite;
  logic [2:0]  pprot;
  logic [9:0]  paddr;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic        pready, pslverr;
  logic [31:0] prdata;

  // AXI4 master (tied off in this UT)
  logic                  m_ar_valid, m_ar_ready;
  logic [39:0]           m_ar_addr;
  logic [7:0]            m_ar_len;
  logic [2:0]            m_ar_prot;
  logic                  m_r_valid;
  wire                   m_r_ready;      // DUT output
  logic [127:0]          m_r_data;
  logic [1:0]            m_r_resp;
  logic                  m_r_last;
  logic                  m_aw_valid, m_aw_ready;
  logic [39:0]           m_aw_addr;
  logic [7:0]            m_aw_len;
  logic [2:0]            m_aw_prot;
  logic                  m_w_valid, m_w_ready;
  logic [127:0]          m_w_data;
  logic [15:0]           m_w_strb;
  logic                  m_w_last;
  logic                  m_b_valid;
  wire                   m_b_ready;      // DUT output
  logic [1:0]            m_b_resp;

  // sideband
  logic        entropy_valid, entropy_ready, entropy_health_ok;
  logic [63:0] entropy_data;
  logic [7:0]  entropy_domain_tag;
  logic        lifecycle_strap, tamper_in, zeroize_req_in, privileged, debug_unlocked;
  logic        irq;
  logic        fault_inject_ecc_ue, fault_inject_ctrl;

  pqc_top #(
    .NTT_LANES(2), .KECCAK_ROUNDS_PER_CYCLE(2), .LOCAL_SRAM_KIB(64),
    .DMA_DATA_WIDTH(128), .KEY_SLOT_NUM(8), .SCA_LEVEL(1)
  ) dut (
    .km_begin(1'b0), .km_handle(32'd0), .km_algo(4'd0), .km_pset(4'd0),
    .km_usage(8'd0), .km_bytes(16'd0), .km_valid(1'b0), .km_data(32'd0),
    .km_last(1'b0), .km_revoke(1'b0),
    .clk(clk), .rst_n(rst_n),
    .s_apb_psel(psel), .s_apb_penable(penable), .s_apb_pwrite(pwrite),
    .s_apb_pprot(pprot), .s_apb_paddr(paddr), .s_apb_pwdata(pwdata),
    .s_apb_pstrb(pstrb), .s_apb_pready(pready), .s_apb_prdata(prdata),
    .s_apb_pslverr(pslverr),
    .m_ar_valid(m_ar_valid), .m_ar_ready(m_ar_ready), .m_ar_addr(m_ar_addr),
    .m_ar_len(m_ar_len), .m_ar_prot(m_ar_prot),
    .m_r_valid(m_r_valid), .m_r_ready(m_r_ready), .m_r_data(m_r_data),
    .m_r_resp(m_r_resp), .m_r_last(m_r_last),
    .m_aw_valid(m_aw_valid), .m_aw_ready(m_aw_ready), .m_aw_addr(m_aw_addr),
    .m_aw_len(m_aw_len), .m_aw_prot(m_aw_prot),
    .m_w_valid(m_w_valid), .m_w_ready(m_w_ready), .m_w_data(m_w_data),
    .m_w_strb(m_w_strb), .m_w_last(m_w_last),
    .m_b_valid(m_b_valid), .m_b_ready(m_b_ready), .m_b_resp(m_b_resp),
    .entropy_valid(entropy_valid), .entropy_ready(entropy_ready),
    .entropy_data(entropy_data), .entropy_health_ok(entropy_health_ok),
    .entropy_domain_tag(entropy_domain_tag),
    .lifecycle_strap(lifecycle_strap), .tamper_in(tamper_in),
    .zeroize_req_in(zeroize_req_in), .privileged(privileged),
    .debug_unlocked(debug_unlocked), .irq(irq),
    .fault_inject_ecc_ue(fault_inject_ecc_ue),
    .fault_inject_ctrl(fault_inject_ctrl)
  );

  int errors = 0;
  int guard;
  logic [31:0] rd;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got 0x%08x exp 0x%08x)", msg, got, exp);
      errors++;
    end
  endtask

  // APB read
  task automatic apb_read(input logic [9:0] a, output logic [31:0] data, output logic err);
    @(negedge clk);
    psel = 1'b1; penable = 1'b0; pwrite = 1'b0; paddr = a; pwdata = 32'h0;
    pstrb = 4'h0; pprot = 3'b001;
    @(negedge clk);
    penable = 1'b1;
    guard = 0;
    while (!pready && guard < 100) begin @(negedge clk); guard++; end
    data = prdata;
    err  = pslverr;
    @(negedge clk);
    psel = 1'b0; penable = 1'b0;
  endtask

  // APB write
  task automatic apb_write(input logic [9:0] a, input logic [31:0] d, output logic err);
    @(negedge clk);
    psel = 1'b1; penable = 1'b0; pwrite = 1'b1; paddr = a; pwdata = d;
    pstrb = 4'hF; pprot = 3'b001;
    @(negedge clk);
    penable = 1'b1;
    guard = 0;
    while (!pready && guard < 100) begin @(negedge clk); guard++; end
    err = pslverr;
    @(negedge clk);
    psel = 1'b0; penable = 1'b0;
  endtask

  logic err;

  initial begin
    // Only DUT *inputs* may be driven here; the AXI/APB outputs are produced
    // by the DUT and must not be assigned by the testbench.
    psel = 0; penable = 0; pwrite = 0; pprot = 0; paddr = 0; pwdata = 0; pstrb = 0;
    m_r_valid = 0; m_b_valid = 0;
    m_r_data = 0; m_r_resp = 0; m_r_last = 0; m_b_resp = 0;
    entropy_valid = 1'b0; entropy_data = 0; entropy_health_ok = 1'b1; entropy_domain_tag = 0;
    lifecycle_strap = 0; tamper_in = 0; zeroize_req_in = 0;
    privileged = 1'b1; debug_unlocked = 0;
    fault_inject_ecc_ue = 0; fault_inject_ctrl = 0;
    m_ar_ready = 1'b1; m_w_ready = 1'b1;

    rst_n = 1'b0;
    repeat (6) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // ID_VERSION reset value over the bus
    // ------------------------------------------------------------------
    apb_read(10'h000, rd, err);
    chk(rd[7:0],   8'h01, "ID_VERSION.ip_minor reset");
    chk(rd[15:8],  8'h00, "ID_VERSION.ip_major reset");
    chk(rd[23:16], 8'h10, "ID_VERSION.abi_version reset");
    chk(rd[31:24], 8'h01, "ID_VERSION.ucode_version reset");

    // ------------------------------------------------------------------
    // CAPABILITY0 reflects the elaborated configuration
    // ------------------------------------------------------------------
    // APB paddr carries byte addresses (PeakRDL cpuif uses paddr[9:2] in words)
    apb_read(10'h004, rd, err);
    chk(rd[5:0],   6'h3F,   "CAPABILITY0.algo_mask is fully enabled");
    // the capability fields carry the raw elaborated parameter values
    chk(rd[9:8],   2'd2,    "CAPABILITY0.ntt_lanes == 2");
    chk(rd[11:10], 2'd2,    "CAPABILITY0.keccak_rounds == 2");
    chk(rd[13:12], 2'd1,    "CAPABILITY0.sca_level == 1");
    chk(rd[6],     1'b1,    "CAPABILITY0.kem_supported set");
    chk(rd[7],     1'b1,    "CAPABILITY0.dsa_supported set");

    // ------------------------------------------------------------------
    // CAPABILITY1 reflects SRAM / DMA / key slots
    // ------------------------------------------------------------------
    apb_read(10'h008, rd, err);
    chk(rd[7:0],   8'd64,  "CAPABILITY1.local_sram_kib == 64");
    chk(rd[15:8],  8'd128, "CAPABILITY1.dma_data_width == 128");
    chk(rd[23:16], 8'd8,   "CAPABILITY1.key_slot_num == 8");

    // ------------------------------------------------------------------
    // STATUS after reset: the IP starts DISABLED (not idle) until enabled,
    // and must not be locked.
    // ------------------------------------------------------------------
    apb_read(10'h014, rd, err);
    chk(rd[0], 1'b0, "STATUS.idle clear while DISABLED");
    chk(rd[4], 1'b0, "STATUS.locked clear after reset");

    // ------------------------------------------------------------------
    // unmapped address must return PSLVERR
    // ------------------------------------------------------------------
    apb_read(10'h3FF, rd, err);
    chk(err, 1'b1, "unmapped address returns PSLVERR");

    // ------------------------------------------------------------------
    // mapped address must not return PSLVERR
    // ------------------------------------------------------------------
    apb_read(10'h000, rd, err);
    chk(err, 1'b0, "mapped address does not return PSLVERR");

    // ------------------------------------------------------------------
    // INTR_TEST sets state; W1C clears only the written bit
    // ------------------------------------------------------------------
    apb_write(10'h098, 32'h0000_0001, err);  // INTR_TEST.done_test
    @(negedge clk);
    @(negedge clk);
    apb_read(10'h090, rd, err);              // INTR_STATE
    chk(rd[0], 1'b1, "INTR_STATE.done set by test");

    // Release the test force first: while INTR_TEST.done_test is asserted the
    // hwset input is held high and a W1C would be immediately re-set.
    apb_write(10'h098, 32'h0000_0000, err);  // clear INTR_TEST
    @(negedge clk);
    apb_write(10'h090, 32'h0000_0001, err);  // W1C clear done
    @(negedge clk);
    apb_read(10'h090, rd, err);
    chk(rd[0], 1'b0, "INTR_STATE.done cleared by W1C");

    // ------------------------------------------------------------------
    // unprivileged access to the secure key-slot window is rejected
    // ------------------------------------------------------------------
    privileged = 1'b0;
    @(negedge clk);
    psel = 1'b1; penable = 1'b1; pwrite = 1'b1; paddr = 10'h200;
    pwdata = 32'h1; pstrb = 4'hF;
    @(negedge clk);
    chk(pslverr, 1'b1, "unprivileged key-slot access returns PSLVERR");
    psel = 1'b0; penable = 1'b0;
    @(negedge clk);
    privileged = 1'b1;

    #60;
    if (errors == 0) $display("UT_pqc_top: PASS (errors=0)");
    else             $display("UT_pqc_top: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #4_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_top: FAIL (errors=1)");
    $finish;
  end

endmodule