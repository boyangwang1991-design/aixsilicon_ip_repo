`ifndef WATCHDOG_APB_QUALIFICATION__SV
`define WATCHDOG_APB_QUALIFICATION__SV
class watchdog_apb_transfer extends uvm_sequence #(apb_item);
  `uvm_object_utils(watchdog_apb_transfer)
  apb_item request;
  extern function new(string name="watchdog_apb_transfer");
  extern task body();
endclass
function watchdog_apb_transfer::new(string name="watchdog_apb_transfer"); super.new(name); endfunction
task watchdog_apb_transfer::body(); start_item(request); finish_item(request); endtask

class watchdog_apb_qualification_test extends uvm_test;
  `uvm_component_utils(watchdog_apb_qualification_test)
  apb_smoke_env env;
  int checks;
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task transfer(bit wr,bit[31:0] addr,bit[31:0] data,bit[3:0] strb,bit[2:0] prot,
    output bit[31:0] value,output bit err);
  extern task run_phase(uvm_phase phase);
  extern function void check_value(bit condition,string label);
  extern function void report_phase(uvm_phase phase);
endclass
function watchdog_apb_qualification_test::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void watchdog_apb_qualification_test::build_phase(uvm_phase phase);
  super.build_phase(phase); env=apb_smoke_env::type_id::create("env",this);
endfunction
function void watchdog_apb_qualification_test::check_value(bit condition,string label);
  checks++; if(!condition) `uvm_error("VIP_QUAL",label)
endfunction
task watchdog_apb_qualification_test::transfer(bit wr,bit[31:0] addr,bit[31:0] data,
  bit[3:0] strb,bit[2:0] prot,output bit[31:0] value,output bit err);
  watchdog_apb_transfer seq;
  seq=watchdog_apb_transfer::type_id::create("seq");seq.request=apb_item::type_id::create("request");
  seq.request.direction=wr ? APB_WRITE : APB_READ;seq.request.addr=addr;
  seq.request.wdata=data;seq.request.strb=strb;seq.request.prot=apb_protection'(prot);
  seq.request.start_delay=0;seq.start(env.master_agent.sequencer);
  value=seq.request.rdata;err=seq.request.slverr;
  check_value(seq.request.status==(err ? APB_ERROR : APB_OK),"transaction status matches sampled error response");
endtask
task watchdog_apb_qualification_test::run_phase(uvm_phase phase);
  bit[31:0] value,expected_value,mask,data;bit err;
  phase.raise_objection(this);
  for(int mode=0;mode<3;mode++) begin
    env.s_cfg.slave_response_mode=mode==0 ? APB_ZERO_WAIT : mode==1 ? APB_FIXED_WAIT : APB_RANDOM_WAIT;
    env.s_cfg.default_wait_cycles=3;env.s_cfg.max_wait_cycles=5;
    for(int i=0;i<16;i++) begin
      expected_value=32'h39a5c617 ^ (32'(i)<<16);
      transfer(1,32'h100+32'(i)*4,expected_value,4'hf,3'(i),value,err);
      check_value(!err,"full write response");
      data=~expected_value; mask=0;
      for(int lane=0;lane<4;lane++) if(i & (1<<lane)) mask|=32'hff<<(8*lane);
      transfer(1,32'h100+32'(i)*4,data,4'(i),3'(i),value,err);
      expected_value=(expected_value & ~mask)|(data & mask);
      transfer(0,32'h100+32'(i)*4,0,0,3'(i),value,err);
      check_value(!err && value===expected_value,$sformatf("byte merge/readback mode=%0d strobe=%x expected=%x actual=%x",mode,i,expected_value,value));
    end
  end
  env.s_cfg.slave_error_mode=APB_ERR_RANDOM;env.s_cfg.slave_err_prob=1.0;
  transfer(0,32'h100,0,0,0,value,err);check_value(err,"PSLVERR read response captured");
  #200ns;phase.drop_objection(this);
endtask
function void watchdog_apb_qualification_test::report_phase(uvm_phase phase);
  if(checks<240) `uvm_error("VIP_QUAL","qualification did not execute all mandatory comparisons")
  if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 &&
     uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0)
    $display("WATCHDOG_APB_QUALIFICATION PASS checks=%0d",checks);
endfunction
`endif
