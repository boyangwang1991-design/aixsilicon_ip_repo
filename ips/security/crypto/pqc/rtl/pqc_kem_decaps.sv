// Serialized Decaps candidate; shared RTL engines perform all arithmetic.
// See docs/lld/03_kemseq_decaps.md. Level 2 is not implemented here.
module pqc_kem_decaps (
  input logic clk, rst_n, start, clear,
  input logic [3:0] pset,
  input logic [15:0] ct_bytes,
  output logic wk_read_req,
  output logic [15:0] wk_read_word,
  input logic wk_read_valid, wk_read_error,
  input logic [31:0] wk_read_data,
  output logic busy, done, error,
  output logic mem_req, mem_we,
  output logic [15:0] mem_addr,
  output logic [31:0] mem_wdata,
  input logic mem_ready,
  input logic [31:0] mem_rdata,
  input logic entropy_valid, entropy_health_ok,
  input logic [7:0] entropy_tag,
  input logic [63:0] entropy_data,
  output logic entropy_ready,
  output logic poly_start,
  output logic [3:0] poly_op,
  output logic [7:0] poly_src, poly_src2, poly_dst,
  input logic poly_done,
  output logic codec_start,
  output logic [3:0] codec_op,
  output logic [4:0] codec_bits,
  output logic [7:0] codec_src, codec_dst,
  input logic codec_done,
  output logic sampler_start,
  output logic [2:0] sampler_mode,
  output logic [3:0] sampler_eta,
  output logic [7:0] sampler_dst,
  input logic sampler_done, sampler_error, sampler_ready,
  output logic sampler_valid,
  output logic hash_start,
  output logic [2:0] hash_function,
  output logic [31:0] hash_length,
  output logic hash_in_valid, hash_in_last,
  output logic [7:0] hash_in_data,
  input logic hash_in_ready,
  input logic hash_out_valid, hash_done,
  input logic [7:0] hash_out_data,
  output logic hash_out_ready
);
  import pqc_pkg::*;
  typedef enum logic [7:0] {
    IDLE=0, COPY=1, COPY_READ=2, COPY_WRITE=3, UNPACK=4, CHECK=5, CHECK_READ=6,
    RHO=7, RHO_READ=8, ENTROPY=9, HASH_PK=10, DERIVE=11,
    Y_SAMPLE=12, Y_NTT=13, Y_NEXT=14, U_BEGIN=15, ZERO_ACC=16,
    MATRIX=17, MATRIX_MAC=18, MATRIX_NEXT=19, INV=20, NOISE=21,
    ADD_NOISE=22, MESSAGE=23, MESSAGE_READ=24, MESSAGE_WRITE=25,
    COMPRESS=26, PACK=27, COPY_OUT=28, COPY_OUT_READ=29, COPY_OUT_WRITE=30,
    ROW_NEXT=31, V_BEGIN=32, V_MAC=33, V_NEXT=34, SS=35, SS_NEXT=36,
    MREAD=40, MWRITE=41, PSTART=42, PWAIT=43, CSTART=44, CWAIT=45,
    HSTART=46, H_PK=47, H_BYTE=48, H_OUT=49, H_DONE=50,
    FINISH=60, FAILED=61,
    D_S=64,D_S_READ=65,D_S_WRITE=66,D_S_UNPACK=67,D_S_NEXT=68,
    D_U=69,D_U_READ=70,D_U_WRITE=71,D_U_UNPACK=72,D_U_DECOMP=73,D_U_NEXT=74,
    D_V=75,D_V_READ=76,D_V_WRITE=77,D_V_UNPACK=78,D_V_DECOMP=79,
    D_NTT=80,D_NTT_NEXT=81,D_ZERO=82,D_ZERO_NEXT=83,D_MAC=84,D_MAC_NEXT=85,
    D_INV=86,D_SUB=87,D_COMP=88,D_PACK=89,D_MSG=90,D_MSG_READ=91,
    D_PK=92,D_PK_READ=93,D_PK_WRITE=94,D_META=95,D_META_READ=96,D_HCHECK=97,
    D_REJECT=98,D_CMP=99,D_CMP_A=100,D_CMP_B=101,D_CMP_ACC=102,
    WSTART=103,WWAIT=104,H_CT=105
  } state_t;
  state_t state, ret, hash_ret;
  logic [3:0] pset_q;
  logic [2:0] k, row, col, pk_poly;
  logic [8:0] idx;
  logic [15:0] out_offset;
  logic [31:0] rd, write_data, compare_word, diff_acc;
  logic [15:0] ct_words;
  logic [4:0] du, dv;
  logic [7:0] hval[0:31], zval[0:31], kbar[0:31];
  logic [31:0] select_mask;
  assign du = k==4 ? 5'd11 : 5'd10;
  assign dv = k==4 ? 5'd5 : 5'd4;
  assign select_mask = {32{diff_acc==0}};
  assign wk_read_req = rst_n && !clear && state==WSTART;
  logic [15:0] address;
  logic [7:0] rho [0:31], message [0:31], digest [0:63];
  logic [1:0] entropy_word;
  logic [2:0] hash_kind; // 0=ek, 1=m||h, 2=r||nonce, 3=rho||i||j, 4=z||c
  logic [15:0] hidx, hinput_len, houtput_idx;
  logic [7:0] nonce;
  logic sample_hash, hash_seen, sample_seen, vector_v;
  logic [4:0] compress_bits;
  logic [8:0] packed_words;
  assign compress_bits = vector_v ? (k==4 ? 5'd5 : 5'd4) : (k==4 ? 5'd11 : 5'd10);
  assign packed_words = 9'(compress_bits)*9'd8;
  assign busy = state!=IDLE && state!=FINISH && state!=FAILED;
  assign done = rst_n && !clear && state==FINISH;
  assign error = rst_n && !clear && state==FAILED;
  assign mem_req = rst_n && !clear && (state==MREAD || state==MWRITE || state==H_PK || state==H_CT);
  assign mem_we = mem_req && state==MWRITE;
  assign mem_addr = state==H_PK ? 16'd3072+(hidx>>2) :
                    state==H_CT ? 16'd4096+((hidx-16'd32)>>2) : address;
  assign mem_wdata = write_data;
  assign entropy_ready = 1'b0; // deterministic internal Decaps; no fresh entropy in this nonmasked candidate
  assign poly_start = rst_n && !clear && state==PSTART;
  assign codec_start = rst_n && !clear && state==CSTART;
  assign hash_start = rst_n && !clear && state==HSTART;
  assign sampler_start = hash_start && sample_hash;
  assign sampler_valid = rst_n && !clear && state==H_OUT && sample_hash && !sample_seen && hash_out_valid;
  assign hash_out_ready = rst_n && !clear && state==H_OUT && (!sample_hash || sample_seen || sampler_ready);
  assign hash_in_valid = rst_n && !clear && state==H_BYTE;
  assign hash_in_last = hash_in_valid && hidx+16'd1==hinput_len;
  always_comb begin
    hash_in_data=0;
    case(hash_kind)
      0: hash_in_data=rd[8*hidx[1:0]+:8];
      1: hash_in_data=hidx<32 ? message[hidx[4:0]] : hval[hidx[4:0]];
      2: hash_in_data=hidx<32 ? digest[32+hidx[4:0]] : nonce;
      3: hash_in_data=hidx<32 ? rho[hidx[4:0]] : hidx==32 ? {5'd0,row} : {5'd0,col};
      4: hash_in_data=hidx<32 ? zval[hidx[4:0]] : rd[8*hidx[1:0]+:8];
      default: hash_in_data=0;
    endcase
  end
  task automatic read_word(input logic [15:0] a, input state_t next_state);
    address<=a; ret<=next_state; state<=MREAD;
  endtask
  task automatic key_word(input logic [15:0] a, input state_t next_state);
    wk_read_word<=a; ret<=next_state; state<=WSTART;
  endtask
  task automatic write_word(input logic [15:0] a, input logic [31:0] d, input state_t next_state);
    address<=a; write_data<=d; ret<=next_state; state<=MWRITE;
  endtask
  task automatic poly(input logic [3:0] op, input logic [7:0] a,b,c, input state_t next_state);
    poly_op<=op; poly_src<=a; poly_src2<=b; poly_dst<=c; ret<=next_state; state<=PSTART;
  endtask
  task automatic codec(input logic [3:0] op, input logic [4:0] bits, input logic [7:0] a,c, input state_t next_state);
    codec_op<=op; codec_bits<=bits; codec_src<=a; codec_dst<=c; ret<=next_state; state<=CSTART;
  endtask
  task automatic hash(input logic [2:0] fn, input logic [2:0] kind,
                      input logic [15:0] ilen, input logic [31:0] olen,
                      input logic sample, input state_t next_state);
    hash_function<=fn; hash_kind<=kind; hinput_len<=ilen; hash_length<=olen;
    hidx<=0; houtput_idx<=0; sample_hash<=sample; hash_seen<=0; sample_seen<=0;
    hash_ret<=next_state; state<=HSTART;
  endtask
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=IDLE; ret<=IDLE; hash_ret<=IDLE; pset_q<=0; k<=0;
      row<=0; col<=0; pk_poly<=0; idx<=0; out_offset<=0; rd<=0; address<=0; write_data<=0;
      wk_read_word<=0; ct_words<=0; compare_word<=0; diff_acc<=0;
      for(int n=0;n<32;n++) begin hval[n]<=0; zval[n]<=0; kbar[n]<=0; end
      entropy_word<=0; hash_kind<=0; hidx<=0; hinput_len<=0; houtput_idx<=0;
      nonce<=0; sample_hash<=0; hash_seen<=0; sample_seen<=0; vector_v<=0;
      poly_op<=0; poly_src<=0; poly_src2<=0; poly_dst<=0;
      codec_op<=0; codec_bits<=0; codec_src<=0; codec_dst<=0;
      sampler_mode<=0; sampler_eta<=0; sampler_dst<=0; hash_function<=0; hash_length<=0;
      for(int n=0;n<32;n++) begin rho[n]<=0; message[n]<=0; end
      for(int n=0;n<64;n++) digest[n]<=0;
    end else if(clear) begin
      state<=IDLE; ret<=IDLE; hash_ret<=IDLE; pset_q<=0; k<=0;
      row<=0; col<=0; pk_poly<=0; idx<=0; out_offset<=0; rd<=0; address<=0; write_data<=0;
      wk_read_word<=0; ct_words<=0; compare_word<=0; diff_acc<=0;
      for(int n=0;n<32;n++) begin hval[n]<=0; zval[n]<=0; kbar[n]<=0; end
      entropy_word<=0; hash_kind<=0; hidx<=0; hinput_len<=0; houtput_idx<=0;
      nonce<=0; sample_hash<=0; hash_seen<=0; sample_seen<=0; vector_v<=0;
      poly_op<=0; poly_src<=0; poly_src2<=0; poly_dst<=0;
      codec_op<=0; codec_bits<=0; codec_src<=0; codec_dst<=0;
      sampler_mode<=0; sampler_eta<=0; sampler_dst<=0; hash_function<=0; hash_length<=0;
      for(int n=0;n<32;n++) begin rho[n]<=0; message[n]<=0; end
      for(int n=0;n<64;n++) digest[n]<=0;
    end else begin
      case(state)
        IDLE: if(start) begin
          if(pset<1 || pset>3 || ct_bytes!=(pset==1 ? 16'd768 : pset==2 ? 16'd1088 : 16'd1568)) state<=FAILED;
          else begin pset_q<=pset; k<=3'(pset+1); pk_poly<=0; idx<=0; out_offset<=0; ct_words<=ct_bytes>>2; diff_acc<=0; state<=D_S; end
        end
        // Decode each polynomial through the one-page packed scratch buffer.
        D_S: key_word(16'(pk_poly)*16'd96+16'(idx),D_S_READ);
        D_S_READ: write_word(16'd2816+16'(idx),rd,D_S_WRITE);
        D_S_WRITE: if(idx==95) begin idx<=0;state<=D_S_UNPACK;end
          else begin idx<=idx+1'b1;state<=D_S;end
        D_S_UNPACK: codec(1,12,11,8'(pk_poly),D_S_NEXT);
        D_S_NEXT: if(pk_poly+1<k) begin pk_poly<=pk_poly+1'b1;state<=D_S;end
          else begin pk_poly<=0;state<=D_U;end
        D_U: read_word(16'd4096+16'(pk_poly)*16'(du)*16'd8+16'(idx),D_U_READ);
        D_U_READ: write_word(16'd2816+16'(idx),rd,D_U_WRITE);
        D_U_WRITE: if(idx+1==9'(du)*9'd8) begin idx<=0;state<=D_U_UNPACK;end
          else begin idx<=idx+1'b1;state<=D_U;end
        D_U_UNPACK: codec(1,du,11,8'd4+8'(pk_poly),D_U_DECOMP);
        D_U_DECOMP: codec(3,du,8'd4+8'(pk_poly),8'd4+8'(pk_poly),D_U_NEXT);
        D_U_NEXT: if(pk_poly+1<k) begin pk_poly<=pk_poly+1'b1;state<=D_U;end
          else begin pk_poly<=0;state<=D_V;end
        D_V: read_word(16'd4096+16'(k)*16'(du)*16'd8+16'(idx),D_V_READ);
        D_V_READ: write_word(16'd2816+16'(idx),rd,D_V_WRITE);
        D_V_WRITE: if(idx+1==9'(dv)*9'd8) begin idx<=0;row<=0;state<=D_V_UNPACK;end
          else begin idx<=idx+1'b1;state<=D_V;end
        D_V_UNPACK: codec(1,dv,11,9,D_V_DECOMP);
        D_V_DECOMP: codec(3,dv,9,9,D_NTT);
        D_NTT: poly(PRIM_NTT_FWD,8'd4+8'(row),0,0,D_NTT_NEXT);
        D_NTT_NEXT: if(row+1<k) begin row<=row+1'b1;state<=D_NTT;end
          else begin col<=0;idx<=0;state<=D_ZERO;end
        D_ZERO: write_word(16'd2048+16'(idx),0,D_ZERO_NEXT);
        D_ZERO_NEXT: if(idx==255) begin idx<=0;state<=D_MAC;end
          else begin idx<=idx+1'b1;state<=D_ZERO;end
        D_MAC: poly(PRIM_PW_MAC,8'(col),8'd4+8'(col),8,D_MAC_NEXT);
        D_MAC_NEXT: if(col+1<k) begin col<=col+1'b1;state<=D_MAC;end else state<=D_INV;
        D_INV: poly(PRIM_NTT_INV,8,0,0,D_SUB);
        D_SUB: poly(PRIM_SUB,9,8,9,D_COMP);
        D_COMP: codec(2,1,9,10,D_PACK);
        D_PACK: begin idx<=0;codec(0,1,10,11,D_MSG);end
        D_MSG: read_word(16'd2816+16'(idx),D_MSG_READ);
        D_MSG_READ: begin
          for(int n=0;n<4;n++) message[4*idx+n]<=rd[8*n+:8];
          if(idx==7) begin idx<=0;state<=D_PK;end
          else begin idx<=idx+1'b1;state<=D_MSG;end
        end
        D_PK: key_word(16'(k)*16'd96+16'(idx),D_PK_READ);
        D_PK_READ: write_word(16'd3072+16'(idx),rd,D_PK_WRITE);
        D_PK_WRITE: if(idx+1==9'(k)*9'd96+9'd8) begin idx<=0;state<=D_META;end
          else begin idx<=idx+1'b1;state<=D_PK;end
        D_META: key_word(16'(k)*16'd192+16'd8+16'(idx),D_META_READ);
        D_META_READ: begin
          for(int n=0;n<4;n++) begin
            if(idx<8) hval[4*idx+n]<=rd[8*n+:8];
            else zval[4*(idx-8)+n]<=rd[8*n+:8];
          end
          if(idx==15) begin idx<=0;state<=HASH_PK;end
          else begin idx<=idx+1'b1;state<=D_META;end
        end
        D_HCHECK: if(digest[idx]!=hval[idx]) state<=FAILED;
          else if(idx==31) begin idx<=0;pk_poly<=0;state<=COPY;end
          else idx<=idx+1'b1;
        D_REJECT: hash(KEC_SHAKE256,4,16'd32+(ct_words<<2),32,0,D_CMP);
        D_CMP: read_word(16'd4096+16'(idx),D_CMP_A);
        D_CMP_A: begin compare_word<=rd;state<=D_CMP_B;end
        D_CMP_B: read_word(16'd5120+16'(idx),D_CMP_ACC);
        D_CMP_ACC: begin
          diff_acc<=diff_acc | (compare_word ^ rd);
          if(16'(idx)+16'd1==ct_words) begin idx<=0;state<=SS;end
          else begin idx<=idx+1'b1;state<=D_CMP;end
        end
        WSTART: state<=WWAIT;
        WWAIT: if(wk_read_error) state<=FAILED;
          else if(wk_read_valid) begin rd<=wk_read_data;state<=ret;end
        COPY: read_word(16'd3072+16'(pk_poly)*16'd96+16'(idx),COPY_READ);
        COPY_READ: write_word(16'd2816+16'(idx),rd,COPY_WRITE);
        COPY_WRITE: if(idx==95) begin idx<=0; state<=UNPACK; end else begin idx<=idx+1'b1; state<=COPY; end
        UNPACK: codec(4'd1,5'd12,8'd11,8'(pk_poly),CHECK);
        CHECK: read_word({5'd0,pk_poly,idx[7:0]},CHECK_READ);
        CHECK_READ: if(rd>=3329) state<=FAILED;
          else if(idx==255) begin
            idx<=0;
            if(pk_poly+1<k) begin pk_poly<=pk_poly+1'b1; state<=COPY; end
            else state<=RHO;
          end else begin idx<=idx+1'b1; state<=CHECK; end
        RHO: read_word(16'd3072+16'(k)*16'd96+16'(idx),RHO_READ);
        RHO_READ: begin
          for(int n=0;n<4;n++) rho[4*idx+n]<=rd[8*n+:8];
          if(idx==7) begin row<=0; state<=DERIVE; end
          else begin idx<=idx+1'b1; state<=RHO; end
        end
        HASH_PK: hash(KEC_SHA3_256,0,16'(k)*16'd384+16'd32,32,0,D_HCHECK);
        DERIVE: begin row<=0; hash(KEC_SHA3_512,1,64,64,0,Y_SAMPLE); end
        Y_SAMPLE: begin
          nonce<={5'd0,row}; sampler_mode<=SAMP_CBD_KEM; sampler_eta<=k==2 ? 4'd3 : 4'd2;
          sampler_dst<=8'd4+8'(row);
          hash(KEC_SHAKE256,2,33,k==2 ? 32'd192 : 32'd128,1,Y_NTT);
        end
        Y_NTT: poly(PRIM_NTT_FWD,8'd4+8'(row),0,0,Y_NEXT);
        Y_NEXT: if(row+1<k) begin row<=row+1'b1; state<=Y_SAMPLE; end
          else begin row<=0; state<=U_BEGIN; end
        U_BEGIN: begin vector_v<=0; idx<=0; col<=0; state<=ZERO_ACC; end
        ZERO_ACC: write_word(16'd2048+16'(idx),0,MATRIX);
        MATRIX: if(idx!=255) begin idx<=idx+1'b1; state<=ZERO_ACC; end
          else if(vector_v) state<=V_MAC;
          else begin
            sampler_mode<=SAMP_REJ_KEM; sampler_eta<=2; sampler_dst<=10;
            hash(KEC_SHAKE128,3,34,4096,1,MATRIX_MAC);
          end
        MATRIX_MAC: poly(PRIM_PW_MAC,10,8'd4+8'(col),8,MATRIX_NEXT);
        MATRIX_NEXT: if(col+1<k) begin col<=col+1'b1; state<=MATRIX; end else state<=INV;
        INV: poly(PRIM_NTT_INV,8,0,0,NOISE);
        NOISE: begin
          nonce<=vector_v ? 8'(k)*2 : 8'(k)+8'(row);
          sampler_mode<=SAMP_CBD_KEM; sampler_eta<=2; sampler_dst<=9;
          hash(KEC_SHAKE256,2,33,128,1,ADD_NOISE);
        end
        ADD_NOISE: begin idx<=0; poly(PRIM_ADD,8,9,8,vector_v ? MESSAGE : COMPRESS); end
        MESSAGE: read_word(16'd2048+16'(idx),MESSAGE_READ);
        MESSAGE_READ: write_word(16'd2048+16'(idx),
          message[idx[7:3]][idx[2:0]] ? ((rd+1665>=3329) ? rd+1665-3329 : rd+1665) : rd,MESSAGE_WRITE);
        MESSAGE_WRITE: if(idx==255) state<=COMPRESS; else begin idx<=idx+1'b1; state<=MESSAGE; end
        COMPRESS: codec(2,compress_bits,8,9,PACK);
        PACK: begin idx<=0; codec(0,compress_bits,9,11,COPY_OUT); end
        COPY_OUT: read_word(16'd2816+16'(idx),COPY_OUT_READ);
        COPY_OUT_READ: write_word(16'd5120+out_offset+16'(idx),rd,COPY_OUT_WRITE);
        COPY_OUT_WRITE: if(idx+1==packed_words) begin out_offset<=out_offset+16'(packed_words); state<=ROW_NEXT; end
          else begin idx<=idx+1'b1; state<=COPY_OUT; end
        ROW_NEXT: if(vector_v) begin idx<=0; diff_acc<=0; state<=D_REJECT; end
          else if(row+1<k) begin row<=row+1'b1; state<=U_BEGIN; end else state<=V_BEGIN;
        V_BEGIN: begin vector_v<=1; col<=0; idx<=0; state<=ZERO_ACC; end
        V_MAC: poly(PRIM_PW_MAC,8'(col),8'd4+8'(col),8,V_NEXT);
        V_NEXT: if(col+1<k) begin col<=col+1'b1; state<=V_MAC; end else state<=INV;
        SS: write_word(16'd5632+16'(idx),({digest[4*idx+3],digest[4*idx+2],digest[4*idx+1],digest[4*idx]} & select_mask) |
          ({kbar[4*idx+3],kbar[4*idx+2],kbar[4*idx+1],kbar[4*idx]} & ~select_mask),SS_NEXT);
        SS_NEXT: if(idx==7) state<=FINISH; else begin idx<=idx+1'b1; state<=SS; end
        MREAD: if(mem_ready) begin rd<=mem_rdata; state<=ret; end
        MWRITE: if(mem_ready) state<=ret;
        PSTART: state<=PWAIT;
        PWAIT: if(poly_done) state<=ret;
        CSTART: state<=CWAIT;
        CWAIT: if(codec_done) state<=ret;
        HSTART: state<=hash_kind==0 ? H_PK : H_BYTE;
        H_PK: if(mem_ready) begin rd<=mem_rdata; state<=H_BYTE; end
        H_CT: if(mem_ready) begin rd<=mem_rdata; state<=H_BYTE; end
        H_BYTE: if(hash_in_ready) begin
          hidx<=hidx+1'b1;
          if(hash_in_last) state<=H_OUT; else if(hash_kind==0) state<=H_PK;
          else if(hash_kind==4 && hidx>=31) state<=H_CT;
        end
        H_OUT: begin
          if(hash_out_valid && hash_out_ready) begin
            if(!sample_hash) begin
              if(hash_kind==4) kbar[houtput_idx[4:0]]<=hash_out_data;
              else digest[houtput_idx[5:0]]<=hash_out_data;
            end
            houtput_idx<=houtput_idx+1'b1;
          end
          if(sampler_done) sample_seen<=1;
          if(hash_done) hash_seen<=1;
          if(sampler_error) state<=FAILED;
          else if((hash_seen || hash_done) && (!sample_hash || sample_seen || sampler_done)) state<=H_DONE;
          // A exhausted public matrix bound must fail, never use a partial polynomial.
          else if(hash_seen && sample_hash && !sample_seen && !sampler_done && sampler_ready) state<=FAILED;
        end
        H_DONE: state<=hash_ret;
        FINISH: begin
          for(int n=0;n<32;n++) begin message[n]<=0; rho[n]<=0; end
          for(int n=0;n<64;n++) digest[n]<=0;
          for(int n=0;n<32;n++) begin hval[n]<=0;zval[n]<=0;kbar[n]<=0;end
          compare_word<=0;diff_acc<=0;rd<=0;write_data<=0;state<=IDLE;
        end
        FAILED: state<=FAILED;
        default: state<=FAILED;
      endcase
    end
  end
endmodule
