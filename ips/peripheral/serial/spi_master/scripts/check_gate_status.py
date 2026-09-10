"""Separate report-generation success from qualification success."""
from pathlib import Path
import yaml
IP=Path(__file__).resolve().parents[1]
data=yaml.safe_load((IP/'model/quality.yaml').read_text())
states={g['id']:g['status'] for g in data['gates']}
for name in ['G0','G1','G2','G3','G4','G5']:print(name,states.get(name,'missing'))
raise SystemExit(any(states.get(name)!='pass' for name in ['G0','G1','G2','G3','G4','G5']))
