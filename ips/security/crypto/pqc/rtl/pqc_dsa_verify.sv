// ML-DSA pure Verify program; no software oracle at runtime.
module pqc_dsa_verify #(parameter int unsigned MAX_CYCLES=100000000) (
  input logic clk, rst_n, start, clear,
  input logic [3:0] pset,
  output logic busy, done, error,
  output logic mem_req, mem_we,
  output logic [15:0] mem_addr,
  output logic [31:0] mem_wdata,
  input logic mem_ready,
  input logic [31:0] mem_rdata,
  input logic [39:0] message_addr,
  input logic [63:0] message_bytes,
  input logic [7:0] context_bytes,
  output logic verify_valid,
  output logic message_dma_req,
  output logic [39:0] message_dma_addr,
  output logic [63:0] message_dma_len,
  input logic message_dma_done,message_dma_error,
  output logic poly_start,
  output logic [3:0] poly_op,
  output logic [7:0] poly_src, poly_src2, poly_dst,
  input logic poly_done,
  output logic codec_start,
  output logic [3:0] codec_op,
  output logic [4:0] codec_bits,
  output logic [7:0] codec_src, codec_src2, codec_dst,
  output logic [1:0] codec_gamma2,
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
  localparam logic[31:0] Q=8380417;
  typedef enum logic[7:0] {
    IDLE,RHO,RHO_READ,CT,CT_READ,HINT_LOAD,HINT_READ,HINT_ROW,HINT_ITEM,HINT_TAIL,
    Z_COPY,Z_READ,Z_WRITE,Z_UNPACK,Z_CONVERT,Z_CONVERT_READ,Z_CONVERT_NEXT,Z_NTT,Z_NEXT,
    HASH_PK,HASH_MU,CHALLENGE,C_NTT,T_COPY,T_READ,T_WRITE,T_UNPACK,T_NEG,T_NEG_READ,T_NEG_NEXT,T_NTT,
    ZERO_ACC,ZERO_NEXT,MATRIX,MATRIX_MAC,MATRIX_NEXT,T_MAC,INV,HINT_ZERO,HINT_ZERO_NEXT,HINT_SET,HINT_SET_NEXT,
    USE_HINT,PACK_W1,W1_COPY,W1_READ,W1_NEXT,ROW_NEXT,HASH_CHALLENGE,COMPARE,COMPARE_DONE,
    MREAD,MWRITE,PSTART,PWAIT,CSTART,CWAIT,HSTART,H_MEM,H_BYTE,H_OUT,H_DONE,MESSAGE_DMA,
    FINISH,FAILED
  } state_t;
  state_t state,ret,hash_ret;
  logic[3:0] pset_q,k,l,row,col;
  logic[7:0] ct_bytes,omega,beta,context_q;
  logic[4:0] z_bits,w1_bits;
  logic[15:0] pk_bytes,idx,address,byte_offset,hint_base,hint_index,hint_end,hint_prev;
  logic[31:0] rd,write_data,gamma1,cycles;
  logic[39:0] message_addr_q;
  logic[63:0] message_bytes_q,hidx,hinput_len,message_offset;
  logic[15:0] houtput_idx;
  logic[2:0] hash_kind;
  logic[1:0] mem_byte_lane;
  logic[7:0] input_byte;
  logic[7:0] rho[0:31],ctilde[0:63],tr[0:63],mu[0:63],digest[0:63],hint[0:87];
  logic sample_hash,hash_seen,sample_seen,norm_bad,equal_acc;
  logic[7:0] diff_acc;
  assign busy=state!=IDLE && state!=FINISH && state!=FAILED;
  assign done=rst_n && !clear && state==FINISH;
  assign error=rst_n && !clear && state==FAILED;
  assign message_offset=hidx-64'd66-{56'd0,context_q};
  assign message_dma_req=rst_n && !clear && state==MESSAGE_DMA;
  assign message_dma_addr=message_addr_q+40'(message_offset);
  assign message_dma_len=(message_bytes_q-message_offset)>1024 ? 64'd1024 : message_bytes_q-message_offset;
  assign mem_req=rst_n && !clear && (state==MREAD || state==MWRITE || state==H_MEM);
  assign mem_we=mem_req && state==MWRITE;
  assign mem_wdata=write_data;
  assign input_byte=rd[8*byte_offset[1:0]+:8];
  always_comb begin
    mem_addr=address;mem_byte_lane=hidx[1:0];
    if(state==H_MEM || state==H_BYTE) case(hash_kind)
      0:mem_addr=16'd4352+16'(hidx>>2);
      1:if(hidx<64'd66+{56'd0,context_q}) begin
          mem_addr=16'd6912+16'((hidx-66)>>2);mem_byte_lane=2'(hidx-66);
        end else begin mem_addr=16'd7168+{8'd0,message_offset[9:2]};mem_byte_lane=message_offset[1:0];end
      4:begin mem_addr=16'd3328+16'((hidx-64)>>2);mem_byte_lane=2'(hidx-64);end
      default:;
    endcase
  end
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
      0:hash_in_data=rd[8*mem_byte_lane+:8];
      1:hash_in_data=hidx<64 ? tr[hidx[5:0]] : hidx==64 ? 8'd0 : hidx==65 ? context_q : rd[8*mem_byte_lane+:8];
      2:hash_in_data=ctilde[hidx[5:0]];
      3:hash_in_data=hidx<32 ? rho[hidx[4:0]] : hidx==32 ? {4'd0,col} : {4'd0,row};
      4:hash_in_data=hidx<64 ? mu[hidx[5:0]] : rd[8*mem_byte_lane+:8];
      default:hash_in_data=0;
    endcase
  end
  task automatic read_word(input logic[15:0] a,input state_t nxt);
    address<=a;ret<=nxt;state<=MREAD;
  endtask
  task automatic read_input_byte(input logic[15:0] a,input state_t nxt);
    byte_offset<=a;address<=16'd4352+(a>>2);ret<=nxt;state<=MREAD;
  endtask
  task automatic write_word(input logic[15:0] a,input logic[31:0] d,input state_t nxt);
    address<=a;write_data<=d;ret<=nxt;state<=MWRITE;
  endtask
  task automatic poly(input logic[3:0] op,input logic[7:0] a,b,c,input state_t nxt);
    poly_op<=op;poly_src<=a;poly_src2<=b;poly_dst<=c;ret<=nxt;state<=PSTART;
  endtask
  task automatic codec(input logic[3:0] op,input logic[4:0] bits,input logic[7:0] a,b,c,input state_t nxt);
    codec_op<=op;codec_bits<=bits;codec_src<=a;codec_src2<=b;codec_dst<=c;ret<=nxt;state<=CSTART;
  endtask
  task automatic hash(input logic[2:0] fn,input logic[2:0] kind,input logic[63:0] ilen,
                      input logic[31:0] olen,input logic sample,input state_t nxt);
    hash_function<=fn;hash_kind<=kind;hinput_len<=ilen;hash_length<=olen;
    hidx<=0;houtput_idx<=0;sample_hash<=sample;hash_seen<=0;sample_seen<=0;hash_ret<=nxt;state<=HSTART;
  endtask
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;
      idx<=0;address<=0;byte_offset<=0;hint_base<=0;hint_index<=0;hint_end<=0;hint_prev<=0;
      rd<=0;write_data<=0;gamma1<=0;cycles<=0;message_addr_q<=0;message_bytes_q<=0;context_q<=0;
      ct_bytes<=0;omega<=0;beta<=0;z_bits<=0;w1_bits<=0;pk_bytes<=0;verify_valid<=0;
      hidx<=0;hinput_len<=0;houtput_idx<=0;hash_kind<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;
      norm_bad<=0;equal_acc<=1;diff_acc<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;
      codec_op<=0;codec_bits<=0;codec_src<=0;codec_src2<=0;codec_dst<=0;codec_gamma2<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) rho[n]<=0;
      for(int n=0;n<64;n++) begin ctilde[n]<=0;tr[n]<=0;mu[n]<=0;digest[n]<=0;end
      for(int n=0;n<88;n++) hint[n]<=0;
    end else if(clear) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;
      idx<=0;address<=0;byte_offset<=0;hint_base<=0;hint_index<=0;hint_end<=0;hint_prev<=0;
      rd<=0;write_data<=0;gamma1<=0;cycles<=0;message_addr_q<=0;message_bytes_q<=0;context_q<=0;
      ct_bytes<=0;omega<=0;beta<=0;z_bits<=0;w1_bits<=0;pk_bytes<=0;verify_valid<=0;
      hidx<=0;hinput_len<=0;houtput_idx<=0;hash_kind<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;
      norm_bad<=0;equal_acc<=1;diff_acc<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;
      codec_op<=0;codec_bits<=0;codec_src<=0;codec_src2<=0;codec_dst<=0;codec_gamma2<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) rho[n]<=0;
      for(int n=0;n<64;n++) begin ctilde[n]<=0;tr[n]<=0;mu[n]<=0;digest[n]<=0;end
      for(int n=0;n<88;n++) hint[n]<=0;
    end else begin
      if(busy) cycles<=cycles+1'b1;
      if(busy && cycles>=MAX_CYCLES-1) state<=FAILED;
      else case(state)
        IDLE:if(start) begin
          pset_q<=pset;verify_valid<=0;norm_bad<=0;equal_acc<=1;diff_acc<=0;cycles<=0;idx<=0;row<=0;col<=0;
          message_addr_q<=message_addr;message_bytes_q<=message_bytes;context_q<=context_bytes;
          k<=pset==4 ? 4 : pset==5 ? 6 : 8;l<=pset==4 ? 4 : pset==5 ? 5 : 7;
          ct_bytes<=pset==4 ? 32 : pset==5 ? 48 : 64;omega<=pset==4 ? 80 : pset==5 ? 55 : 75;
          beta<=pset==4 ? 78 : pset==5 ? 196 : 120;gamma1<=pset==4 ? 131072 : 524288;
          pk_bytes<=pset==4 ? 1312 : pset==5 ? 1952 : 2592;
          z_bits<=pset==4 ? 18 : 20;w1_bits<=pset==4 ? 6 : 4;codec_gamma2<=pset==4 ? 0 : 1;
          state<=(pset>=4 && pset<=6) ? RHO : FAILED;
        end
        RHO:read_input_byte(idx,RHO_READ);
        RHO_READ:begin rho[idx]<=input_byte;if(idx==31) begin idx<=0;state<=CT;end else begin idx<=idx+1'b1;state<=RHO;end end
        CT:read_input_byte(pk_bytes+idx,CT_READ);
        CT_READ:begin ctilde[idx]<=input_byte;if(idx+1==ct_bytes) begin idx<=0;state<=HINT_LOAD;end else begin idx<=idx+1'b1;state<=CT;end end
        HINT_LOAD:read_input_byte(pk_bytes+16'(ct_bytes)+16'(l)*16'(z_bits)*32+idx,HINT_READ);
        HINT_READ:begin
          hint[idx]<=input_byte;
          if(idx+1==16'(omega)+16'(k)) begin row<=0;hint_index<=0;hint_base<=0;state<=HINT_ROW;end
          else begin idx<=idx+1'b1;state<=HINT_LOAD;end
        end
        HINT_ROW:if(hint[omega+row]<hint_base || hint[omega+row]>omega) state<=FINISH;
          else begin hint_end<={8'd0,hint[omega+row]};hint_prev<=0;state<=HINT_ITEM;end
        HINT_ITEM:if(hint_index==hint_end) begin
            hint_base<=hint_end;
            if(row+1==k) state<=HINT_TAIL;else begin row<=row+1'b1;state<=HINT_ROW;end
          end else if(hint_index!=hint_base && {8'd0,hint[hint_index]}<=hint_prev) state<=FINISH;
          else begin hint_prev<={8'd0,hint[hint_index]};hint_index<=hint_index+1'b1;end
        HINT_TAIL:if(hint_index==omega) begin row<=0;idx<=0;state<=Z_COPY;end
          else if(hint[hint_index]!=0) state<=FINISH;else hint_index<=hint_index+1'b1;
        Z_COPY:read_word(16'd4352+(pk_bytes+16'(ct_bytes))/4+16'(row)*16'(z_bits)*8+idx,Z_READ);
        Z_READ:write_word(16'd3072+idx,rd,Z_WRITE);
        Z_WRITE:if(idx+1==16'(z_bits)*8) begin idx<=0;state<=Z_UNPACK;end else begin idx<=idx+1'b1;state<=Z_COPY;end
        Z_UNPACK:codec(1,z_bits,12,0,8'(row),Z_CONVERT);
        Z_CONVERT:read_word({4'd0,row,8'd0}+idx,Z_CONVERT_READ);
        Z_CONVERT_READ:begin
          if(rd<=32'(beta) || rd>=2*gamma1-32'(beta)) norm_bad<=1;
          write_word({4'd0,row,8'd0}+idx,rd>gamma1 ? Q+gamma1-rd : gamma1-rd,Z_CONVERT_NEXT);
        end
        Z_CONVERT_NEXT:if(idx==255) state<=Z_NTT;else begin idx<=idx+1'b1;state<=Z_CONVERT;end
        Z_NTT:poly(PRIM_NTT_FWD,8'(row),0,0,Z_NEXT);
        Z_NEXT:if(row+1<l) begin row<=row+1'b1;idx<=0;state<=Z_COPY;end else state<=HASH_PK;
        HASH_PK:hash(KEC_SHAKE256,0,{48'd0,pk_bytes},64,0,HASH_MU);
        HASH_MU:hash(KEC_SHAKE256,1,64'd66+{56'd0,context_q}+message_bytes_q,64,0,CHALLENGE);
        CHALLENGE:begin
          sampler_mode<=SAMP_IN_BALL;sampler_eta<=2;sampler_dst<=9;
          hash(KEC_SHAKE256,2,{56'd0,ct_bytes},4096,1,C_NTT);
        end
        C_NTT:begin row<=0;idx<=0;poly(PRIM_NTT_FWD,9,0,0,T_COPY);end
        T_COPY:read_word(16'd4360+16'(row)*80+idx,T_READ);
        T_READ:write_word(16'd3072+idx,rd,T_WRITE);
        T_WRITE:if(idx==79) begin idx<=0;state<=T_UNPACK;end else begin idx<=idx+1'b1;state<=T_COPY;end
        T_UNPACK:codec(1,10,12,0,10,T_NEG);
        T_NEG:read_word(16'd2560+idx,T_NEG_READ);
        T_NEG_READ:write_word(16'd2560+idx,rd==0 ? 32'd0 : Q-(rd<<13),T_NEG_NEXT);
        T_NEG_NEXT:if(idx==255) state<=T_NTT;else begin idx<=idx+1'b1;state<=T_NEG;end
        T_NTT:begin idx<=0;col<=0;poly(PRIM_NTT_FWD,10,0,0,ZERO_ACC);end
        ZERO_ACC:write_word(16'd1792+idx,0,ZERO_NEXT);
        ZERO_NEXT:if(idx==255) begin idx<=0;state<=MATRIX;end else begin idx<=idx+1'b1;state<=ZERO_ACC;end
        MATRIX:begin sampler_mode<=SAMP_EXPAND_A;sampler_eta<=2;sampler_dst<=8;hash(KEC_SHAKE128,3,34,4096,1,MATRIX_MAC);end
        MATRIX_MAC:poly(PRIM_PW_MAC,8,8'(col),7,MATRIX_NEXT);
        MATRIX_NEXT:if(col+1<l) begin col<=col+1'b1;state<=MATRIX;end else state<=T_MAC;
        T_MAC:poly(PRIM_PW_MAC,9,10,7,INV);
        INV:begin idx<=0;poly(PRIM_NTT_INV,7,0,0,HINT_ZERO);end
        HINT_ZERO:write_word(16'd2816+idx,0,HINT_ZERO_NEXT);
        HINT_ZERO_NEXT:if(idx==255) begin
            hint_index<=row==0 ? 16'd0 : {8'd0,hint[omega+row-1]};hint_end<={8'd0,hint[omega+row]};state<=HINT_SET;
          end else begin idx<=idx+1'b1;state<=HINT_ZERO;end
        HINT_SET:if(hint_index==hint_end) state<=USE_HINT;
          else write_word(16'd2816+{8'd0,hint[hint_index]},1,HINT_SET_NEXT);
        HINT_SET_NEXT:begin hint_index<=hint_index+1'b1;state<=HINT_SET;end
        USE_HINT:codec(7,0,7,11,10,PACK_W1);
        PACK_W1:begin idx<=0;codec(0,w1_bits,10,0,12,W1_COPY);end
        W1_COPY:read_word(16'd3072+idx,W1_READ);
        W1_READ:write_word(16'd3328+16'(row)*16'(w1_bits)*8+idx,rd,W1_NEXT);
        W1_NEXT:if(idx+1==16'(w1_bits)*8) state<=ROW_NEXT;else begin idx<=idx+1'b1;state<=W1_COPY;end
        ROW_NEXT:if(row+1<k) begin row<=row+1'b1;idx<=0;state<=T_COPY;end else state<=HASH_CHALLENGE;
        HASH_CHALLENGE:begin idx<=0;hash(KEC_SHAKE256,4,64'd64+64'(k)*64'(w1_bits)*32,32'(ct_bytes),0,COMPARE);end
        COMPARE:begin
          diff_acc<=diff_acc|(digest[idx]^ctilde[idx]);equal_acc<=equal_acc && digest[idx]==ctilde[idx];
          if(idx+1==ct_bytes) state<=COMPARE_DONE;else idx<=idx+1'b1;
        end
        COMPARE_DONE:begin verify_valid<=!norm_bad && diff_acc==0 && equal_acc;state<=FINISH;end
        MREAD:if(mem_ready) begin rd<=mem_rdata;state<=ret;end
        MWRITE:if(mem_ready) state<=ret;
        PSTART:state<=PWAIT;PWAIT:if(poly_done) state<=ret;
        CSTART:state<=CWAIT;CWAIT:if(codec_done) state<=ret;
        HSTART:state<=hash_kind==0 ? H_MEM : H_BYTE;
        H_MEM:if(mem_ready) begin rd<=mem_rdata;state<=H_BYTE;end
        MESSAGE_DMA:if(message_dma_error) state<=FAILED;else if(message_dma_done) state<=H_MEM;
        H_BYTE:if(hash_in_ready) begin
          hidx<=hidx+1'b1;
          if(hash_in_last) state<=H_OUT;
          else if(hash_kind==0) state<=H_MEM;
          else if(hash_kind==1 && hidx+1>=66) begin
            if(hidx+1>=64'd66+{56'd0,context_q} && 10'(hidx+1-66-{56'd0,context_q})==0) state<=MESSAGE_DMA;
            else state<=H_MEM;
          end else if(hash_kind==4 && hidx+1>=64) state<=H_MEM;
        end
        H_OUT:begin
          if(hash_out_valid && hash_out_ready) begin
            if(!sample_hash) case(hash_kind)
              0:tr[houtput_idx[5:0]]<=hash_out_data;
              1:mu[houtput_idx[5:0]]<=hash_out_data;
              4:digest[houtput_idx[5:0]]<=hash_out_data;
              default:;
            endcase
            houtput_idx<=houtput_idx+1'b1;
          end
          if(sampler_done) sample_seen<=1;if(hash_done) hash_seen<=1;
          if(sampler_error) state<=FAILED;
          else if((hash_seen || hash_done) && (!sample_hash || sample_seen || sampler_done)) state<=H_DONE;
          else if(hash_seen && sample_hash && !sample_seen && !sampler_done && sampler_ready) state<=FAILED;
        end
        H_DONE:state<=hash_ret;
        FINISH:state<=IDLE;
        FAILED:state<=FAILED;
        default:state<=FAILED;
      endcase
    end
  end
endmodule
