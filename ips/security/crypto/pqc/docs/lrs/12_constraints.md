# PQC LRS：集成与交付约束

### LRS.CONS.PQC.LANG.001 综合语言兼容性

<!-- LRS_META
id: LRS.CONS.PQC.LANG.001
category: CONS
feature: synthesis_language
priority: P0
status: active
source_ref:
- pqc_contract.md#§13
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

交付 RTL 应为可综合 SystemVerilog（`.sv`/`.svh`），不得包含仅仿真构造，并应通过
lint、elaboration 与综合检查。

#### Acceptance Criteria

- RTL 目录不含 `.v`/`.vh` 与仅仿真构造；
- SpyGlass lint 无 error/fatal；
- Design Compiler 可综合出网表。

---

### LRS.CONS.PQC.CORE.001 FuseSoC 交付

<!-- LRS_META
id: LRS.CONS.PQC.CORE.001
category: CONS
feature: fusesoc_core
priority: P0
status: active
source_ref:
- pqc_contract.md#§13
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

IP 应以单一 FuseSoC core 表达 fileset、参数、依赖与 lint/elab/sim/synth target，
VLNV 为 `aixsilicon:ip:pqc:<version>`。

#### Acceptance Criteria

- core 解析成功且 fileset 完整；
- 所有 target 可被执行；
- VLNV vendor 为 `aixsilicon`。

---

### LRS.CONS.PQC.REG.001 寄存器 SSOT 与派生视图

<!-- LRS_META
id: LRS.CONS.PQC.REG.001
category: CONS
feature: register_ssot
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.2
- pqc_contract.md#§13
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

寄存器结构应使用 SystemRDL 作为唯一事实源，并由 PeakRDL 确定性生成 CSR RTL、
C header 与 UVM RAL；不得手工维护多份寄存器定义。

#### Acceptance Criteria

- RDL 可编译且生成全部派生视图；
- CSR RTL/header/RAL 与 RDL 一致；
- 无手工编辑的派生寄存器文件。

---

### LRS.CONS.PQC.CONST.001 参数与常量生成源一致

<!-- LRS_META
id: LRS.CONS.PQC.CONST.001
category: CONS
feature: constants
priority: P0
status: active
source_ref:
- pqc_contract.md#§13
- pqc_contract.md#§24
applicability:
  expr: 'true'
verification_method:
- static
- review
END_LRS_META -->

#### Requirement

软件参考模型、RTL 与验证环境应共同使用同一参数/常量生成源；标准版本与 NIST errata
应进入配置管理，变更触发影响分析。

#### Acceptance Criteria

- NTT roots、约减常量由同一生成器产生；
- RTL 常量 ROM 与参考模型一致；
- 标准版本与 errata 有版本记录。

---

### LRS.CONS.PQC.DELIVER.001 交付件集合

<!-- LRS_META
id: LRS.CONS.PQC.DELIVER.001
category: CONS
feature: deliverables
priority: P0
status: active
source_ref:
- pqc_contract.md#§13
applicability:
  expr: 'true'
verification_method:
- review
END_LRS_META -->

#### Requirement

应交付：可综合 RTL、约束、lint 报告、SystemRDL 与派生 C header/UVM RAL、
参数/常量生成器与生成清单、bare-metal 同步 API、KAT/ACVP harness、Python/C 参考模型、
UVM 环境、formal properties、FuseSoC core、集成指南、安全手册、生命周期/密钥/zeroize
说明与代码结构 PPA 评估（至少 Tiny/Balanced）。本轮不要求实测 PPA 报告；
不得把未测量的频率、面积或功耗标为签核通过。

#### Acceptance Criteria

- 每项交付件存在且可执行/可复现；
- 交付件版本与 manifest 一致；
- 缺失项在报告中显式披露。

---

### LRS.CONS.PQC.API.001 驱动 API 语义

<!-- LRS_META
id: LRS.CONS.PQC.API.001
category: CONS
feature: driver_api
priority: P0
status: active
source_ref:
- pqc_contract.md#§13
- pqc_contract.md#§20.4
applicability:
  expr: 'true'
verification_method:
- software
- review
END_LRS_META -->

#### Requirement

驱动应提供 `pqc_open`、`pqc_keygen`、`pqc_kem_encaps`、`pqc_kem_decaps`、
`pqc_dsa_sign_init/update/final`、`pqc_dsa_verify_init/update/final`、
`pqc_key_destroy`、`pqc_get_capabilities`。API 返回值不得形成 decapsulation oracle。
枚举应使用 `ML_KEM_512` 等算法名而非“security level 数字”。

#### Acceptance Criteria

- API 集合可用且返回值语义符合定义；
- decaps 返回码不区分密文有效性；
- 驱动在调用前校验输出容量并在错误时清除敏感 buffer。