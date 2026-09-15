`ifndef TC_APB_SECURE_DEMUX_RANDOM_STRESS__SV
`define TC_APB_SECURE_DEMUX_RANDOM_STRESS__SV
// TC.APB_SECURE_DEMUX.APB.RANDOM
class tc_apb_secure_demux_random_stress_sequence extends apb_secure_demux_virtual_sequence;
  `uvm_object_utils(tc_apb_secure_demux_random_stress_sequence)
  extern function new(string name="tc_apb_secure_demux_random_stress_sequence");
  extern task body();
endclass
function tc_apb_secure_demux_random_stress_sequence::new(string name="tc_apb_secure_demux_random_stress_sequence");
  super.new(name);
endfunction
task tc_apb_secure_demux_random_stress_sequence::body();
  for(int n=0;n<1000;n++) begin
    int p,m,action;
    p=$urandom_range(ASD_NP-1,0);m=$urandom_range(ASD_NM-1,0);action=$urandom_range(9,0);
    case(action)
      0,1:allow_port(p,m,8'($urandom()),2'($urandom()));
      2:begin
        p_sequencer.cfg.downstream[p].slave_response_mode=APB_FIXED_WAIT;
        p_sequencer.cfg.downstream[p].default_wait_cycles=$urandom_range(257,0);
      end
      3:begin
        p_sequencer.cfg.downstream[p].slave_error_mode=APB_ERR_RANDOM;
        p_sequencer.cfg.downstream[p].slave_err_prob=0.25;
      end
      4:begin csr_write(K_FAULT_CLEAR,'hf);csr_write(K_INTR_RAW,'h1ff);end
      5:begin if(n%50==0) reset_policy();else transfer(address_of(K_POLICY_VERSION));end
      default:transfer(C_PORT_BASE[p]+4*$urandom_range(3,0),1'($urandom()),$urandom(),m,
                       1'($urandom()),3'($urandom()),4'($urandom()));
    endcase
  end
  transfer(address_of(K_LAST_FAULT));for(int w=1;w<8;w++) transfer(address_of(K_LAST_FAULT,0,0,w));
endtask
class tc_apb_secure_demux_random_stress extends tc_base;
  `uvm_component_utils(tc_apb_secure_demux_random_stress)
  extern function new(string name,uvm_component parent);
  extern task stimulus();
endclass
function tc_apb_secure_demux_random_stress::new(string name,uvm_component parent);
  super.new(name,parent);
endfunction
task tc_apb_secure_demux_random_stress::stimulus();
  tc_apb_secure_demux_random_stress_sequence seq;
  seq=tc_apb_secure_demux_random_stress_sequence::type_id::create("sequence");seq.start(env.v_sqr);
endtask
`endif

