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

module ut_pqc_cmd_frontend;

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
  pqc_pkg::pqc_command_t command;
  logic command_valid;

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
    .command(command), .command_valid(command_valid),
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
    return c ^ 32'hffff_ffff;
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
    begin
      int pk,ct,sig,n0,n1,o0,o1;
      pk=(ps==1)?800:(ps==2)?1184:(ps==3)?1568:(ps==4)?1312:(ps==5)?1952:2592;
      ct=(ps==1)?768:(ps==2)?1088:1568;
      sig=(ps==4)?2420:(ps==5)?3309:4627;
      n0=0;n1=0;o0=0;o1=0;
      case(op)
        8'h00,8'h10:begin o0=pk;o1=4;end
        8'h01:begin n0=pk;o0=ct;o1=32;end
        8'h02:begin n0=ct;o0=32;end
        8'h11:begin n0=64;o0=sig;end
        8'h12:begin n0=64;n1=pk+sig;end
        default:begin end
      endcase
      for(int b=0;b<4;b++)begin
        desc_bytes['h18+b]=8'(n0>>(b*8));desc_bytes['h28+b]=8'(n1>>(b*8));
        desc_bytes['h48+b]=8'(o0>>(b*8));desc_bytes['h58+b]=8'(o1>>(b*8));
      end
      desc_bytes['h12]=1;desc_bytes['h22]=2;desc_bytes['h32]=3;
      desc_bytes['h42]=4;desc_bytes['h52]=5;desc_bytes['h62]=6;
      desc_bytes['h3c]=2;
    end
    exp_crc = crc32(desc_bytes);
    desc_bytes[8'h7C] = exp_crc[7:0];
    desc_bytes[8'h7D] = exp_crc[15:8];
    desc_bytes[8'h7E] = exp_crc[23:16];
    desc_bytes[8'h7F] = exp_crc[31:24];
  endtask

  task automatic feed_descriptor(input bit acknowledge=1);
    desc_fetch_done=0;
    for (int i = 0; i < 128; i++) begin
      @(negedge clk);
      desc_data_idx   = 8'(i);
      desc_data       = desc_bytes[i];
      desc_data_valid = 1'b1;
    end
    @(negedge clk);
    desc_data_valid = 1'b0;
    desc_fetch_done=acknowledge;
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

  initial begin
    enable_sw = 0; abort_sw = 0; zeroize_sw = 0; self_test_sw = 0; doorbell_sw = 0;
    desc_addr_lo_sw = 32'h1000_0000; desc_addr_hi_sw = 8'h0;
    key_handle_slot = 8'h01; key_handle_gen = 8'h01; key_handle_owner = 8'h00;
    key_handle_type = 3'h1; key_handle_ok = 1'b1;
    cap_enabled = 1'b1; cap_algo_mask = 6'h3F;
    desc_data = 0; desc_data_idx = 0; desc_data_valid = 0;
    alg_busy = 0; alg_done = 0; alg_op_error = 0;
    locked = 0; zeroize_req = 0; tamper = 0; rng_fault = 0; selftest_fail = 0;

    build_desc(8'h00, 4'd2);

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    chk(fsm_state_o, 10'b0000000001, "reset enters DISABLED");

    @(negedge clk);
    enable_sw = 1'b1;
    @(negedge clk);
    chk(fsm_state_o, 10'b0000000010, "enable enters SELFTEST");
    enable_sw = 1'b0;
    wait_state(10'b0000000100);
    chk(fsm_state_o, 10'b0000000100, "self-test pass enters IDLE");

    // ------------------------------------------------------------------
    // F02 regression: opcode 0x02 (KEM Decaps) must route to op index 2
    // ------------------------------------------------------------------
    build_desc(8'h02, 4'd2);
    doorbell_and_feed();
    wait_state(10'b0000100000);
    chk({30'h0, alg_op}, 32'h2, "KEM Decaps (0x02) routes to op index 2");
    chk({29'h0, alg_pset}, 32'h2, "KEM-768 parameter set routed to the KEM path");
    @(negedge clk); alg_done = 1'b1; @(negedge clk); alg_done = 1'b0;
    wait_state(10'b0010000000);
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // F02 regression: opcode 0x11 (DSA Sign) must route to op index 1
    // ------------------------------------------------------------------
    build_desc(8'h11, 4'd5);
    doorbell_and_feed();
    wait_state(10'b0000100000);
    chk({30'h0, alg_op}, 32'h1, "DSA Sign (0x11) routes to op index 1");
    chk({29'h0, alg_pset}, 32'h5, "ML-DSA-65 parameter set routed");
    @(negedge clk); alg_done = 1'b1; @(negedge clk); alg_done = 1'b0;
    wait_state(10'b0010000000);
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // parameter-set / opcode mismatch must be rejected
    // ------------------------------------------------------------------
    build_desc(8'h10, 4'd2);   // DSA opcode with a KEM parameter set
    doorbell_and_feed();
    wait_state(10'b0010000000);
    chk(comp_error, 6'h02, "opcode/pset mismatch reports ERR_BAD_PARAMSET");
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // CRC corruption must be rejected
    // ------------------------------------------------------------------
    build_desc(8'h00, 4'd2);
    desc_bytes[8'h10] = 8'hFF;                 // change a covered byte
    doorbell_and_feed();
    wait_state(10'b0010000000);
    chk(comp_status, 3'd2, "corrupt descriptor reports CONFIG_ERROR");
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // misaligned descriptor address must be rejected
    // ------------------------------------------------------------------
    build_desc(8'h00, 4'd2);
    desc_addr_lo_sw = 32'h1000_0004;
    doorbell_and_feed();
    wait_state(10'b0010000000);
    chk(comp_error, 6'h04, "misaligned address reports ERR_BAD_ALIGN");
    desc_addr_lo_sw = 32'h1000_0080;
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // invalid key handle must be rejected for a consuming command
    // ------------------------------------------------------------------
    build_desc(8'h02, 4'd2);
    key_handle_ok = 1'b0;
    doorbell_and_feed();
    wait_state(10'b0010000000);
    chk(comp_error, 6'h07, "bad key handle reports ERR_BAD_KEY");
    key_handle_ok = 1'b1;
    @(negedge clk); wait_state(10'b0000000100);

    // ------------------------------------------------------------------
    // done_pulse must be exactly one cycle wide per command
    // ------------------------------------------------------------------
    build_desc(8'h00, 4'd2);
    // let any pulse from the previous command land before taking the snapshot
    @(negedge clk);
    @(negedge clk);
    pulse_snap = done_pulse_cnt;
    doorbell_and_feed();
    wait_state(10'b0000100000);
    @(negedge clk); alg_done = 1'b1; @(negedge clk); alg_done = 1'b0;
    wait_state(10'b0010000000);
    @(negedge clk); wait_state(10'b0000000100);
    @(negedge clk);
    chk(done_pulse_cnt - pulse_snap, 1, "done_pulse is one cycle per command");
    chk(irq_done, 1'b0, "DONE interrupt is not left asserted after the pulse");

    // ------------------------------------------------------------------
    // All bytes alone must not authorize execution; wait for fetch completion.
    @(negedge clk);doorbell_sw=1;
    @(negedge clk);doorbell_sw=0;
    feed_descriptor(0);
    repeat(8) begin
      @(negedge clk);
      chk(alg_start,0,"no execution before descriptor done");
      chk(fsm_state_o,pqc_pkg::S_FETCH,"wait in FETCH for descriptor done");
    end
    // Error has priority even when the complete byte shadow was received.
    desc_fetch_done=1;desc_fetch_error=1;
    @(negedge clk);desc_fetch_done=0;desc_fetch_error=0;
    chk(comp_status,pqc_pkg::ST_DMA_ERROR,"descriptor failure blocks execution");
    chk(alg_start,0,"error cannot dispatch algorithm");
    wait_state(10'b0000000100);
    // Premature completion is a malformed transfer, not a short descriptor.
    @(negedge clk);doorbell_sw=1;
    @(negedge clk);doorbell_sw=0;desc_fetch_done=1;
    @(negedge clk);desc_fetch_done=0;
    chk(comp_status,pqc_pkg::ST_DMA_ERROR,"early descriptor done rejected");
    wait_state(10'b0000000100);

    // Exact normative ciphertext lengths, including all high 64-bit length bits.
    for(int p=1;p<=3;p++)for(int bad=0;bad<3;bad++)begin
      build_desc(8'h02,4'(p));
      if(bad==0)desc_bytes[8'h18]--;
      if(bad==1)desc_bytes[8'h18]++;
      if(bad==2)desc_bytes[8'h1F]=1;
      exp_crc=crc32(desc_bytes);
      for(int b=0;b<4;b++)desc_bytes[8'h7C+b]=exp_crc[b*8+:8];
      doorbell_and_feed();wait_state(pqc_pkg::S_COMPLETE);
      chk(comp_error,pqc_pkg::ERR_BAD_LENGTH,"invalid ciphertext length rejected");
      chk(alg_start,0,"invalid length cannot dispatch");
      @(negedge clk);wait_state(pqc_pkg::S_IDLE);
    end
    // Capture the address once and do not replay a level-held doorbell.
    build_desc(8'h00,4'd2);desc_addr_lo_sw=32'h1000_0080;
    @(negedge clk);doorbell_sw=1;
    @(negedge clk);desc_addr_lo_sw=32'h1000_0001;
    chk(desc_fetch_addr,32'h1000_0080,"captured descriptor address");
    feed_descriptor();wait_state(pqc_pkg::S_EXECUTE);
    @(negedge clk);alg_done=1;@(negedge clk);alg_done=0;
    wait_state(pqc_pkg::S_IDLE);
    repeat(8)begin @(negedge clk);chk(desc_fetch_req,0,"held doorbell cannot replay");end
    doorbell_sw=0;desc_addr_lo_sw=32'h1000_0080;@(negedge clk);

    // Empty messages are legal for both DSA operations. Capabilities are captured
    // with the doorbell, and command data is hidden outside the execution window.
    for(int op=17;op<=18;op++)begin
      build_desc(8'(op),4'd4);
      for(int b=0;b<8;b++)desc_bytes['h18+b]=0;
      exp_crc=crc32(desc_bytes);
      for(int b=0;b<4;b++)desc_bytes['h7c+b]=exp_crc[b*8+:8];
      @(negedge clk);doorbell_sw=1;
      @(negedge clk);doorbell_sw=0;cap_enabled=0;cap_algo_mask=0;
      feed_descriptor();wait_state(pqc_pkg::S_EXECUTE);
      chk(command_valid,1,"empty DSA message dispatches");
      chk(command.command_id,32'hddccbbaa,"typed command retains identifier");
      chk(command.src0_len==0,1,"empty message retains zero length");
      repeat(3)begin @(negedge clk);chk(command_valid,1,"captured capabilities stable");end
      abort_sw=1;#1;
      chk(command_valid,0,"abort immediately revokes command view");
      chk(command=='0,1,"revoked command fields are zero");
      @(negedge clk);abort_sw=0;cap_enabled=1;cap_algo_mask=63;
      wait_state(pqc_pkg::S_IDLE);
      chk(command_valid,0,"idle does not expose prior command");
    end

    // illegal state encoding forces ZEROIZE, never EXECUTE
    // ------------------------------------------------------------------
    @(negedge clk);
    force dut.fsm_state = 10'b0000110000;
    @(posedge clk);
    @(posedge clk);
    release dut.fsm_state;
    @(negedge clk);
    chk(fsm_state_o, 10'b0100000000, "illegal encoding forces ZEROIZE");

    // ------------------------------------------------------------------
    // external zeroize request is honoured
    // ------------------------------------------------------------------
    @(negedge clk);
    zeroize_req = 1'b1;
    #1;chk(desc_fetch_req,0,"clear revokes descriptor request");
    chk(alg_start,0,"clear revokes algorithm request");
    @(negedge clk);
    for(int i=0;i<128;i++)chk(dut.desc_shadow[i],0,"clear wipes descriptor shadow");
    zeroize_req = 1'b0;
    @(negedge clk);
    chk(fsm_state_o, 10'b0000000100, "returns to IDLE after zeroize");

    #40;
    if (errors == 0) $display("UT_pqc_cmd_frontend: PASS (errors=0)");
    else             $display("UT_pqc_cmd_frontend: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #8_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_cmd_frontend: FAIL (errors=1)");
    $finish;
  end

endmodule
