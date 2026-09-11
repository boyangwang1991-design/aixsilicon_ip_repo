"""Create build-only CAPI adapters; all reusable CBB/VIP source stays owner-read-only."""
from pathlib import Path
import os,yaml,json,hashlib
p=Path(__file__).resolve().parents[1]
r=Path(os.environ.get('AIX_WORKFLOW_ROOT',Path(__file__).resolve().parents[7]))
cbb=r/'repos/aixsilicon_cbb_repo/components/arbitration_scheduling/round_robin_arbiter'
vip=r/'repos/aixsilicon_vip_repo/vip/amba/apb'
a=p/'build/dependency_adapter';a.mkdir(parents=True,exist_ok=True)
def core(path,data):path.write_text('CAPI=2:\n'+yaml.safe_dump(data,sort_keys=False))
core(a/'round_robin.core',dict(name='aixsilicon:cbb:round_robin_arbiter:0.1.0',filesets={'rtl':dict(files=[str(cbb/'rtl/round_robin_arbiter.sv')],file_type='systemVerilogSource')},targets={'default':dict(filesets=['rtl'])}))
b=a/'vip';b.mkdir(exist_ok=True)
# The owner core lists package-included classes as compilation units and omits
# include search paths. Adapt metadata only; include files are not separate units.
files=[str(vip/'src'/f) for f in ('apb_types_pkg.sv','apb_if.sv','apb_pkg.sv')]
headers=[{str(f):dict(is_include_file=True,include_path=str(vip/'src'))} for f in sorted((vip/'src').rglob('*.sv')) if str(f) not in files]
core(b/'apb.core',dict(name='aixsilicon:vip:apb:1.0.0',filesets={'rtl':dict(files=files+headers,file_type='systemVerilogSource')},targets={'default':dict(filesets=['rtl'])}))
inputs=[cbb/'rtl/round_robin_arbiter.sv',*sorted((vip/'src').rglob('*.sv'))]
record=dict(schema='watchdog-dependency-binding/1.0',reason=dict(cbb='Legacy core parameter metadata lacks CAPI2 paramtype',vip='Package include files must not be separately compiled; include root must be exported'),sources=[dict(path=str(f.relative_to(r)),sha256=hashlib.sha256(f.read_bytes()).hexdigest()) for f in inputs])
(p/'reports/full_flow/dependency_binding.json').write_text(json.dumps(record,indent=2)+'\n')
print('DEPENDENCY_ADAPTERS PASS: read-only owner sources, build-only metadata')
