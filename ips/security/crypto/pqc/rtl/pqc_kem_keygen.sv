// Serialized ML-KEM KeyGen; all arithmetic runs in the shared RTL engines.
module pqc_kem_keygen #(parameter int unsigned MAX_CYCLES=4000000) (
  input logic clk, rst_n, start, clear,
  input logic [3:0] pset,
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
  output logic hash_out_ready,
  output logic generated_valid, generated_last,
  output logic [31:0] generated_data,
  input logic generated_ready
);
  import pqc_pkg::*;
  typedef enum logic [7:0] {
    IDLE, ENTROPY, DERIVE, SEED_SAVE, S_SAMPLE, S_NTT, S_NEXT,
    E_SAMPLE, E_NTT, ZERO_ACC, ZERO_NEXT, MATRIX, MATRIX_MAC, MATRIX_NEXT,
    ADD_E, PACK_T, COPY_PK, COPY_PK_READ, COPY_PK_NEXT, ROW_NEXT,
    RHO_WRITE, RHO_NEXT, HASH_PK, S_PACK, S_COPY, S_READ, S_WORD_NEXT,
    EK_COPY, EK_READ, EK_NEXT, H_WORD, H_NEXT, Z_WORD, Z_NEXT,
    WIPE, WIPE_NEXT, GWORD, MREAD, MWRITE, PSTART, PWAIT, CSTART, CWAIT,
    HSTART, H_PK, H_BYTE, H_OUT, H_DONE, FINISH, FAILED
  } state_t;
  state_t state, ret, hash_ret;
  logic [3:0] pset_q;
  logic [2:0] k,row,col,entropy_word;
  logic [15:0] idx,address;
  logic [31:0] rd,write_data,cycles;
  logic [7:0] seed_d[0:31],seed_z[0:31],rho[0:31],digest[0:63];
  logic [1:0] hash_kind;
  logic [15:0] hidx,hinput_len,houtput_idx;
  logic [7:0] nonce;
  logic sample_hash,hash_seen,sample_seen;
  logic generated_last_q;
  assign busy=state!=IDLE && state!=FINISH && state!=FAILED;
  assign done=rst_n && !clear && state==FINISH;
  assign error=rst_n && !clear && state==FAILED;
  assign mem_req=rst_n && !clear && (state==MREAD || state==MWRITE || state==H_PK);
  assign mem_we=mem_req && state==MWRITE;
  assign mem_addr=state==H_PK ? 16'd4096+(hidx>>2) : address;
  assign mem_wdata=write_data;
  assign entropy_ready=rst_n && !clear && state==ENTROPY && entropy_health_ok && entropy_tag=={4'd1,pset_q};
  assign generated_valid=rst_n && !clear && state==GWORD;
  assign generated_data=generated_valid ? write_data : 32'd0;
  assign generated_last=generated_valid && generated_last_q;
  assign poly_start=rst_n && !clear && state==PSTART;
  assign codec_start=rst_n && !clear && state==CSTART;
  assign hash_start=rst_n && !clear && state==HSTART;
  assign sampler_start=hash_start && sample_hash;
  assign sampler_valid=rst_n && !clear && state==H_OUT && sample_hash && !sample_seen && hash_out_valid;
  assign hash_out_ready=rst_n && !clear && state==H_OUT && (!sample_hash || sample_seen || sampler_ready);
  assign hash_in_valid=rst_n && !clear && state==H_BYTE;
  assign hash_in_last=hash_in_valid && hidx+16'd1==hinput_len;
  always_comb begin
    hash_in_data=0;
    case(hash_kind)
      0:hash_in_data=hidx<32 ? seed_d[hidx[4:0]] : {5'd0,k};
      1:hash_in_data=hidx<32 ? digest[32+hidx[4:0]] : nonce;
      // A[row,col] uses rho || col || row; Encaps uses the transpose.
      2:hash_in_data=hidx<32 ? rho[hidx[4:0]] : hidx==32 ? {5'd0,col} : {5'd0,row};
      3:hash_in_data=rd[8*hidx[1:0]+:8];
      default:hash_in_data=0;
    endcase
  end
  task automatic read_word(input logic[15:0] a,input state_t nxt);
    address<=a;ret<=nxt;state<=MREAD;
  endtask
  task automatic write_word(input logic[15:0] a,input logic[31:0] d,input state_t nxt);
    address<=a;write_data<=d;ret<=nxt;state<=MWRITE;
  endtask
  task automatic generated_word(input logic[31:0] d,input logic last_word,input state_t nxt);
    write_data<=d;generated_last_q<=last_word;ret<=nxt;state<=GWORD;
  endtask
  task automatic poly(input logic[3:0] op,input logic[7:0] a,b,c,input state_t nxt);
    poly_op<=op;poly_src<=a;poly_src2<=b;poly_dst<=c;ret<=nxt;state<=PSTART;
  endtask
  task automatic pack_poly(input logic[7:0] a,input state_t nxt);
    codec_op<=0;codec_bits<=12;codec_src<=a;codec_dst<=11;ret<=nxt;state<=CSTART;
  endtask
  task automatic hash(input logic[2:0] fn,input logic[1:0] kind,input logic[15:0] ilen,
                      input logic[31:0] olen,input logic sample,input state_t nxt);
    hash_function<=fn;hash_kind<=kind;hinput_len<=ilen;hash_length<=olen;
    hidx<=0;houtput_idx<=0;sample_hash<=sample;hash_seen<=0;sample_seen<=0;
    hash_ret<=nxt;state<=HSTART;
  endtask
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;row<=0;col<=0;
      idx<=0;address<=0;rd<=0;write_data<=0;cycles<=0;entropy_word<=0;generated_last_q<=0;
      hash_kind<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;nonce<=0;
      sample_hash<=0;hash_seen<=0;sample_seen<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;
      codec_op<=0;codec_bits<=0;codec_src<=0;codec_dst<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) begin seed_d[n]<=0;seed_z[n]<=0;rho[n]<=0;end
      for(int n=0;n<64;n++) digest[n]<=0;
    end else if(clear) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;row<=0;col<=0;
      idx<=0;address<=0;rd<=0;write_data<=0;cycles<=0;entropy_word<=0;generated_last_q<=0;
      hash_kind<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;nonce<=0;
      sample_hash<=0;hash_seen<=0;sample_seen<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;
      codec_op<=0;codec_bits<=0;codec_src<=0;codec_dst<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) begin seed_d[n]<=0;seed_z[n]<=0;rho[n]<=0;end
      for(int n=0;n<64;n++) digest[n]<=0;
    end else begin
      if(busy) cycles<=cycles+1'b1;
      if(busy && cycles>=MAX_CYCLES-1) state<=FAILED;
      else case(state)
        IDLE:if(start) begin
          pset_q<=pset;k<=3'(pset)+1'b1;row<=0;col<=0;idx<=0;entropy_word<=0;cycles<=0;
          state<=(pset>=1 && pset<=3) ? ENTROPY : FAILED;
        end
        ENTROPY:if(!entropy_health_ok || (entropy_valid && entropy_tag!={4'd1,pset_q})) state<=FAILED;
          else if(entropy_valid && entropy_ready) begin
            for(int n=0;n<8;n++) begin
              if(entropy_word<4) seed_d[8*entropy_word+n]<=entropy_data[8*n+:8];
              else seed_z[8*(entropy_word-4)+n]<=entropy_data[8*n+:8];
            end
            if(entropy_word==7) state<=DERIVE;else entropy_word<=entropy_word+1'b1;
          end
        DERIVE:hash(KEC_SHA3_512,0,33,64,0,SEED_SAVE);
        SEED_SAVE:begin for(int n=0;n<32;n++) rho[n]<=digest[n];state<=S_SAMPLE;end
        S_SAMPLE:begin
          nonce<={5'd0,row};sampler_mode<=SAMP_CBD_KEM;sampler_eta<=k==2 ? 3 : 2;sampler_dst<=8'(row);
          hash(KEC_SHAKE256,1,33,k==2 ? 192 : 128,1,S_NTT);
        end
        S_NTT:poly(PRIM_NTT_FWD,8'(row),0,0,S_NEXT);
        S_NEXT:if(row+1<k) begin row<=row+1'b1;state<=S_SAMPLE;end
          else begin row<=0;state<=E_SAMPLE;end
        E_SAMPLE:begin
          nonce<=8'(k)+8'(row);sampler_mode<=SAMP_CBD_KEM;sampler_eta<=k==2 ? 3 : 2;sampler_dst<=9;
          hash(KEC_SHAKE256,1,33,k==2 ? 192 : 128,1,E_NTT);
        end
        E_NTT:begin idx<=0;col<=0;poly(PRIM_NTT_FWD,9,0,0,ZERO_ACC);end
        ZERO_ACC:write_word(16'd2048+idx,0,ZERO_NEXT);
        ZERO_NEXT:if(idx==255) begin idx<=0;state<=MATRIX;end else begin idx<=idx+1'b1;state<=ZERO_ACC;end
        MATRIX:begin
          sampler_mode<=SAMP_REJ_KEM;sampler_eta<=2;sampler_dst<=10;
          hash(KEC_SHAKE128,2,34,4096,1,MATRIX_MAC);
        end
        MATRIX_MAC:poly(PRIM_PW_MAC,10,8'(col),8,MATRIX_NEXT);
        MATRIX_NEXT:if(col+1<k) begin col<=col+1'b1;state<=MATRIX;end else state<=ADD_E;
        ADD_E:poly(PRIM_ADD,8,9,8,PACK_T);
        PACK_T:begin idx<=0;pack_poly(8,COPY_PK);end
        COPY_PK:read_word(16'd2816+idx,COPY_PK_READ);
        COPY_PK_READ:write_word(16'd4096+16'(row)*96+idx,rd,COPY_PK_NEXT);
        COPY_PK_NEXT:if(idx==95) state<=ROW_NEXT;else begin idx<=idx+1'b1;state<=COPY_PK;end
        ROW_NEXT:if(row+1<k) begin row<=row+1'b1;state<=E_SAMPLE;end else begin idx<=0;state<=RHO_WRITE;end
        RHO_WRITE:write_word(16'd4096+16'(k)*96+idx,{rho[4*idx+3],rho[4*idx+2],rho[4*idx+1],rho[4*idx]},RHO_NEXT);
        RHO_NEXT:if(idx==7) state<=HASH_PK;else begin idx<=idx+1'b1;state<=RHO_WRITE;end
        HASH_PK:begin row<=0;idx<=0;hash(KEC_SHA3_256,3,16'(k)*384+32,32,0,S_PACK);end
        S_PACK:begin idx<=0;pack_poly(8'(row),S_COPY);end
        S_COPY:read_word(16'd2816+idx,S_READ);
        S_READ:generated_word(rd,0,S_WORD_NEXT);
        S_WORD_NEXT:if(idx==95) begin
            idx<=0;if(row+1<k) begin row<=row+1'b1;state<=S_PACK;end else state<=EK_COPY;
          end else begin idx<=idx+1'b1;state<=S_COPY;end
        EK_COPY:read_word(16'd4096+idx,EK_READ);
        EK_READ:generated_word(rd,0,EK_NEXT);
        EK_NEXT:if(idx+1==16'(k)*96+8) begin idx<=0;state<=H_WORD;end else begin idx<=idx+1'b1;state<=EK_COPY;end
        H_WORD:generated_word({digest[4*idx+3],digest[4*idx+2],digest[4*idx+1],digest[4*idx]},0,H_NEXT);
        H_NEXT:if(idx==7) begin idx<=0;state<=Z_WORD;end else begin idx<=idx+1'b1;state<=H_WORD;end
        Z_WORD:generated_word({seed_z[4*idx+3],seed_z[4*idx+2],seed_z[4*idx+1],seed_z[4*idx]},idx==7,Z_NEXT);
        Z_NEXT:if(idx==7) begin idx<=0;state<=WIPE;end else begin idx<=idx+1'b1;state<=Z_WORD;end
        WIPE:write_word(idx,0,WIPE_NEXT);
        WIPE_NEXT:if(idx==3071) state<=FINISH;else begin idx<=idx+1'b1;state<=WIPE;end
        GWORD:if(generated_ready) state<=ret;
        MREAD:if(mem_ready) begin rd<=mem_rdata;state<=ret;end
        MWRITE:if(mem_ready) state<=ret;
        PSTART:state<=PWAIT;
        PWAIT:if(poly_done) state<=ret;
        CSTART:state<=CWAIT;
        CWAIT:if(codec_done) state<=ret;
        HSTART:state<=hash_kind==3 ? H_PK : H_BYTE;
        H_PK:if(mem_ready) begin rd<=mem_rdata;state<=H_BYTE;end
        H_BYTE:if(hash_in_ready) begin
          hidx<=hidx+1'b1;if(hash_in_last) state<=H_OUT;else if(hash_kind==3) state<=H_PK;
        end
        H_OUT:begin
          if(hash_out_valid && hash_out_ready) begin
            if(!sample_hash) digest[houtput_idx[5:0]]<=hash_out_data;
            houtput_idx<=houtput_idx+1'b1;
          end
          if(sampler_done) sample_seen<=1;
          if(hash_done) hash_seen<=1;
          if(sampler_error) state<=FAILED;
          else if((hash_seen || hash_done) && (!sample_hash || sample_seen || sampler_done)) state<=H_DONE;
          else if(hash_seen && sample_hash && !sample_seen && !sampler_done && sampler_ready) state<=FAILED;
        end
        H_DONE:state<=hash_ret;
        FINISH:begin
          for(int n=0;n<32;n++) begin seed_d[n]<=0;seed_z[n]<=0;rho[n]<=0;end
          for(int n=0;n<64;n++) digest[n]<=0;
          rd<=0;write_data<=0;state<=IDLE;
        end
        FAILED:state<=FAILED;
        default:state<=FAILED;
      endcase
    end
  end
endmodule
