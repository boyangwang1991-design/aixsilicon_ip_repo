# 内部接口细化 3

所有信号属于pclk/RST_PRESET_N。无ready反馈的组合接口不得隐含反压；完成脉冲只保持一拍，状态更新在该拍末沿。valid=0时接收方不得执行命令或索引无效目标。

## AUDIT_CONTROL

| 信号 | 位宽 | 含义 |
|---|---|---|
| accepted_clear | 4 | FIRST/LAST/FIFO/OVF清除 |
| accepted_pop | 1 | 合法POP完成 |
| accepted_counter_clear | 4 | 全局计数清除 |
| read_first0/read_last0 | 各1 | 成功读字0刷新快照 |
| read_word | 3 | 当前32位字索引 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.AUDIT_CONTROL
owner_module: LLD.MOD.APB_SECURE_DEMUX.CSR
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.AUDIT_CONTROL
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: accepted_clear
  width: '4'
  meaning: FIRST/LAST/FIFO/OVF清除
- name: accepted_pop
  width: '1'
  meaning: 合法POP完成
- name: accepted_counter_clear
  width: '4'
  meaning: 全局计数清除
- name: read_first0/read_last0
  width: 各1
  meaning: 成功读字0刷新快照
- name: read_word
  width: '3'
  meaning: 当前32位字索引
END_LLD_INTERFACE_META -->
## LOCAL_REQUEST

| 信号 | 位宽 | 含义 |
|---|---|---|
| csr_valid | 1 | 唯一CSR命中，不能由地址优先级放行 |
| offset | ADDR_WIDTH | 全宽减法后偏移，不截断别名 |
| request | 完整锁存请求 | 权限身份和APB属性绑定 |
| ready/error | 各1 | 首ACCESS响应 |
| read_data | 32 | 拒绝强制零 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.LOCAL_REQUEST
owner_module: LLD.MOD.APB_SECURE_DEMUX.DECODE
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.LOCAL_REQUEST
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: csr_valid
  width: '1'
  meaning: 唯一CSR命中，不能由地址优先级放行
- name: offset
  width: ADDR_WIDTH
  meaning: 全宽减法后偏移，不截断别名
- name: request
  width: 完整锁存请求
  meaning: 权限身份和APB属性绑定
- name: ready/error
  width: 各1
  meaning: 首ACCESS响应
- name: read_data
  width: '32'
  meaning: 拒绝强制零
END_LLD_INTERFACE_META -->
## IRQ_CONTROL

| 信号 | 位宽 | 含义 |
|---|---|---|
| clear_mask/enable/alert | 各9 | 生成CSR有效字段 |
| write_enable/write_alert | 各1 | 成功软件写完成脉冲 |
| test | 1 | 已授权通知测试 |
| raw/masked | 各9 | 只读状态 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.IRQ_CONTROL
owner_module: LLD.MOD.APB_SECURE_DEMUX.CSR
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.IRQ_CONTROL
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: clear_mask/enable/alert
  width: 各9
  meaning: 生成CSR有效字段
- name: write_enable/write_alert
  width: 各1
  meaning: 成功软件写完成脉冲
- name: test
  width: '1'
  meaning: 已授权通知测试
- name: raw/masked
  width: 各9
  meaning: 只读状态
END_LLD_INTERFACE_META -->
## DFX_CONTROL

| 信号 | 位宽 | 含义 |
|---|---|---|
| command_accept | 1 | 当前硬件授权与完整CSR检查通过 |
| command | 生成器命名选中 | 控制/清除/注入目标/命令选择 |
| write_data/read_data | 各32 | 命令参数与读回 |
| dynamic_error | 8 | 锁/非法目标/武装/配置错误原因 |

<!-- LLD_INTERFACE_META
id: LLD.IF.APB_SECURE_DEMUX.DFX_CONTROL
owner_module: LLD.MOD.APB_SECURE_DEMUX.CSR
hld_ref:
- HLD.IF.INT.APB_SECURE_DEMUX.DFX_CONTROL
protocol: synchronous_control
clock_domain: CLK_PCLK
reset_domain: RST_PRESET_N
signals:
- name: command_accept
  width: '1'
  meaning: 当前硬件授权与完整CSR检查通过
- name: command
  width: 生成器命名选中
  meaning: 控制/清除/注入目标/命令选择
- name: write_data/read_data
  width: 各32
  meaning: 命令参数与读回
- name: dynamic_error
  width: '8'
  meaning: 锁/非法目标/武装/配置错误原因
END_LLD_INTERFACE_META -->
