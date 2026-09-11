// LRS.FUNC.WATCHDOG.TIM.001 / SAFETY final holding invariants.
// Constrained configuration is explicit; this proof does not cover APB transport.
module watchdog_formal_harness #(
 parameter int W=32,P=16,SAFETY=1
)(input logic clk,rst_n,service_valid,sleep_req,debug_req,debug_auth,warm,access_error,cdc_error,
 input logic[31:0] service_data);
 import watchdog_pkg::*;
 function automatic config_t proof_configuration();
   config_t c;c='0;c.word[0]='h600;c.word[4]=16;c.word[10]=8;c.word[11]=1;c.word[12]='h3de;return c;
 endfunction
 localparam config_t CONF=proof_configuration();
 command_t command;
 always_comb begin command='0;command.opcode=SERVICE;command.data=service_data;command.service_auth=1;end
 logic final_request,safe_request,alert;
 watchdog_channel #(.COUNTER_WIDTH(W),.PRESCALE_WIDTH(P),.SAFETY_EN(SAFETY),.AUTO_START(1),.DEFAULT_CFG(CONF)) dut(
  .clk(clk),.rst_n(rst_n),.cmd_valid(service_valid),.cmd(command),.cmd_config(CONF),
  .access_error(access_error),.cdc_error(cdc_error),.sleep_req(sleep_req),.debug_req(debug_req),.debug_auth(debug_auth),
  .warm_reset_evt(warm),.recovery_done(1'b0),.test_auth(1'b0),.system_reset_req(final_request),.safe_state_req(safe_request),
  .safety_alert(alert),.result(),.snapshot_next(),.irq(),.active_fault(),.pause_ack(),.recovery_ack(),.nmi_req(),.local_reset_req(),.wake_req());
 final_hold: assert property(@(posedge clk) disable iff(!rst_n) final_request && !warm |=> final_request);
 safe_follows_final: assert property(@(posedge clk) disable iff(!rst_n) final_request |-> safe_request && alert);
 counter_bounded: assert property(@(posedge clk) disable iff(!rst_n) dut.q.count<=16);
 exact_timeout: assert property(@(posedge clk) disable iff(!rst_n)
   dut.q.state==RUN && dut.q.count==15 && !warm |=> final_request);
 paused_count: assert property(@(posedge clk) disable iff(!rst_n)
   dut.q.state==PAUSED_STATE && !warm |=> $stable(dut.q.count));
 final_reachable: cover property(@(posedge clk) disable iff(!rst_n) final_request);
 refresh_reachable: cover property(@(posedge clk) disable iff(!rst_n) dut.q.service_seq==2 && !final_request);
 pause_reachable: cover property(@(posedge clk) disable iff(!rst_n) dut.q.state==PAUSED_STATE);
endmodule
