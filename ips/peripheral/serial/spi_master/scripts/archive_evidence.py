"""Archive textual build evidence for a portable IP checkout; never copy tool runtimes or PDK libraries."""
from pathlib import Path
import argparse,hashlib,json,shutil
IP=Path(__file__).resolve().parents[1];archive=IP/'reports/evidence';manifest=archive/'index.json'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
parser=argparse.ArgumentParser();parser.add_argument('--restore',action='store_true');args=parser.parse_args()
if args.restore:
 records=json.loads(manifest.read_text())
 for relative,digest in records.items():
  dst=(IP/relative).resolve();src=archive/relative
  assert dst.is_relative_to(IP/'build') and src.is_file() and sha(src)==digest
  if dst.exists():assert sha(dst)==digest,('refuse overwrite',relative)
  else:dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
 print('Verified/restored',len(records),'build evidence files')
else:
 patterns=['build/sim/*/*.log','build/ut/*-*.log','build/parameter-checks/*/run.log','build/delivery/driver-*.log','build/urg-*.log',
 'build/fusesoc-smoke-final.log','build/fusesoc-lint-corrected.log','build/rtl/pdk_setup.tcl',
 'build/rtl/lint_spyglass/spyglass-1/spi_master_top/lint/lint_rtl/spyglass.log',
 'build/rtl/lint_spyglass/spyglass-1/consolidated_reports/spi_master_top_lint_lint_rtl/moresimple.rpt',
 'build/rtl/synth-*/aixsilicon_ip_spi_master_1.0.0/synth-design_compiler/outputs/*.v',
 'build/rtl/synth-*/aixsilicon_ip_spi_master_1.0.0/synth-design_compiler/src/aixsilicon_ip_spi_master_1.0.0/rtl/**/*.sv']
 files=sorted({p for pattern in patterns for p in IP.glob(pattern) if p.is_file()});records={}
 for p in files:
  relative=str(p.relative_to(IP));dst=archive/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst);records[relative]=sha(p)
 manifest.write_text(json.dumps(records,indent=2)+'\n');print('Archived',len(records),'text evidence files')
