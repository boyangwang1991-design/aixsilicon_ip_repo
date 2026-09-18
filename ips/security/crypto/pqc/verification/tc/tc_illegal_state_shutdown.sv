// TC.PQC.INTEGRITY.001: bounded idle fault/zeroize integration subset.
// Real external tamper stimulus; no forced internal state or fabricated ACK.
// This does not cover active-command fault injection or physical erasure contents.
`ifndef TC_ILLEGAL_STATE_SHUTDOWN__SV
`define TC_ILLEGAL_STATE_SHUTDOWN__SV
class tc_illegal_state_shutdown extends tc_base;
  `uvm_component_utils(tc_illegal_state_shutdown)
  virtual pqc_main_if bus;
  function new(string name="tc_illegal_state_shutdown",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual pqc_main_if)::get(this,"","main_bus",bus))
      `uvm_fatal("FAULT","missing main_bus")
  endfunction
  task check_reg(logic [9:0] addr,logic [31:0] mask,logic [31:0] expected);
    logic [31:0] data;bit err;
    apb_read(addr,data,err);
    if(err || (data & mask)!==expected)
      `uvm_fatal("FAULT",$sformatf("register %h got %h expected %h mask %h err %b",addr,data,expected,mask,err))
  endtask
  task await_wipe();
    bit completed=0;
    for(int n=0;n<20000;n++) begin
      @(negedge bus.clk);
      if(bus.arvalid || bus.awvalid || bus.wvalid)
        `uvm_fatal("FAULT","unexpected DMA during idle fault wipe")
      if(bus.wipe_done===1'b1) begin completed=1;break;end
    end
    if(!completed) `uvm_fatal("FAULT","no complete subsystem wipe acknowledgment within 20000 cycles")
    repeat(4) @(negedge bus.clk);
    if(bus.wipe_request!==0) `uvm_fatal("FAULT","wipe request failed to retire")
  endtask
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    check_reg(PQC_REG_ALERT_FATAL,32'hffffffff,0);
    check_reg(PQC_REG_ALERT_RECOVERABLE,32'hffffffff,0);
    apb_write(PQC_REG_ALERT_FATAL,32'hffffffff);
    check_reg(PQC_REG_ALERT_FATAL,32'hffffffff,0);
    // Lifecycle DFT gate is closed in the harness: injection must be ignored.
    @(negedge bus.clk);bus.fault_ecc_inject=1;
    repeat(4) @(negedge bus.clk);
    bus.fault_ecc_inject=0;
    check_reg(PQC_REG_ALERT_FATAL,32'hffffffff,0);
    check_reg(PQC_REG_STATUS,32'h10,0);
    if(bus.wipe_request!==0) `uvm_fatal("FAULT","DFT injection bypassed closed lifecycle gate")
    // External tamper must latch fatal/lock and trigger a real full wipe.
    @(negedge bus.clk);bus.tamper=1;
    repeat(4) @(negedge bus.clk);
    if(bus.wipe_request!==1) `uvm_fatal("FAULT","tamper did not request wipe")
    bus.tamper=0;
    check_reg(PQC_REG_ALERT_FATAL,32'h1f,2);
    check_reg(PQC_REG_STATUS,32'h10,32'h10);
    await_wipe();
    // RDL defines W1C history, not a read-only aggregate. W1C does not unlock.
    apb_write(PQC_REG_ALERT_FATAL,32'h2);
    check_reg(PQC_REG_ALERT_FATAL,32'h1f,0);
    check_reg(PQC_REG_STATUS,32'h10,32'h10);
    // A second external wipe is permitted, but must never clear fatal lock.
    @(negedge bus.clk);bus.zeroize_req=1;
    repeat(2) @(negedge bus.clk);bus.zeroize_req=0;
    await_wipe();
    check_reg(PQC_REG_ALERT_FATAL,32'h1f,0);
    check_reg(PQC_REG_STATUS,32'h10,32'h10);
    `uvm_info("FAULT_IDLE_PASS","DFT gating, tamper, two bounded wipe ACKs, W1C and sticky lock checked",UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
`endif
