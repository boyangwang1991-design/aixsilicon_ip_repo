// ============================================================================
// AXI MPU - 顶层定义头文件（可综合）
// 包含：参数、常量、deny_reason 编码、Request Context 类型
// ============================================================================

// ----------------------------------------------------------------------------
// 参数默认值（Generator 默认配置基线 CFG_MAIN）
// ----------------------------------------------------------------------------
`ifndef AXI_MPU_DEFS_SVH
`define AXI_MPU_DEFS_SVH

// 默认参数（可被实例化覆盖）
`define AXI_MPU_ADDR_WIDTH_DEFAULT     48
`define AXI_MPU_DATA_WIDTH_DEFAULT     128
`define AXI_MPU_ID_WIDTH_DEFAULT       8
`define AXI_MPU_MASTER_NUM_DEFAULT     8
`define AXI_MPU_MASTER_ID_WIDTH_DEFAULT 4
`define AXI_MPU_REGION_NUM_DEFAULT     16
`define AXI_MPU_READ_OUTSTANDING_DEFAULT 8
`define AXI_MPU_WRITE_OUTSTANDING_DEFAULT 8
`define AXI_MPU_HAS_EXECUTE_DEFAULT    1
`define AXI_MPU_HAS_MASTER_ATTR_DEFAULT 1
`define AXI_MPU_HAS_IRQ_DEFAULT        1
`define AXI_MPU_HAS_VIOLATION_LOG_DEFAULT 1
`define AXI_MPU_PIPELINE_DEFAULT       0
`define AXI_MPU_WRAP_SUPPORT_DEFAULT   1

// ----------------------------------------------------------------------------
// deny_reason 编码（对应 contract §18）
// ----------------------------------------------------------------------------
typedef enum logic [3:0] {
    DENY_NONE                 = 4'd0,
    DENY_NO_REGION            = 4'd1,
    DENY_MASTER               = 4'd2,
    DENY_MASTER_SECURITY      = 4'd3,
    DENY_SECURITY             = 4'd4,
    DENY_PRIVILEGE            = 4'd5,
    DENY_READ                 = 4'd6,
    DENY_WRITE                = 4'd7,
    DENY_EXECUTE              = 4'd8,
    DENY_BURST_BOUNDARY       = 4'd9,
    DENY_INVALID_CONTEXT      = 4'd10
} axi_mpu_deny_reason_t;

// ----------------------------------------------------------------------------
// Request Context
// ----------------------------------------------------------------------------
typedef struct packed {
    logic [63:0]                address;       // 完整地址（最大 64 位）
    logic                       read_write;    // 1=read, 0=write
    logic [7:0]                 axi_id;        // AXI ID
    logic [15:0]                master_id;     // Master identity
    logic                       secure;
    logic                       privileged;
    logic                       instruction;
    logic [1:0]                 burst_type;    // AXI_BURST
    logic [7:0]                 burst_len;     // AWLEN/ARLEN
    logic [3:0]                 burst_size;    // AWSIZE/ARSIZE
    logic [63:0]                burst_start;
    logic [63:0]                burst_end;
} axi_mpu_req_ctx_t;

// ----------------------------------------------------------------------------
// 权限判定结果
// ----------------------------------------------------------------------------
typedef struct packed {
    logic                       allow;
    axi_mpu_deny_reason_t       reason;
    logic [15:0]                region_id;     // selected region (or all-ones if none)
} axi_mpu_perm_result_t;

`endif // AXI_MPU_DEFS_SVH
