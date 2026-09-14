`ifndef GPIO_TC_BASE_SV
`define GPIO_TC_BASE_SV
class gpio_bus_sequence extends uvm_sequence#(apb_xaction);
 `uvm_object_utils(gpio_bus_sequence)
 apb_xaction item;
 extern function new(string name="gpio_bus_sequence");
 extern task body();
endclass
function gpio_bus_sequence::new(string name="gpio_bus_sequence");super.new(name);endfunction
task gpio_bus_sequence::body();start_item(item);finish_item(item);endtask
class tc_base extends uvm_test;
 `uvm_component_utils(tc_base)
 gpio_env env;virtual gpio_control_if ctrl;int checked=0;
 extern function new(string name,uvm_component parent);
 extern function void build_phase(uvm_phase phase);
 extern task run_phase(uvm_phase phase);
 extern virtual task scenario();
 extern task access(bit wr,int addr,bit[31:0] value,output logic[31:0] data,input bit error=0,bit[3:0] strb=15,bit[2:0] prot=1,int setup=1);
 extern task wr(int addr,bit[31:0] value,bit error=0,bit[3:0] strb=15,bit[2:0] prot=1);
 extern task rd(int addr,bit[31:0] expected,bit[31:0] mask='1,bit error=0);
 extern function void expect_true(bit ok,string message);
 extern task reset(bit warm=0);
 extern function void report_phase(uvm_phase phase);
endclass
function tc_base::new(string name,uvm_component parent);super.new(name,parent);endfunction
function void tc_base::build_phase(uvm_phase phase);
 super.build_phase(phase);env=gpio_env::type_id::create("env",this);
 if(!uvm_config_db#(virtual gpio_control_if)::get(this,"","ctrl",ctrl)) `uvm_fatal("VIF","control missing")
endfunction
task tc_base::reset(bit warm=0);ctrl.reset(warm);env.rm.reset();env.ral.reset();endtask
function void tc_base::expect_true(bit ok,string message);checked++;if(!ok) `uvm_error("CHECK",message) endfunction
task tc_base::access(bit wr,int addr,bit[31:0] value,output logic[31:0] data,input bit error=0,bit[3:0] strb=15,bit[2:0] prot=1,int setup=1);
 gpio_bus_sequence seq=new("access");seq.item=new("item");seq.item.write=wr;seq.item.addr=addr;seq.item.data=value;
 seq.item.strb=strb;seq.item.prot=prot;seq.item.setup_cycles=setup;seq.start(env.apb.sqr);data=seq.item.data;
 expect_true(seq.item.error===error,$sformatf("APB addr=%h write=%b expected error=%b actual=%b",addr,wr,error,seq.item.error));
 if(error&&!wr) expect_true(data===0,"error read must return zero");
endtask
task tc_base::wr(int addr,bit[31:0] value,bit error=0,bit[3:0] strb=15,bit[2:0] prot=1);logic[31:0] data;access(1,addr,value,data,error,strb,prot);endtask
task tc_base::rd(int addr,bit[31:0] expected,bit[31:0] mask='1,bit error=0);
 logic[31:0] data;access(0,addr,0,data,error);expect_true((data&mask)===(expected&mask),$sformatf("read %h expected=%h actual=%h mask=%h",addr,expected,data,mask));
endtask
task tc_base::scenario();`uvm_fatal("ABSTRACT","Select a concrete testcase") endtask
task tc_base::run_phase(uvm_phase phase);
 phase.raise_objection(this);reset();scenario();ctrl.main_run=1;ctrl.aon_run=1;ctrl.ticks(5);phase.drop_objection(this);
endtask
function void tc_base::report_phase(uvm_phase phase);
 uvm_report_server server=uvm_report_server::get_server();
 if(checked==0) `uvm_error("EMPTY","No checks executed")
 `uvm_info("CHECK_COUNT",$sformatf("checks=%0d monitored=%0d rm_compares=%0d",checked,env.rm.transactions,env.rm.comparisons),UVM_NONE)
 if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0 && checked>0)
  `uvm_info("TEST_PASS",$sformatf("%s PASS",get_type_name()),UVM_NONE)
endfunction
`endif
