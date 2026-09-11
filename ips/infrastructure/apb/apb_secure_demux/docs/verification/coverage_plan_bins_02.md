# 强制覆盖义务 2

## ACL

- 每端口×每主体×四属性×读写×许可位0/1
- 数据/指令读/指令写×INSTR_ALLOW0/1
- 身份合法/valid0/越界/高位别名×管理/非管理
- PSTRB0写仍检查权限

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.ACL.MANDATORY
name: acl_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.ACL
bins:
- 每端口×每主体×四属性×读写×许可位0/1
- 数据/指令读/指令写×INSTR_ALLOW0/1
- 身份合法/valid0/越界/高位别名×管理/非管理
- PSTRB0写仍检查权限
target: 100
END_COVERAGE_META -->
## APB

- direct/register×零/1/17/257等待×成功/下游错
- 端口切换/读写交替/CSR交替/拒绝交替
- 等待中FATAL/撤权不取消；下游错误非零数据

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.APB.MANDATORY
name: apb_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.APB
bins:
- direct/register×零/1/17/257等待×成功/下游错
- 端口切换/读写交替/CSR交替/拒绝交替
- 等待中FATAL/撤权不取消；下游错误非零数据
target: 100
END_COVERAGE_META -->
## CSR

- 每实现寄存器可读/可写属性
- 全部PSTRB0..15×地址低位0..3×读写
- 公开区/敏感区/DFX区×身份与PPROT授权
- 所有保留位RAZ/WI与未实现/裁剪位置拒绝

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.CSR.MANDATORY
name: csr_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.CSR
bins:
- 每实现寄存器可读/可写属性
- 全部PSTRB0..15×地址低位0..3×读写
- 公开区/敏感区/DFX区×身份与PPROT授权
- 所有保留位RAZ/WI与未实现/裁剪位置拒绝
target: 100
END_COVERAGE_META -->
## UPDATE

- commit空/越界/单端口/多端口/全部端口
- 全局锁/最低及非最低端口锁/完整性×合法和非法掩码
- 成功版本自然回绕/失败版本不变/reload不增
- 非零启动策略、追加锁、锁写零、commit后背靠背SETUP

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.UPDATE.MANDATORY
name: update_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.UPDATE
bins:
- commit空/越界/单端口/多端口/全部端口
- 全局锁/最低及非最低端口锁/完整性×合法和非法掩码
- 成功版本自然回绕/失败版本不变/reload不增
- 非零启动策略、追加锁、锁写零、commit后背靠背SETUP
target: 100
END_COVERAGE_META -->
