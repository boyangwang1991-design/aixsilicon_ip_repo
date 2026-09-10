"""Negative evidence tests: adapter must reject stale, failed, or missing C proof."""
from pathlib import Path
import copy, hashlib, json, tempfile
from evaluate_quality_compat import IP, validate_spi_static_execution, load_evaluator
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
with tempfile.TemporaryDirectory(prefix='spi-proof-') as directory:
    root=Path(directory)
    original=json.loads((IP/'reports/quality/delivery-check.json').read_text())
    for name in original['hashes']:
        dst=root/name;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes((IP/name).read_bytes())
    rel='reports/quality/delivery-check.json';report=root/rel;report.parent.mkdir(parents=True,exist_ok=True)
    record={'executor':'static+c','log':'build/delivery/driver-1.log'}
    def check(data, expected, rec=None):
        report.write_text(json.dumps(data))
        result=validate_spi_static_execution(rec or record,root/record['log'],root,{rel:{'sha256':sha(report)}})
        assert result[0] is expected,result
    check(original,True)
    data=copy.deepcopy(original);data['checks'][0]['status']='fail';check(data,False)
    data=copy.deepcopy(original);data['executions'][0]['exit_code']=1;check(data,False)
    data=copy.deepcopy(original);del data['hashes']['sw/tests/test_driver.c'];check(data,False)
    check(original,False,dict(record,executor='vcs-uvm'))
    check(original,False,dict(record,log='build/delivery/other.log'))
    src=root/'sw/src/spi_master.c';src.write_text(src.read_text()+'\n/* stale */\n');check(original,False)
    src.write_bytes((IP/'sw/src/spi_master.c').read_bytes())
    (root/'build/delivery/driver-0.log').unlink();check(original,False)
# A plain C success cannot pass the ordinary UVM validator.
evaluator=load_evaluator()
assert not evaluator['validate_uvm_log'](IP/'build/delivery/driver-1.log')[0]
print('QUALITY_ADAPTER PASS: valid proof accepted; eight invalid/misclassified evidence cases rejected')
