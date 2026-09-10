"""Adapt legacy asset metadata in build/, referencing unchanged asset sources."""
from pathlib import Path
import hashlib
import json
import yaml
IP=Path(__file__).resolve().parents[1]
ROOT=IP.parents[5]
source=ROOT/'repos/aixsilicon_cbb_repo/components/fifo_queue_buffer/sync_fifo/fusesoc/aixsilicon_cbb_sync_fifo.core'
data=yaml.safe_load(source.read_text())
data.pop('provider',None)
for p in data.get('parameters',{}).values(): p.setdefault('paramtype','vlogparam')
data['targets']={'default':data['targets']['default']}
data['filesets']={'rtl_src':data['filesets']['rtl_src']}
data['filesets']['rtl_src']['files']=[str((source.parent/f).resolve()) for f in data['filesets']['rtl_src']['files']]
out=IP/'build/dependencies';out.mkdir(parents=True,exist_ok=True)
(out/'sync_fifo.core').write_text(yaml.safe_dump(data,sort_keys=False))
(IP/'reports/quality/dependency-adapter.json').write_text(json.dumps({
    'original_core':str(source),'original_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
    'adapter':'build/dependencies/sync_fifo.core','changes':['declare vlogparam', 'drop unused provider metadata','resolve source paths'],
    'rtl_modified':False},indent=2)+'\n')
print(out)
