# 内部接口细化 2

所有信号属于pclk/RST_PRESET_N。无ready反馈的组合接口不得隐含反压；完成脉冲只保持一拍，状态更新在该拍末沿。valid=0时接收方不得执行命令或索引无效目标。

## CSR_COMMAND

| 信号 | 位宽 | 含义 |
|---|---|---|
| commit_attempt/accept | 各1 | 诊断尝试与成功修改分开 |
| port_mask | NUM_PORTS | 全量更新目标，越界检查使用原32位命令 |
| write_data | 32 | 原数据保留至完成 |
| register_select | 生成器决定 | 命名的生成译码选中，非另写地址译码 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.CSR_COMMAND
owner_module: LLD.MOD.APB_SECURE_DEMUX.CSR
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.CSR_COMMAND
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: commit_attempt/accept
  width: 各1
  meaning: 诊断尝试与成功修改分开
- name: port_mask
  width: NUM_PORTS
  meaning: 全量更新目标，越界检查使用原32位命令
- name: write_data
  width: '32'
  meaning: 原数据保留至完成
- name: register_select
  width: 生成器决定
  meaning: 命名的生成译码选中，非另写地址译码
END_LLD_INTERFACE_META -->
## EVENT_CANDIDATES

| 信号 | 位宽 | 含义 |
|---|---|---|
| candidate_valid | 4 | 全部事件，不止获胜项 |
| candidate_data | 4*256 | 每候选完整记录，时间戳与序列在EVENTS填充 |
| lost_count | 3 | 同周期候选仲裁和满FIFO丢失总数 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.EVENT_CANDIDATES
owner_module: LLD.MOD.APB_SECURE_DEMUX.EVENTS
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.EVENT_CANDIDATES
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: candidate_valid
  width: '4'
  meaning: 全部事件，不止获胜项
- name: candidate_data
  width: 4*256
  meaning: 每候选完整记录，时间戳与序列在EVENTS填充
- name: lost_count
  width: '3'
  meaning: 同周期候选仲裁和满FIFO丢失总数
END_LLD_INTERFACE_META -->
## DFX_INJECTION

| 信号 | 位宽 | 含义 |
|---|---|---|
| armed_mode | 2 | 00未武装/01拒绝/10完整性；11非法并拒绝武装 |
| armed_port | 5 | 完整目标端口 |
| armed_master | 6 | 完整目标主体 |
| authorized | 1 | 当前可信授权 |
| consume | 1 | 自然允许匹配SETUP末沿消费 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.DFX_INJECTION
owner_module: LLD.MOD.APB_SECURE_DEMUX.DFX
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.DFX_INJECTION
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: armed_mode
  width: '2'
  meaning: 00未武装/01拒绝/10完整性；11非法并拒绝武装
- name: armed_port
  width: '5'
  meaning: 完整目标端口
- name: armed_master
  width: '6'
  meaning: 完整目标主体
- name: authorized
  width: '1'
  meaning: 当前可信授权
- name: consume
  width: '1'
  meaning: 自然允许匹配SETUP末沿消费
END_LLD_INTERFACE_META -->
## ACTIVITY

| 信号 | 位宽 | 含义 |
|---|---|---|
| port_valid | 1 | 正在向外设发起或保持事务 |
| port | 5 | 零扩展后的有效目标 |
| downstream_wait | 1 | PSEL&&PENABLE&&!PREADY |
| complete/error | 各1 | 下游真实完成信息 |
| context | 完整锁存请求 | 带SETUP版本和TEST |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.ACTIVITY
owner_module: LLD.MOD.APB_SECURE_DEMUX.ROUTE
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.ACTIVITY
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: port_valid
  width: '1'
  meaning: 正在向外设发起或保持事务
- name: port
  width: '5'
  meaning: 零扩展后的有效目标
- name: downstream_wait
  width: '1'
  meaning: PSEL&&PENABLE&&!PREADY
- name: complete/error
  width: 各1
  meaning: 下游真实完成信息
- name: context
  width: 完整锁存请求
  meaning: 带SETUP版本和TEST
END_LLD_INTERFACE_META -->
