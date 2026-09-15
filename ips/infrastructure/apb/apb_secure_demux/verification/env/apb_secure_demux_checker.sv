`ifndef APB_SECURE_DEMUX_CHECKER__SV
`define APB_SECURE_DEMUX_CHECKER__SV
// Checks every SETUP and ACCESS edge, including transactions with no downstream activity.
class apb_secure_demux_checker extends uvm_component;
  `uvm_component_utils(apb_secure_demux_checker)
  virtual apb_secure_demux_control_if vif;
  apb_secure_demux_rm rm;
  apb_secure_demux_fcov fcov;
  asd_request_t request;
  asd_prediction_t admitted;
  bit pending,test_tag,wait_reported;
  int unsigned age,waits,version,cycles,checks,completed,downstream_completed;
  int unsigned setups[ASD_NP],effects[ASD_NP];
  extern function new(string name,uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void verify(bit ok,string message);
  extern task run_phase(uvm_phase phase);
  extern function void observe();
  extern function void check_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
endclass
function apb_secure_demux_checker::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
function void apb_secure_demux_checker::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual apb_secure_demux_control_if)::get(this,"","control",vif))
    `uvm_fatal("CONTROL","Missing sideband cycle interface")
endfunction
function void apb_secure_demux_checker::verify(bit ok,string message);
  checks++;
  if(!ok) `uvm_error("ASD_COMPARE",$sformatf("cycle=%0d addr=%h master=%0d: %s",
                                           cycles,request.addr,request.master,message))
endfunction
task apb_secure_demux_checker::run_phase(uvm_phase phase);
  forever begin @(vif.cb); observe();end
endtask
function void apb_secure_demux_checker::observe();
  bit setup,access,route,selected_setup,ready,error;
  int selected;
  bit [31:0] data;
  byte reason;
  bit [ASD_NP-1:0] expected_select;
  cycles++;
  if(cycles>200000) `uvm_fatal("TIMEOUT","200000-cycle test timeout")
  if(!vif.cb.reset_n) begin
    pending=0;rm.reset();age=0;waits=0;wait_reported=0;
    foreach(setups[p]) begin setups[p]=0;effects[p]=0;end
    verify(vif.cb.m_sel==='0 && vif.cb.m_valid==='0 &&
           vif.cb.s_ready===0 && vif.cb.s_error===0 && vif.cb.s_rdata===0,"reset isolation");
    return;
  end
  verify(vif.cb.irq===bit'(|(rm.raw&rm.intr_enable)),"IRQ equation");
  verify(vif.cb.alert===bit'(|(rm.raw&rm.alert_enable)),"alert equation");
  rm.start_cycle();
  rm.observe_fault(vif.cb.fault_active,vif.cb.fault_data,vif.cb.fault_kind,
                   vif.cb.fault_port,vif.cb.fault_master,vif.cb.fault_bit);
  setup=vif.cb.s_sel && !vif.cb.s_en && !pending;
  access=vif.cb.s_sel && vif.cb.s_en && pending;
  if(setup) begin
    request='{addr:vif.cb.s_addr,data:vif.cb.s_wdata,strb:vif.cb.s_strb,
              prot:vif.cb.s_prot,write:vif.cb.s_write,valid:vif.cb.master_valid,
              master:32'(vif.cb.master_id)};
    admitted=rm.admission(request,vif.cb.authorized);version=rm.policy_version;
    if(vif.cb.decode_fault) begin admitted.reason='h02;admitted.port=-1;admitted.error=1;end
    test_tag=admitted.reason=='h41 || (admitted.reason=='h04 && !rm.fatal && !rm.raw_fault && rm.armed[1]);
    age=0;waits=0;wait_reported=0;pending=1;
    if(fcov!=null) fcov.sample(request,admitted);
  end
  selected=admitted.port;
  route=pending && selected>=0 && admitted.reason==0;
  verify(vif.cb.busy===bit'(C_DFX_EN && vif.cb.authorized && route),"DFX busy authorization");
  verify(vif.cb.port_valid===bit'(C_DFX_EN && vif.cb.authorized && route),"DFX port validity");
  verify(vif.cb.active_port===((C_DFX_EN && vif.cb.authorized && route)?5'(selected):5'b0),
         "DFX selected port");
  verify(vif.cb.wait_hit===bit'(C_DFX_EN && vif.cb.authorized && rm.wait_hit),"DFX sticky wait visibility");
  selected_setup=route && ((setup && !C_REGISTER_MODE) || (age==1 && C_REGISTER_MODE));
  expected_select='0;
  if(route && (!C_REGISTER_MODE || !setup)) expected_select[selected]=1;
  verify(vif.cb.m_sel===expected_select,"exact downstream select, including denied SETUP");
  verify(vif.cb.m_valid===expected_select,"identity valid only on selected output");
  foreach(setups[p]) begin
    if(expected_select[p]) begin
      verify(vif.cb.m_en[p]===!selected_setup,"downstream phase");
      verify(vif.cb.m_addr[p]===request.addr && vif.cb.m_write[p]===request.write &&
             vif.cb.m_wdata[p]===request.data && vif.cb.m_strb[p]===request.strb &&
             vif.cb.m_prot[p]===request.prot && 32'(vif.cb.m_id[p])===request.master,
             "retained request, attributes and full identity");
      if(selected_setup) setups[p]++;
    end else if(C_OUTPUT_ISOLATION_EN) begin
      verify(vif.cb.m_en[p]===0 && vif.cb.m_addr[p]===0 && vif.cb.m_write[p]===0 &&
             vif.cb.m_wdata[p]===0 && vif.cb.m_strb[p]===0 &&
             vif.cb.m_prot[p]===0 && vif.cb.m_id[p]===0,"unselected isolation");
    end
  end
  ready=!(vif.cb.s_sel && vif.cb.s_en);error=0;data=0;reason=admitted.reason;
  if(access) begin
    verify(vif.cb.s_addr===request.addr && vif.cb.s_write===request.write &&
           vif.cb.s_wdata===request.data && vif.cb.s_strb===request.strb &&
           vif.cb.s_prot===request.prot && 32'(vif.cb.master_id)===request.master &&
           vif.cb.master_valid===request.valid,"upstream identity/request stable through completion");
    if(route && !selected_setup) begin
      ready=vif.cb.m_ready[selected];error=ready && vif.cb.m_error[selected];
      // The response payload is exposed only on downstream completion.
      data=ready ? vif.cb.m_rdata[selected] : 32'b0;
      if(error) reason='h20;
    end else if(!route) begin
      ready=1;
      if(selected==-2) reason=rm.csr_reason(request,vif.cb.authorized);
      error=reason!=0;
      if(!error && !request.write) data=rm.read_csr(request,vif.cb.authorized);
    end
  end
  verify(vif.cb.s_ready===ready,"completion latency");
  verify(vif.cb.s_error===error,"response error");
  verify(vif.cb.s_rdata===data,$sformatf("response data actual=%h expected=%h",vif.cb.s_rdata,data));
  if(route && access && !selected_setup && !ready) begin
    waits=rm.sat(waits);
    rm.wait_cycle(request,selected,waits,!wait_reported && rm.threshold!=0 &&
                  waits>=rm.threshold,version);
    if(rm.threshold!=0 && waits>=rm.threshold) wait_reported=1;
  end
  if(access && ready) begin
    completed++;
    if(selected==-2) rm.complete_csr(request,vif.cb.authorized);
    if(route) begin
      rm.target_complete(selected,error,waits);
      downstream_completed++;effects[selected]++;
      verify(setups[selected]==effects[selected],"exactly one downstream completion per SETUP");
    end
    if(error) rm.bus_failure(request,reason,selected==-2,selected,test_tag,version);
    pending=0;
  end
  if(setup && test_tag) rm.consume_injection(request,selected,admitted.reason);
  if(!vif.cb.authorized) rm.armed=0;
  rm.end_cycle();
  if(pending) age++;
endfunction
function void apb_secure_demux_checker::check_phase(uvm_phase phase);
  super.check_phase(phase);
  verify(!pending,"no missing completion at end of test");
  verify(completed>0,"nonempty checked transaction set");
endfunction
function void apb_secure_demux_checker::report_phase(uvm_phase phase);
  super.report_phase(phase);
  `uvm_info("CHECKER",$sformatf("checked=%0d completed=%0d downstream=%0d",checks,
                               completed,downstream_completed),UVM_LOW)
  if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 &&
     uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0)
    `uvm_info("CHECKER","CHECKER PASS",UVM_NONE)
endfunction

`endif // APB_SECURE_DEMUX_CHECKER__SV
