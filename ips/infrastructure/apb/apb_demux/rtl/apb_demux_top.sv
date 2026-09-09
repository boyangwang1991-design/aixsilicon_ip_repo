// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 AIXSILICON
//
// apb_demux_top.sv — APB Demux (1-to-N APB Router)
//
// 将 1 个上游 APB Slave-facing 接口按地址空间路由至 N 个下游 APB
// Master-facing 接口。支持：
//   - 参数化 NUM_SLAVES / ADDR_WIDTH / DATA_WIDTH
//   - 每端口独立 BASE_ADDR / ADDR_MASK 地址窗口
//   - APB3 / APB4（APB_PROFILE 参数裁剪 PSTRB/PPROT 通路）
//   - 组合地址译码 + PSEL one-hot 生成
//   - 请求信号 fanout + 响应 one-hot mux
//   - Decode Miss 立即错误响应（PREADY=1, PSLVERR=1, PRDATA=0）
//   - PSLVERR 透传
//   - 可选静态地址 remap（ADDR_REMAP_ENABLE）
//   - 可选 transaction timeout（TIMEOUT_ENABLE/TIMEOUT_CYCLES）
//   - 可选 response register（OUTPUT_REGISTER）
//
// 单时钟域（PCLK），单一复位（PRESETn，低有效）。
// 本文件为唯一 RTL 交付物（LLD RTL_MAP 单模块决策）。

module apb_demux_top #(
    parameter int NUM_SLAVES    = 4,
    parameter int ADDR_WIDTH    = 32,
    parameter int DATA_WIDTH    = 32,
    parameter bit APB_PROFILE   = 1,               // 1=APB4, 0=APB3
    parameter bit ADDR_REMAP_ENABLE = 1'b0,
    parameter bit TIMEOUT_ENABLE = 1'b0,
    parameter int TIMEOUT_CYCLES = 16,
    parameter bit OUTPUT_REGISTER = 1'b0,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR [NUM_SLAVES] = '{default: '0},
    parameter logic [ADDR_WIDTH-1:0] ADDR_MASK  [NUM_SLAVES] = '{default: '0}
) (
    input  logic                      pclk,
    input  logic                      presetn,

    // 上游 APB Slave-facing
    input  logic [ADDR_WIDTH-1:0]     paddr,
    input  logic                      psel,
    input  logic                      penable,
    input  logic                      pwrite,
    input  logic [DATA_WIDTH-1:0]     pwdata,
    input  logic [DATA_WIDTH/8-1:0]   pstrb,
    input  logic [2:0]                pprot,
    output logic [DATA_WIDTH-1:0]     prdata,
    output logic                      pready,
    output logic                      pslverr,

    // 下游 APB Master-facing
    output logic [ADDR_WIDTH-1:0]     m_paddr  [NUM_SLAVES],
    output logic                      m_psel   [NUM_SLAVES],
    output logic                      m_penable[NUM_SLAVES],
    output logic                      m_pwrite [NUM_SLAVES],
    output logic [DATA_WIDTH-1:0]     m_pwdata [NUM_SLAVES],
    output logic [DATA_WIDTH/8-1:0]   m_pstrb  [NUM_SLAVES],
    output logic [2:0]                m_pprot  [NUM_SLAVES],
    input  logic [DATA_WIDTH-1:0]     m_prdata [NUM_SLAVES],
    input  logic                      m_pready [NUM_SLAVES],
    input  logic                      m_pslverr[NUM_SLAVES]
);

    // 内部信号
    logic [NUM_SLAVES-1:0] hit;
    logic [NUM_SLAVES-1:0] sel;          // M_PSEL 内部
    logic sel_any;
    logic decode_miss;

    // 可选 timeout
    localparam int TOUT_W = TIMEOUT_CYCLES > 0 ? $clog2(TIMEOUT_CYCLES + 1) : 1;
    logic [TOUT_W-1:0] timeout_cnt;
    logic timeout_active;
    logic timeout_expired;

    // 1. 地址译码：hit[i] = (PADDR & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])
    always_comb begin
        for (int i = 0; i < NUM_SLAVES; i++) begin
            hit[i] = (paddr & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i]);
        end
    end

    // 2. PSEL one-hot 生成
    always_comb begin
        for (int i = 0; i < NUM_SLAVES; i++) begin
            sel[i] = psel & hit[i];
        end
    end

    assign sel_any     = |sel;
    assign decode_miss = psel & ~(|hit);

    // 3. 请求 fanout（广播 + 可选 remap）
    always_comb begin
        for (int i = 0; i < NUM_SLAVES; i++) begin
            if (ADDR_REMAP_ENABLE) begin
                m_paddr[i] = paddr - BASE_ADDR[i];
            end else begin
                m_paddr[i] = paddr;
            end
            m_psel[i]    = sel[i];
            m_penable[i] = penable;
            m_pwrite[i]  = pwrite;
            m_pwdata[i]  = pwdata;
            if (APB_PROFILE) begin
                m_pstrb[i] = pstrb;
                m_pprot[i] = pprot;
            end else begin
                m_pstrb[i] = '0;
                m_pprot[i] = '0;
            end
        end
    end

    // 4. 响应 mux（one-hot）—— 选中端口响应
    logic [DATA_WIDTH-1:0] resp_data_sel;
    logic resp_ready_sel;
    logic resp_err_sel;
    always_comb begin
        resp_data_sel  = '0;
        resp_ready_sel = 1'b0;
        resp_err_sel   = 1'b0;
        for (int i = 0; i < NUM_SLAVES; i++) begin
            if (sel[i]) begin
                resp_data_sel  = m_prdata[i];
                resp_ready_sel = m_pready[i];
                resp_err_sel   = m_pslverr[i];
            end
        end
    end

    // 5. Timeout 控制信号
    assign timeout_active  = TIMEOUT_ENABLE & sel_any & penable & ~resp_ready_sel & ~decode_miss;
    assign timeout_expired = TIMEOUT_ENABLE & timeout_active & (timeout_cnt >= TIMEOUT_CYCLES[TOUT_W-1:0]);

    // 6. 组合响应：默认选中端口；Decode Miss 立即错误；未选中保持推进；超时终止
    logic [DATA_WIDTH-1:0] prdata_c;
    logic pready_c;
    logic pslverr_c;
    always_comb begin
        prdata_c  = resp_data_sel;
        pready_c  = resp_ready_sel;
        pslverr_c = resp_err_sel;

        if (timeout_expired) begin
            prdata_c  = '0;
            pready_c  = 1'b1;
            pslverr_c = 1'b1;
        end else if (decode_miss) begin
            prdata_c  = '0;
            pready_c  = 1'b1;
            pslverr_c = 1'b1;
        end

        if (~psel) begin
            prdata_c  = '0;
            pready_c  = 1'b1;
            pslverr_c = 1'b0;
        end
    end

    // 7. Timeout counter（仅 TIMEOUT_ENABLE=1 时实现）
    generate
        if (TIMEOUT_ENABLE) begin : g_timeout
            always_ff @(posedge pclk or negedge presetn) begin
                if (!presetn) begin
                    timeout_cnt <= '0;
                end else if (timeout_active) begin
                    timeout_cnt <= timeout_cnt + 1'b1;
                end else begin
                    timeout_cnt <= '0;
                end
            end
        end else begin : g_no_timeout
            // 无 timeout 时不引入有效逻辑
        end
    endgenerate

    // 8. Response Register（可选）或组合直通
    generate
        if (OUTPUT_REGISTER) begin : g_out_reg
            logic [DATA_WIDTH-1:0] prdata_r;
            logic pready_r;
            logic pslverr_r;
            always_ff @(posedge pclk or negedge presetn) begin
                if (!presetn) begin
                    prdata_r  <= '0;
                    pready_r  <= 1'b1;
                    pslverr_r <= 1'b0;
                end else begin
                    prdata_r  <= prdata_c;
                    pready_r  <= pready_c;
                    pslverr_r <= pslverr_c;
                end
            end
            assign prdata  = prdata_r;
            assign pready  = pready_r;
            assign pslverr = pslverr_r;
        end else begin : g_no_out_reg
            assign prdata  = prdata_c;
            assign pready  = pready_c;
            assign pslverr = pslverr_c;
        end
    endgenerate

endmodule
