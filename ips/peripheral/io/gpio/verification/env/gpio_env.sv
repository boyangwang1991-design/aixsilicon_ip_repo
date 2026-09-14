class gpio_env extends uvm_env;
 `uvm_component_utils(gpio_env)
 apb_interface_agent apb;gpio_rm rm;gpio_fcov fcov;
 gpio_regs ral;gpio_ral_adapter adapter;uvm_reg_predictor#(apb_xaction) predictor;
 virtual gpio_control_if ctrl;
 extern function new(string name,uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);
endclass
function gpio_env::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void gpio_env::build_phase(uvm_phase phase);
 super.build_phase(phase);
 if(!uvm_config_db#(virtual gpio_control_if)::get(this,"","ctrl",ctrl)) `uvm_fatal("VIF","control missing")
 apb=apb_interface_agent::type_id::create("apb",this);rm=gpio_rm::type_id::create("rm",this);fcov=gpio_fcov::type_id::create("fcov",this);
 rm.width=ctrl.width;ral=new("ral");ral.build();ral.lock_model();ral.reset();adapter=new();predictor=new("predictor",this);
endfunction
function void gpio_env::connect_phase(uvm_phase phase);
 apb.mon.ap.connect(rm.analysis_export);apb.mon.ap.connect(fcov.analysis_export);
 ral.default_map.set_sequencer(apb.sqr,adapter);ral.default_map.set_auto_predict(0);
 predictor.map=ral.default_map;predictor.adapter=adapter;apb.mon.ap.connect(predictor.bus_in);
endfunction
