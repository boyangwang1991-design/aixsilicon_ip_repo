# PQC 专用密钥接口


## HLD.IF.EXT.PQC.KEY_MANAGER

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.PQC.KEY_MANAGER
name: secure_key_manager
scope: external
protocol: secure_transaction_stream
role: bidirectional
owner_module: HLD.MOD.PQC.WORKKEY
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.KEY_MANAGER.001
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

导入、KeyGen 托管、确认与撤销为专用安全接口组，与普通总线物理隔离。输入头包含
完整 handle、owner/domain、算法、参数集、用途、字节数和事务身份；接受头后锁定到终止。
材料 valid/ready 在背压下保持数据及边界信息；完整长度、末标记与 ECC 扫描通过后才能 READY。

托管只允许“本命令新生成”材料。PQC 发起绑定命令身份的托管头和有界材料流，Key Manager
完整接收后回传成功/失败确认及句柄归属；不接受其他事务的迟到 ACK。重复确认不重复提交。
撤销优先于导入/确认；终止双方未决事务并擦除副本，不能撤销已由普通总线接受的公开写事务。

可信来源由 SoC 连接与安全域隔离保证，单个普通 CSR 位不能认证来源。接口为核心时钟域；
异步 Key Manager 必须在 SoC 边界使用完整数据握手 CDC，不能逐 bit 同步材料流。
Level 2 材料流使用两个独立 share 数据域及一个原子握手，逻辑长度不翻倍；
导入和新生成密钥托管均禁止在 PQC 内部普通通路重构私钥。见 [掩码架构](09_masking_level2.md)。
目前 RTL 只有导入/撤销子集；owner/domain、事务确认及 KeyGen 托管均需 LLD 和 RTL 补齐。
