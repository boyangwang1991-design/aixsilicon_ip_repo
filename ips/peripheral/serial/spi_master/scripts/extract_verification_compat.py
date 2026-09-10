"""Local adapter for the suite's SV-only testcase path rule.
Accept exactly the implemented static delivery check in addition to normal SV tests.
Never edit the shared skill or generated model. All other validation remains upstream.
"""
from pathlib import Path
import hashlib,json,sys
IP=Path(__file__).resolve().parents[1]
source=IP.parents[4]/'aixsilicon_skill_repo/skills/ip-development-suite/skills/06-verification-plan/scripts/extract_verification.py'
text=source.read_text()
old='''or implementation.suffix != ".sv"
            or implementation.parts[:2] != ("verification", "tc")'''
new='''or not (
                (implementation.suffix == ".sv" and implementation.parts[:2] == ("verification", "tc"))
                or (testcase.get("type") == "static" and implementation.as_posix() == "scripts/check_delivery.py"
                    and implementation.is_file())
            )'''
assert text.count(old)==1,'Upstream changed; adapter must be reviewed'
text=text.replace(old,new)
(IP/'reports/quality/verification-extractor-adapter.json').write_text(json.dumps({'upstream':str(source),'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'change':'allow exactly type=static scripts/check_delivery.py, require real file; retain all other guards'},indent=2)+'\n')
exec(compile(text,str(source),'exec'),{'__name__':'__main__','__file__':str(source)})
