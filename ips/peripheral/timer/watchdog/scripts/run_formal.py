# VC Formal user hook executed by the FuseSoC formal target.
from pathlib import Path
import hashlib,json,os,re,signal,subprocess,sys,time
P=Path(os.environ['WATCHDOG_IP_ROOT']).resolve()
R=Path(os.environ['UV_PROJECT']).resolve()
out=P/'build/formal'/time.strftime('%Y%m%d_%H%M%S');out.mkdir(parents=True)
report=P/'reports/formal'/out.name;report.mkdir(parents=True)
vc=Path(os.environ.get('VC_STATIC_HOME','/home/eda/app/synopsys/vcs/W-2024.09-SP1/vcfca'))
qt=Path(os.environ.get('WATCHDOG_VCF_QT','/home/eda/app/synopsys/verdi/W-2024.09-SP1/platform/linux64/lib/Qt5/lib'))
files=[P/'rtl/watchdog_pkg.sv',P/'rtl/watchdog_channel.sv',P/'verification/formal/watchdog_formal_harness.sv',Path(__file__).resolve()]
def hashes():return {str(f.relative_to(P)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files}
before=hashes();tcl=out/'prove.tcl'
width=os.environ.get('WATCHDOG_FORMAL_W','32');prescale=os.environ.get('WATCHDOG_FORMAL_P','16');safety=os.environ.get('WATCHDOG_FORMAL_SAFETY','1')
if any(not re.fullmatch(r'\d+',x) for x in [width,prescale,safety]):raise SystemExit('invalid formal parameter')
tcl.write_text('''set_fml_appmode FPV
set_fml_var fml_max_time 120S
set_fml_var fml_vacuity_on true
read_file -top watchdog_formal_harness -format sverilog -sva -parameters {W=%s,P=%s,SAFETY=%s} {%s}
create_clock clk -period 10
create_reset rst_n -sense low
sim_run -stable
sim_save_reset
check_fv -block
redirect {%s} {report_fv -list -verbose}
exit
'''%(width,prescale,safety,' '.join(str(f) for f in files[:3]),report/'properties.rpt'))
env=os.environ.copy();env['VC_STATIC_HOME']=str(vc);env['LD_LIBRARY_PATH']=str(qt)+':'+env.get('LD_LIBRARY_PATH','')
cmd=[str(vc/'bin/vcf'),'-batch','-no_init','-fmode','FPV','-f',str(tcl)]
with (report/'vcf.log').open('w') as stream:
 process=subprocess.Popen(cmd,cwd=out,env=env,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True)
 try:rc=process.wait(timeout=900)
 except subprocess.TimeoutExpired:os.killpg(process.pid,signal.SIGTERM);process.wait(timeout=15);rc=124
text=(report/'vcf.log').read_text(errors='replace');props=(report/'properties.rpt').read_text(errors='replace') if (report/'properties.rpt').exists() else ''
required=['final_hold','safe_follows_final','counter_bounded','exact_timeout','paused_count']
passed=rc==0 and before==hashes() and not re.search(r'(?mi)^Error:|falsified|inconclusive|not_run',props+'\n'+text) and all(re.search(r'(?im)^.*'+name+r'.*proven|^.*proven.*'+name,props) for name in required)
record=dict(schema='watchdog-formal-run/1.0',status='pass' if passed else 'fail',command=cmd,exit_code=rc,parameters=dict(W=width,P=prescale,SAFETY=safety),inputs=before,inputs_after=hashes(),required_properties=required,artifacts={str(f.relative_to(P)):hashlib.sha256(f.read_bytes()).hexdigest() for f in [tcl,*report.glob('*.log'),*report.glob('*.rpt')]})
(report/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(dict(status=record['status'],manifest=str((report/'manifest.json').relative_to(P)))))
sys.exit(0 if passed else 1)
