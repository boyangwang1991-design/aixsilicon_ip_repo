package watchdog_pkg;
  localparam logic [31:0] KEY1=32'ha5c35a3c, KEY2=32'h5a3ca5c3;
  localparam logic [31:0] UNLOCK1=32'hc0de1234, UNLOCK2=32'h3f21edcb;
  localparam int DISABLED=0, BOOT=1, RUN=2, PAUSED_STATE=3, FAULT=4, RESET_PENDING=5;
  localparam logic [7:0] OK=0, BUSY=1, ACCESS_DENIED=2, BAD_STATE=3,
    BAD_CONFIG=4, LOCKED=5, UNSUPPORTED=6, BAD_SERVICE=7, PAUSED=8,
    CANCELED_RESET=9, CANCELED_FAULT=10, PENDING_APPLY=11, BAD_CLIENT=12,
    EPOCH_BOUNDARY=13, EXPIRED_UNLOCK=14, NO_PENDING=15;
  // Command opcodes 1..5 are software COMMAND payloads. Other mailbox opcodes
  // use their byte offsets; DONE_INFO carries the actual operation, not address.
  localparam logic [7:0] COMMIT=1, START=2, STOP=3, CANCEL=4, SNAPSHOT=5,
    UNLOCK=8'h40, LOCK_SET=8'h48, SERVICE=8'h50, IRQ_ENABLE=8'h54,
    IRQ_CLEAR=8'h58, IRQ_TEST=8'h5c, DIAG_CLEAR=8'h60, INJECT=8'h64;
  localparam logic [31:0] REQUIRED_POLICY=32'h3c2, DEFAULT_POLICY=32'h3de;
  localparam logic [31:0] FATAL_MASK=32'h37800;
  typedef struct packed {
    logic [31:0][6:0][31:0] client;
    logic [15:0][31:0] word;
  } config_t;
  typedef struct packed {
    logic [31:0][15:0][31:0] client;
    logic [111:0][31:0] word;
  } snapshot_t;
  typedef struct packed {
    logic [3:0] channel;
    logic [4:0] client;
    logic [2:0] event_type;
    logic [7:0] opcode;
    logic [31:0] data, seq;
    logic [15:0] source;
    logic cfg_auth, service_auth, diag_auth, hardware;
  } command_t;
  function automatic config_t default_config();
    config_t c;
    c='0;
    c.word[0]=32'hc; // BOOT and DUAL_KEY; time units are WDT ticks.
    c.word[4]=32'd65536;
    c.word[8]=32'd65536;
    c.word[10]=32'd256;
    c.word[11]=1;
    c.word[12]=DEFAULT_POLICY;
    return c;
  endfunction
  function automatic logic [31:0] sat32(input logic [31:0] x);
    return (&x) ? x : x+1'b1;
  endfunction
  function automatic logic [31:0] seed(input int ch, cl);
    logic [31:0] x;
    x=32'h1d872b41 ^ (32'(ch)<<8) ^ 32'(cl);
    return (x==0) ? 32'd1 : x;
  endfunction
  function automatic logic [31:0] next_token(input logic [31:0] x);
    return (x>>1) ^ (x[0] ? 32'h80200003 : 32'b0);
  endfunction
  function automatic logic [31:0] response(input logic [31:0] x, input int ch, cl);
    return {x[24:0],x[31:25]} ^ 32'h6d2b79f5 ^ (32'(ch)<<8) ^ 32'(cl);
  endfunction
  function automatic logic [7:0] primary_cause(input logic [31:0] e);
    if(e[11]) return 11; if(e[12]) return 12; if(e[13]) return 13;
    if(e[14]) return 14; if(e[17]) return 17; if(e[16]) return 16;
    if(e[1]) return 1; if(e[6]) return 6; if(e[9]) return 9;
    if(e[8]) return 8; if(e[7]) return 7; if(e[2]) return 2;
    if(e[3]) return 3; if(e[4]) return 4;
    for(int i=0;i<19;i++) if(e[i]) return 8'(i);
    return 0;
  endfunction
  function automatic logic [7:0] validate_config(input config_t c,
    input int cw,pw,nc,sw, input bit token_support,supervision,hw_support,safety);
    logic [63:0] win,tmo,pre,boot,dmin,dmax;
    logic [31:0] ctrl,mask,required;
    win={c.word[3],c.word[2]}; tmo={c.word[5],c.word[4]};
    pre={c.word[7],c.word[6]}; boot={c.word[9],c.word[8]};
    ctrl=c.word[0]; mask=c.word[11];
    required=REQUIRED_POLICY | (safety ? 32'h1c : 0);
    if((ctrl[4:3]>=2 && !token_support) || (ctrl[6:5]!=0 && !supervision) ||
       (ctrl[12] && !hw_support)) return UNSUPPORTED;
    if((ctrl>>13)!=0 || (c.word[1]>>pw)!=0 || (cw<64 &&
       ((win>>cw)!=0 || (tmo>>cw)!=0 || (pre>>cw)!=0 || (boot>>cw)!=0))) return BAD_CONFIG;
    if(tmo==0 || c.word[10]==0 || mask==0 || (nc<32 && (mask>>nc)!=0)) return BAD_CONFIG;
    if((!ctrl[0] && win!=0) || (ctrl[0] && win>=tmo)) return BAD_CONFIG;
    if(ctrl[1] ? (pre<win || pre>=tmo) : (pre!=0)) return BAD_CONFIG;
    if(ctrl[2] ? boot==0 : boot!=0) return BAD_CONFIG;
    if(ctrl[6:5]==0 && mask!=1) return BAD_CONFIG;
    if(ctrl[6:5]==2 && ctrl[0]) return BAD_CONFIG;
    if(ctrl[6:5]==3 && ctrl[4:3]!=0) return BAD_CONFIG;
    if((c.word[12]&required)!=required || (c.word[12]&~32'h7fe)!=0) return BAD_CONFIG;
    if((c.word[15]>>8)!=0) return BAD_CONFIG;
    if(!ctrl[7]) begin
      if(c.word[13]!=0 || c.word[14]!=0 || c.word[15]!=0 || ctrl[8]) return BAD_CONFIG;
    end else begin
      if(c.word[14]<=c.word[13]) return BAD_CONFIG;
      if(ctrl[8] ? c.word[15]==0 : c.word[15]!=0) return BAD_CONFIG;
    end
    for(int i=0;i<32;i++) begin
      if(i<nc && mask[i]) begin
        if((c.client[i][0]>>sw)!=0 || (c.client[i][2]>>8)!=0) return BAD_CONFIG;
        if(ctrl[6:5]==2 && (c.client[i][1][15:0]==0 ||
          c.client[i][1][31:16]<c.client[i][1][15:0])) return BAD_CONFIG;
        dmin={c.client[i][4],c.client[i][3]}; dmax={c.client[i][6],c.client[i][5]};
        if(ctrl[6:5]==3 && (c.client[i][2]==0 || dmax<=dmin ||
           (cw<64 && ((dmin>>cw)!=0 || (dmax>>cw)!=0)))) return BAD_CONFIG;
      end
    end
    return OK;
  endfunction
endpackage
