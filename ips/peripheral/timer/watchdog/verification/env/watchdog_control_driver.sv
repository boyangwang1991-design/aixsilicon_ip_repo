`ifndef WATCHDOG_CONTROL_DRIVER__SV
`define WATCHDOG_CONTROL_DRIVER__SV
class watchdog_control_driver extends uvm_driver #(watchdog_control_item);
  `uvm_component_utils(watchdog_control_driver)
  virtual watchdog_control_if vif;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
endclass
function watchdog_control_driver::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void watchdog_control_driver::build_phase(uvm_phase phase);
  if(!uvm_config_db#(virtual watchdog_control_if)::get(this,"","vif",vif)) `uvm_fatal("CTRL","missing interface")
endfunction
task watchdog_control_driver::run_phase(uvm_phase phase);
  watchdog_control_item req;
  forever begin
    seq_item_port.get_next_item(req);
    case(req.kind)
      CTRL_POR: begin
        vif.pclk_enable=1;vif.wdt_enable=1;vif.por_n=0;vif.preset_n=0;
        vif.warm=0;vif.sleep_req=0;vif.debug_req=0;vif.recovery_done=0;vif.hw_valid=0;
        repeat(5) @(negedge vif.wdt_clk);vif.por_n=1;vif.preset_n=1;
        repeat(vif.sync_stages+3) @(negedge vif.wdt_clk);
        repeat(vif.sync_stages+3) @(negedge vif.pclk);
      end
      CTRL_PRESET: begin
        @(negedge vif.pclk);vif.preset_n=0;repeat(req.cycles) @(negedge vif.pclk);vif.preset_n=1;
        repeat(vif.sync_stages+2) @(negedge vif.pclk);
      end
      CTRL_WARM: begin @(negedge vif.wdt_clk);vif.warm=1;@(negedge vif.wdt_clk);vif.warm=0;end
      CTRL_SLEEP: begin @(negedge vif.wdt_clk);vif.sleep_req=req.value;end
      CTRL_DEBUG: begin @(negedge vif.wdt_clk);vif.debug_req=req.value;vif.debug_auth=req.aux;end
      CTRL_AUTH: begin
        @(negedge vif.pclk);vif.source_id=16'(req.source);vif.cfg_auth=req.cfg_auth;
        vif.service_auth=req.service_auth;vif.diag_auth=req.diag_auth;vif.test_auth=req.test_auth;
      end
      CTRL_RECOVERY: begin @(negedge vif.wdt_clk);vif.recovery_done[req.channel]=req.value;end
      CTRL_CLOCKS: begin
        if(vif.pclk_enable) @(negedge vif.pclk);
        if(vif.wdt_enable) @(negedge vif.wdt_clk);
        vif.pclk_enable=req.value;vif.wdt_enable=req.aux;
      end
      CTRL_HW_EVENT: begin
        @(negedge vif.wdt_clk);vif.hw_valid=1;vif.hw_channel=4'(req.channel);vif.hw_client=5'(req.client);
        vif.hw_type=3'(req.event_type);vif.hw_data=req.data;vif.hw_source=16'(req.source);
        begin bit accepted=0;
          for(int i=0;i<100000;i++) begin @(posedge vif.wdt_clk);if(vif.hw_ready) begin accepted=1;break;end end
          if(!accepted) `uvm_fatal("CTRL","HW event timed out")
        end
        @(negedge vif.wdt_clk);vif.hw_valid=0;
      end
      CTRL_WAIT: repeat(req.cycles) @(negedge vif.wdt_clk);
      default: `uvm_fatal("CTRL","unknown control operation")
    endcase
    seq_item_port.item_done();
  end
endtask
`endif
