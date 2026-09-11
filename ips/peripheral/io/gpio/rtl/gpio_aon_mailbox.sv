// LLD.MOD.GPIO.MAILBOX / LLD.FSM.GPIO.MAILBOX. A toggle and payload survive warm reset.
module gpio_aon_mailbox #(
  parameter int REQUEST_W=224, RESPONSE_W=352
) (
  input logic clk_i, por_ni, rst_ni,
  input logic aon_clk_i, aon_rst_ni,
  input logic command_i,
  input logic [REQUEST_W-1:0] request_i,
  input logic [1:0] bank_i,
  input logic [23:0] timeout_i,
  input logic clear_timeout_fault_i, clear_error_fault_i,
  output logic ready_o, busy_o, done_o, timeout_o, error_o,
  output logic timeout_fault_o, error_fault_o,
  output logic [1:0] bank_o,
  output logic [RESPONSE_W-1:0] response_o,
  output logic response_valid_o,
  output logic aon_command_o,
  output logic [REQUEST_W-1:0] aon_request_o,
  input logic aon_response_valid_i, aon_error_i,
  input logic [RESPONSE_W-1:0] aon_response_i
);
  typedef enum logic [1:0] {RECOVER=2'b00, READY=2'b01, BUSY=2'b10} state_t;
  state_t state_q;
  logic request_token_q, ack_token_q, inflight_q, destination_busy_q;
  logic [REQUEST_W-1:0] payload_q;
  logic [RESPONSE_W-1:0] response_payload_q;
  logic response_error_q;
  (* ASYNC_REG="TRUE" *) logic [1:0] request_sync_q, ack_sync_q;
  logic [2:0] recovery_q;
  logic [23:0] timer_q;
  logic accept, completed, timeout_now;
  assign accept=command_i && ready_o && rst_ni;
  assign completed=inflight_q && ack_sync_q[1]==request_token_q;
  assign ready_o=rst_ni && state_q==READY && !inflight_q;
  assign busy_o=rst_ni && (state_q==BUSY || inflight_q);
  assign timeout_now=state_q==BUSY && !timeout_o && timer_q>=timeout_i-24'd1;
  assign aon_request_o=payload_q;
  assign aon_command_o=request_sync_q[1]!=ack_token_q && !destination_busy_q;
  // Transport source: POR reset only, never main reset. The source slot retires late ACKs in RECOVER.
  always_ff @(posedge clk_i or negedge por_ni) begin
    if (!por_ni) begin request_token_q<=1'b0; inflight_q<=1'b0; payload_q<='0; end
    else begin
      if (completed) inflight_q<=1'b0;
      if (accept) begin request_token_q<=~request_token_q; inflight_q<=1'b1; payload_q<=request_i; end
    end
  end
  always_ff @(posedge clk_i or negedge por_ni) begin
    if (!por_ni) ack_sync_q<='0;
    else ack_sync_q<={ack_sync_q[0],ack_token_q};
  end
  always_ff @(posedge aon_clk_i or negedge aon_rst_ni) begin
    if (!aon_rst_ni) request_sync_q<='0;
    else request_sync_q<={request_sync_q[0],request_token_q};
  end
  always_ff @(posedge aon_clk_i or negedge aon_rst_ni) begin
    if (!aon_rst_ni) begin
      ack_token_q<=1'b0; destination_busy_q<=1'b0; response_payload_q<='0; response_error_q<=1'b0;
    end else begin
      if (aon_command_o) destination_busy_q<=1'b1;
      if (destination_busy_q && aon_response_valid_i) begin
        response_payload_q<=aon_response_i; response_error_q<=aon_error_i;
        ack_token_q<=request_sync_q[1]; destination_busy_q<=1'b0;
      end
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q<=RECOVER; recovery_q<='0; timer_q<='0;
      done_o<=1'b0; timeout_o<=1'b0; error_o<=1'b0; bank_o<='0;
      timeout_fault_o<=1'b0; error_fault_o<=1'b0; response_o<='0; response_valid_o<=1'b0;
    end else begin
      response_valid_o<=1'b0;
      if (clear_timeout_fault_i) timeout_fault_o<=1'b0;
      if (clear_error_fault_i) error_fault_o<=1'b0;
      case (state_q)
        RECOVER: begin
          if (recovery_q<3'd4) recovery_q<=recovery_q+3'd1;
          else if (!inflight_q && ack_sync_q[1]==request_token_q) state_q<=READY;
        end
        READY: if (accept) begin
          state_q<=BUSY; timer_q<='0; done_o<=1'b0; timeout_o<=1'b0; error_o<=1'b0; bank_o<=bank_i;
        end
        BUSY: begin
          if (!timeout_o) timer_q<=timer_q+24'd1;
          if (timeout_now) begin timeout_o<=1'b1; timeout_fault_o<=1'b1; end
          if (completed) begin
            state_q<=READY; done_o<=1'b1; error_o<=response_error_q;
            response_o<=response_payload_q; response_valid_o<=1'b1;
            if (response_error_q) error_fault_o<=1'b1;
          end
        end
        default: begin state_q<=RECOVER; recovery_q<='0; end
      endcase
    end
  end
endmodule
