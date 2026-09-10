"""Regenerate all canonical semantic models using the owning SKILL tools."""
from pathlib import Path
import subprocess,sys
IP=Path(__file__).resolve().parents[1]
SUITE=IP.parents[4]/'aixsilicon_skill_repo/skills/ip-development-suite/skills'
steps=[
('01-lrs-author','extract_requirements.py',['--lrs-dir','docs/lrs','--output','model/requirements.yaml']),
('19-param-space-verification','extract_parameters.py',['--lrs-dir','docs/lrs','--output','model/parameter_space.yaml']),
('03-hld-architect','extract_hld.py',['--hld-dir','docs/hld','--requirements','model/requirements.yaml','--output','model']),
('05-lld-microdesign','extract_lld.py',['--lld-dir','docs/lld','--output','model/micro_design.yaml']),
('06-verification-plan','extract_verification.py',['--testplan-dir','docs/verification','--requirements','model/requirements.yaml','--output','model/verification.yaml'])]
for skill,script,args in steps:
    subprocess.run([sys.executable,str(IP/'scripts/extract_verification_compat.py') if skill=='06-verification-plan' else str(SUITE/skill/'scripts'/script),*args,'--ip-name','spi_master'],cwd=IP,check=True)
