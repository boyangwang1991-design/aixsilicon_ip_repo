`ifndef APB_SECURE_DEMUX_TARGET_MODEL__SV
`define APB_SECURE_DEMUX_TARGET_MODEL__SV
// Completion-edge peripheral model: +8 read-clear, +12 write-trigger.
// PSTRB=0 performs a checked write transaction with no data/trigger change.
module apb_secure_demux_target_model #(parameter logic [31:0] BASE=0)(
  input logic clk,reset_n,sel,en,write,ready,error,
  input logic [31:0] addr,wdata,input logic [3:0] strb,output logic [31:0] rdata);
  logic [31:0] memory[logic [31:0]];
  logic [31:0] read_clear,trigger_count;
  int unsigned completions,writes,reads;
  always @* begin
    rdata=0;
    if(addr==BASE+8) rdata=read_clear;
    else if(addr==BASE+12) rdata=trigger_count;
    else if(memory.exists(addr)) rdata=memory[addr];
  end
  always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
      memory.delete();read_clear=32'hcafe1234;trigger_count=0;
      completions=0;writes=0;reads=0;
    end else if(sel && en && ready) begin
      // Commit after the sampling region; all responders sample the old value.
      #1ps;
      completions++;
      if(write) begin
        writes++;
        if(!error) begin
          if(!memory.exists(addr)) memory[addr]=0;
          for(int b=0;b<4;b++) if(strb[b]) memory[addr][b*8+:8]=wdata[b*8+:8];
          if(addr==BASE+12 && strb!=0) trigger_count++;
        end
      end else begin
        reads++;
        if(!error && addr==BASE+8) read_clear=0;
      end
    end
  end
endmodule

`endif // APB_SECURE_DEMUX_TARGET_MODEL__SV
