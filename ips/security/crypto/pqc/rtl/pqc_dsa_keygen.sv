// FIPS 204 KeyGen, shared arithmetic engines and dedicated private stream.
module pqc_dsa_keygen #(parameter int unsigned MAX_CYCLES=8000000) (
  input logic clk,rst_n,start,clear,input logic[3:0] pset,
  output logic busy,done,error,
  output logic mem_req,mem_we,output logic[15:0] mem_addr,output logic[31:0] mem_wdata,
  input logic mem_ready,input logic[31:0] mem_rdata,
  input logic entropy_valid,entropy_health_ok,input logic[7:0] entropy_tag,
  input logic[63:0] entropy_data,output logic entropy_ready,
  output logic poly_start,output logic[3:0] poly_op,output logic[7:0] poly_src,poly_src2,poly_dst,input logic poly_done,
  output logic codec_start,output logic[3:0] codec_op,output logic[4:0] codec_bits,
  output logic[7:0] codec_src,codec_dst,input logic codec_done,
  output logic sampler_start,output logic[2:0] sampler_mode,output logic[3:0] sampler_eta,
  output logic[7:0] sampler_dst,input logic sampler_done,sampler_error,sampler_ready,output logic sampler_valid,
  output logic hash_start,output logic[2:0] hash_function,output logic[31:0] hash_length,
  output logic hash_in_valid,hash_in_last,output logic[7:0] hash_in_data,input logic hash_in_ready,
  input logic hash_out_valid,hash_done,input logic[7:0] hash_out_data,output logic hash_out_ready,
  output logic generated_valid,generated_last,output logic[31:0] generated_data,input logic generated_ready
);
  import pqc_pkg::*;
  localparam logic[31:0] Q=8380417;
  typedef enum logic[7:0] {IDLE,ENTROPY,DERIVE,S_SAMPLE,S_NTT,S_NEXT,E_SAMPLE,ZERO_ACC,ZERO_NEXT,
    MATRIX,MATRIX_MAC,MATRIX_NEXT,INV,ADD_E,SPLIT,SPLIT_READ,SPLIT_LOW,SPLIT_NEXT,PACK_T,
    COPY_PK,COPY_PK_READ,COPY_PK_NEXT,ROW_NEXT,RHO_WRITE,RHO_NEXT,HASH_PK,
    SK_HEADER,SK_HEADER_NEXT,SK_S_INV,SK_CONVERT,SK_CONVERT_READ,SK_CONVERT_NEXT,SK_PACK,
    SK_COPY,SK_READ,SK_NEXT,SK_ROW_NEXT,WIPE,WIPE_NEXT,
    GWORD,MREAD,MWRITE,PSTART,PWAIT,CSTART,CWAIT,HSTART,H_PK,H_BYTE,H_OUT,H_DONE,FINISH,FAILED} state_t;
  state_t state,ret,hash_ret;
  logic[3:0] pset_q,k,l,row,col,eta_q;
  logic[2:0] entropy_word;
  logic[1:0] sk_part,hash_kind;
  logic[4:0] eta_bits;
  logic[7:0] sk_page;
  logic[15:0] idx,address,hidx,hinput_len,houtput_idx,nonce,pk_bytes,packed_words;
  logic[31:0] rd,write_data,cycles,low_encoded;
  logic[7:0] xi[0:31],seed[0:127],tr[0:63];
  logic sample_hash,hash_seen,sample_seen,generated_last_q;
  assign busy=state!=IDLE && state!=FINISH && state!=FAILED;
  assign done=rst_n && !clear && state==FINISH;
  assign error=rst_n && !clear && state==FAILED;
  assign entropy_ready=rst_n && !clear && state==ENTROPY && entropy_health_ok && entropy_tag=={4'd2,pset_q};
  assign mem_req=rst_n && !clear && (state==MREAD || state==MWRITE || state==H_PK);
  assign mem_we=mem_req && state==MWRITE;
  assign mem_addr=state==H_PK ? 16'd7168+(hidx>>2) : address;
  assign mem_wdata=write_data;
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
  assign hash_in_last=hash_in_valid && hidx+1==hinput_len;
  always_comb begin
    hash_in_data=0;
    case(hash_kind)
      0:hash_in_data=hidx<32 ? xi[hidx[4:0]] : hidx==32 ? {4'd0,k} : {4'd0,l};
      1:hash_in_data=hidx<64 ? seed[32+hidx[5:0]] : hidx==64 ? nonce[7:0] : nonce[15:8];
      2:hash_in_data=hidx<32 ? seed[hidx[4:0]] : hidx==32 ? {4'd0,col} : {4'd0,row};
      3:hash_in_data=rd[8*hidx[1:0]+:8];
    endcase
  end
  task automatic read_word(input logic[15:0] a,input state_t nxt);address<=a;ret<=nxt;state<=MREAD;endtask
  task automatic write_word(input logic[15:0] a,input logic[31:0] d,input state_t nxt);address<=a;write_data<=d;ret<=nxt;state<=MWRITE;endtask
  task automatic generated_word(input logic[31:0] d,input logic last_word,input state_t nxt);write_data<=d;generated_last_q<=last_word;ret<=nxt;state<=GWORD;endtask
  task automatic poly(input logic[3:0] op,input logic[7:0] a,b,c,input state_t nxt);poly_op<=op;poly_src<=a;poly_src2<=b;poly_dst<=c;ret<=nxt;state<=PSTART;endtask
  task automatic codec(input logic[4:0] bits,input logic[7:0] a,b,input state_t nxt);codec_op<=0;codec_bits<=bits;codec_src<=a;codec_dst<=b;ret<=nxt;state<=CSTART;endtask
  task automatic hash(input logic[2:0] fn,input logic[1:0] kind,input logic[15:0] ilen,input logic[31:0] olen,input logic sample,input state_t nxt);
    hash_function<=fn;hash_kind<=kind;hinput_len<=ilen;hash_length<=olen;hidx<=0;houtput_idx<=0;
    sample_hash<=sample;hash_seen<=0;sample_seen<=0;hash_ret<=nxt;state<=HSTART;
  endtask
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;eta_q<=0;entropy_word<=0;
      sk_part<=0;hash_kind<=0;eta_bits<=0;sk_page<=0;idx<=0;address<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;nonce<=0;pk_bytes<=0;packed_words<=0;
      rd<=0;write_data<=0;cycles<=0;low_encoded<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;generated_last_q<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;codec_op<=0;codec_bits<=0;codec_src<=0;codec_dst<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) xi[n]<=0;
      for(int n=0;n<128;n++) seed[n]<=0;
      for(int n=0;n<64;n++) tr[n]<=0;
    end else if(clear) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;eta_q<=0;entropy_word<=0;
      sk_part<=0;hash_kind<=0;eta_bits<=0;sk_page<=0;idx<=0;address<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;nonce<=0;pk_bytes<=0;packed_words<=0;
      rd<=0;write_data<=0;cycles<=0;low_encoded<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;generated_last_q<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;codec_op<=0;codec_bits<=0;codec_src<=0;codec_dst<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) xi[n]<=0;
      for(int n=0;n<128;n++) seed[n]<=0;
      for(int n=0;n<64;n++) tr[n]<=0;
    end else begin
      if(busy) cycles<=cycles+1'b1;
      if(busy && cycles>=MAX_CYCLES-1) state<=FAILED;
      else case(state)
        IDLE:if(start) begin
          pset_q<=pset;cycles<=0;entropy_word<=0;row<=0;col<=0;idx<=0;nonce<=0;
          k<=pset==4?4:pset==5?6:8;l<=pset==4?4:pset==5?5:7;
          eta_q<=pset==5?4:2;eta_bits<=pset==5?4:3;pk_bytes<=pset==4?1312:pset==5?1952:2592;
          state<=(pset>=4 && pset<=6)?ENTROPY:FAILED;
        end
        ENTROPY:if(entropy_valid && entropy_ready) begin
          for(int b=0;b<8;b++) xi[8*entropy_word+b]<=entropy_data[8*b+:8];
          if(entropy_word==3) state<=DERIVE;else entropy_word<=entropy_word+1'b1;
        end
        DERIVE:hash(KEC_SHAKE256,0,34,128,0,S_SAMPLE);
        S_SAMPLE:begin sampler_mode<=SAMP_EXPAND_S;sampler_eta<=eta_q;sampler_dst<=8'(row);hash(KEC_SHAKE256,1,66,4096,1,S_NTT);end
        S_NTT:poly(PRIM_NTT_FWD,8'(row),0,0,S_NEXT);
        S_NEXT:if(row+1<l) begin row<=row+1'b1;nonce<=nonce+1'b1;state<=S_SAMPLE;end
          else begin row<=0;nonce<=16'(l);state<=E_SAMPLE;end
        E_SAMPLE:begin sampler_mode<=SAMP_EXPAND_S;sampler_eta<=eta_q;sampler_dst<=8'd8+8'(row);idx<=0;col<=0;hash(KEC_SHAKE256,1,66,4096,1,ZERO_ACC);end
        ZERO_ACC:write_word(16'd6144+idx,0,ZERO_NEXT);
        ZERO_NEXT:if(idx==255) begin idx<=0;state<=MATRIX;end else begin idx<=idx+1'b1;state<=ZERO_ACC;end
        MATRIX:begin sampler_mode<=SAMP_EXPAND_A;sampler_eta<=eta_q;sampler_dst<=25;hash(KEC_SHAKE128,2,34,4096,1,MATRIX_MAC);end
        MATRIX_MAC:poly(PRIM_PW_MAC,25,8'(col),24,MATRIX_NEXT);
        MATRIX_NEXT:if(col+1<l) begin col<=col+1'b1;state<=MATRIX;end else state<=INV;
        INV:poly(PRIM_NTT_INV,24,0,0,ADD_E);
        ADD_E:begin idx<=0;poly(PRIM_ADD,24,8'd8+8'(row),24,SPLIT);end
        SPLIT:read_word(16'd6144+idx,SPLIT_READ);
        SPLIT_READ:begin
          low_encoded<=32'd4096-rd+(((rd+4095)>>13)<<13);
          write_word(16'd6912+idx,(rd+4095)>>13,SPLIT_LOW);
        end
        SPLIT_LOW:write_word(16'd4096+16'(row)*256+idx,low_encoded,SPLIT_NEXT);
        SPLIT_NEXT:if(idx==255) begin idx<=0;state<=PACK_T;end else begin idx<=idx+1'b1;state<=SPLIT;end
        PACK_T:codec(10,27,26,COPY_PK);
        COPY_PK:read_word(16'd6656+idx,COPY_PK_READ);
        COPY_PK_READ:write_word(16'd7176+16'(row)*80+idx,rd,COPY_PK_NEXT);
        COPY_PK_NEXT:if(idx==79) state<=ROW_NEXT;else begin idx<=idx+1'b1;state<=COPY_PK;end
        ROW_NEXT:if(row+1<k) begin row<=row+1'b1;nonce<=nonce+1'b1;state<=E_SAMPLE;end else begin idx<=0;state<=RHO_WRITE;end
        RHO_WRITE:write_word(16'd7168+idx,{seed[4*idx+3],seed[4*idx+2],seed[4*idx+1],seed[4*idx]},RHO_NEXT);
        RHO_NEXT:if(idx==7) begin idx<=0;state<=HASH_PK;end else begin idx<=idx+1'b1;state<=RHO_WRITE;end
        HASH_PK:hash(KEC_SHAKE256,3,pk_bytes,64,0,SK_HEADER);
        SK_HEADER:begin
          if(idx<8) generated_word({seed[4*idx+3],seed[4*idx+2],seed[4*idx+1],seed[4*idx]},0,SK_HEADER_NEXT);
          else if(idx<16) generated_word({seed[64+4*idx+3],seed[64+4*idx+2],seed[64+4*idx+1],seed[64+4*idx]},0,SK_HEADER_NEXT);
          else generated_word({tr[4*(idx-16)+3],tr[4*(idx-16)+2],tr[4*(idx-16)+1],tr[4*(idx-16)]},0,SK_HEADER_NEXT);
        end
        SK_HEADER_NEXT:if(idx==31) begin idx<=0;row<=0;sk_part<=0;sk_page<=0;state<=SK_S_INV;end else begin idx<=idx+1'b1;state<=SK_HEADER;end
        SK_S_INV:poly(PRIM_NTT_INV,sk_page,0,0,SK_CONVERT);
        SK_CONVERT:read_word({sk_page,8'd0}+idx,SK_CONVERT_READ);
        SK_CONVERT_READ:write_word(16'd6912+idx,sk_part==2 ? rd : rd>Q/2 ? 32'(eta_q)+Q-rd : 32'(eta_q)-rd,SK_CONVERT_NEXT);
        SK_CONVERT_NEXT:if(idx==255) begin idx<=0;state<=SK_PACK;end else begin idx<=idx+1'b1;state<=SK_CONVERT;end
        SK_PACK:begin packed_words<=sk_part==2?104:16'(eta_bits)*8;codec(sk_part==2?5'd13:eta_bits,27,26,SK_COPY);end
        SK_COPY:read_word(16'd6656+idx,SK_READ);
        SK_READ:generated_word(rd,sk_part==2 && row+1==k && idx+1==packed_words,SK_NEXT);
        SK_NEXT:if(idx+1==packed_words) state<=SK_ROW_NEXT;else begin idx<=idx+1'b1;state<=SK_COPY;end
        SK_ROW_NEXT:begin
          idx<=0;
          if(row+1<(sk_part==0?l:k)) begin row<=row+1'b1;sk_page<=sk_page+1'b1;state<=sk_part==0?SK_S_INV:SK_CONVERT;end
          else if(sk_part<2) begin sk_part<=sk_part+1'b1;row<=0;sk_page<=sk_part==0?8:16;state<=SK_CONVERT;end
          else state<=WIPE;
        end
        WIPE:write_word(idx,0,WIPE_NEXT);
        WIPE_NEXT:if(idx==7167) state<=FINISH;else begin idx<=idx+1'b1;state<=WIPE;end
        GWORD:if(generated_ready) begin generated_last_q<=0;state<=ret;end
        MREAD:if(mem_ready) begin rd<=mem_rdata;state<=ret;end
        MWRITE:if(mem_ready) state<=ret;
        PSTART:state<=PWAIT;PWAIT:if(poly_done) state<=ret;
        CSTART:state<=CWAIT;CWAIT:if(codec_done) state<=ret;
        HSTART:state<=hash_kind==3?H_PK:H_BYTE;
        H_PK:if(mem_ready) begin rd<=mem_rdata;state<=H_BYTE;end
        H_BYTE:if(hash_in_ready) begin hidx<=hidx+1'b1;if(hash_in_last) state<=H_OUT;else if(hash_kind==3) state<=H_PK;end
        H_OUT:begin
          if(hash_out_valid && hash_out_ready) begin
            if(!sample_hash) begin if(hash_kind==0) seed[houtput_idx[6:0]]<=hash_out_data;else tr[houtput_idx[5:0]]<=hash_out_data;end
            houtput_idx<=houtput_idx+1'b1;
          end
          if(hash_done) hash_seen<=1;if(sampler_done) sample_seen<=1;
          if(sampler_error) state<=FAILED;
          else if((hash_seen || hash_done) && (!sample_hash || sample_seen || sampler_done)) state<=H_DONE;
          else if(hash_seen && sample_hash && !sample_seen && !sampler_done && sampler_ready) state<=FAILED;
        end
        H_DONE:state<=hash_ret;
        FINISH:begin
          for(int n=0;n<32;n++) xi[n]<=0;
          for(int n=0;n<128;n++) seed[n]<=0;
          for(int n=0;n<64;n++) tr[n]<=0;
          rd<=0;write_data<=0;low_encoded<=0;state<=IDLE;
        end
        FAILED:state<=FAILED;
        default:state<=FAILED;
      endcase
    end
  end
endmodule
