# Watchdog：APB external CSR 数据通路

## 原生APB4-flat适配

<!-- LLD_DATAPATH_META
id: LLD.DP.WATCHDOG.BUS.CSR
module_ref: LLD.MOD.WATCHDOG.BUS
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
input_width: 15 address + 32 data + 4 strobe + 3 protection
output_width: 32 read_data + ready + error
latency: 1..2 pclk ACCESS cycles
signed: false
END_LLD_DATAPATH_META -->

明确采用已实测可生成的PeakRDL apb4-flat CPU接口，地址15位/数据32位；传入完整
PSEL/PENABLE/PWRITE/PADDR/PWDATA/PSTRB/PPROT，不能只将ACCESS req接到psel导致丢SETUP。
本地owner状态由external register hwif提供，生成适配器根据RDL生成mask和读写属性。
CSR external req/ack只完成协议，不直接触发staging/邮箱/锁副作用；这些动作唯一在
顶层APB完成且所有权限/格式/忙检查成功时产生。拒绝请求可在协议层应答，但禁止
把其external write pulse直接连到有副作用存储。读数据同样按合法性在顶层置零。

PeakRDL对PADDR低位按字对齐，因此原始低位合法性必须在顶层独立检查，不得丢失
误对齐地址后当合法命令执行。PREADY使用原生完成且复位已释放，不能与WDT busy
组合成无限背压。busy错误只影响当前命令PSLVERR，保留原DONE。WO读零故不全局
打开err-if-bad-rw；RO写通过RDL派生writable检查拒绝。err-if-bad-addr必须开启。

生成物位于build/g2_csr_candidate用于本阶段接口检查；正式寄存器产物按冻结结论
再生。当前旧passthrough产物仍为候选，不能混用两个CPU接口的module和adapter。

