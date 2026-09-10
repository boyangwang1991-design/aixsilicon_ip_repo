// ============================================================================
// AXI MPU - Virtual Interface Bundle (S_AXI / M_AXI / APB4 / IRQ)
// ============================================================================
// 供 UVM env / testcase 通过 uvm_config_db 使用。DUT 端口与 RTL axi_mpu 对齐。
// ============================================================================

interface axi_mpu_if #(
    parameter int ADDR_WIDTH      = 48,
    parameter int DATA_WIDTH      = 128,
    parameter int ID_WIDTH        = 8,
    parameter int MASTER_ID_WIDTH = 4
) (input logic clk);
    // arst_n 为接口内部变量：harness 与 testcase 均以 procedural 驱动
    //（默认复位序列在 harness，TC 级复位控制在 tc_reset/config_lock 等）。
    logic arst_n;

    // ---- S_AXI (upstream master -> DUT slave) ----
    logic [ID_WIDTH-1:0]      s_axi_arid;
    logic [ADDR_WIDTH-1:0]    s_axi_araddr;
    logic [7:0]               s_axi_arlen;
    logic [2:0]               s_axi_arsize;
    logic [1:0]               s_axi_arburst;
    logic [2:0]               s_axi_arprot;
    logic                     s_axi_arvalid;
    logic                     s_axi_arready;
    logic [ID_WIDTH-1:0]      s_axi_rid;
    logic [DATA_WIDTH-1:0]    s_axi_rdata;
    logic [1:0]               s_axi_rresp;
    logic                     s_axi_rlast;
    logic                     s_axi_rvalid;
    logic                     s_axi_rready;

    logic [ID_WIDTH-1:0]      s_axi_awid;
    logic [ADDR_WIDTH-1:0]    s_axi_awaddr;
    logic [7:0]               s_axi_awlen;
    logic [2:0]               s_axi_awsize;
    logic [1:0]               s_axi_awburst;
    logic [2:0]               s_axi_awprot;
    logic                     s_axi_awvalid;
    logic                     s_axi_awready;
    logic [ID_WIDTH-1:0]      s_axi_wid;
    logic [DATA_WIDTH-1:0]    s_axi_wdata;
    logic [DATA_WIDTH/8-1:0]  s_axi_wstrb;
    logic                     s_axi_wlast;
    logic                     s_axi_wvalid;
    logic                     s_axi_wready;
    logic [ID_WIDTH-1:0]      s_axi_bid;
    logic [1:0]               s_axi_bresp;
    logic                     s_axi_bvalid;
    logic                     s_axi_bready;

    // ---- M_AXI (DUT master -> protected slave) ----
    logic [ID_WIDTH-1:0]      m_axi_arid;
    logic [ADDR_WIDTH-1:0]    m_axi_araddr;
    logic [7:0]               m_axi_arlen;
    logic [2:0]               m_axi_arsize;
    logic [1:0]               m_axi_arburst;
    logic [2:0]               m_axi_arprot;
    logic                     m_axi_arvalid;
    logic                     m_axi_arready;
    logic [ID_WIDTH-1:0]      m_axi_rid;
    logic [DATA_WIDTH-1:0]    m_axi_rdata;
    logic [1:0]               m_axi_rresp;
    logic                     m_axi_rlast;
    logic                     m_axi_rvalid;
    logic                     m_axi_rready;

    logic [ID_WIDTH-1:0]      m_axi_awid;
    logic [ADDR_WIDTH-1:0]    m_axi_awaddr;
    logic [7:0]               m_axi_awlen;
    logic [2:0]               m_axi_awsize;
    logic [1:0]               m_axi_awburst;
    logic [2:0]               m_axi_awprot;
    logic                     m_axi_awvalid;
    logic                     m_axi_awready;
    logic [ID_WIDTH-1:0]      m_axi_wid;
    logic [DATA_WIDTH-1:0]    m_axi_wdata;
    logic [DATA_WIDTH/8-1:0]  m_axi_wstrb;
    logic                     m_axi_wlast;
    logic                     m_axi_wvalid;
    logic                     m_axi_wready;
    logic [ID_WIDTH-1:0]      m_axi_bid;
    logic [1:0]               m_axi_bresp;
    logic                     m_axi_bvalid;
    logic                     m_axi_bready;

    // ---- APB4 ----
    logic                     s_apb_psel;
    logic                     s_apb_penable;
    logic                     s_apb_pwrite;
    logic [2:0]               s_apb_pprot;
    logic [ADDR_WIDTH-1:0]    s_apb_paddr;
    logic [31:0]              s_apb_pwdata;
    logic [3:0]               s_apb_pstrb;
    logic                     s_apb_pready;
    logic [31:0]              s_apb_prdata;
    logic                     s_apb_pslverr;

    // ---- Master identity sideband / IRQ ----
    logic [MASTER_ID_WIDTH-1:0] s_axi_ar_master_id;
    logic [MASTER_ID_WIDTH-1:0] s_axi_aw_master_id;
    logic                       irq;

    // 组合断言钩子（verification-only，不参与 DUT 行为）
    // Denied AR/AW shall never reach M_AXI（由 checker/assertion 消费）

endinterface
