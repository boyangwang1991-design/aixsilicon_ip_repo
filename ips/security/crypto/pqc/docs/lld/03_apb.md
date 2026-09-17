# PQC APB 微架构（恢复中）

### LLD.MOD.PQC.APB

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.APB
name: pqc_apb_if
parent_ref: HLD.MOD.PQC.TOP
hld_ref:
- HLD.MOD.PQC.TOP
req_ref:
- LRS.INTF.PQC.APB.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_apb_if
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

#### Responsibility

APB4 adapter，桥接 `pqc_csr` regblock 接口；未映射地址 pslverr；特权/安全属性门控
KEY_SLOT_CTRL 与 CTRL.zeroize/abort。

---

## 属性、地址与拒绝应答

安全管理窗口为 0x200..0x3ff，只有专用 privileged 旁带有效且 APB PPROT[0]=1、
PPROT[1]=0 的主体可以访问；PPROT[2] 不改变当前授权。CTRL 的 abort/zeroize
请求（低字节 strobe 有效且对应请求位写 1）遵守相同规则，普通只读状态不额外加锁。
权限由可信旁带和总线属性共同约束，debug 解锁不作为访问条件。

所有寄存器按 32-bit 字地址访问，地址低两位非零返回 PSLVERR；字节写通过 PSTRB
表达，不能用未对齐地址绕过 COMMAND 等保护比较。BUSY 保护组包含 COMMAND、
0x020..0x080 命令 shadow、DOORBELL、DESC_ADDR 两半；读取不受 BUSY 限制。
TOP 提供的 busy 必须包含已经接受门铃、FE 尚未进入 FETCH 的待启动窗口。

拒绝条件在 SETUP 阶段即可组合阻断 csr_psel/csr_penable/csr_pstrb，读数据置零；
到 ACCESS 阶段由包装层本地给出 PREADY=1、PSLVERR=1，不等待被禁止访问的 CSR。
合法访问保持 CSR 的等待与错误语义，PREADY/PSLVERR 仅在本端选中且 PENABLE 时
有效。复位期间不发布 CSR 选择、写 strobe、外部完成或数据。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.APB.ACCESS_FILTER
module_ref: LLD.MOD.PQC.APB
input_width: 32
output_width: 32
operators: [secure_privilege_check, aligned_address_check, busy_write_filter, local_error_response]
representation: public_control_and_metadata_only
req_ref:
- LRS.INTF.PQC.APB.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->
