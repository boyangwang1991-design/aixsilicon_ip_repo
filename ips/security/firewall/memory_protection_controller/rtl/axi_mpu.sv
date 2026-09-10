// ============================================================================
// AXI MPU - Top Level (synthesizable)
// ============================================================================
// 实例化：CSR + Permission Engine + Read Path + Write Path + Violation capture。
// Region-based, Default-Deny, Context-aware AXI access control。
// ============================================================================

`include "axi_mpu_defs.svh"

module axi_mpu #(
    parameter int ADDR_WIDTH        = `AXI_MPU_ADDR_WIDTH_DEFAULT,
    parameter int DATA_WIDTH        = `AXI_MPU_DATA_WIDTH_DEFAULT,
    parameter int ID_WIDTH          = `AXI_MPU_ID_WIDTH_DEFAULT,
    parameter int MASTER_NUM        = `AXI_MPU_MASTER_NUM_DEFAULT,
    parameter int MASTER_ID_WIDTH   = `AXI_MPU_MASTER_ID_WIDTH_DEFAULT,
    parameter int REGION_NUM        = `AXI_MPU_REGION_NUM_DEFAULT,
    parameter int READ_OUTSTANDING  = `AXI_MPU_READ_OUTSTANDING_DEFAULT,
    parameter int WRITE_OUTSTANDING = `AXI_MPU_WRITE_OUTSTANDING_DEFAULT,
    parameter bit HAS_EXECUTE       = `AXI_MPU_HAS_EXECUTE_DEFAULT,
    parameter bit HAS_MASTER_ATTR   = `AXI_MPU_HAS_MASTER_ATTR_DEFAULT,
    parameter bit HAS_IRQ           = `AXI_MPU_HAS_IRQ_DEFAULT,
    parameter bit HAS_VIOLATION_LOG = `AXI_MPU_HAS_VIOLATION_LOG_DEFAULT,
    parameter int PIPELINE          = `AXI_MPU_PIPELINE_DEFAULT,
    parameter bit WRAP_SUPPORT      = `AXI_MPU_WRAP_SUPPORT_DEFAULT
) (
    input  logic                        clk,
    input  logic                        arst_n,

    // ---- S_AXI ----
    input  logic [ID_WIDTH-1:0]         s_axi_arid,
    input  logic [ADDR_WIDTH-1:0]       s_axi_araddr,
    input  logic [7:0]                  s_axi_arlen,
    input  logic [2:0]                  s_axi_arsize,
    input  logic [1:0]                  s_axi_arburst,
    input  logic [2:0]                  s_axi_arprot,
    input  logic                        s_axi_arvalid,
    output logic                        s_axi_arready,
    output logic [ID_WIDTH-1:0]         s_axi_rid,
    output logic [DATA_WIDTH-1:0]       s_axi_rdata,
    output logic [1:0]                  s_axi_rresp,
    output logic                        s_axi_rlast,
    output logic                        s_axi_rvalid,
    input  logic                        s_axi_rready,
    input  logic [ID_WIDTH-1:0]         s_axi_awid,
    input  logic [ADDR_WIDTH-1:0]       s_axi_awaddr,
    input  logic [7:0]                  s_axi_awlen,
    input  logic [2:0]                  s_axi_awsize,
    input  logic [1:0]                  s_axi_awburst,
    input  logic [2:0]                  s_axi_awprot,
    input  logic                        s_axi_awvalid,
    output logic                        s_axi_awready,
    input  logic [ID_WIDTH-1:0]         s_axi_wid,
    input  logic [DATA_WIDTH-1:0]       s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]     s_axi_wstrb,
    input  logic                        s_axi_wlast,
    input  logic                        s_axi_wvalid,
    output logic                        s_axi_wready,
    output logic [ID_WIDTH-1:0]         s_axi_bid,
    output logic [1:0]                  s_axi_bresp,
    output logic                        s_axi_bvalid,
    input  logic                        s_axi_bready,

    // ---- M_AXI ----
    output logic [ID_WIDTH-1:0]         m_axi_arid,
    output logic [ADDR_WIDTH-1:0]       m_axi_araddr,
    output logic [7:0]                  m_axi_arlen,
    output logic [2:0]                  m_axi_arsize,
    output logic [1:0]                  m_axi_arburst,
    output logic [2:0]                  m_axi_arprot,
    output logic                        m_axi_arvalid,
    input  logic                        m_axi_arready,
    input  logic [ID_WIDTH-1:0]         m_axi_rid,
    input  logic [DATA_WIDTH-1:0]       m_axi_rdata,
    input  logic [1:0]                  m_axi_rresp,
    input  logic                        m_axi_rlast,
    input  logic                        m_axi_rvalid,
    output logic                        m_axi_rready,
    output logic [ID_WIDTH-1:0]         m_axi_awid,
    output logic [ADDR_WIDTH-1:0]       m_axi_awaddr,
    output logic [7:0]                  m_axi_awlen,
    output logic [2:0]                  m_axi_awsize,
    output logic [1:0]                  m_axi_awburst,
    output logic [2:0]                  m_axi_awprot,
    output logic                        m_axi_awvalid,
    input  logic                        m_axi_awready,
    output logic [ID_WIDTH-1:0]         m_axi_wid,
    output logic [DATA_WIDTH-1:0]       m_axi_wdata,
    output logic [DATA_WIDTH/8-1:0]     m_axi_wstrb,
    output logic                        m_axi_wlast,
    output logic                        m_axi_wvalid,
    input  logic                        m_axi_wready,
    input  logic [ID_WIDTH-1:0]         m_axi_bid,
    input  logic [1:0]                  m_axi_bresp,
    input  logic                        m_axi_bvalid,
    output logic                        m_axi_bready,

    // ---- APB4 ----
    input  logic                        s_apb_psel,
    input  logic                        s_apb_penable,
    input  logic                        s_apb_pwrite,
    input  logic [2:0]                  s_apb_pprot,
    input  logic [ADDR_WIDTH-1:0]       s_apb_paddr,
    input  logic [31:0]                 s_apb_pwdata,
    input  logic [3:0]                  s_apb_pstrb,
    output logic                        s_apb_pready,
    output logic [31:0]                 s_apb_prdata,
    output logic                        s_apb_pslverr,

    // ---- Master identity sideband ----
    input  logic [MASTER_ID_WIDTH-1:0]  s_axi_ar_master_id,
    input  logic [MASTER_ID_WIDTH-1:0]  s_axi_aw_master_id,

    // ---- IRQ ----
    output logic                        irq
);

    // ==========================================================================
    // CSR 实例化
    // ==========================================================================
    axi_mpu_csr_pkg::axi_mpu__in_t      hwif_in;
    axi_mpu_csr_pkg::axi_mpu__out_t     hwif_out;

    axi_mpu_csr u_csr (
        .clk          (clk),
        .arst_n       (arst_n),
        .s_apb_psel   (s_apb_psel),
        .s_apb_penable(s_apb_penable),
        .s_apb_pwrite (s_apb_pwrite),
        .s_apb_pprot  (s_apb_pprot),
        .s_apb_paddr  (s_apb_paddr[10:0]),
        .s_apb_pwdata (s_apb_pwdata),
        .s_apb_pstrb  (s_apb_pstrb),
        .s_apb_pready (s_apb_pready),
        .s_apb_prdata (s_apb_prdata),
        .s_apb_pslverr(s_apb_pslverr),
        .hwif_in      (hwif_in),
        .hwif_out     (hwif_out)
    );

    // ==========================================================================
    // 配置投影
    // ==========================================================================
    logic                       global_enable;
    logic                       global_lock;
    logic                       irq_viol_en;
    logic [REGION_NUM-1:0]      region_enable;
    logic [REGION_NUM-1:0]      region_lock;
    logic [ADDR_WIDTH-1:0]      region_base   [REGION_NUM];
    logic [ADDR_WIDTH-1:0]      region_limit  [REGION_NUM];
    logic [MASTER_NUM-1:0]      region_master_mask [REGION_NUM];
    logic [REGION_NUM-1:0]      region_secure_allow;
    logic [REGION_NUM-1:0]      region_nonsecure_allow;
    logic [REGION_NUM-1:0]      region_priv_allow;
    logic [REGION_NUM-1:0]      region_unpriv_allow;
    logic [REGION_NUM-1:0]      region_read_allow;
    logic [REGION_NUM-1:0]      region_write_allow;
    logic [REGION_NUM-1:0]      region_exec_allow;
    logic [MASTER_NUM-1:0]      master_secure_capable;
    logic [MASTER_NUM-1:0]      master_nonsecure_capable;

    always_comb begin
        global_enable             = hwif_out.GLOBAL_CTRL.global_enable.value;
        global_lock               = hwif_out.GLOBAL_LOCK.lock.value;
        irq_viol_en               = hwif_out.IRQ_ENABLE.viol_en.value;

        for (int m = 0; m < MASTER_NUM; m++) begin
            master_secure_capable[m]    = hwif_out.MASTER_ATTR[m].secure_capable.value;
            master_nonsecure_capable[m] = hwif_out.MASTER_ATTR[m].nonsecure_capable.value;
        end

        for (int r = 0; r < REGION_NUM; r++) begin
            region_enable[r]            = hwif_out.REGION[r].REGION_CONTROL.enable.value;
            region_lock[r]              = hwif_out.REGION[r].REGION_CONTROL.lock.value;
            region_base[r]              = {hwif_out.REGION[r].REGION_BASE_HI.base_hi.value,
                                           hwif_out.REGION[r].REGION_BASE_LO.base_lo.value};
            region_limit[r]             = {hwif_out.REGION[r].REGION_LIMIT_HI.limit_hi.value,
                                           hwif_out.REGION[r].REGION_LIMIT_LO.limit_lo.value};
            region_master_mask[r]       = hwif_out.REGION[r].REGION_MASTER_MASK.master_mask.value[MASTER_NUM-1:0];
            region_secure_allow[r]      = hwif_out.REGION[r].REGION_PERMISSION.secure_allow.value;
            region_nonsecure_allow[r]   = hwif_out.REGION[r].REGION_PERMISSION.nonsecure_allow.value;
            region_priv_allow[r]        = hwif_out.REGION[r].REGION_PERMISSION.priv_allow.value;
            region_unpriv_allow[r]      = hwif_out.REGION[r].REGION_PERMISSION.unpriv_allow.value;
            region_read_allow[r]        = hwif_out.REGION[r].REGION_PERMISSION.read_allow.value;
            region_write_allow[r]       = hwif_out.REGION[r].REGION_PERMISSION.write_allow.value;
            region_exec_allow[r]        = hwif_out.REGION[r].REGION_PERMISSION.exec_allow.value;
        end
    end

    // ==========================================================================
    // Read / Write path 内部信号
    // ==========================================================================
    logic [ADDR_WIDTH-1:0]  rd_pe_addr, wr_pe_addr;
    logic                   rd_pe_read, wr_pe_read;   // pe_is_read
    logic                   rd_pe_ir, wr_pe_ir;       // pe_is_instruction
    logic                   rd_pe_sec, wr_pe_sec;
    logic                   rd_pe_priv, wr_pe_priv;
    logic                   rd_pe_valid, wr_pe_valid;
    logic [15:0]            rd_pe_mid, wr_pe_mid;
    logic [7:0]             rd_pe_len, wr_pe_len;
    logic [2:0]             rd_pe_size, wr_pe_size;
    logic [1:0]             rd_pe_burst, wr_pe_burst;

    logic                   perm_allow;
    logic [3:0]             perm_reason;
    logic [15:0]            perm_region_id;

    logic                   rd_viol_valid, wr_viol_valid;
    logic                   rd_viol_read, wr_viol_read; // viol_is_read
    logic                   rd_viol_ir, wr_viol_ir;     // viol_is_instruction
    logic                   rd_viol_sec, wr_viol_sec;
    logic                   rd_viol_priv, wr_viol_priv;
    logic [15:0]            rd_viol_mid, wr_viol_mid;
    logic [7:0]             rd_viol_axid, wr_viol_axid;
    logic [ADDR_WIDTH-1:0]  rd_viol_addr, wr_viol_addr;
    logic [15:0]            rd_viol_rid, wr_viol_rid;
    logic [3:0]             rd_viol_reason, wr_viol_reason;

    logic                   read_idle, write_idle;

    // ==========================================================================
    // Permission Engine（read 优先）
    // ==========================================================================
    logic [ADDR_WIDTH-1:0]  pe_addr;
    logic                   pe_is_read, pe_is_instruction, pe_secure, pe_privileged;
    logic                   pe_req_valid;
    logic [15:0]            pe_master_id;
    logic [7:0]             pe_len;
    logic [2:0]             pe_size;
    logic [1:0]             pe_burst;

    always_comb begin
        if (rd_pe_valid) begin
            pe_addr            = rd_pe_addr;
            pe_is_read         = 1'b1;
            pe_is_instruction  = rd_pe_ir;
            pe_secure          = rd_pe_sec;
            pe_privileged      = rd_pe_priv;
            pe_master_id       = rd_pe_mid;
            pe_len             = rd_pe_len;
            pe_size            = rd_pe_size;
            pe_burst           = rd_pe_burst;
            pe_req_valid       = 1'b1;
        end else if (wr_pe_valid) begin
            pe_addr            = wr_pe_addr;
            pe_is_read         = 1'b0;
            pe_is_instruction  = 1'b0;
            pe_secure          = wr_pe_sec;
            pe_privileged      = wr_pe_priv;
            pe_master_id       = wr_pe_mid;
            pe_len             = wr_pe_len;
            pe_size            = wr_pe_size;
            pe_burst           = wr_pe_burst;
            pe_req_valid       = 1'b1;
        end else begin
            pe_addr            = '0;
            pe_is_read         = 1'b1;
            pe_is_instruction  = 1'b0;
            pe_secure          = 1'b0;
            pe_privileged      = 1'b0;
            pe_master_id       = 16'd0;
            pe_len             = 8'd0;
            pe_size            = 3'd0;
            pe_burst           = 2'd0;
            pe_req_valid       = 1'b0;
        end
    end

    axi_mpu_permission #(
        .ADDR_WIDTH      (ADDR_WIDTH),
        .MASTER_NUM      (MASTER_NUM),
        .MASTER_ID_WIDTH (MASTER_ID_WIDTH),
        .REGION_NUM      (REGION_NUM),
        .HAS_EXECUTE     (HAS_EXECUTE),
        .HAS_MASTER_ATTR (HAS_MASTER_ATTR),
        .WRAP_SUPPORT    (WRAP_SUPPORT)
    ) u_perm (
        .clk                    (clk),
        .arst_n                 (arst_n),
        .req_addr               (pe_addr),
        .req_is_read            (pe_is_read),
        .req_is_instruction     (pe_is_instruction),
        .req_secure             (pe_secure),
        .req_privileged         (pe_privileged),
        .req_master_id          (pe_master_id[MASTER_ID_WIDTH-1:0]),
        .req_len                (pe_len),
        .req_size               (pe_size),
        .req_burst              (pe_burst),
        .req_valid              (pe_req_valid),
        .region_enable          (region_enable),
        .region_base            (region_base),
        .region_limit           (region_limit),
        .region_master_mask     (region_master_mask),
        .region_secure_allow    (region_secure_allow),
        .region_nonsecure_allow (region_nonsecure_allow),
        .region_priv_allow      (region_priv_allow),
        .region_unpriv_allow    (region_unpriv_allow),
        .region_read_allow      (region_read_allow),
        .region_write_allow     (region_write_allow),
        .region_exec_allow      (region_exec_allow),
        .master_secure_capable  (master_secure_capable),
        .master_nonsecure_capable (master_nonsecure_capable),
        .perm_allow             (perm_allow),
        .perm_reason            (perm_reason),
        .perm_region_id         (perm_region_id)
    );

    // ==========================================================================
    // Read Path 实例化
    // ==========================================================================
    axi_mpu_read #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_read (
        .clk               (clk),
        .arst_n            (arst_n),
        .s_axi_arid        (s_axi_arid),
        .s_axi_araddr      (s_axi_araddr),
        .s_axi_arlen       (s_axi_arlen),
        .s_axi_arsize      (s_axi_arsize),
        .s_axi_arburst     (s_axi_arburst),
        .s_axi_arprot      (s_axi_arprot),
        .s_axi_arvalid     (s_axi_arvalid),
        .s_axi_arready     (s_axi_arready),
        .s_axi_rid         (s_axi_rid),
        .s_axi_rdata       (s_axi_rdata),
        .s_axi_rresp       (s_axi_rresp),
        .s_axi_rlast       (s_axi_rlast),
        .s_axi_rvalid      (s_axi_rvalid),
        .s_axi_rready      (s_axi_rready),
        .m_axi_arid        (m_axi_arid),
        .m_axi_araddr      (m_axi_araddr),
        .m_axi_arlen       (m_axi_arlen),
        .m_axi_arsize      (m_axi_arsize),
        .m_axi_arburst     (m_axi_arburst),
        .m_axi_arprot      (m_axi_arprot),
        .m_axi_arvalid     (m_axi_arvalid),
        .m_axi_arready     (m_axi_arready),
        .m_axi_rid         (m_axi_rid),
        .m_axi_rdata       (m_axi_rdata),
        .m_axi_rresp       (m_axi_rresp),
        .m_axi_rlast       (m_axi_rlast),
        .m_axi_rvalid      (m_axi_rvalid),
        .m_axi_rready      (m_axi_rready),
        .pe_addr           (rd_pe_addr),
        .pe_is_read        (rd_pe_read),
        .pe_is_instruction (rd_pe_ir),
        .pe_secure         (rd_pe_sec),
        .pe_privileged     (rd_pe_priv),
        .pe_master_id      (rd_pe_mid),
        .pe_len            (rd_pe_len),
        .pe_size           (rd_pe_size),
        .pe_burst          (rd_pe_burst),
        .pe_req_valid      (rd_pe_valid),
        .perm_allow        (perm_allow),
        .perm_reason       (perm_reason),
        .perm_region_id    (perm_region_id),
        .viol_valid        (rd_viol_valid),
        .viol_is_read      (rd_viol_read),
        .viol_is_instruction (rd_viol_ir),
        .viol_secure       (rd_viol_sec),
        .viol_privileged   (rd_viol_priv),
        .viol_master_id    (rd_viol_mid),
        .viol_axi_id       (rd_viol_axid),
        .viol_addr         (rd_viol_addr),
        .viol_region_id    (rd_viol_rid),
        .viol_reason       (rd_viol_reason),
        .read_idle         (read_idle),
        .master_id_sideband(s_axi_ar_master_id)
    );

    // ==========================================================================
    // Write Path 实例化
    // ==========================================================================
    axi_mpu_write #(
        .ADDR_WIDTH        (ADDR_WIDTH),
        .DATA_WIDTH        (DATA_WIDTH),
        .ID_WIDTH          (ID_WIDTH),
        .WRITE_OUTSTANDING (WRITE_OUTSTANDING),
        .MASTER_ID_WIDTH   (MASTER_ID_WIDTH)
    ) u_write (
        .clk               (clk),
        .arst_n            (arst_n),
        .s_axi_awid        (s_axi_awid),
        .s_axi_awaddr      (s_axi_awaddr),
        .s_axi_awlen       (s_axi_awlen),
        .s_axi_awsize      (s_axi_awsize),
        .s_axi_awburst     (s_axi_awburst),
        .s_axi_awprot      (s_axi_awprot),
        .s_axi_awvalid     (s_axi_awvalid),
        .s_axi_awready     (s_axi_awready),
        .s_axi_wid         (s_axi_wid),
        .s_axi_wdata       (s_axi_wdata),
        .s_axi_wstrb       (s_axi_wstrb),
        .s_axi_wlast       (s_axi_wlast),
        .s_axi_wvalid      (s_axi_wvalid),
        .s_axi_wready      (s_axi_wready),
        .s_axi_bid         (s_axi_bid),
        .s_axi_bresp       (s_axi_bresp),
        .s_axi_bvalid      (s_axi_bvalid),
        .s_axi_bready      (s_axi_bready),
        .m_axi_awid        (m_axi_awid),
        .m_axi_awaddr      (m_axi_awaddr),
        .m_axi_awlen       (m_axi_awlen),
        .m_axi_awsize      (m_axi_awsize),
        .m_axi_awburst     (m_axi_awburst),
        .m_axi_awprot      (m_axi_awprot),
        .m_axi_awvalid     (m_axi_awvalid),
        .m_axi_awready     (m_axi_awready),
        .m_axi_wid         (m_axi_wid),
        .m_axi_wdata       (m_axi_wdata),
        .m_axi_wstrb       (m_axi_wstrb),
        .m_axi_wlast       (m_axi_wlast),
        .m_axi_wvalid      (m_axi_wvalid),
        .m_axi_wready      (m_axi_wready),
        .m_axi_bid         (m_axi_bid),
        .m_axi_bresp       (m_axi_bresp),
        .m_axi_bvalid      (m_axi_bvalid),
        .m_axi_bready      (m_axi_bready),
        .pe_addr           (wr_pe_addr),
        .pe_is_read        (wr_pe_read),
        .pe_is_instruction (wr_pe_ir),
        .pe_secure         (wr_pe_sec),
        .pe_privileged     (wr_pe_priv),
        .pe_master_id      (wr_pe_mid),
        .pe_len            (wr_pe_len),
        .pe_size           (wr_pe_size),
        .pe_burst          (wr_pe_burst),
        .pe_req_valid      (wr_pe_valid),
        .perm_allow        (perm_allow),
        .perm_reason       (perm_reason),
        .perm_region_id    (perm_region_id),
        .viol_valid        (wr_viol_valid),
        .viol_is_read      (wr_viol_read),
        .viol_is_instruction (wr_viol_ir),
        .viol_secure       (wr_viol_sec),
        .viol_privileged   (wr_viol_priv),
        .viol_master_id    (wr_viol_mid),
        .viol_axi_id       (wr_viol_axid),
        .viol_addr         (wr_viol_addr),
        .viol_region_id    (wr_viol_rid),
        .viol_reason       (wr_viol_reason),
        .write_idle        (write_idle),
        .aw_master_id_sideband (s_axi_aw_master_id)
    );

    // ==========================================================================
    // Violation Capture（驱动 CSR hwif_in）
    // ==========================================================================
    logic viol_capture;
    logic viol_secure, viol_privileged, viol_instruction, viol_read;
    logic [15:0] viol_master_id;
    logic [7:0]  viol_axi_id;
    logic [ADDR_WIDTH-1:0] viol_addr;
    logic [15:0] viol_region_id;
    logic [3:0]  viol_reason;

    assign viol_capture   = rd_viol_valid | wr_viol_valid;
    assign viol_read      = rd_viol_valid ? rd_viol_read : wr_viol_read;
    assign viol_instruction = rd_viol_valid ? rd_viol_ir : wr_viol_ir;
    assign viol_secure    = rd_viol_valid ? rd_viol_sec : wr_viol_sec;
    assign viol_privileged= rd_viol_valid ? rd_viol_priv : wr_viol_priv;
    assign viol_master_id = rd_viol_valid ? rd_viol_mid : wr_viol_mid;
    assign viol_axi_id    = rd_viol_valid ? rd_viol_axid : wr_viol_axid;
    assign viol_addr      = rd_viol_valid ? rd_viol_addr : wr_viol_addr;
    assign viol_region_id = rd_viol_valid ? rd_viol_rid : wr_viol_rid;
    assign viol_reason    = rd_viol_valid ? rd_viol_reason : wr_viol_reason;

    // 配置写使能 gate（lock 抑制写）：任一 REGION_LOCK[r] 或 GLOBAL_LOCK 置位时
    // 对应 REGION[r] 的 BASE/LIMIT/MASK/PERM SW 写被抑制（SystemRDL swwe）。
    // cfg_swwe 为标量 gate：任意 region lock 置位即抑制全部 region 配置写
    //（与 GLOBAL_LOCK 等效的全局冻结语义；区域级细粒度由 lock 字段位置记录）。
    always_comb begin
        hwif_in.cfg_swwe = !(global_lock | (|region_lock));
    end

    // FIRST_ERROR_STICKY：首错属性/地址/信息锁存一次，直到 SW 清除 VIOL_STATUS/IRQ。
    // viol_latched 在 valid 未清（sticky=1）期间保持；IRQ W1C 亦保持 addr 快照。
    logic viol_latched;
    logic viol_valid_now;
    assign viol_valid_now = hwif_out.VIOL_STATUS.valid.value;
    always_ff @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            viol_latched <= 1'b0;
        end else if (viol_capture && !viol_latched) begin
            viol_latched <= 1'b1;
        end else if (!viol_valid_now && !viol_capture) begin
            viol_latched <= 1'b0;  // SW W1C 清除后允许重新捕获首错
        end
    end

    logic viol_first;
    assign viol_first = viol_capture & ~viol_latched;

    assign hwif_in.VIOL_STATUS.valid.hwset            = viol_first;
    assign hwif_in.IRQ_STATUS.viol_sticky.hwset       = viol_capture;
    assign hwif_in.VIOL_STATUS.read.hwset             = viol_first & viol_read;
    assign hwif_in.VIOL_STATUS.write.hwset            = viol_first & ~viol_read;
    assign hwif_in.VIOL_STATUS.instruction.hwset      = viol_first & viol_instruction;
    assign hwif_in.VIOL_STATUS.secure.hwset           = viol_first & viol_secure;
    assign hwif_in.VIOL_STATUS.privileged.hwset       = viol_first & viol_privileged;
    assign hwif_in.VIOL_ADDR_LO.addr_lo.we            = viol_first;
    assign hwif_in.VIOL_ADDR_HI.addr_hi.we            = viol_first;
    assign hwif_in.VIOL_ADDR_LO.addr_lo.next          = viol_addr[31:0];
    assign hwif_in.VIOL_ADDR_HI.addr_hi.next          = viol_addr[ADDR_WIDTH-1:32];
    assign hwif_in.VIOL_INFO0.master_id.we            = viol_first;
    assign hwif_in.VIOL_INFO0.axi_id.we               = viol_first;
    assign hwif_in.VIOL_INFO0.region_id.we            = viol_first;
    assign hwif_in.VIOL_INFO0.reason.we               = viol_first;
    assign hwif_in.VIOL_INFO0.master_id.next          = viol_master_id[7:0];
    assign hwif_in.VIOL_INFO0.axi_id.next             = viol_axi_id;
    assign hwif_in.VIOL_INFO0.region_id.next          = viol_region_id[7:0];
    assign hwif_in.VIOL_INFO0.reason.next             = {4'b0, viol_reason};
    assign hwif_in.VIOL_COUNT.count.incr              = viol_capture;

    // ==========================================================================
    // IRQ
    // ==========================================================================
    assign irq = (irq_viol_en && hwif_out.IRQ_STATUS.viol_sticky.value);

endmodule
