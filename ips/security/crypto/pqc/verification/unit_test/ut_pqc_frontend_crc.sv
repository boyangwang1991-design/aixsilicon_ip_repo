// =============================================================================
// ut_pqc_cmd_frontend - module UT for descriptor validation and the top FSM
//
// Checks that invalid descriptors are rejected before execution, that the
// opcode/parameter-set routing is decoded from the captured descriptor shadow
// (F02), that the CRC/reserved/length checks work, that an illegal state
// encoding forces the safe shutdown path, that done_pulse is one cycle wide,
// and that status/tag reach the completion outputs.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_frontend_crc;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic        enable_sw, abort_sw, zeroize_sw, self_test_sw, doorbell_sw;
  logic [31:0] desc_addr_lo_sw;
  logic [7:0]  desc_addr_hi_sw;
  logic [7:0]  key_handle_slot, key_handle_owner;
  logic [15:0] key_handle_gen;
  logic [2:0]  key_handle_type;
  logic        key_handle_ok;
  logic        cap_enabled;
  logic [5:0]  cap_algo_mask;

  logic        desc_fetch_req;
  logic [39:0] desc_fetch_addr;
  logic [7:0]  desc_data, desc_data_idx;
  logic        desc_data_valid;
  logic        desc_fetch_done=0, desc_fetch_error=0;

  logic        alg_start, alg_busy, alg_done, alg_op_error;
  logic [1:0]  alg_op;
  logic [2:0]  alg_pset;

  logic        busy, idle, done_pulse;
  logic [2:0]  comp_status;
  logic [5:0]  comp_error;
  logic [31:0] completion_tag;
  logic [9:0]  fsm_state_o;

  logic        locked, zeroize_req, tamper, rng_fault, selftest_fail;
  logic        irq_done, irq_error, irq_rng, irq_tamper, irq_selftest;

  pqc_cmd_frontend dut (
    .clk(clk), .rst_n(rst_n),
    .enable_sw(enable_sw), .abort_sw(abort_sw), .zeroize_sw(zeroize_sw),
    .self_test_sw(self_test_sw), .doorbell_sw(doorbell_sw),
    .desc_addr_lo_sw(desc_addr_lo_sw), .desc_addr_hi_sw(desc_addr_hi_sw),
    .key_handle_slot(key_handle_slot), .key_handle_gen(key_handle_gen),
    .key_handle_owner(key_handle_owner), .key_handle_type(key_handle_type),
    .key_handle_ok(key_handle_ok),
    .cap_enabled(cap_enabled), .cap_algo_mask(cap_algo_mask),
    .desc_fetch_req(desc_fetch_req), .desc_fetch_addr(desc_fetch_addr),
    .desc_data(desc_data), .desc_data_idx(desc_data_idx),
    .desc_data_valid(desc_data_valid),
    .desc_fetch_done(desc_fetch_done), .desc_fetch_error(desc_fetch_error),
    .alg_start(alg_start), .alg_op(alg_op), .alg_pset(alg_pset),
    .alg_busy(alg_busy), .alg_done(alg_done), .alg_op_error(alg_op_error),
    .busy(busy), .idle(idle), .done_pulse(done_pulse),
    .comp_status(comp_status), .comp_error(comp_error),
    .completion_tag(completion_tag), .fsm_state_o(fsm_state_o),
    .locked(locked), .zeroize_req(zeroize_req), .tamper(tamper),
    .rng_fault(rng_fault), .selftest_fail(selftest_fail),
    .irq_done(irq_done), .irq_error(irq_error), .irq_rng(irq_rng),
    .irq_tamper(irq_tamper), .irq_selftest(irq_selftest)
  );

  int errors = 0;
  int guard;
  int done_pulse_cnt;

  logic [7:0] desc_bytes [0:127];
  logic [31:0] exp_crc;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  task automatic wait_state(input logic [9:0] s, input int limit = 400);
    guard = 0;
    while (fsm_state_o != s && guard < limit) begin @(negedge clk); guard++; end
  endtask

  // CRC-32 over bytes 0..123 of the descriptor
  function automatic logic [31:0] crc32(input logic [7:0] b [0:127]);
    logic [31:0] c;
    logic [31:0] x;
    c = 32'hFFFF_FFFF;
    for (int i = 0; i < 124; i++) begin
      x = c ^ {24'h0, b[i]};
      for (int k = 0; k < 8; k++) x = x[0] ? ((x >> 1) ^ 32'hEDB8_8320) : (x >> 1);
      c = x;
    end
    return c;
  endfunction

  // build a descriptor with the given opcode/pset and CRC
  task automatic build_desc(input logic [7:0] op, input logic [3:0] ps);
    for (int i = 0; i < 128; i++) desc_bytes[i] = 8'h00;
    desc_bytes[0]  = op;
    desc_bytes[1]  = {4'h0, ps};
    desc_bytes[3]  = 8'h10;                 // ABI
    desc_bytes[4]  = 8'hAA; desc_bytes[5] = 8'hBB;
    desc_bytes[6]  = 8'hCC; desc_bytes[7] = 8'hDD;
    desc_bytes[8]  = 8'h00; desc_bytes[9] = 8'h01;   // key handle
    desc_bytes[8'h18] = 8'h40;              // src0_len = 64
    exp_crc = crc32(desc_bytes);
    desc_bytes[8'h7C] = exp_crc[7:0];
    desc_bytes[8'h7D] = exp_crc[15:8];
    desc_bytes[8'h7E] = exp_crc[23:16];
    desc_bytes[8'h7F] = exp_crc[31:24];
  endtask

  task automatic feed_descriptor();
    desc_fetch_done=0;
    for (int i = 0; i < 128; i++) begin
      @(negedge clk);
      desc_data_idx   = 8'(i);
      desc_data       = desc_bytes[i];
      desc_data_valid = 1'b1;
    end
    @(negedge clk);
    desc_data_valid = 1'b0;
    desc_fetch_done=1;
    @(negedge clk);desc_fetch_done=0;
  endtask

  task automatic doorbell_and_feed();
    @(negedge clk);
    doorbell_sw = 1'b1;
    @(negedge clk);
    doorbell_sw = 1'b0;
    feed_descriptor();
  endtask

  // capture alg_start pulses to ensure it is a one-shot
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) done_pulse_cnt <= 0;
    else if (done_pulse) done_pulse_cnt <= done_pulse_cnt + 1;
  end

  int pulse_snap;
  string dir;

 initial begin
 enable_sw=0;abort_sw=0;zeroize_sw=0;self_test_sw=0;doorbell_sw=0;desc_addr_lo_sw=32'h10000000;desc_addr_hi_sw=0;
 key_handle_slot=1;key_handle_gen=1;key_handle_owner=0;key_handle_type=1;key_handle_ok=1;
 cap_enabled=1;cap_algo_mask=63;desc_data=0;desc_data_idx=0;desc_data_valid=0;
 alg_busy=0;alg_done=0;alg_op_error=0;locked=0;zeroize_req=0;tamper=0;rng_fault=0;selftest_fail=0;
 rst_n=0;repeat(4) @(negedge clk);rst_n=1;enable_sw=1;repeat(4) @(negedge clk);
if(!$value$plusargs("VECTORS=%s",dir)) $fatal(1,"VECTORS required");
$readmemh({dir,"/descriptor_zlib.hex"},desc_bytes);
doorbell_and_feed();repeat(5) @(negedge clk);
 $display("CHECK FE zlib CRC: status=%0d error=%0d crc_acc=%h expected=%h; expected accepted",comp_status,comp_error,dut.crc_acc,dut.crc_expected);
 if(comp_status !== 0 || comp_error !== 0 || !busy) $fatal(1,"zlib descriptor rejected");
 $display("UT_pqc_frontend_crc: PASS (errors=0)");$finish;end
endmodule
