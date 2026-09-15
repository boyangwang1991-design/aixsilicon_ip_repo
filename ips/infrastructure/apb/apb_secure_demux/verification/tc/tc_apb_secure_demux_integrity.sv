`ifndef TC_APB_SECURE_DEMUX_INTEGRITY__SV
`define TC_APB_SECURE_DEMUX_INTEGRITY__SV
// TC.APB_SECURE_DEMUX.INTEGRITY.001
class tc_apb_secure_demux_integrity_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_integrity_sequence)
  extern function new(string name="tc_apb_secure_demux_integrity_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_integrity_sequence::new(string name="tc_apb_secure_demux_integrity_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_integrity_sequence::body();
  if(!C_POLICY_PARITY_EN) begin
    transfer(address_of(K_INTEGRITY_STATUS));allow_port(0,0);transfer(C_PORT_BASE[0]);
  end else begin
    for(int kind=0;kind<6;kind++) begin
      for(int data_mode=0;data_mode<(kind<2?1:2);data_mode++) begin
        int bits_to_check;
        bits_to_check=kind<2?2:(data_mode?(kind<4?2:8):1);
        for(int bit_index=0;bit_index<bits_to_check;bit_index++) begin
          allow_port(ASD_NP-1,ASD_NM-1);
          inject_field(kind,kind==0?0:ASD_NP-1,kind>=4?ASD_NM-1:0,data_mode,bit_index);
          transfer(C_PORT_BASE[ASD_NP-1],0,0,ASD_NM-1);
          transfer(address_of(K_INTEGRITY_STATUS));transfer(address_of(K_STATUS));
          csr_write(K_CFG_SHADOW,3,0);csr_write(K_COMMIT_MASK,1);csr_write(K_SHADOW_RELOAD,1);
          transfer(address_of(K_COMMIT_STATUS));
          transfer(address_of(K_FIRST_FAULT));
          for(int w=1;w<8;w++) transfer(address_of(K_FIRST_FAULT,0,0,w));
          csr_write(K_INTR_RAW,'h1ff);transfer(address_of(K_INTR_RAW));
          release_faults();reset_policy();
        end
      end
    end
    // A later lower-index error cannot replace the first recorded location.
    inject_field(5,ASD_NP-1,ASD_NM-1);
    repeat(2) @(negedge p_sequencer.control.pclk);
    inject_field(0);transfer(address_of(K_INTEGRITY_STATUS));
    release_faults();reset_policy();
  end
endtask
class tc_apb_secure_demux_integrity extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_integrity)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_integrity::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_integrity::stimulus();
  tc_apb_secure_demux_integrity_sequence seq;
  seq=tc_apb_secure_demux_integrity_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask
`endif

