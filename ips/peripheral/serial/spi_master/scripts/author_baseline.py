"""One-time baseline authoring from the supplied contract; never edits canonical YAML.

Run from workflow root with uv run --extra ip-dev python <this file>.
Refuses to overwrite authored documents. Owning suite extractors run after each volume.
"""
from pathlib import Path
import re
import subprocess
import sys
import yaml

IP = Path(__file__).resolve().parents[1]
ROOT = IP.parents[5]
SUITE = ROOT / 'repos/aixsilicon_skill_repo/skills/ip-development-suite'

def meta(kind, **data):
    return '<!-- ' + kind + '_META\n' + yaml.safe_dump(data, allow_unicode=True, sort_keys=False, width=100) + 'END_' + kind + '_META -->\n'

def extract(stage):
    defs = {'lrs': ('01-lrs-author', 'extract_requirements', 'requirements.yaml'),
            'hld': ('03-hld-architect', 'extract_hld', ''),
            'lld': ('05-lld-microdesign', 'extract_lld', 'micro_design.yaml')}
    owner, script, out = defs[stage]
    args = [sys.executable, str(SUITE / f'skills/{owner}/scripts/{script}.py'),
            f'--{stage}-dir', str(IP / 'docs' / stage), '--output', str(IP / 'model' / out), '--ip-name', 'spi_master']
    if stage == 'hld':
        args += ['--requirements', str(IP / 'model/requirements.yaml')]
    result = subprocess.run(args, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stdout + result.stderr)

def write(stage, name, content):
    path = IP / 'docs' / stage / name
    if path.exists():
        raise RuntimeError(f'Refusing overwrite: {path}')
    path.write_text(content)
    if stage in {'lrs', 'hld', 'lld'}:
        extract(stage)

contract = (IP / 'spi_master_contract.md').read_text()
sources = {}
for m in re.finditer(r'^([A-Z]+-\d{3})：(.+?)(?=\n\n|\Z)', contract, re.M | re.S):
    sources[m[1]] = m[2]
for line in contract.splitlines():
    m = re.match(r'\| ((?:SCP|PAR|APB)-\d{3}) \| (.*)\|$', line)
    if m:
        sources[m[1]] = m[2].replace('|', '；').strip('； ')
category = {'PAR':'CFG', 'SCP':'FUNC', 'IF':'INTF', 'APB':'INTF', 'DAT':'FUNC', 'TIM':'PERF',
            'CMD':'FUNC', 'CS':'FUNC', 'FIFO':'FUNC', 'STALL':'FUNC', 'REC':'RESET', 'REG':'REG',
            'IRQ':'REG', 'ERR':'REG', 'DRV':'CONS', 'PERF':'PERF', 'PPA':'LP', 'INT':'CONS'}
reqs = {key: f'LRS.{category[key.split("-")[0]]}.SPI_MASTER.{key.replace("-", ".")}'
        for key in sources if key.split('-')[0] in category}
write('lrs', '00_overview.md', '# SPI Master 需求基线\n\n原始产品合同：[spi_master_contract.md](../../spi_master_contract.md)。'
      '本基线保留原 ID 的 source_ref；架构提示 ARCH 不作为外部行为需求。'
      '正式数值/软件 ABI 以合同第 9 章与 SystemRDL 为准。\n\n' +
      meta('LRS_DOC', schema_version='2.0', ip_name='spi_master', delivery_model='parameterized',
           register_model='required', ppa_signoff='required', document_version='1.0.0', status='draft',
           requirement_baseline='SPI_MASTER_V1_CONTRACT_0.1') +
      meta('LRS_GATE', gate='G0', status='open', requirement_freeze=False, approvals={}) +
      '\n安全 SAFE：N/A，无功能安全诊断。SEC：无权限过滤，由 SoC 保护。DFX：内部回环。'
      'GEN：N/A，无拓扑生成器。物理 PCLK/Pad/IO 预算未指定，不承诺实际最大频率。\n')
for prefix in category:
    keys = [k for k in reqs if k.startswith(prefix + '-')]
    if not keys:
        continue
    # <= 10 objects per semantic volume; numeric source IDs remain unchanged.
    for start in range(0, len(keys), 10):
        body = f'# {prefix} 需求\n\n'
        for key in keys[start:start+10]:
            desc = sources[key]
            if prefix == 'REG':
                desc = f'提供合同 {key} 定义的软件可见能力和访问限制；字段结构在 SystemRDL 固化。'
            body += '\n### ' + reqs[key] + '\n\n' + meta('LRS', id=reqs[key], category=category[prefix],
                feature=key, priority='P0', status='active', source_ref=[f'spi_master_contract.md#{key}'],
                applicability={'expr':'true'}, verification_method=['simulation', 'review'])
            body += '\n#### Requirement\n\n' + desc + '\n\n#### Acceptance Criteria\n\n'
            body += f'- 对照原合同 {key} 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。\n'
        write('lrs', f'10_{prefix.lower()}_{start//10}.md', body)
body = '# 静态参数合同\n\n| Parameter | Kind | Type | Default | Legal Values | 对应需求 ID |\n|---|---|---|---|---|---|\n'
for n, d, dom, ref in [('NUM_CS',4,'1..8','PAR-001'), ('TX_FIFO_DEPTH',32,'[4, 8, 16, 32, 64, 128, 256]','PAR-002'),
                     ('RX_FIFO_DEPTH',32,'[4, 8, 16, 32, 64, 128, 256]','PAR-003'), ('CMD_FIFO_DEPTH',4,'[2, 4, 8, 16]','PAR-004')]:
    body += f'| {n} | elaboration | int | {d} | {dom} | {reqs[ref]} |\n'
for name, values in [('SMALL',[1,4,4,2]), ('DEFAULT',[4,32,32,4]), ('MAX',[8,256,256,16]), ('ASYMMETRIC',[3,8,16,4])]:
    body += '\n' + meta('CONFIG', id='CFG_'+name, purpose=name, values=dict(zip(['NUM_CS','TX_FIFO_DEPTH','RX_FIFO_DEPTH','CMD_FIFO_DEPTH'], values)))
write('lrs', '01_configuration.md', body)
subprocess.run([sys.executable,str(SUITE/'skills/19-param-space-verification/scripts/extract_parameters.py'),
                '--lrs-dir',str(IP/'docs/lrs'),'--output',str(IP/'model/parameter_space.yaml'),'--ip-name','spi_master'],check=True)
write('hld','00_overview.md','# SPI Master 架构\n\n单 PCLK，独立 APB 控制面与 SPI 执行面。命令队列实现提交/完成分离；'
      '数据队列支持流式搬运。参数仅改变 CS 数及三类队列深度，CSR 地址不变。\n\n'+
      meta('HLD_DOC', schema_version='2.0',ip_name='spi_master', delivery_model='parameterized',status='draft',
           lrs_baseline='SPI_MASTER_V1_CONTRACT_0.1',architecture_baseline='SPI_MASTER_HLD_V1')+
      meta('HLD_GATE',gate='G1',status='open',architecture_freeze=False,approvals={}))
mods = {'CSR': ('APB 零等待访问检查、SystemRDL 配置/状态/中断、命令原子提交', ['APB','REG','IRQ','ERR','DRV','IF']),
        'ENGINE': ('片选/段/帧执行、时序调度、资源预留、超时、安全终止', ['SCP','DAT','TIM','CMD','CS','STALL','REC','PERF','INT']),
        'QUEUES': ('同步 TX/RX/命令队列及清除胶水；复用 sync_fifo', ['FIFO','PAR','PPA'])}
for i,(name,(responsibility,prefixes)) in enumerate(mods.items()):
    refs=[v for k,v in reqs.items() if k.split('-')[0] in prefixes]
    write('hld',f'01_{name.lower()}.md',f'# {name}\n\n{responsibility}。\n\n'+meta('HLD_MODULE',id='HLD.MOD.SPI_MASTER.'+name,
          name=name,responsibility=responsibility,req_ref=refs,applicability={'expr':'true'}))
ports = [('pclk','input',1),('preset_n','input',1),('psel','input',1),('penable','input',1),('pwrite','input',1),
         ('paddr','input',12),('pwdata','input',32),('pstrb','input',4),('pprot','input',3),('prdata','output',32),
         ('pready','output',1),('pslverr','output',1),('spi_sclk_o','output',1),('spi_mosi_o','output',1),
         ('spi_miso_i','input',1),('spi_cs_n_o','output','NUM_CS'),('irq_o','output',1)]
body='# 接口与数据流\n\nAPB 请求完成后才改变配置或队列；响应不等待串行状态。SPI 接口为专用推挽。\n\n'
for name,proto,selected in [('APB','APB4',ports[:12]),('SPI','SPI',ports[12:16]),('IRQ','event',ports[16:])]:
    body+=meta('HLD_INTERFACE',id='HLD.IF.EXT.SPI_MASTER.'+name,name=name,scope='external',protocol=proto,role='slave' if name=='APB' else 'master',
               owner_module='HLD.MOD.SPI_MASTER.CSR' if name!='SPI' else 'HLD.MOD.SPI_MASTER.ENGINE',
               signals=[dict(name=n,direction=d,width=w,clock='pclk',reset='preset_n') for n,d,w in selected],req_ref=[reqs['IF-002']])
body+=meta('HLD_INTERFACE',id='HLD.IF.INT.SPI_MASTER.QUEUE',name='QUEUE',scope='internal',protocol='fifo_push_pop',
    owner_module='HLD.MOD.SPI_MASTER.QUEUES', signals=[{'name':'push','width':1},{'name':'pop','width':1},{'name':'data','width':'32 or 64'}, {'name':'count','width':'clog2(DEPTH+1)'}],req_ref=[reqs['FIFO-003']])
body+='\n配置分 CONTROL/CONFIG/STATUS/IRQ/ERROR/COMMAND。CS 配置与等待阈值仅 disabled 可写；'
body+='命令 shadow 可写，PUSH 原子提交；sticky 使用硬件置位优先的 W1C。RX 仅完整帧提交，队列和执行进度独立。\n'
write('hld','03_interface.md',body)
body='# 域、预算与集成约束\n\n内部不存在 CDC，MISO 是源同步返回时序路径，不加两级同步器、不置 false path。'
body+='外部 IO/PDK 目标待集成；综合表征使用明确的实验约束，不等于产品频率保证。功能安全与 DFT 插入不在本版范围。\n\n'
for typ,name,source in [('clk','pclk','SoC'),('rst','preset_n','SoC asynchronous assert / synchronous release'),('pwr','always_on','SoC supply')]:
    body+=meta('HLD_DOMAIN',id=f'HLD.DOM.SPI_MASTER.{name.upper()}',type=typ,name=name,source=source,modules=['HLD.MOD.SPI_MASTER.'+n for n in mods])
body+=meta('HLD_PERF',id='HLD.PERF.SPI_MASTER.CONTINUOUS',metric='SCLK half period',target='CLKDIV+1 PCLK; no intra-segment bubble when FRAME_GAP=0 and resources available',allocated_to=['HLD.MOD.SPI_MASTER.ENGINE'])
write('hld','04_clock_power.md',body)
write('lld','00_doc_control.md','# SPI Master 微架构\n\n所有周期决策由此分册及模块分册定义。\n\n'+meta('LLD_DOC',schema_version='2.0',ip_name='spi_master',delivery_model='parameterized',status='draft',
       lrs_baseline='SPI_MASTER_V1_CONTRACT_0.1',hld_baseline='SPI_MASTER_HLD_V1',microarchitecture_baseline='SPI_MASTER_LLD_V1')+
       meta('LLD_GATE',gate='G2',status='open',microarchitecture_freeze=False,approvals={}))
details={
'CSR': '''使用 PeakRDL passthrough CPU 接口，由组合 APB 包装器只在 ACCESS 送请求，避免标准 APB exporter 的流水等待。
地址常量和访问属性由 RDL 节点生成，包装器仅执行运行期错误/字节合并合法性检查，不保存第二套 CSR。
全部失败写和零 strobe 写均禁止 CSR 请求与命令/FIFO 副作用；读错误返回零。
普通 RW 的 byte merge 后判断合法性；CTRL 同值写允许，变化受 busy/fault 限制。
WO 副作用用请求译码 + 当前 pwdata，不能以延迟一个周期的 CSR 存储值提交。
W1C 每个事件/错误位独立 hwset，新事件优先。软复位清全部 CSR 与执行状态。
每个 CS 的寄存器物化为八个槽；NUM_CS 限制 wrapper 访问且未用配置不会到达执行引脚。
''',
'ENGINE': '''状态编码 IDLE=0, FETCH=1, RESOURCE=2, NEW_IDLE=3, SETUP=4, SHIFT=5, GAP=6, HOLD_CS=7, HOLD_TIME=8, IDLE_TIME=9。
每个活动 descriptor 缓存 cfg/len/tag；配置仅 disabled 可改，可直接选择稳定的 CS 配置。
RESOURCE 在首次资源完整时原子取 TX 并预留 RX；CS 尚未激活时先更新 CPOL、等待新 idle、断言 CS、执行 setup。
从 CS 断言沿到第一 leading 沿精确 SETUP+1。每次边沿用倒数器，重装 CLKDIV，零代表下一沿执行。
SHIFT 的 edge_idx 从 0 到 2*FRAME_BITS-1，偶数 leading、奇数 trailing。
CPHA0 在准备帧时建立首位，leading 采样，非末 trailing 推出下一位；CPHA1 leading 推位，trailing 采样。
接收寄存器按数值 bit index 放置采样，帧开始清零；末 trailing 提交含当沿采样的完整结果。
仅一个活动 RX 预留槽；开始下一帧时容量判断包含本沿要提交的当前帧，但不乐观依赖同沿 APB pop。
下一帧 TX 使用组合 FIFO 头及边沿前 occupancy，末 trailing 原子取下一 entry，并同步建立 CPHA0 首位。
可用资源在前一周期已就绪时无需额外预取存储；H=1 时亦连续。FRAME_GAP 加在 H 上，DUMMY 不加 gap。
资源不足仅帧边界停顿，ALLOW_STALL=0 同沿记录资源错误；ALLOW_STALL=1 进入 RESOURCE。
DUMMY 将 frame bits 等效为 1，MOSI 常值，不碰数据 FIFO；progress 按完整周期计数。
KEEP_CS 段末 trailing 提交 RX 并完成段；否则装载 HOLD，释放 CS 时完成段/事务，然后等待旧 IDLE。
HOLD_CS 无命令时 WAIT_CMD；取到错误 CS 的 descriptor 后安全终止。RELEASE 无 CS 时只完成段。
无进展等待计数饱和，原因改变不重置；资源进展优先于同沿阈值，setup/shift/gap/hold/idle 不计时。
ABORT 在完成沿前组合加入 stop 条件，禁止同沿开始新帧/命令，完整当前帧后按 hold/idle 收尾。
ABORT 在非 SHIFT 状态不等资源；已在 HOLD/IDLE 倒计时不得重新开始，保证终止上界。
终止清 TX/CMD、保留完整 RX，置 fault；软件 ABORT 额外置 ABORT_DONE。正常完成被 stop 抑制。
busy 为状态非 IDLE、命令非空或 aborting；活动 valid 与 CS active 独立。非法状态安全进入终止路径。
''',
'QUEUES': '''复用 aixsilicon:cbb:sync_fifo:0.1.0，IMPL=0、OUTPUT_REG=0，DATA_W 为 32/32/64。
队列数据不全量复位；指针/count 复位。原资产无同步 clear 输入，采用受 PCLK 低相更新的清除请求复位胶水；
只在已接受清除/终止后执行，清除覆盖窗口内禁止 push/pop。软件 clear 的 APB 完成后、下一传输前清除完毕。
所有 APB 满写/空读按沿前状态拒绝，三个 count 不包含活动 descriptor/shift entry。
RX 只有执行引擎写入；单活动帧开始时检查可用槽，无第二写者，故不会覆盖或溢出。
'''}
for name in mods:
    mid='LLD.MOD.SPI_MASTER.'+name
    body='# '+name+' 微架构\n\n'+details[name]+'\n'+meta('LLD_MODULE',id=mid,name=name,hld_ref=['HLD.MOD.SPI_MASTER.'+name],responsibility=mods[name][0])
    body+=meta('LLD_DATAPATH',id='LLD.DP.SPI_MASTER.'+name,module_ref=mid,width=32,latency='APB zero wait; SPI counted edges',description=details[name])
    if name=='ENGINE':
        body+=meta('LLD_FSM',id='LLD.FSM.SPI_MASTER.ENGINE',module_ref=mid,reset_state='IDLE',encoding='explicit binary',
            states=['IDLE','FETCH','RESOURCE','NEW_IDLE','SETUP','SHIFT','GAP','HOLD_CS','HOLD_TIME','IDLE_TIME'],
            illegal_state='safe stop; release CS, fault',transitions=details[name])
    body+=meta('LLD_RESET',id='LLD.RST.SPI_MASTER.'+name,reset_domain='preset_n',type='asynchronous assert, synchronous release by integration',module_ref=mid,reset_values='contract REC-007; FIFO RAM untouched')
    write('lld','03_'+name.lower()+'.md',body)
write('lld','07_delivery_mapping.md','# RTL 交付映射\n\n'+''.join(meta('RTL_MAP',id='RTL.MAP.SPI_MASTER.'+n,rtl_module=m,
    rtl_file='rtl/'+m+'.sv',implements=['LLD.MOD.SPI_MASTER.'+n]) for n,m in [('CSR','spi_master_top'),('ENGINE','spi_master_engine'),('QUEUES','spi_master_queues')]))
for stage in ['lrs','hld','lld']:
    (IP/'docs'/stage/'index.md').write_text('# '+stage.upper()+' 索引\n\n'+''.join(f'- [{p.stem}]({p.name})\n' for p in sorted((IP/'docs'/stage).glob('*.md')) if p.name!='index.md'))
print(f'Authored {len(reqs)} requirements and design baseline')
