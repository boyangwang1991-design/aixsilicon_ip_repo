"""Local adapter for SK-011: consume scanner's exact in-memory view, not public JSON."""
from pathlib import Path
import sys
import importlib.util
import hashlib
import yaml
IP=Path(__file__).resolve().parents[1]
ROOT=IP.parents[5]
skills=ROOT/'repos/aixsilicon_skill_repo/skills'
sys.path.insert(0,str(skills/'cbb-development-suite/scripts'))
from impl import pdk
source=skills/'ip-development-suite/skills/09-rtl-check/scripts/ip_pdk_scan.py'
spec=importlib.util.spec_from_file_location('ip_scanner',source)
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
root=Path('/home/eda/pdk')
snapshot={'schema':pdk.SCHEMA_VERSION,'pdk_root':str(root),
          'nodes':[pdk._scan_node(root/'CMOS28NM')],'eda_tools':pdk._probe_tools()}
data=module.bind_snapshot(snapshot,'spi_master','28','sc9_cmos28lp_base_hvt','tt_nominal_max_1p00v_25c')
data['provenance'].update(adapter='scripts/scan_pdk.py',adapter_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                           upstream_scanner_sha256=hashlib.sha256(source.read_bytes()).hexdigest())
(IP/'model/pdk.yaml').write_text(yaml.safe_dump(data,sort_keys=False))
print(data['status'],data['library'],data['corner'])
if data['status']!='PDK_READY':raise SystemExit(1)
