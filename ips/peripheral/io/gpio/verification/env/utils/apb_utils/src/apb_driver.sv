class apb_driver extends uvm_driver #(apb_xaction);
 `uvm_component_utils(apb_driver)
 virtual apb_interface vif;
 extern function new(string name,uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern task run_phase(uvm_phase phase);
endclass
function apb_driver::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void apb_driver::build_phase(uvm_phase phase);
 super.build_phase(phase);
 if(!uvm_config_db#(virtual apb_interface)::get(this,"","vif",vif)) `uvm_fatal("VIF","APB interface missing")
endfunction
task apb_driver::run_phase(uvm_phase phase);
 forever begin
  seq_item_port.get_next_item(req);
  @(negedge vif.clk);vif.sel=1;vif.enable=0;vif.write=req.write;vif.addr=req.addr;
  vif.wdata=req.data;vif.strb=req.strb;vif.prot=req.prot;
  repeat(req.setup_cycles) @(negedge vif.clk);
  vif.enable=1;
  begin
   bit done=0;
   for(int i=0;i<100;i++) begin
    @(posedge vif.clk);
    if(vif.ready===1'b1) begin req.error=vif.error; if(!req.write) req.data=vif.rdata; done=1;break;end
   end
   if(!done) `uvm_fatal("APB_TIMEOUT","No completion within 100 cycles")
  end
  @(negedge vif.clk);vif.sel=0;vif.enable=0;
  seq_item_port.item_done();
 end
endtask
