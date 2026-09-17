// =============================================================================
// ut_pqc_key_slots - module UT for key metadata, permissions and zeroization
//
// Checks handle validation (generation/owner/type), stale handle rejection
// after destroy, privilege gating and lifecycle-driven key destruction.
// =============================================================================
`timescale 1ns/1ps

module ut_pqc_key_slots;

  logic clk, rst_n;
  initial begin clk = 1'b0; forever #5ns clk = ~clk; end

  logic       ctl_we, ctl_import, ctl_destroy, ctl_export, ctl_lock, ctl_exportable, ctl_privileged;
  logic [7:0] ctl_index, ctl_owner, ctl_usage;
  logic [2:0] ctl_type;
  logic [3:0] ctl_algo, ctl_pset;

  logic [7:0] meta_owner, meta_usage;
  logic [15:0] meta_generation;
  logic [3:0] meta_algo, meta_pset;
  logic       meta_exportable, meta_valid, meta_locked;

  logic       hnd_valid, hnd_ok;
  logic [7:0] hnd_slot, hnd_owner, key_ref;
  logic [15:0] hnd_generation;
  logic [2:0] hnd_type;

  logic privileged, debug_unlocked, lifecycle_change, access_denied;
  logic zeroize_req, zeroize_done;

  pqc_key_slots #(.KEY_SLOT_NUM(8), .KEY_BYTES(64)) dut (
    .clk(clk), .rst_n(rst_n),
    .ctl_we(ctl_we), .ctl_index(ctl_index), .ctl_type(ctl_type),
    .ctl_import(ctl_import), .ctl_destroy(ctl_destroy), .ctl_export(ctl_export),
    .ctl_lock(ctl_lock), .ctl_owner(ctl_owner), .ctl_algo(ctl_algo), .ctl_pset(ctl_pset),
    .ctl_usage(ctl_usage), .ctl_exportable(ctl_exportable), .ctl_privileged(ctl_privileged),
    .meta_owner(meta_owner), .meta_algo(meta_algo), .meta_pset(meta_pset),
    .meta_usage(meta_usage), .meta_exportable(meta_exportable), .meta_valid(meta_valid),
    .meta_locked(meta_locked), .meta_generation(meta_generation),
    .hnd_valid(hnd_valid), .hnd_slot(hnd_slot), .hnd_generation(hnd_generation),
    .hnd_algo(ctl_algo), .hnd_pset(ctl_pset), .hnd_usage(ctl_usage),
    .hnd_owner(hnd_owner), .hnd_type(hnd_type), .hnd_ok(hnd_ok), .key_ref(key_ref),
    .privileged(privileged), .debug_unlocked(debug_unlocked),
    .lifecycle_change(lifecycle_change), .access_denied(access_denied),
    .zeroize_req(zeroize_req), .zeroize_done(zeroize_done)
  );

  int errors = 0;
  logic [15:0] prev_gen;
  logic [15:0] gen_before_zero;

  task automatic chk(input logic [31:0] got, input logic [31:0] exp, input string msg);
    if (got !== exp) begin
      $display("FAIL: %s (got %0d exp %0d)", msg, got, exp);
      errors++;
    end
  endtask

  task automatic do_import(input logic [7:0] idx, input logic [2:0] t, input logic [7:0] owner);
    @(negedge clk);
    ctl_we = 1'b1; ctl_import = 1'b1; ctl_destroy = 1'b0; ctl_lock = 1'b0;
    ctl_index = idx; ctl_type = t; ctl_owner = owner;
    ctl_algo = 4'h0; ctl_pset = 4'h2; ctl_usage = 8'h0F; ctl_exportable = 1'b0;
    @(negedge clk);
    ctl_we = 1'b0; ctl_import = 1'b0;
    @(negedge clk);
  endtask

  task automatic check_handle(
    input logic [7:0] slot, input logic [15:0] gen,
    input logic [7:0] owner, input logic [2:0] t,
    input logic exp_ok, input string msg
  );
    hnd_valid = 1'b1; hnd_slot = slot; hnd_generation = gen; hnd_owner = owner; hnd_type = t;
    @(negedge clk);
    chk(hnd_ok, {31'h0, exp_ok}, msg);
  endtask

  initial begin
    ctl_we = 0; ctl_import = 0; ctl_destroy = 0; ctl_export = 0; ctl_lock = 0;
    ctl_exportable = 0; ctl_privileged = 1; ctl_index = 0; ctl_owner = 0;
    ctl_usage = 0; ctl_type = 0; ctl_algo = 0; ctl_pset = 0;
    hnd_valid = 0; hnd_slot = 0; hnd_generation = 0; hnd_owner = 0; hnd_type = 0;
    privileged = 1'b1; debug_unlocked = 1'b0; lifecycle_change = 1'b0;
    zeroize_req = 1'b0;

    rst_n = 1'b0;
    repeat (4) @(posedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // ------------------------------------------------------------------
    // import a key into slot 2 and read back its metadata
    // ------------------------------------------------------------------
    do_import(8'h02, 3'h1, 8'hA5);
    @(negedge clk);
    ctl_index = 8'h02;
    @(negedge clk);
    chk(meta_valid, 32'h1, "slot 2 valid after import");
    chk(meta_owner, 8'hA5, "slot 2 owner metadata");
    chk(meta_pset, 4'h2, "slot 2 parameter set metadata");

    // ------------------------------------------------------------------
    // handle validation: matching tuple succeeds
    // ------------------------------------------------------------------
    check_handle(8'h02, meta_generation, 8'hA5, 3'h1, 1'b1, "valid handle accepted");

    // wrong owner must fail
    check_handle(8'h02, meta_generation, 8'h11, 3'h1, 1'b0, "wrong owner rejected");
    // wrong type must fail
    check_handle(8'h02, meta_generation, 8'hA5, 3'h2, 1'b0, "wrong key type rejected");
    // wrong generation must fail
    check_handle(8'h02, meta_generation + 8'h1, 8'hA5, 3'h1, 1'b0, "wrong generation rejected");

    // ------------------------------------------------------------------
    // destroy invalidates the handle generation
    // ------------------------------------------------------------------
    prev_gen = meta_generation;
    @(negedge clk);
    ctl_we = 1'b1; ctl_destroy = 1'b1; ctl_index = 8'h02;
    @(negedge clk);
    ctl_we = 1'b0; ctl_destroy = 1'b0;
    @(negedge clk);
    ctl_index = 8'h02;
    @(negedge clk);
    chk(meta_valid, 32'h0, "slot 2 invalid after destroy");
    chk(meta_generation, prev_gen + 8'h1, "generation incremented on destroy");
    check_handle(8'h02, prev_gen, 8'hA5, 3'h1, 1'b0, "stale handle rejected after destroy");

    // ------------------------------------------------------------------
    // privilege gating: unprivileged control writes must be ignored
    // ------------------------------------------------------------------
    privileged = 1'b0;
    do_import(8'h03, 3'h1, 8'h5A);
    @(negedge clk);
    ctl_index = 8'h03;
    @(negedge clk);
    chk(meta_valid, 32'h0, "unprivileged import must not create a valid slot");
    ctl_we=1; #1;
    chk(access_denied, 32'h1, "access_denied asserted on unprivileged request");
    ctl_we=0;

    // ------------------------------------------------------------------
    // lifecycle change destroys all keys
    // ------------------------------------------------------------------
    privileged = 1'b1;
    do_import(8'h04, 3'h1, 8'h77);
    @(negedge clk);
    lifecycle_change = 1'b1;
    @(negedge clk);
    lifecycle_change = 1'b0;
    @(negedge clk);
    ctl_index = 8'h04;
    @(negedge clk);
    chk(meta_valid, 32'h0, "lifecycle change invalidates slot 4");

    // ------------------------------------------------------------------
    // zeroize clears all slots
    // ------------------------------------------------------------------
    do_import(8'h05, 3'h1, 8'h99);
    @(negedge clk);
    ctl_index = 8'h05;
    @(negedge clk);
    gen_before_zero = meta_generation;
    zeroize_req = 1'b1;
    @(negedge clk);
    zeroize_req = 1'b0;
    @(negedge clk);
    @(negedge clk);
    chk(meta_valid, 32'h0, "zeroize invalidates slot 5");
    // This IP holds no key bytes (key material lives in the external key
    // manager); zeroize must invalidate every slot and retire its generation.
    if (meta_generation == gen_before_zero) begin
      $display("FAIL: zeroize did not retire the slot generation");
      errors++;
    end

    do_import(8'd6,3'd1,8'h66);
    ctl_index=6;repeat(2) @(negedge clk);
    prev_gen=meta_generation;
    ctl_pset=3;check_handle(6,prev_gen,8'h66,1,0,"wrong pset rejected");ctl_pset=2;
    ctl_algo=1;check_handle(6,prev_gen,8'h66,1,0,"wrong algorithm rejected");ctl_algo=0;
    ctl_usage=8'h80;check_handle(6,prev_gen,8'h66,1,0,"wrong usage rejected");ctl_usage=8'h0f;
    do_import(8'd6,3'd1,8'h66);
    check_handle(6,prev_gen,8'h66,1,0,"reimport retires old handle");
    @(negedge clk);ctl_we=1;ctl_lock=1;ctl_index=6;
    @(negedge clk);ctl_we=0;ctl_lock=0;
    check_handle(6,meta_generation,8'h66,1,0,"locked slot rejected");
    @(negedge clk);ctl_we=1;ctl_destroy=1;
    @(negedge clk);ctl_we=0;ctl_destroy=0;
    chk(meta_valid,1,"locked slot cannot be destroyed by control window");
    for(int i=0;i<65540;i++) do_import(8'd7,3'd1,8'h77);
    ctl_index=7;repeat(2) @(negedge clk);
    chk(meta_generation,65535,"generation saturates without stale-handle wrap");
    check_handle(7,16'h00ff,8'h77,1,0,"high generation byte participates in comparison");
    zeroize_req=1;repeat(10) @(negedge clk);zeroize_req=0;
    chk(meta_generation,65535,"held zeroize cannot wrap generation");

    #40;
    if (errors == 0) $display("UT_pqc_key_slots: PASS (errors=0)");
    else             $display("UT_pqc_key_slots: FAIL (errors=%0d)", errors);
    $finish;
  end

  initial begin
    #3_000_000;
    $display("FAIL: TIMEOUT");
    $display("UT_pqc_key_slots: FAIL (errors=1)");
    $finish;
  end

endmodule