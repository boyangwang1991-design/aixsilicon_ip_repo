# GPIO 文档检查

已核对当前设计输入、端口、寄存器示例、连接/使用步骤与限制说明。SoC 实例验收仍由集成清单记录。

<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: user_guide_review
status: pass
reviewed_by: execution_agent_under_user_delegation
review_evidence:
  path: docs/reviews/documentation_authorization.md
  sha256: fa5595a8dde775e7412ac77df6d00cf7a71801ec0ce449c6bdc5c48e40fc963d
artifacts:
- path: docs/user_manual/gpio_register_programming_guide.md
  sha256: cd8b94e17acc3e2033e3ffedf50e5265fc0e0f27cfe7fdde9113ee2823e227dc
- path: docs/user_manual/gpio_user_guide.md
  sha256: b55010af09c91429481e34b4d474b951334f66b818f1a0822c5c04ead72d3b26
- path: model/requirements.yaml
  sha256: a9391fd36743b715198ace06e2dfef634c8c5db36ca51ab2acac79486210e620
- path: model/architecture.yaml
  sha256: 1d30ad2c87caed88fe88f96de3512b4a3a405f3101cce27c948c1a84c5821011
- path: model/micro_design.yaml
  sha256: 7ab0ff880283862fb9999415e0efff8fa657c621c1d74d6b89a70e0b9bae7ef9
- path: model/external_interface.yaml
  sha256: 2cdbb78ec40e57fbd649645227dc9277ca82b321bd56821b93d3c83d43a641cc
- path: model/clock_domains.yaml
  sha256: 763dd0df82216fe3475a3b340610e90ab8c5ba5ae9411fb8d078426c40ca6dda
- path: rtl/generated/gpio_csr.sv
  sha256: 20a60ca882f8d77a0022b5098c85d47a27d03be0b180f3cbfa6b75155cd8a749
- path: rtl/generated/gpio_csr_adapter.sv
  sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
- path: rtl/generated/gpio_csr_pkg.sv
  sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
- path: rtl/generated/gpio_reg_desc_pkg.sv
  sha256: f709bb8faecdf59f6206e77564f5e51c6599770c62b0c69797b39e65a304f507
- path: rtl/gpio.sv
  sha256: bfaaad7b7fbeec00e088e67132bc595fdd735eb21d00659ba8c7d01d5774a0d2
- path: rtl/gpio_aon_mailbox.sv
  sha256: cca9516e4ecf017b548c059407036feb71dc9ebfa46b655d440cd4bc02fd50b9
- path: rtl/gpio_aon_wake.sv
  sha256: f55c78309a898b23c4e9530a49c010d44c188128150808df8d88d5bbe145dbad
- path: rtl/gpio_apb_if.sv
  sha256: eed67322dfdd2143237c4f93ea8af350f036a87c9ee52cddd689da84869616be
- path: rtl/gpio_capture.sv
  sha256: 71e3b2a6ffb272f05c99390addead35f5709d8292596ee84bb2010e4bc5e8af5
- path: rtl/gpio_diag.sv
  sha256: 03c792f38def1bffc2fd1726b0e88ec2b36aa151a1377a0f660df2aae5641061
- path: rtl/gpio_event_fifo.sv
  sha256: 791832b98dc7e7675bae96a53c01fa114562660fe536ec315f4e40f554b9cd7c
- path: rtl/gpio_input.sv
  sha256: 16ba407e14681dbb68154f9a290e7e351ac07afb395325a918d8d4dbc3e99d6b
- path: rtl/gpio_irq.sv
  sha256: 01d96f140262d58b530348830274a0789d1cbe9016977d48f403609f611f2556
- path: rtl/gpio_output.sv
  sha256: 6010ecb13e88eb779dc16a84e60b9ef9e48cf8b8763d38fb3746e52772a727f5
- path: rtl/gpio_pkg.sv
  sha256: 48f5ffdc5cf46b697dd625c23c45697f46d68c92e1aee6438347428e31026894
- path: rtl/gpio_regfile.sv
  sha256: 24e665d030fb606492fa95e06cdf40219974ea72ac39e1baaceb228559306cb4
- path: rtl/gpio_security.sv
  sha256: 26b65cbfdb2ad13bb7acaf133e3005c27688c86ba819e4bc6bd47cf494f0e079
- path: regs/gpio.rdl
  sha256: 46bd1bab2da0f44f9bdff6c5bba6f4c7f7a93a9d09d7f6e6849cc3ea40571984
sections:
  usage:
  - docs/user_manual/gpio_register_programming_guide.md
  - docs/user_manual/gpio_user_guide.md
  configuration:
  - docs/user_manual/gpio_register_programming_guide.md
  - docs/user_manual/gpio_user_guide.md
  errors:
  - docs/user_manual/gpio_register_programming_guide.md
  - docs/user_manual/gpio_user_guide.md
  limitations:
  - docs/user_manual/gpio_register_programming_guide.md
  - docs/user_manual/gpio_user_guide.md
  registers:
  - docs/user_manual/gpio_register_programming_guide.md
  - docs/user_manual/gpio_user_guide.md
END_REPORT_META -->
