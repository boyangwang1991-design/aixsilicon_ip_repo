"""Adapt legacy parity CBB packaging locally without modifying its RTL or source core."""
import argparse
import hashlib
import json
from pathlib import Path
import yaml

parser=argparse.ArgumentParser()
parser.add_argument('--cbb-root',required=True,type=Path)
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
asset=args.cbb_root.resolve()/'components/coding_integrity/parity_gen_check'
source=asset/'rtl/parity_gen_check.sv'
original=asset/'fusesoc/aixsilicon_cbb_parity_gen_check.core'
if not source.is_file() or not original.is_file():raise SystemExit('Missing original parity source/core')
output=root/'build/cbb_adapter';output.mkdir(parents=True,exist_ok=True)
(root/'build/FUSESOC_IGNORE').write_text('Build intermediates are not a recursive core library.\n')
core={'name':'aixsilicon:cbb:parity_gen_check:0.1.0',
      'description':'Local metadata compatibility adapter; original RTL is read-only',
      'filesets':{'rtl':{'files':[str(source)],'file_type':'systemVerilogSource'}},
      'parameters':{name:{'datatype':'int','paramtype':'vlogparam','default':value} for name,value in [('DATA_WIDTH',64),('PARITY_TYPE',0),('PC_IMPL',0)]},
      'targets':{'default':{'filesets':['rtl']}}}
target=output/'parity_gen_check.core'
target.write_text('CAPI=2:\n'+yaml.safe_dump(core,sort_keys=False))
record={'reason':'Original core lacks paramtype and has legacy provider/backend metadata; source RTL unchanged',
        'files':{str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in [original,source,target]}}
(output/'provenance.json').write_text(json.dumps(record,indent=2)+'\n')
print(target)
