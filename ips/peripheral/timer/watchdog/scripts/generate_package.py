from pathlib import Path
import yaml,json,hashlib
p=Path(__file__).resolve().parents[1]
rtl=['rtl/watchdog_pkg.sv','rtl/watchdog_channel.sv','rtl/watchdog_top.sv']
generated=['rtl/generated/watchdog_csr_pkg.sv','rtl/generated/watchdog_csr.sv','rtl/generated/watchdog_reg_adapter.sv']
filesets={'pkg':{'files':[rtl[0]],'file_type':'systemVerilogSource'},'generated':{'files':generated,'file_type':'systemVerilogSource'},'rtl':{'files':rtl[1:],'file_type':'systemVerilogSource','depend':['aixsilicon:cbb:round_robin_arbiter:0.1.0']}}
params={n:dict(datatype='int',paramtype='vlogparam',default=d) for n,d in dict(NUM_CHANNELS=1,COUNTER_WIDTH=32,PRESCALE_WIDTH=16,NUM_CLIENTS=1,SOURCE_WIDTH=4,SYNC_STAGES=2,SUPPORT_TOKEN_QA=0,SUPPORT_SUPERVISION=0,SUPPORT_HW_EVENT=0,SAFETY_EN=0,ALLOW_RUNTIME_UPDATE=0,DIAG_INJECT_EN=0).items()}
targets={'default':{'filesets':['pkg','generated','rtl'],'toplevel':'watchdog_top'}}
for target in ['elab','lint']:
 targets[target]={'default_tool':'vcs','filesets':['pkg','generated','rtl'],'parameters':list(params),'toplevel':'watchdog_top','tools':{'vcs':{'vcs_options':['-full64','-sverilog','-ntb_opts','uvm-1.2','-timescale=1ns/1ps']+(['+lint=all'] if target=='lint' else [])}}}
targets['lint']={'default_tool':'spyglass','filesets':['pkg','generated','rtl'],'parameters':list(params),'toplevel':'watchdog_top','tools':{'spyglass':{'goals':['lint/lint_rtl'],'spyglass_options':['enableSV09 yes','mthresh 1048576','define SYNTHESIS']}}}
for name in ['channel','top']:
 filesets['ut_'+name]={'files':['verification/unit_test/ut_watchdog_'+name+'.sv'],'file_type':'systemVerilogSource'}
 targets['ut_'+name]={'default_tool':'vcs','filesets':['pkg','generated','rtl','ut_'+name],'toplevel':'ut_watchdog_'+name,'tools':{'vcs':{'vcs_options':['-full64','-sverilog','-ntb_opts','uvm-1.2','-timescale=1ns/1ps','-cm','line+cond+branch+fsm+tgl'],'run_options':['-no_save','-cm','line+cond+branch+fsm+tgl']}}}
params.update({n:dict(datatype='int',paramtype='vlogparam',default=d) for n,d in dict(W=32,PS=7,WS=5).items()})
targets['ut_channel']['parameters']=['W']
targets['ut_top']['parameters']=['PS','WS']
targets['sim']=targets['ut_top'];targets['smoke']=targets['ut_channel']
targets['synth']={'default_tool':'design_compiler','filesets':['pkg','generated','rtl'],'parameters':[],'toplevel':'watchdog_top','tools':{'design_compiler':{'script_dir':'$::env(WATCHDOG_IP_ROOT)/scripts/ppa','dc_script':'synth.tcl'}}}
(p/'aixsilicon_ip_watchdog.core').write_text('CAPI=2:\n'+yaml.safe_dump(dict(name='aixsilicon:ip:watchdog:1.0.0',description='Candidate parameterized watchdog',parameters=params,filesets=filesets,targets=targets),sort_keys=False))
(p/'rtl/filelist.f').write_text('\n'.join([rtl[0]]+generated+rtl[1:])+'\n')
(p/'ip-package.yaml').write_text(yaml.safe_dump(dict(name='watchdog',version='1.0.0',vlnv='aixsilicon:ip:watchdog:1.0.0',status='candidate')))
files=[p/'regs/watchdog.rdl']+[p/x for x in generated]
(p/'rtl/generated/register_manifest.json').write_text(json.dumps({str(f.relative_to(p)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files},indent=2)+'\n')
print('PACKAGE_GENERATION PASS')
