"""Merge only compatible current UVM databases and preserve raw URG reports."""
from pathlib import Path
import argparse
import datetime
import json
import os
import re
import subprocess
import sys
from run_uvm import P, digest, inputs, run, runtime_inventory


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--regression-manifest',type=Path,required=True)
    args=parser.parse_args()
    source=args.regression_manifest.resolve()
    data=json.loads(source.read_text());before=inputs()
    if data['inputs']!=before or data.get('inputs_after')!=before:
        raise ValueError('stale/incomplete regression input binding')
    groups={};designs={}
    for job in data['jobs']:
        if job['status']!='pass' or 'manifest' not in job:continue
        item=job['manifest'];manifest=P/item['path']
        if digest(manifest)!=item['sha256']:raise ValueError('run manifest changed')
        record=json.loads(manifest.read_text())
        if record['inputs']!=before or record['inputs_after']!=before:
            raise ValueError('stale run identity')
        binary=P/record['binary']['path']
        if digest(binary)!=record['binary']['sha256']:raise ValueError('binary changed')
        if runtime_inventory(binary)!=record.get('runtime_artifacts'):raise ValueError('compiled runtime changed')
        for log in record['logs']:
            if digest(P/log['path'])!=log['sha256']:raise ValueError('run log changed')
        key=(job['config_id'],record['binary']['sha256'])
        design=Path(str(binary)+'.vdb')
        if not design.is_dir():raise ValueError('missing compilation coverage design database')
        designs[key]=design
        groups.setdefault(key,set()).add(P/record['coverage_database'])
    if not groups:raise ValueError('no successful current simulation databases')
    stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%f')
    out=P/'build/reports/coverage'/stamp;out.mkdir(parents=True)
    result=dict(schema='watchdog-coverage-execution/1.0',tool='URG W-2024.09-SP1',
                collector_sha256=digest(Path(__file__)),
                regression=dict(path=str(source.relative_to(P)),sha256=digest(source)),inputs=before,groups=[])
    for (config,binary_hash),databases in groups.items():
        databases=[designs[(config,binary_hash)],*sorted(databases)]
        dest=out/config;dest.mkdir()
        inventory={str(f.relative_to(P)):digest(f) for db in databases for f in db.rglob('*') if f.is_file()}
        cmd=['urg','-dir',*[str(x) for x in databases],'-format','both','-show','ratios',
             '-report',str(dest/'report')]
        code=run(cmd,P,dest/'urg.log',600);initial_code=code;retries=[]
        raw=(dest/'urg.log').read_text(errors='replace')
        if code!=0 and ('libsnpsmalloc' in raw or 'snpsGetCurrentProcessSize' in raw):
            retry=['env','VCS_USE_MALLOC=1',*cmd]
            code=run(retry,P,dest/'urg_malloc_retry.log',600)
            raw=(dest/'urg_malloc_retry.log').read_text(errors='replace')
            retries.append(dict(command=retry,exit_code=code,environment={'VCS_USE_MALLOC':'1'}))
        after={str(f.relative_to(P)):digest(f) for db in databases for f in db.rglob('*') if f.is_file()}
        reports=[dict(path=str(f.relative_to(P)),sha256=digest(f)) for f in dest.rglob('*') if f.is_file()]
        result['groups'].append(dict(config_id=config,binary_sha256=binary_hash,command=cmd,exit_code=initial_code,final_exit_code=code,
            databases=inventory,databases_after=after,retries=retries,reports=reports,
            status='reported' if code==0 and not re.search(r'(?m)^\s*(?:Error-|Fatal-|Error:|Fatal:)',raw)
            and inventory==after and (dest/'report/dashboard.txt').is_file() else 'fail'))
    result['inputs_after']=inputs()
    result['status']='reported' if result['inputs_after']==before and digest(Path(__file__))==result['collector_sha256'] and all(g['status']=='reported' for g in result['groups']) else 'fail'
    result['scope']='raw code/covergroup measurements; no claim that VPLAN mandatory bins or targets are closed'
    (out/'manifest.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status=result['status'],manifest=str((out/'manifest.json').relative_to(P)))))
    return 0 if result['status']=='reported' else 1


if __name__=='__main__':raise SystemExit(main())
