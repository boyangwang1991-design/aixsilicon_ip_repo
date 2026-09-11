`timescale 1ns/1ps
module ut_apb_secure_demux_access;
    logic setup_valid=1;
    logic [7:0] decode_reason=0;
    logic port_valid=1;
    logic [1:0] port=1;
    logic [15:0] master_id=0;
    logic master_valid=1;
    logic [2:0] prot=0;
    logic wr=0;
    logic [1:0] cfg[3];
    logic [7:0] perm[3][3];
    logic raw_bad=0,fatal=0,auth=0,match_target=0,deny_arm=0,int_arm=0;
    wire natural_allow,allow_access,test_flag,consume,synthetic;
    wire [7:0] reason;
    int errors=0,checks=0;
    logic [7:0] expected;
    apb_secure_demux_access #(.NUM_PORTS(3),.NUM_MASTERS(3),.MASTER_ID_WIDTH(16)) dut (
        .setup_valid_i(setup_valid),.decode_reason_i(decode_reason),.port_valid_i(port_valid),.port_i(port),
        .master_id_i(master_id),.master_valid_i(master_valid),.prot_i(prot),.write_i(wr),
        .active_cfg_i(cfg),.active_perm_i(perm),.raw_bad_i(raw_bad),.fatal_i(fatal),
        .dfx_authorized_i(auth),.dfx_match_i(match_target),.dfx_deny_armed_i(deny_arm),
        .dfx_integrity_armed_i(int_arm),.natural_allow_o(natural_allow),.allow_o(allow_access),
        .reason_o(reason),.test_o(test_flag),.consume_o(consume),.synthetic_integrity_o(synthetic));
    task automatic check(input bit ok);
        checks++; if(!ok) begin errors++; if(errors<10) $display("access mismatch id=%h cfg=%h perm=%h prot=%h write=%b reason=%h expected=%h",master_id,cfg[1],perm[1][0],prot,wr,reason,expected); end
    endtask
    initial begin
        for(int p=0;p<3;p++) begin cfg[p]=3; for(int m=0;m<3;m++) perm[p][m]=8'hff; end
        for(int id=0;id<65536;id++) begin
            master_id=16'(id); #1;
            check((id<3) ? (allow_access && reason==0) : (!allow_access && reason==3));
        end
        master_id=0;
        for(int c=0;c<4;c++) for(int bits=0;bits<256;bits++) for(int attr=0;attr<8;attr++) for(int w=0;w<2;w++) begin
            cfg[1]=2'(c); perm[1][0]=8'(bits); prot=3'(attr); wr=1'(w);
            expected=0;
            if((c%2)==0) expected=5;
            else if(attr>=4 && (w==1 || c<2)) expected=6;
            else if((bits & (1 << ((attr%4)+(4*w))))==0) expected=(w==1)?8:7;
            #1; check(reason===expected && allow_access===(expected==0));
        end
        cfg[1]=3;perm[1][0]=8'hff;prot=0;wr=0;
        auth=1;match_target=1;deny_arm=1; #1;check(natural_allow && !allow_access && reason==8'h41 && test_flag && consume && !synthetic);
        auth=0; #1;check(allow_access && !test_flag && !consume);
        auth=1;raw_bad=1; #1;check(reason==4 && !natural_allow && !consume);
        master_valid=0; #1;check(reason==3 && !consume);
        decode_reason=2; #1;check(reason==2 && !consume);
        decode_reason=1; #1;check(reason==1 && !consume);
        decode_reason=0;master_valid=1;raw_bad=0;deny_arm=0;int_arm=1; #1;
        check(reason==4 && test_flag && consume && synthetic);
        setup_valid=0; #1;check(!consume && !synthetic);
        int_arm=0;port_valid=0; #1;check(!allow_access && !consume && reason==0);
        if(errors) $fatal(1,"UT_APB_SECURE_DEMUX_ACCESS: FAIL (errors=%0d)",errors);
        $display("UT_APB_SECURE_DEMUX_ACCESS: METRICS (errors=0 checks=%0d)",checks);$display("UT_APB_SECURE_DEMUX_ACCESS: PASS (errors=0)");$finish;
    end
    initial begin #100000; $fatal(1,"access timeout"); end
endmodule
