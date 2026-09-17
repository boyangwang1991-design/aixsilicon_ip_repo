# PQC 加速器逻辑详细设计：接口细节与 RTL 映射

## 信号级接口

### LLD.IF.PQC.FE.APB

<!-- LLD_INTERFACE_META
id: LLD.IF.PQC.FE.APB
owner_module: LLD.MOD.PQC.APB
interface_ref: HLD.IF.EXT.PQC.APB
protocol: apb4
signal_groups:
- psel_penable_pwrite_paddr_pwdata_pstrb
- prdata_pready_pslverr
handshake: APB4 SETUP/ACCESS 两相
notes: 特权/安全属性作为旁带输入参与 KEY_SLOT_CTRL 与 CTRL 敏感字段门控。
req_ref:
- LRS.INTF.PQC.APB.001
applicability:
  expr: 'true'
END_LLD_INTERFACE_META -->

### LLD.IF.PQC.DMA.AXI

<!-- LLD_INTERFACE_META
id: LLD.IF.PQC.DMA.AXI
owner_module: LLD.MOD.PQC.DMA
interface_ref: HLD.IF.EXT.PQC.DMA
protocol: axi4
signal_groups:
- ar_aw_channel
- r_w_channel
- b_channel
handshake: AXI4 valid/ready
notes: 数据宽度 DMA_DATA_WIDTH；地址宽度 >= 40 bit；每请求携带安全/特权属性。
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.002
applicability:
  expr: 'true'
END_LLD_INTERFACE_META -->

### LLD.IF.PQC.POLY.PAGE

<!-- LLD_INTERFACE_META
id: LLD.IF.PQC.POLY.PAGE
owner_module: LLD.MOD.PQC.POLY
interface_ref: HLD.IF.INT.PQC.PAGE
protocol: memory
signal_groups:
- page_sel_a_coeff_a_req_a_rdata
- page_sel_b_coeff_b_req_b_rdata
- page_sel_w_coeff_w_we_wdata
handshake: 请求 valid/ready；同步 RAM 与 ECC 共两拍返回；预留 read/write slot
notes: butterfly 两输入分配到保留 bank；详见 POLY 六 batch slot 调度，不能假设单拍组合读。
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
applicability:
  expr: 'true'
END_LLD_INTERFACE_META -->

### LLD.IF.PQC.KECCAK.SQZ

<!-- LLD_INTERFACE_META
id: LLD.IF.PQC.KECCAK.SQZ
owner_module: LLD.MOD.PQC.KECCAK
interface_ref: HLD.IF.INT.PQC.SQZ
protocol: stream
signal_groups:
- sqz_valid_sqz_data64_sqz_ready
- sqz_last_sqz_out_len
handshake: valid/ready，自动续块
notes: 采样器消费不足时反压；context 在 block 边界切换。
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
applicability:
  expr: 'true'
END_LLD_INTERFACE_META -->

## RTL 映射

### RTL.PQC.TOP

<!-- RTL_MAP_META
id: RTL.PQC.TOP
rtl_file: rtl/pqc_top.sv
rtl_module: pqc_top
implements:
- LLD.MOD.PQC.TOP
- LLD.DP.PQC.TOP.COMMAND_CONTEXT
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.APB

<!-- RTL_MAP_META
id: RTL.PQC.APB
rtl_file: rtl/pqc_apb_if.sv
rtl_module: pqc_apb_if
implements:
- LLD.MOD.PQC.APB
- LLD.IF.PQC.FE.APB
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.FE

<!-- RTL_MAP_META
id: RTL.PQC.FE
rtl_file: rtl/pqc_cmd_frontend.sv
rtl_module: pqc_cmd_frontend
implements:
- LLD.MOD.PQC.FE
- LLD.FSM.PQC.TOP.MAIN
- LLD.BUF.PQC.FE.DESC
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.KEYSLOT

<!-- RTL_MAP_META
id: RTL.PQC.KEYSLOT
rtl_file: rtl/pqc_key_slots.sv
rtl_module: pqc_key_slots
implements:
- LLD.MOD.PQC.KEYSLOT
- LLD.DP.PQC.KEYSLOT.AUTH
- LLD.FSM.PQC.KEYSLOT.LIFETIME
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.KEMSEQ

<!-- RTL_MAP_META
id: RTL.PQC.KEMSEQ
rtl_file: rtl/pqc_kem_seq.sv
rtl_module: pqc_kem_seq
implements:
- LLD.MOD.PQC.KEMSEQ
- LLD.FSM.PQC.KEMSEQ.DISPATCH
- LLD.DP.PQC.KEMSEQ.COMPARE_SELECT
- LLD.SAFE.PQC.CT_SELECT
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.DSASEQ

<!-- RTL_MAP_META
id: RTL.PQC.DSASEQ
rtl_file: rtl/pqc_dsa_seq.sv
rtl_module: pqc_dsa_seq
implements:
- LLD.MOD.PQC.DSASEQ
- LLD.FSM.PQC.DSASEQ.ATTEMPT
- LLD.BUF.PQC.DSASEQ.STAGE
- LLD.SAFE.PQC.VERIFY_DUAL
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.POLY

<!-- RTL_MAP_META
id: RTL.PQC.POLY
rtl_file: rtl/pqc_poly_engine.sv
rtl_module: pqc_poly_engine
implements:
- LLD.MOD.PQC.POLY
- LLD.DP.PQC.POLY.BFLY
- LLD.PIPE.PQC.POLY.STAGE
- LLD.DERIVED.PQC.BANKHASH
- LLD.DERIVED.PQC.LAZY
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.KECCAK

<!-- RTL_MAP_META
id: RTL.PQC.KECCAK
rtl_file: rtl/pqc_keccak.sv
rtl_module: pqc_keccak
implements:
- LLD.MOD.PQC.KECCAK
- LLD.DP.PQC.KECCAK.PERM
- LLD.PIPE.PQC.KECCAK.BLOCK
- LLD.DERIVED.PQC.KCTX
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.SAMPLER

<!-- RTL_MAP_META
id: RTL.PQC.SAMPLER
rtl_file: rtl/pqc_sampler.sv
rtl_module: pqc_sampler
implements:
- LLD.MOD.PQC.SAMPLER
- LLD.FSM.PQC.SAMPLER.EXECUTE
- LLD.DP.PQC.SAMPLER.STREAM
- LLD.DP.PQC.SAMPLER.SECRET_SCAN
- LLD.BUF.PQC.SAMPLER.SQZ
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.CODEC

<!-- RTL_MAP_META
id: RTL.PQC.CODEC
rtl_file: rtl/pqc_codec.sv
rtl_module: pqc_codec
implements:
- LLD.MOD.PQC.CODEC
- LLD.DP.PQC.CODEC.BITPACK
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.SRAM

<!-- RTL_MAP_META
id: RTL.PQC.SRAM
rtl_file: rtl/pqc_secure_sram_ctrl.sv
rtl_module: pqc_secure_sram_ctrl
implements:
- LLD.MOD.PQC.SRAM
- LLD.DP.PQC.SRAM.TAG_ECC
- LLD.FSM.PQC.SRAM.PAGE
- LLD.ARB.PQC.SRAM.BANK
- LLD.SAFE.PQC.ECC
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.DMA

<!-- RTL_MAP_META
id: RTL.PQC.DMA
rtl_file: rtl/pqc_dma.sv
rtl_module: pqc_dma
implements:
- LLD.MOD.PQC.DMA
- LLD.DP.PQC.DMA.BYTE_STREAM
- LLD.FSM.PQC.DMA.TRANSFER
- LLD.IF.PQC.DMA.AXI
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.FAULT

<!-- RTL_MAP_META
id: RTL.PQC.FAULT
rtl_file: rtl/pqc_fault_ctrl.sv
rtl_module: pqc_fault_ctrl
implements:
- LLD.MOD.PQC.FAULT
- LLD.RST.PQC.ZEROPATH
- LLD.SAFE.PQC.CTRL_SPARSE
- LLD.SAFE.PQC.COUNTER_PARITY
- LLD.SAFE.PQC.NO_SECRET_GATING
generated: false
generator_ref: null
END_RTL_MAP_META -->

### RTL.PQC.CSR

<!-- RTL_MAP_META
id: RTL.PQC.CSR
rtl_file: rtl/generated/pqc_csr.sv
rtl_module: pqc_csr
implements:
- LLD.REG.PQC.ID_VERSION
- LLD.REG.PQC.CTRL_ENABLE
- LLD.REG.PQC.STATUS
- LLD.REG.PQC.INTR_STATE
- LLD.REG.PQC.SLOT_CTRL
generated: true
generator_ref: GEN.PQC.RDL
END_RTL_MAP_META -->
