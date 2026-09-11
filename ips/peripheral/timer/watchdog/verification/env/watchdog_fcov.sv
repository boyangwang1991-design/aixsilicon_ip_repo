`ifndef WATCHDOG_FCOV__SV
`define WATCHDOG_FCOV__SV

class watchdog_fcov extends uvm_subscriber #(watchdog_prediction);
  `uvm_component_utils(watchdog_fcov)
  int sampled_feature,sampled_scenario,sampled_config;
  covergroup outcomes;
    option.per_instance=1;
    feature: coverpoint sampled_feature {bins features[]={[1:18]};}
    scenario: coverpoint sampled_scenario {bins nominal={0};bins boundary={1};bins rejection={2};bins reset={3};bins stress={4};}
    configuration: coverpoint sampled_config {bins standard={0};bins safety={1};bins supervisor={2};}
  endgroup
  extern function new(string name,uvm_component parent);
  extern function void write(watchdog_prediction t);
endclass
function watchdog_fcov::new(string name,uvm_component parent);super.new(name,parent);outcomes=new;endfunction
function void watchdog_fcov::write(watchdog_prediction t);
  sampled_feature=t.feature;sampled_scenario=t.scenario;sampled_config=t.config_class;
  if(sampled_feature>0) outcomes.sample();
endfunction

`endif
