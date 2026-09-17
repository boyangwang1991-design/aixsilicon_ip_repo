// LLD.MOD.PQC.TOP.RANDOM: single 600-byte entropy cache and exclusive lease.
module pqc_random_service (
  input logic clk, rst_n,
  input logic [31:0] trusted_epoch,
  input logic [7:0] trusted_domain,
  input logic req_valid,
  output logic req_ready,
  input logic [2:0] req_consumer, req_purpose,
  input logic [31:0] req_epoch, req_primitive, req_quota_bits, req_wait_limit,
  input logic [12:0] req_chunk_bits,
  input logic entropy_valid,
  output logic entropy_ready,
  input logic [63:0] entropy_data,
  input logic [7:0] entropy_domain,
  input logic entropy_health_ok,
  output logic [4:0] chunk_valid,
  input logic [4:0] chunk_ready,
  output logic [4:0][4799:0] chunk_data,
  output logic [31:0] chunk_epoch, chunk_primitive, chunk_lease, chunk_index,
  output logic [2:0] chunk_purpose,
  output logic [12:0] chunk_bits,
  input logic release_valid,
  input logic [2:0] release_consumer,
  input logic [31:0] release_epoch, release_primitive, release_lease, release_index,
  input logic [12:0] next_chunk_bits,
  input logic clear_req,
  input logic [31:0] clear_epoch,
  input logic [4:0] consumer_clear_done,
  input logic [4:0][31:0] consumer_clear_epoch,
  output logic clear_done,
  output logic [31:0] clear_done_epoch,
  output logic fault
);
  typedef enum logic [4:0] {
    CLEAR=5'b00001, FREE=5'b00010, COLLECT=5'b00100,
    HOLD=5'b01000, IN_USE=5'b10000
  } state_t;
  state_t state;
  logic [4799:0] cache;
  logic [31:0] remaining, lease_counter, clear_id;
  logic [31:0] wait_cycles, wait_limit;
  logic [12:0] collected;
  logic [6:0] word_index;
  logic [2:0] owner;
  logic [7:0] domain_q;
  logic clear_active, wiped, all_ack, release_matches, context_matches;
  logic chunk_fire, bad_entropy, request_ok, release_ok;
  logic timed_out;
  logic [63:0] entropy_mask;
  logic [12:0] needed;

  assign context_matches = chunk_epoch == trusted_epoch && domain_q == trusted_domain;
  assign request_ok = req_consumer < 3'd5 && req_purpose < 3'd5 && req_epoch != 32'd0 &&
                      req_epoch == trusted_epoch && req_chunk_bits != 13'd0 &&
                      req_chunk_bits <= 13'd4800 && {19'd0,req_chunk_bits} <= req_quota_bits &&
                      lease_counter != 32'hffffffff && req_wait_limit != 32'd0;
  assign release_matches = release_consumer == owner && release_epoch == chunk_epoch &&
                           release_primitive == chunk_primitive && release_lease == chunk_lease &&
                           release_index == chunk_index;
  assign release_ok = release_matches && (remaining == 32'd0 ||
                      (next_chunk_bits != 13'd0 && next_chunk_bits <= 13'd4800 &&
                       {19'd0,next_chunk_bits} <= remaining && chunk_index != 32'hffffffff));
  assign req_ready = rst_n && state == FREE && !clear_req && !fault && entropy_health_ok;
  assign timed_out = (state == COLLECT || state == HOLD || state == IN_USE) &&
                     wait_cycles >= wait_limit;
  assign entropy_ready = rst_n && state == COLLECT && !clear_req && !fault && !timed_out &&
                         entropy_health_ok && context_matches && entropy_domain == domain_q;
  assign needed = chunk_bits-collected;
  assign entropy_mask = needed >= 13'd64 ? 64'hffffffffffffffff :
                        (64'h1 << needed)-64'h1;
  assign bad_entropy = state == COLLECT && entropy_valid && entropy_domain != domain_q;
  assign chunk_fire = |(chunk_valid & chunk_ready);
  assign clear_done = rst_n && state == CLEAR && wiped && all_ack &&
                      (!clear_req || (clear_active && clear_id == clear_epoch));
  assign clear_done_epoch = clear_id;
  always_comb begin
    all_ack = 1'b1;
    for (int i=0;i<5;i++)
      all_ack = all_ack && consumer_clear_done[i] && consumer_clear_epoch[i] == clear_id;
    chunk_valid = 5'b00000;
    chunk_data = '0;
    if (rst_n && !clear_req && !fault && !timed_out && entropy_health_ok && context_matches && owner < 3'd5) begin
      if (state == HOLD) chunk_valid[owner] = 1'b1;
      if (state == HOLD || state == IN_USE) chunk_data[owner] = cache;
    end
  end
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= CLEAR; cache <= '0; remaining <= '0; collected <= '0; word_index <= '0;
      owner <= '0; domain_q <= '0; lease_counter <= '0; chunk_epoch <= '0;
      chunk_primitive <= '0; chunk_lease <= '0; chunk_index <= '0; chunk_purpose <= '0;
      chunk_bits <= '0; clear_id <= '0; clear_active <= 1'b0; wiped <= 1'b0; fault <= 1'b0;
      wait_cycles <= '0;wait_limit <= '0;
    end else begin
      if (!clear_req) clear_active <= 1'b0;
      if (state == COLLECT || state == HOLD || state == IN_USE) begin
        if ((entropy_valid && entropy_ready) || chunk_fire || (state == IN_USE && release_valid && release_ok))
          wait_cycles <= '0;
        else if (!timed_out) wait_cycles <= wait_cycles+32'd1;
      end
      if (clear_req || !entropy_health_ok || bad_entropy || timed_out ||
          ((state == COLLECT || state == HOLD || state == IN_USE) && !context_matches)) begin
        state <= CLEAR; cache <= '0; remaining <= '0; collected <= '0; word_index <= '0;
        owner <= '0; domain_q <= '0; chunk_epoch <= '0; chunk_primitive <= '0;
        chunk_lease <= '0; chunk_index <= '0; chunk_purpose <= '0; chunk_bits <= '0;
        wiped <= 1'b1;
        wait_cycles <= '0;wait_limit <= '0;
        if (clear_req && !clear_active) begin
          clear_id <= clear_epoch; clear_active <= 1'b1;
        end
        if (!entropy_health_ok || bad_entropy || timed_out ||
            (clear_req && clear_active && clear_id != clear_epoch) ||
            (!clear_req && (state == COLLECT || state == HOLD || state == IN_USE) && !context_matches))
          fault <= 1'b1;
      end else begin
        case (state)
          CLEAR: begin
            cache <= '0; wiped <= 1'b1;
            remaining <= '0;collected <= '0;word_index <= '0;owner <= '0;domain_q <= '0;
            chunk_epoch <= '0;chunk_primitive <= '0;chunk_lease <= '0;
            chunk_index <= '0;chunk_purpose <= '0;chunk_bits <= '0;
            wait_cycles <= '0;wait_limit <= '0;
            if (wiped && all_ack && !fault) begin state <= FREE; wiped <= 1'b0; end
          end
          FREE: if (req_valid) begin
            if (!request_ok) begin fault <= 1'b1;state <= CLEAR; end
            else begin
              owner <= req_consumer;domain_q <= trusted_domain;
              wait_limit <= req_wait_limit;wait_cycles <= '0;
              chunk_epoch <= req_epoch;chunk_primitive <= req_primitive;
              chunk_purpose <= req_purpose;remaining <= req_quota_bits;
              chunk_bits <= req_chunk_bits;chunk_index <= '0;
              lease_counter <= lease_counter+32'd1;chunk_lease <= lease_counter+32'd1;
              collected <= '0;word_index <= '0;cache <= '0;state <= COLLECT;
            end
          end
          COLLECT: if (entropy_valid && entropy_ready) begin
            cache[word_index*64+:64] <= entropy_data & entropy_mask;
            if (needed <= 13'd64) begin collected <= chunk_bits;state <= HOLD; end
            else begin collected <= collected+13'd64;word_index <= word_index+7'd1; end
          end
          HOLD: if (chunk_fire) begin
            remaining <= remaining-{19'd0,chunk_bits};state <= IN_USE;
          end
          IN_USE: if (release_valid) begin
            cache <= '0;collected <= '0;word_index <= '0;
            if (!release_ok) begin fault <= 1'b1;state <= CLEAR; end
            else if (remaining == 32'd0) begin
              state <= FREE;chunk_epoch <= '0;chunk_primitive <= '0;chunk_lease <= '0;
              chunk_index <= '0;chunk_purpose <= '0;chunk_bits <= '0;owner <= '0;domain_q <= '0;
            end else begin
              chunk_bits <= next_chunk_bits;chunk_index <= chunk_index+32'd1;state <= COLLECT;
            end
          end
          default: begin fault <= 1'b1;state <= CLEAR;cache <= '0; end
        endcase
      end
    end
  end
endmodule
