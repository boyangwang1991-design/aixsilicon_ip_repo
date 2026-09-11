# 内部接口细化 1

所有信号属于pclk/RST_PRESET_N。无ready反馈的组合接口不得隐含反压；完成脉冲只保持一拍，状态更新在该拍末沿。valid=0时接收方不得执行命令或索引无效目标。

## CLASSIFY

| 信号 | 位宽 | 含义 |
|---|---|---|
| setup_valid | 1 | 上游合法SETUP |
| address | ADDR_WIDTH | 全部原始地址 |
| request | ADDR_WIDTH+40+MASTER_ID_WIDTH | 完整请求；数据32、strb4、prot3、write1及身份；valid独立1 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.CLASSIFY
owner_module: LLD.MOD.APB_SECURE_DEMUX.FRONTEND
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.CLASSIFY
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: setup_valid
  width: '1'
  meaning: 上游合法SETUP
- name: address
  width: ADDR_WIDTH
  meaning: 全部原始地址
- name: request
  width: ADDR_WIDTH+40+MASTER_ID_WIDTH
  meaning: 完整请求；数据32、strb4、prot3、write1及身份；valid独立1
END_LLD_INTERFACE_META -->
## TARGET

| 信号 | 位宽 | 含义 |
|---|---|---|
| port_hits | NUM_PORTS | 全部端口命中 |
| csr_hit | 1 | 本地CSR命中 |
| port | max(1,$clog2(NUM_PORTS)) | 仅唯一外设时有效 |
| port_valid | 1 | 唯一外设 |
| reason | 8 | 总译码原因 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.TARGET
owner_module: LLD.MOD.APB_SECURE_DEMUX.DECODE
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.TARGET
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: port_hits
  width: NUM_PORTS
  meaning: 全部端口命中
- name: csr_hit
  width: '1'
  meaning: 本地CSR命中
- name: port
  width: max(1,$clog2(NUM_PORTS))
  meaning: 仅唯一外设时有效
- name: port_valid
  width: '1'
  meaning: 唯一外设
- name: reason
  width: '8'
  meaning: 总译码原因
END_LLD_INTERFACE_META -->
## POLICY_LOOKUP

| 信号 | 位宽 | 含义 |
|---|---|---|
| active_cfg | 2*NUM_PORTS | 端口使能与指令许可 |
| active_perm | 8*NUM_PORTS*NUM_MASTERS | 完整active表 |
| policy_version | 32 | 判权版本 |
| raw_bad/fatal | 各1 | 新SETUP准入门控 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.POLICY_LOOKUP
owner_module: LLD.MOD.APB_SECURE_DEMUX.POLICY
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.POLICY_LOOKUP
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: active_cfg
  width: 2*NUM_PORTS
  meaning: 端口使能与指令许可
- name: active_perm
  width: 8*NUM_PORTS*NUM_MASTERS
  meaning: 完整active表
- name: policy_version
  width: '32'
  meaning: 判权版本
- name: raw_bad/fatal
  width: 各1
  meaning: 新SETUP准入门控
END_LLD_INTERFACE_META -->
## ADMISSION

| 信号 | 位宽 | 含义 |
|---|---|---|
| allow | 1 | 完整自然判权及DFX叠加后的准入 |
| reason | 8 | 互斥主原因 |
| port_valid/test | 各1 | 诊断标记 |
| port | max(1,$clog2(NUM_PORTS)) | 捕获目标 |
| version | 32 | SETUP版本 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.ADMISSION
owner_module: LLD.MOD.APB_SECURE_DEMUX.ACCESS
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.ADMISSION
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: allow
  width: '1'
  meaning: 完整自然判权及DFX叠加后的准入
- name: reason
  width: '8'
  meaning: 互斥主原因
- name: port_valid/test
  width: 各1
  meaning: 诊断标记
- name: port
  width: max(1,$clog2(NUM_PORTS))
  meaning: 捕获目标
- name: version
  width: '32'
  meaning: SETUP版本
END_LLD_INTERFACE_META -->
