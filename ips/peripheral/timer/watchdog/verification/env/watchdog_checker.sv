`ifndef WATCHDOG_CHECKER__SV
`define WATCHDOG_CHECKER__SV

class watchdog_checker extends uvm_scoreboard;
  `uvm_component_utils(watchdog_checker)
  uvm_analysis_imp_expected #(watchdog_prediction,watchdog_checker) expected_in;
  uvm_analysis_imp_actual #(watchdog_prediction,watchdog_checker) actual_in;
  uvm_analysis_port #(watchdog_prediction) matched_ap;
  watchdog_prediction expected[string],actual[string];
  longint unsigned checks,mismatches;
  extern function new(string name,uvm_component parent);
  extern function void write_expected(watchdog_prediction p);
  extern function void write_actual(watchdog_prediction p);
  extern function void compare(string label);
  extern function void check_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
endclass
function watchdog_checker::new(string name,uvm_component parent);
  super.new(name,parent);expected_in=new("expected_in",this);actual_in=new("actual_in",this);matched_ap=new("matched_ap",this);
endfunction
function void watchdog_checker::write_expected(watchdog_prediction p);
  if(expected.exists(p.label)) `uvm_fatal("SB_DUP","duplicate expected observation")
  expected[p.label]=p;compare(p.label);
endfunction
function void watchdog_checker::write_actual(watchdog_prediction p);
  if(actual.exists(p.label)) `uvm_fatal("SB_DUP","duplicate actual observation")
  actual[p.label]=p;compare(p.label);
endfunction
function void watchdog_checker::compare(string label);
  if(!expected.exists(label) || !actual.exists(label)) return;
  checks++;
  if((actual[label].actual_value & expected[label].mask)!==(expected[label].expected_value & expected[label].mask)) begin
    mismatches++;
    `uvm_error("SB_MISMATCH",$sformatf("%s expected=%h actual=%h mask=%h",label,expected[label].expected_value,actual[label].actual_value,expected[label].mask))
  end else matched_ap.write(expected[label]);
  expected.delete(label);actual.delete(label);
endfunction
function void watchdog_checker::check_phase(uvm_phase phase);
  if(expected.num() || actual.num()) `uvm_error("SB_DRAIN",$sformatf("unmatched expected=%0d actual=%0d",expected.num(),actual.num()))
  if(checks<100) `uvm_error("SB_EMPTY","insufficient checked observations")
endfunction
function void watchdog_checker::report_phase(uvm_phase phase);
  `uvm_info("WATCHDOG_CHECKS",$sformatf("checks=%0d mismatches=%0d pending=%0d",checks,mismatches,expected.num()+actual.num()),UVM_NONE)
endfunction

`endif
