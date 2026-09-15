`ifndef APB_SECURE_DEMUX_FCOV__SV
`define APB_SECURE_DEMUX_FCOV__SV
class apb_secure_demux_fcov extends uvm_component;
  `uvm_component_utils(apb_secure_demux_fcov)
  covergroup admission_cg with function sample(int port,bit write,bit [2:0] prot,
                                                int master,byte reason,bit valid);
    option.per_instance=1;
    cp_port: coverpoint port { bins local_csr={-2}; bins unmapped={-1}; bins targets[]={[0:ASD_NP-1]}; }
    cp_write: coverpoint write;
    cp_prot: coverpoint prot { bins attributes[]={[0:7]}; }
    cp_master: coverpoint master { bins legal[]={[0:ASD_NM-1]}; bins invalid=default; }
    cp_valid: coverpoint valid;
    cp_reason: coverpoint reason { bins allow={0}; bins deny[]={[1:8]}; bins csr[]={['h10:'h17]};
                                  bins injected={'h41}; }
    access_matrix: cross cp_write,cp_prot,cp_valid;
  endgroup
  extern function new(string name,uvm_component parent);
  extern function void sample(asd_request_t r,asd_prediction_t prediction);
endclass
function apb_secure_demux_fcov::new(string name,uvm_component parent);
  super.new(name,parent);admission_cg=new();
endfunction
function void apb_secure_demux_fcov::sample(asd_request_t r,asd_prediction_t prediction);
  admission_cg.sample(prediction.port,r.write,r.prot,r.master,prediction.reason,r.valid);
endfunction


`endif // APB_SECURE_DEMUX_FCOV__SV
