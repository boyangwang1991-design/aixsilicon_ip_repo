# 强制覆盖义务 1

## PARAM

- NUM_PORTS=1,8,32及3非二幂
- NUM_MASTERS=1,16,64及3非二幂
- FIFO_DEPTH=0,1,8,32及3
- 8命名配置和75支持点，11预期失败阶段各一bin

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.PARAM.MANDATORY
name: param_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.PARAM
bins:
- NUM_PORTS=1,8,32及3非二幂
- NUM_MASTERS=1,16,64及3非二幂
- FIFO_DEPTH=0,1,8,32及3
- 8命名配置和75支持点，11预期失败阶段各一bin
target: 100
END_COVERAGE_META -->
## INTERFACE

- 每端口选择/未选×隔离开关
- 完整身份最高位0/1及valid0/1
- SETUP/ACCESS/等待/背靠背×DFX授权0/1

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.INTERFACE.MANDATORY
name: interface_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.INTERFACE
bins:
- 每端口选择/未选×隔离开关
- 完整身份最高位0/1及valid0/1
- SETUP/ACCESS/等待/背靠背×DFX授权0/1
target: 100
END_COVERAGE_META -->
## SYSTEM

- 每条系统信任需求有当前实例证据
- 受控APB版本审查通过
- X2P读写属性/身份绑定和所有旁路/别名路径逐项关闭

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.SYSTEM.MANDATORY
name: system_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.SYSTEM
bins:
- 每条系统信任需求有当前实例证据
- 受控APB版本审查通过
- X2P读写属性/身份绑定和所有旁路/别名路径逐项关闭
target: 100
END_COVERAGE_META -->
## DECODE

- 各区首/末/前/后地址
- 无命中/唯一端口/唯一CSR/双端口/CSR+端口
- 端口开启/关闭×命中

<!-- COVERAGE_META
id: COV.APB_SECURE_DEMUX.DECODE.MANDATORY
name: decode_mandatory
type: functional
description: 全部列出bins命中或逐项评审豁免；静态feature使用真实checker结果
feature_ref:
- FL.APB_SECURE_DEMUX.DECODE
bins:
- 各区首/末/前/后地址
- 无命中/唯一端口/唯一CSR/双端口/CSR+端口
- 端口开启/关闭×命中
target: 100
END_COVERAGE_META -->
