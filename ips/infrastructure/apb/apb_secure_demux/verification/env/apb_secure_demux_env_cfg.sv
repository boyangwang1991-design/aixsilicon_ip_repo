`ifndef APB_SECURE_DEMUX_ENV_CFG__SV
`define APB_SECURE_DEMUX_ENV_CFG__SV
class apb_secure_demux_env_cfg extends uvm_object;
  `uvm_object_utils(apb_secure_demux_env_cfg)
  apb_config upstream,downstream[ASD_NP];
  apb_secure_demux_rm_cfg rm_cfg;
  apb_secure_demux_checker_cfg checker_cfg;
  apb_secure_demux_dut_cfg dut_cfg;
  bit enable_rm=1,enable_checker=1,enable_cov=1;
  string scoreboard_mode="in_order";
  int timeout_cycles=200000;
  extern function new(string name="apb_secure_demux_env_cfg");
endclass
function apb_secure_demux_env_cfg::new(string name="apb_secure_demux_env_cfg");
  super.new(name);
  upstream=apb_config::type_id::create("upstream");
  upstream.agent_mode=APB_ACTIVE_MASTER;
  upstream.protocol_version=APB4;
  upstream.enable_strb=1;
  upstream.enable_prot=1;
  foreach(downstream[p]) begin
    downstream[p]=apb_config::type_id::create($sformatf("downstream_%0d",p));
    downstream[p].protocol_version=APB4;
    downstream[p].agent_mode=APB_ACTIVE_SLAVE;
    downstream[p].enable_strb=1;
    downstream[p].enable_prot=1;
  end
  rm_cfg=apb_secure_demux_rm_cfg::type_id::create("rm_cfg");
  checker_cfg=apb_secure_demux_checker_cfg::type_id::create("checker_cfg");
  dut_cfg=apb_secure_demux_dut_cfg::type_id::create("dut_cfg");
endfunction

`endif // APB_SECURE_DEMUX_ENV_CFG__SV
