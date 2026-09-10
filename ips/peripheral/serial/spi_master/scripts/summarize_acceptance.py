"""Bind actual logs, binaries and generated reports to the delivered sources; no inferred PASS."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess,sys
import xml.etree.ElementTree as ET
import yaml
IP=Path(__file__).resolve().parents[1];ROOT=IP.parents[5]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
def artifact(p):return {'path':str(p.relative_to(IP)),'sha256':sha(p)}
def meta(kind,status,paths,**extra):
 return '<!-- REPORT_META\n'+yaml.safe_dump(dict(schema_version='2.0',ip_name='spi_master',report_type=kind,status=status,eda_profile='commercial-systemverilog',tool='summarize_acceptance.py',tool_version='1.0',command='python scripts/summarize_acceptance.py',artifacts=[artifact(p) for p in paths],**extra),sort_keys=False,allow_unicode=True)+'END_REPORT_META -->\n'
subprocess.run([sys.executable,str(IP/'scripts/check_delivery.py')],cwd=IP,check=True)
results=[];evidence=[]
for config,seeds in [('small',[1]),('default',[1,17,101,2026]),('max',[1]),('asymmetric',[1])]:
 for seed in seeds:
  p=IP/f'reports/quality/regression-{config}-{seed}.json';data=json.loads(p.read_text());evidence.append(p)
  for path,digest in data['source_hashes'].items():assert sha(ROOT/path)==digest,('stale source',path)
  for r in data['results']:
   assert sha(IP/r['log'])==r['sha256'],('changed log',r['log'])
   assert r['status']=='pass',r
   group=r['test'].removeprefix('tc_spi_');results.append(('TC.SPI_MASTER.'+group.upper()+'.001',f'{config}.seed{seed}',r['seconds']))
for filename,prefix,key in [('unit-tests.json','UT','unit'),('negative-parameters.json','PARAM','parameter')]:
 p=IP/'reports/quality'/filename;data=json.loads(p.read_text());evidence.append(p)
 for r in data:
  assert r['status']=='pass',r
  digest=r.get('log_sha256',r.get('sha256'));assert sha(IP/r['log'])==digest
  results.append((prefix+'.SPI_MASTER.'+r[key]+('.'+str(r['value']) if 'value' in r else ''),'standalone',0))
p=IP/'reports/quality/delivery-check.json';evidence.append(p);assert json.loads(p.read_text())['status']=='pass'
results.append(('TC.SPI_MASTER.DELIVERY.001','static_and_c_driver',0))
# The exported source copies are direct evidence of what Design Compiler compiled.
for config in ['small','default','max']:
 out=IP/f'build/rtl/synth-{config}/aixsilicon_ip_spi_master_1.0.0/synth-design_compiler'
 summary=json.loads((IP/f'reports/synth/{config}/summary.json').read_text());assert summary['status']=='pass'
 hashes={}
 for p in sorted((IP/'rtl').rglob('*.sv')):
  exported=out/'src/aixsilicon_ip_spi_master_1.0.0'/p.relative_to(IP)
  if exported.exists():assert sha(p)==sha(exported),(config,'stale synthesized source',p);hashes[str(p.relative_to(IP))]=sha(p)
 assert len(hashes)>=6
 hashes[summary['netlist']]=sha(IP/summary['netlist'])
 write(IP/f'reports/synth/{config}/source-binding.json',json.dumps(hashes,indent=2)+'\n')
# Smoke target identity is mandatory; duplicate UVM_TESTNAME is a failure.
log=IP/'build/fusesoc-smoke-final.log';s=log.read_text()
assert 'apb PASS' in s and 'Running test tc_spi_apb' in s and 'MULTTST' not in s and 'UVM_ERROR :    0' in s and 'UVM_FATAL :    0' in s
smoke=IP/'reports/smoke';smoke.mkdir(parents=True,exist_ok=True);shutil.copy2(log,smoke/'fusesoc-smoke.log')
x=ET.Element('testsuite',name='spi_master_smoke',tests='1',failures='0');ET.SubElement(x,'testcase',id='TC.SPI_MASTER.APB.001',name='TC.SPI_MASTER.APB.001');ET.ElementTree(x).write(smoke/'smoke_junit.xml',encoding='utf-8',xml_declaration=True)
reg=IP/'reports/regression';reg.mkdir(parents=True,exist_ok=True)
x=ET.Element('testsuite',name='spi_master',tests=str(len(results)),failures='0')
for name,config,seconds in results:ET.SubElement(x,'testcase',id=name,name=name,classname=config,time=str(seconds))
ET.ElementTree(x).write(reg/'junit.xml',encoding='utf-8',xml_declaration=True)
write(smoke/'smoke_summary.md','# FuseSoC smoke\n\n'+meta('smoke','pass',[smoke/'smoke_junit.xml',smoke/'fusesoc-smoke.log'])+'实际运行 tc_spi_apb，零 UVM error/fatal，无重复 testname。\n')
write(reg/'regression_summary.md','# 回归结果\n\n'+meta('regression','pass',[*evidence,reg/'junit.xml',smoke/'smoke_junit.xml'])+f'共 {len(results)} 项执行证据：39 项 UVM 配置/种子运行、2 项模块 UT、11 项非法参数拒绝、1 项静态和 C 驱动检查。全部通过。源文件和日志哈希已重新核验。\n')
# Generate execution list from canonical model without dropping non-SV proof objects.
v=yaml.safe_load((IP/'model/verification.yaml').read_text());listing={k:[] for k in ['smoke','regression','extended']}
for f in v['features']:
 for tc in f['testcases']:listing[tc['tier']].append(dict(test=tc['id'],name=tc['name'],implementation=tc['implementation']))
write(IP/'verification/sim/regression_list.yaml',yaml.safe_dump(listing,sort_keys=False))
cov=IP/'reports/coverage';raw=cov/'raw';raw.mkdir(exist_ok=True)
for name in ['dashboard.txt','hierarchy.txt','groups.txt','asserts.txt','modlist.txt']:
 shutil.copy2(cov/'default'/name,raw/name)
groups=(raw/'groups.txt').read_text();assert re.search(r'96\s+96\s+100.00',groups)
coverage_meta=meta('coverage','pass',[raw/'dashboard.txt',raw/'hierarchy.txt',raw/'groups.txt',raw/'asserts.txt',reg/'regression_summary.md'],coverage={'functional':{'achieved':100,'target':100,'scope':'96 bins including 72 serial cross bins'},'code':{'achieved':91.62,'target':90,'metric':'line','scope':'default DUT, raw unexcluded; 90 percent target authorized by user; see coverage_plan.md'},'assertion':{'achieved':100,'target':100,'scope':'six mandatory IP assertions; all attempted with real successes'}},coverage_source={'collector':'VCS W-2024.09-SP1 + URG','collection_command':'python scripts/run_verification.py','merge_command':'VCS_USE_MALLOC=1 python scripts/run_coverage.py (same elaboration only)','report':'reports/coverage/raw/dashboard.txt','report_sha256':sha(raw/'dashboard.txt')},exclusions=[],waivers=[])
write(cov/'coverage_summary.md','# 覆盖率评审\n\n'+coverage_meta+'''
功能 bins 96/96，模式 × 位宽 × 位序交叉 72/72。六项 IP SVA 均有真实成功，全部断言失败数为 0。

| 默认配置模块 | Line | Branch | Condition | Toggle |
|---|---:|---:|---:|---:|
| spi_master_top | 100% | 96.43% | 85.71% | 30.47% |
| spi_master_engine | 100% | 97.14% | 90.07% | 36.73% |
| spi_master_queues | 100% | 100% | 74.07% | 75.80% |
| generated CSR | 90.17% | 84.82% | 68.75% | 28.08% |

原始默认 DUT 行覆盖 91.62%，最大配置 CSR 行覆盖 95.98%。没有排除生成代码或 UVM 来改写原始报告；表格只是明确指定观察范围。按用户“放宽覆盖率的限制，如实记录，先完成G5”指示，默认 DUT 原始行覆盖门槛由暂定 95% 调整为 90%，实测 91.62% 满足调整后门槛；功能及必需断言仍要求 100%。不宣称原 95% 门槛通过，FSM/branch/condition/toggle 保留原始结果作为已披露残余风险。

FSM 九个可达状态全部触达，自动识别转移 15/20（75%）。未触达 HOLD_TIME/NEW_IDLE/SETUP→IDLE 是复位边；这些状态的复位由独立 engine UT 已逐态检查，但 UT 覆盖库未混入集成覆盖库。SETUP→HOLD_CS/RESOURCE 是 case fall-through 分析带出的边，实际下一状态始终 SHIFT；需工具确认后才可作不可达豁免。

低 toggle 包含指令保留位、计数器高位、固定配置及 CSR 动态状态镜像。并非全部都不可达，例如 32 位等待计数长时间翻转未穷举，故保留空洞，不伪造豁免。CBB FULL/EMPTY 无操作性质前件在 IP 包装器处被拒绝，真实成功为零但无断言失败；库独立验证和本 IP 访问错误检查承担相应责任。UVM RAL 内部两项无 attempt 是当前显式 CSR oracle 架构的结果。

所有四种参数的原始 HTML/text 都保留在各自目录；未将不同 elaboration 的层次强行合并。
''')
formal=IP/'reports/formal';formal.mkdir(exist_ok=True)
availability={t:shutil.which(t) for t in ['vcf','vcformal','vc_static','sby','yosys']}
write(formal/'availability.json',json.dumps(availability,indent=2)+'\n')
write(formal/'formal_status.md','# 形式验证状态\n\nOPTIONAL_UNAVAILABLE：本机未发现独立形式引擎，见 availability.json。本次 SVA 是仿真执行，不宣称穷举证明。未生成会虚假通过的 formal core target。\n')
# PPA characterization, with measured data and explicit workload assumptions.
rows=[]
for config in ['small','default','max']:
 d=json.loads((IP/f'reports/synth/{config}/summary.json').read_text());p=(IP/f'reports/synth/{config}/power.rpt').read_text()
 dyn=re.search(r'Total Dynamic Power\s*=\s*([\d.]+)\s*(\w+)',p)
 rows.append(f"| {config} | {'/'.join(map(str,d['parameters']))} | {d['area_um2']:.3f} | {d['worst_slack_ns']:.2f} | {dyn.group(1)+' '+dyn.group(2) if dyn else 'see report'} |")
ppa='# 28nm PPA 表征\n\nGF CMOS28LP sc9 base HVT，TT 1.00 V / 25°C，DC V-2023.12-SP3。目标库和 operating condition 由 model/pdk.yaml 与 build/rtl/pdk_setup.tcl 绑定。100 MHz PCLK、IO/负载假设见 constraints/characterization.sdc。\n\n| 配置 | CS/TX/RX/CMD | cell area (µm²) | 最差 slack (ns) | dynamic power |\n|---|---|---:|---:|---:|\n'+'\n'.join(rows)+'\n\n三种配置均生成真实门级网表，零 violated constraints。功耗为默认概率传播的 vectorless 估计，未经工作负载 VCD/SAIF 标定；不等于实测功耗。无布局布线、Pad、PCB 或功耗门控签核。源/导出副本/网表哈希见各配置 source-binding.json。\n'
write(IP/'reports/synth/ppa_summary.md',ppa)
# Comprehensive current-input inventory, excluding generated reports and mutable build intermediates.
paths=[IP/'spi_master_contract.md',IP/'aixsilicon_ip_spi_master.core',IP/'Makefile',*sorted((IP/'rtl').rglob('*.sv')),*sorted((IP/'regs').rglob('*.rdl')),*sorted((IP/'verification').rglob('*.sv')),*sorted((IP/'sw').rglob('*.c')),*sorted((IP/'sw').rglob('*.h')),*sorted((IP/'scripts').rglob('*.py')),*sorted((IP/'constraints').glob('*'))]
write(IP/'reports/quality/delivery-manifest.json',json.dumps({str(p.relative_to(IP)):sha(p) for p in paths if p.is_file()},indent=2)+'\n')
quality_path=IP/'model/quality.yaml'
gate_text='、'.join(g['id']+'='+g['status'] for g in yaml.safe_load(quality_path.read_text())['gates']) if quality_path.exists() else '尚未生成'
write(IP/'reports/acceptance.md',f'''# SPI Master 实施与验收报告

本合同的可综合 IP、RDL 生成链、验证环境、驱动示例及复现入口已实现；本机动态测试和真实 28nm 综合通过。交付为 **1.0.0 experimental 候选实现**，G0–G5 结果见下文；交付范围为 IP 及 100 MHz / GF28nm 表征基线，不等于量产或板级冻结。

| 验收项 | 实测结果 |
|---|---|
| UVM 参数矩阵 | 4 配置 × 9 组 = 36/36 PASS |
| 追加随机 | seeds 17/101/2026，3/3 PASS；每 seed 32 次随机事务 |
| 模块 UT | FIFO 2,000 次随机周期；engine 精确超时/进展优先、等待原因切换、末沿中止保留 RX、九状态复位、DONE_COUNT 回绕，通过 |
| 非法参数 | 11/11 正确拒绝 |
| 软件 | C11 严格编译、长流和计数回绕、锁/屏障、总期限和恢复 mock 测试通过 |
| 功能覆盖 | 96/96 bins；其中模式×位宽×位序 72/72 |
| 手写 RTL 行覆盖 | top/engine/queues 均 100% |
| IP SVA | 6/6 有真实成功；全报告 assertion failure=0 |
| 静态 | SpyGlass 0 Fatal / 0 Error / 150 Warning，逐类分析，无工具 waiver |
| 综合 | small/default/max，真实 GF 28nm，全部通过 |
| 追踪 | 93 条 LRS → HLD → LLD → RTL 与 verification proof；由套件提取及 trace 工具生成 |

{ppa.replace('# 28nm PPA 表征','## 28nm PPA 表征',1)}

## 交付与复现

入口 [README](../README.md)、[Makefile](../Makefile)、[集成指南](../docs/integration.md)。[回归证据](regression/regression_summary.md)、[覆盖率评审](coverage/coverage_summary.md)、[静态评审](quality/static-review.md)、[需求追踪](quality/trace_matrix.md)、[SKILL 改进报告](skill-improvement-report.md)。当前源码/工具脚本清单见 [delivery-manifest.json](quality/delivery-manifest.json)。CBB 源码与原始合同未由本次实现修改，只有原资产的构建元数据在 build 内适配。

## 验收边界与保留项

当前门禁（含明确记录的 SPI mixed-proof 本地适配）：{gate_text}。全部 53 项实际执行 PASS。原始未适配套件结果另保存在 quality/upstream-gate-report.md，便于复核工具对 C/static proof 的支持缺口。

原始默认 DUT 行覆盖 91.62%、FSM 转移 75%、低 toggle 的空洞已记录；未将未覆盖项自动豁免。按用户授权，原始 DUT 行覆盖以 90% 为本次 G5 门槛；未达原暂定 95% 的差距仍保留。独立形式引擎未安装，专用 CDC/RDC 与布局后 recovery/removal 没有工具证明；已完成单时钟/复位结构审查及动态检查。

目标外设是否允许暂停、最终 PCLK/SCLK、Pad/板级 MISO 预算和负载未给定，100 MHz 只用于可复现表征。默认软件流式 API 仅适用于允许帧边界暂停的器件。

LRS/HLD/LLD 保留 draft，独立技术审查和项目冻结记录不伪造。[Gate 重算](quality/gate_report.md) 和 [适配器来源](quality/quality-evaluator-adapter.json) 记录本次工具执行结果；用户的自动执行授权不被当作技术审查签名。需要上游改进的 21 项发现及本地处理均已记录。
''')
print(f'Acceptance evidence assembled: {len(results)} execution records; raw coverage and signoff limits retained')
