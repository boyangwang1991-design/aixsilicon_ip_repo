#!/usr/bin/env -S uv run --locked --no-sync python
from pathlib import Path
import json,re,sys
checks=[]
for raw in sys.argv[1:]:
 p=Path(raw);text=p.read_text();name=p.stem
 if name not in ('lowpower','aon'):raise ValueError('Unexpected low-power report')
 ok=(f'tc_gpio_{name} PASS' in text and bool(re.search(r'UVM_ERROR\s*:\s*0\b',text)) and bool(re.search(r'UVM_FATAL\s*:\s*0\b',text)) and '[CHECK_COUNT]' in text)
 checks.append({'id':'LOW_POWER.'+name.upper(),'status':'pass' if ok else 'fail'})
print(json.dumps(checks))
