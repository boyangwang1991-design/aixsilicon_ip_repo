class apb_monitor extends uvm_monitor;
 `uvm_component_utils(apb_monitor)
 virtual apb_interface vif;
 uvm_analysis_port#(apb_xaction) ap;
 extern function new(string name,uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern task run_phase(uvm_phase phase);
endclass
function apb_monitor::new(string name,uvm_component parent);super.new(name,parent);ap=new("ap",this);endfunction
function void apb_monitor::build_phase(uvm_phase phase);
 super.build_phase(phase);
 if(!uvm_config_db#(virtual apb_interface)::get(this,"","vif",vif)) `uvm_fatal("VIF","APB monitor interface missing")
endfunction
task apb_monitor::run_phase(uvm_phase phase);
 forever begin
  @(vif.mon_cb);
  if(vif.mon_cb.rst_n && vif.mon_cb.sel && vif.mon_cb.enable && vif.mon_cb.ready) begin
   apb_xaction t=apb_xaction::type_id::create("observed");
   t.write=vif.mon_cb.write;t.addr=vif.mon_cb.addr;t.strb=vif.mon_cb.strb;t.prot=vif.mon_cb.prot;
   t.error=vif.mon_cb.error;t.data=t.write?vif.mon_cb.wdata:vif.mon_cb.rdata;ap.write(t);
  end
 end
endtask
