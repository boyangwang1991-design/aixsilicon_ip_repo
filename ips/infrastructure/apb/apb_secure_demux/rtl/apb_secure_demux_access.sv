// Implements LLD.MOD.APB_SECURE_DEMUX.ACCESS. SETUP combinational admission.
module apb_secure_demux_access #(
    parameter int unsigned NUM_PORTS = 8,
    parameter int unsigned NUM_MASTERS = 16,
    parameter int unsigned MASTER_ID_WIDTH = 4,
    parameter bit DFX_EN = 1'b1,
    localparam int unsigned PORT_W = (NUM_PORTS > 1) ? $clog2(NUM_PORTS) : 1
) (
    input logic setup_valid_i,
    input logic [7:0] decode_reason_i,
    input logic port_valid_i,
    input logic [PORT_W-1:0] port_i,
    input logic [MASTER_ID_WIDTH-1:0] master_id_i,
    input logic master_valid_i,
    input logic [2:0] prot_i,
    input logic write_i,
    input logic [1:0] active_cfg_i [NUM_PORTS],
    input logic [7:0] active_perm_i [NUM_PORTS][NUM_MASTERS],
    input logic raw_bad_i,
    input logic fatal_i,
    input logic dfx_authorized_i,
    input logic dfx_match_i,
    input logic dfx_deny_armed_i,
    input logic dfx_integrity_armed_i,
    output logic natural_allow_o,
    output logic allow_o,
    output logic [7:0] reason_o,
    output logic test_o,
    output logic consume_o,
    output logic synthetic_integrity_o
);
    logic [7:0] permission;
    logic [1:0] cfg;
    logic identity_ok;
    logic [2:0] permission_bit;
    assign identity_ok = master_valid_i &&
        ({1'b0,master_id_i} < (MASTER_ID_WIDTH+1)'(NUM_MASTERS));
    assign permission_bit = {write_i,prot_i[1:0]};
    always_comb begin
        permission = '0;
        cfg = '0;
        // Never index with a truncated or invalid identity/target.
        if (port_valid_i && (int'(port_i) < NUM_PORTS)) begin
            cfg = active_cfg_i[port_i];
            if (identity_ok) permission = active_perm_i[port_i][master_id_i];
        end
        reason_o = decode_reason_i;
        natural_allow_o = 1'b0;
        allow_o = 1'b0;
        test_o = 1'b0;
        consume_o = 1'b0;
        synthetic_integrity_o = 1'b0;
        if ((decode_reason_i == 8'h00) && port_valid_i) begin
            if (!identity_ok) reason_o = 8'h03;
            else if (fatal_i || raw_bad_i) reason_o = 8'h04;
            else if (!cfg[0]) reason_o = 8'h05;
            else if (prot_i[2] && (write_i || !cfg[1])) reason_o = 8'h06;
            else if (!permission[permission_bit]) reason_o = write_i ? 8'h08 : 8'h07;
            else natural_allow_o = 1'b1;
        end
        allow_o = natural_allow_o;
        if (DFX_EN && natural_allow_o && dfx_authorized_i && dfx_match_i &&
            (dfx_deny_armed_i || dfx_integrity_armed_i)) begin
            allow_o = 1'b0;
            test_o = 1'b1;
            reason_o = dfx_integrity_armed_i ? 8'h04 : 8'h41;
            consume_o = setup_valid_i;
            synthetic_integrity_o = setup_valid_i && dfx_integrity_armed_i;
        end
    end
endmodule
