class gpio_fcov extends uvm_subscriber#(apb_xaction);
 `uvm_component_utils(gpio_fcov)
 covergroup apb_cg with function sample(bit wr,bit[3:0] strb,bit[2:0] prot,bit err);
  option.per_instance=1;
  direction:coverpoint wr;
  byte_enable:coverpoint strb {bins values[]={[0:15]};}
  protection:coverpoint prot {bins values[]={[0:7]};}
  error:coverpoint err;
  access_cross:cross direction,byte_enable,protection;
 endgroup
 extern function new(string name,uvm_component parent);
 extern function void write(apb_xaction t);
endclass
function gpio_fcov::new(string name,uvm_component parent);super.new(name,parent);apb_cg=new();endfunction
function void gpio_fcov::write(apb_xaction t);apb_cg.sample(t.write,t.strb,t.prot,t.error);endfunction
