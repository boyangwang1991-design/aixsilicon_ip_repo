"""Author Markdown; all canonical models remain extractor-owned."""
from pathlib import Path
import yaml
IP=Path(__file__).resolve().parents[1];out=IP/'docs/verification';out.mkdir(parents=True,exist_ok=True)
def meta(k,d):return '<!-- '+k+'_META\n'+yaml.safe_dump(d,allow_unicode=True,sort_keys=False)+'END_'+k+'_META -->\n'
reqs=yaml.safe_load((IP/'model/requirements.yaml').read_text())['requirements']
groups={'apb':(['APB','REG'],'APB 零等待、字节屏蔽、访问属性和副作用'),'modes':(['DAT','SCP'],'四模式、两位序、边界位宽及外部从机'),'commands':(['CMD','CS'],'五种命令、快照、队列和 CS 链'),'fifo_stall':(['FIFO','STALL'],'FIFO 边界、长流、资源等待'),'recovery':(['REC'],'安全中止、故障和软硬复位'),'irq':(['IRQ','ERR'],'事件、水位、屏蔽、W1C'),'extended':(['TIM','PERF'],'精确时序、最大计时值、MISO 延迟'),'random':(['DAT','TIM','CS'],'随机配置和数据'),'races':(['IRQ','REC'],'完成/W1C 同沿、复位阶段'),'delivery':(['DRV','IF','INT','PAR','PPA'],'软件、参数空间、静态集成和交付')}
(out/'verification_plan.md').write_text('# SPI Master 验证方案\n\n'+meta('VPLAN',dict(schema_version='2.0',ip_name='spi_master',delivery_model='parameterized',lrs_baseline='SPI_MASTER_V1_CONTRACT_0.1',hld_baseline='SPI_MASTER_HLD_V1',lld_baseline='SPI_MASTER_LLD_V1',verification_level='full',document_version='1.0.0',status='draft',verification_baseline='SPI_MASTER_VPLAN_V1'))+'''\n合同第 14 章是验证输入。外部从机 MISO clock-to-out 覆盖 0.2 ns 和 3 ns；内部 loopback 只作补充。100 MHz 是本次表征条件。

最小、默认、最大、非对称参数全部执行九组。随机组固定种子 1、17、101、2026，保留失败日志。wall-clock 超时 180 秒，测试内另有有界等待。

没有安装 VC Formal 时不得标记证明通过；模块 UT 覆盖精确竞争沿。最终报告分别列仿真、静态、综合证据和待集成签核项。
''')
for part,keys in [('protocol',list(groups)[:5]),('closure',list(groups)[5:])]:
    features='# 验证功能 '+part+'\n\n';tests='# 测试矩阵 '+part+'\n\n'
    for group in keys:
        prefixes,desc=groups[group];fid='FL.SPI_MASTER.'+group.upper();tid='TC.SPI_MASTER.'+group.upper()+'.001'
        refs=[r['id'] for r in reqs if r['id'].split('.')[-2] in prefixes]
        features+='## '+fid+'\n\n'+meta('FEATURE',dict(id=fid,name=group,description=desc,priority='must',req_ref=refs,proof_methods=['review','static'] if group=='delivery' else ['simulation','assertion'],applicability={'expr':'true'}))+desc+'。映射表示验证责任；是否通过取决于真实证据。\n\n'
        tests+='## '+tid+'\n\n'+meta('TESTCASE',dict(id=tid,name='tc_spi_'+group,type='static' if group=='delivery' else ('random' if group=='random' else 'directed'),priority='must',tier='smoke' if group=='apb' else 'regression',feature_ref=[fid],implementation='scripts/check_delivery.py' if group=='delivery' else f'verification/tc/tc_spi_{group}.sv',config_ref=['CFGSET.SPI_MASTER.'+x for x in ['SMALL','DEFAULT','MAX','ASYMMETRIC']],description=desc,stimulus=['执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态'],expected_result=[desc],timeout_policy='180 seconds; bounded status polling'))
    (out/f'feature_list_{part}.md').write_text(features);(out/f'test_matrix_{part}.md').write_text(tests)
body='# 参数矩阵\n\n'
for name,values in {'SMALL':[1,4,4,2],'DEFAULT':[4,32,32,4],'MAX':[8,256,256,16],'ASYMMETRIC':[3,8,16,4]}.items():
    body+=meta('CONFIG_SET',dict(id='CFGSET.SPI_MASTER.'+name,strategy='default' if name=='DEFAULT' else 'boundary',parameters=dict(zip(['NUM_CS','TX_FIFO_DEPTH','RX_FIFO_DEPTH','CMD_FIFO_DEPTH'],values)),purpose=name))+'\n'
(out/'test_matrix_configs.md').write_text(body+'合法空间以 LRS 为准；补充逐参数非法值失败测试，不穷举全部笛卡尔积。\n')
(out/'checker_plan.md').write_text('''# Reference model 与 checker

独立 oracle 将软件事务展开为线性 MOSI/MISO 位队列，通过外部引脚的 CPOL/CPHA 事件逐位比较。它不读取 DUT 移位寄存器，也不复制其 FSM。每帧 RX 与独立零扩展 expected word 比较。

时序检查比较 PCLK 计数：首沿 SETUP+1；半周期 DIV+1；帧间附加 FRAME_GAP；最后沿到 CS 释放 HOLD+1。CSR 检查每次 ACCESS 的 ready/error、读值和副作用。engine UT 用直接接口精确注入超时临界、等待原因切换、末沿中止和计数回绕。

APB master、可配置 slave、oracle 和 checker 在 verification/th/spi_tb_if.sv，UVM env 管理虚接口及测试生命周期。测试直接调用 BFM task；不伪造尚未实现的标准 VIP/sequence 架构。RAL 从 RDL 生成；实际动态测试使用显式 CSR oracle，不以 RAL 自预测替代 correctness check。
''')
body='# 断言和覆盖率\n\n'
for name,feature,prop in [('cs_onehot','commands','最多一个 CS 有效'),('zero_wait','apb','ACCESS 首周期 ready'),('known_outputs','recovery','控制输出无 X'),('tx_bound','fifo_stall','TX count 不超深度'),('rx_bound','fifo_stall','RX count 不超深度'),('cmd_bound','commands','CMD count 不超深度')]:
    body+=meta('ASSERTION',dict(id='ASSERT.SPI_MASTER.'+name.upper()+'.001',name='ap_'+name,feature_ref=['FL.SPI_MASTER.'+feature.upper()],property=prop,severity='error',verification_method='assertion'))+'\n'
for name,feature in [('serial_mode_width_order','modes'),('command_opcode_keep_stall','commands')]:
    body+=meta('COVERAGE',dict(id='COV.SPI_MASTER.'+name.upper()+'.001',name=name,type='functional',feature_ref=['FL.SPI_MASTER.'+feature.upper()]))+'\n'
(out/'coverage_plan.md').write_text(body+'四模式 × 九位宽 × 两位序共 72 个 mandatory bins 应全部触达。代码覆盖率使用 URG 原始结果，空洞逐项评审；不得临时删除逻辑制造百分比。覆盖触达和功能正确性分开报告。\n')
(out/'agent_plan.md').write_text('# Agent 复用\n\n详见 ../reuse_plan.md。sync_fifo 是实际 CBB 依赖；APB VIP 尚未达到完整交付 gate，SPI VIP 未实现，当前采用本地 BFM。模块 UT 对罕见计数边界的 force 仅存在于验证源。\n')
(out/'99_quality_gate.md').write_text('# 验收规则\n\n动态测试零错误、mandatory bins 齐全、参数边界通过、真实综合完成、静态告警评审、追踪无孤项。最终详见 ../../reports/acceptance.md。用户授权自主执行；不代填独立审查人，不把表征约束当板级冻结。\n'+meta('VPLAN_GATE',dict(gate='VP0',status='open',verification_plan_freeze=False,approvals={'architecture':'pending','rtl':'pending','verification':'pending'})))
(out/'index.md').write_text('# 验证文档索引\n\n'+'\n'.join(f'- [{p.stem}]({p.name})' for p in sorted(out.glob('*.md')) if p.name!='index.md')+'\n')
seed=IP/'reports/trace-seeds';seed.mkdir(parents=True,exist_ok=True)
(seed/'lld_to_rtl.yaml').write_text(yaml.safe_dump(dict(schema_version='2.0',ip_name='spi_master',links=[dict(source_id='LLD.MOD.SPI_MASTER.'+n,target_id='RTL.FILE.rtl/'+f) for n,f in [('CSR','spi_master_top.sv'),('CSR','generated/spi_master_csr.sv'),('ENGINE','spi_master_engine.sv'),('QUEUES','spi_master_queues.sv')]]),sort_keys=False))
