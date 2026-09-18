// ML-DSA pure Sign program; shared arithmetic and bounded complete attempts.
module pqc_dsa_sign #(parameter int unsigned MAX_CYCLES=750000000, MAX_ATTEMPTS=256, ATTEMPT_CYCLES=1500000, ATTEMPT_CYCLES_87=2250000) (
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
  input logic hedged,
  input logic entropy_valid,entropy_health_ok,
  input logic [7:0] entropy_tag,
  input logic [63:0] entropy_data,
  output logic entropy_ready,
  output logic wk_read_req,
  output logic [15:0] wk_read_word,
  input logic wk_read_valid,wk_read_error,
  input logic [31:0] wk_read_data,
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
  typedef enum logic[7:0] {IDLE,HEADER,HEADER_READ,ENTROPY,HASH_MU,DERIVE,
    LOAD_S,LOAD_SK,LOAD_SK_READ,LOAD_SK_WRITE,UNPACK_SK,CONVERT_SK,CONVERT_SK_READ,CONVERT_SK_NEXT,NTT_SK,SK_RETURN,
    ATTEMPT,Y_SAMPLE,Y_NTT,Y_NEXT,ZERO_ACC,ZERO_NEXT,MATRIX,MATRIX_MAC,MATRIX_NEXT,INV_W,
    HIGH_W,HIGH_READ,HIGH_NEXT,PACK_W,COPY_W,COPY_W_READ,COPY_W_NEXT,W_ROW_NEXT,
    HASH_C,CHALLENGE,C_NTT,Z_ZERO,Z_ZERO_NEXT,Z_MAC,Z_INV,Y_COPY,Y_COPY_READ,Y_COPY_NEXT,Y_INV,Z_ADD,
    Z_SCAN,Z_SCAN_READ,Z_SCAN_NEXT,Z_PACK,Z_COPY,Z_COPY_READ,Z_COPY_NEXT,Z_NEXT,
    CS_ZERO,CS_ZERO_NEXT,CS_MAC,CS_INV,CS_SUB,R_SCAN,R_SCAN_READ,R_SCAN_NEXT,
    CT_ZERO,CT_ZERO_NEXT,CT_MAC,CT_INV,H_SCAN,H_SCAN_READ,H_SCAN_PAIR,H_SCAN_NEXT,H_ROW_NEXT,
    BOUNDARY,SAVE_C,SAVE_C_NEXT,SAVE_H,SAVE_H_NEXT,WIPE,WIPE_NEXT,
    MREAD,MWRITE,WK_REQ,WK_WAIT,PSTART,PWAIT,CSTART,CWAIT,HSTART,H_MEM,H_BYTE,H_OUT,H_DONE,MESSAGE_DMA,FINISH,FAILED} state_t;
  state_t state,ret,hash_ret,load_ret;
  logic[3:0] pset_q,k,l,row,col,eta_q;
  logic[4:0] eta_bits,z_bits,w1_bits;
  logic[7:0] ct_bytes,omega,beta,context_q;
  logic[31:0] gamma1,gamma2,rd,write_data,cycles,attempt_cycles,held_coeff;
  logic[15:0] idx,address,wk_address,key_offset,packed_words,nonce,kappa,attempt;
  logic[7:0] key_page;
  logic[1:0] key_kind;
  logic[2:0] entropy_word,hash_kind;
  logic[39:0] message_addr_q;
  logic[63:0] message_bytes_q,hidx,hinput_len,message_offset;
  logic[15:0] houtput_idx;
  logic[1:0] mem_byte_lane;
  logic[11:0] hint_count;
  wire [31:0] attempt_limit=(pset_q==6) ? ATTEMPT_CYCLES_87 : ATTEMPT_CYCLES;
  logic second_pass,reject_acc,sample_hash,hash_seen,sample_seen,attempt_active;
  logic[7:0] rho[0:31],key_seed[0:31],rnd[0:31],tr[0:63],mu[0:63],rhoprime[0:63],ctilde[0:63],hint[0:87];
  function automatic logic[31:0] high_bits(input logic[31:0] a);
    logic[31:0] t;
    if(pset_q==4) begin
      t=(a+32'd95231)/32'd190464;
      return t==32'd44 ? 32'd0 : t;
    end
    t=(a+32'd261887)/32'd523776;
    return t==32'd16 ? 32'd0 : t;
  endfunction
  function automatic logic signed[31:0] centered(input logic[31:0] a);return a>Q/2 ? $signed(a)-$signed(Q) : $signed(a);endfunction
  function automatic logic[31:0] abs_center(input logic[31:0] a);return a>Q/2?Q-a:a;endfunction
  function automatic logic[31:0] low_abs(input logic[31:0] a);
    logic signed[31:0] low;low=$signed(a)-$signed(high_bits(a)*2*gamma2);
    if(low>$signed(Q/2)) low=low-$signed(Q);return low<0 ? -low : low;
  endfunction
  function automatic logic[31:0] add_mod(input logic[31:0] a,b);return a+b>=Q?a+b-Q:a+b;endfunction
  assign busy=state!=IDLE && state!=FINISH && state!=FAILED;
  assign done=rst_n && !clear && state==FINISH;
  assign error=rst_n && !clear && state==FAILED;
  assign entropy_ready=rst_n && !clear && state==ENTROPY && entropy_health_ok && entropy_tag=={4'd2,pset_q};
  assign wk_read_req=rst_n && !clear && state==WK_REQ;
  assign wk_read_word=wk_address;
  assign message_offset=hidx-64'd66-{56'd0,context_q};
  assign message_dma_req=rst_n && !clear && state==MESSAGE_DMA;
  assign message_dma_addr=message_addr_q+40'(message_offset);
  assign message_dma_len=message_bytes_q-message_offset>1024 ? 64'd1024 : message_bytes_q-message_offset;
  assign mem_req=rst_n && !clear && (state==MREAD || state==MWRITE || state==H_MEM);
  assign mem_we=mem_req && state==MWRITE;assign mem_wdata=write_data;
  always_comb begin
    mem_addr=address;mem_byte_lane=hidx[1:0];
    if(state==H_MEM || state==H_BYTE) case(hash_kind)
      0:if(hidx<64'd66+{56'd0,context_q}) begin mem_addr=16'd6912+16'((hidx-66)>>2);mem_byte_lane=2'(hidx-66);end
        else begin mem_addr=16'd7168+{8'd0,message_offset[9:2]};mem_byte_lane=message_offset[1:0];end
      4:begin mem_addr=16'd6144+16'((hidx-64)>>2);mem_byte_lane=2'(hidx-64);end
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
      0:hash_in_data=hidx<64?tr[hidx[5:0]]:hidx==64?8'd0:hidx==65?context_q:rd[8*mem_byte_lane+:8];
      1:hash_in_data=hidx<32?key_seed[hidx[4:0]]:hidx<64?rnd[hidx[4:0]]:mu[hidx[5:0]];
      2:hash_in_data=hidx<64?rhoprime[hidx[5:0]]:hidx==64?nonce[7:0]:nonce[15:8];
      3:hash_in_data=hidx<32?rho[hidx[4:0]]:hidx==32?{4'd0,col}:{4'd0,row};
      4:hash_in_data=hidx<64?mu[hidx[5:0]]:rd[8*mem_byte_lane+:8];
      5:hash_in_data=ctilde[hidx[5:0]];
      default:;
    endcase
  end
  task automatic read_word(input logic[15:0] a,input state_t nxt);address<=a;ret<=nxt;state<=MREAD;endtask
  task automatic write_word(input logic[15:0] a,input logic[31:0] d,input state_t nxt);address<=a;write_data<=d;ret<=nxt;state<=MWRITE;endtask
  task automatic read_key(input logic[15:0] a,input state_t nxt);wk_address<=a;ret<=nxt;state<=WK_REQ;endtask
  task automatic poly(input logic[3:0] op,input logic[7:0] a,b,c,input state_t nxt);poly_op<=op;poly_src<=a;poly_src2<=b;poly_dst<=c;ret<=nxt;state<=PSTART;endtask
  task automatic codec(input logic[3:0] op,input logic[4:0] bits,input logic[7:0] a,b,input state_t nxt);
    codec_op<=op;codec_bits<=bits;codec_src<=a;codec_dst<=b;codec_src2<=0;ret<=nxt;state<=CSTART;
  endtask
  task automatic load_sk(input logic[1:0] kind,input logic[7:0] page,input logic[15:0] offset,input state_t nxt);
    key_kind<=kind;key_page<=page;key_offset<=offset;packed_words<=kind==2 ? 104 : 16'(eta_bits)*8;idx<=0;load_ret<=nxt;state<=LOAD_SK;
  endtask
  task automatic hash(input logic[2:0] fn,kind,input logic[63:0] ilen,input logic[31:0] olen,input logic sample,input state_t nxt);
    hash_function<=fn;hash_kind<=kind;hinput_len<=ilen;hash_length<=olen;hidx<=0;houtput_idx<=0;
    sample_hash<=sample;hash_seen<=0;sample_seen<=0;hash_ret<=nxt;state<=HSTART;
  endtask
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;load_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;eta_q<=0;
      eta_bits<=0;z_bits<=0;w1_bits<=0;ct_bytes<=0;omega<=0;beta<=0;context_q<=0;gamma1<=0;gamma2<=0;
      rd<=0;write_data<=0;cycles<=0;attempt_cycles<=0;held_coeff<=0;idx<=0;address<=0;wk_address<=0;key_offset<=0;
      packed_words<=0;nonce<=0;kappa<=0;attempt<=0;key_page<=0;key_kind<=0;entropy_word<=0;hash_kind<=0;
      message_addr_q<=0;message_bytes_q<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;hint_count<=0;
      second_pass<=0;reject_acc<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;attempt_active<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;codec_op<=0;codec_bits<=0;codec_src<=0;codec_src2<=0;codec_dst<=0;codec_gamma2<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) begin rho[n]<=0;key_seed[n]<=0;rnd[n]<=0;end
      for(int n=0;n<64;n++) begin tr[n]<=0;mu[n]<=0;rhoprime[n]<=0;ctilde[n]<=0;end
      for(int n=0;n<88;n++) hint[n]<=0;
    end else if(clear) begin
      state<=IDLE;ret<=IDLE;hash_ret<=IDLE;load_ret<=IDLE;pset_q<=0;k<=0;l<=0;row<=0;col<=0;eta_q<=0;
      eta_bits<=0;z_bits<=0;w1_bits<=0;ct_bytes<=0;omega<=0;beta<=0;context_q<=0;gamma1<=0;gamma2<=0;
      rd<=0;write_data<=0;cycles<=0;attempt_cycles<=0;held_coeff<=0;idx<=0;address<=0;wk_address<=0;key_offset<=0;
      packed_words<=0;nonce<=0;kappa<=0;attempt<=0;key_page<=0;key_kind<=0;entropy_word<=0;hash_kind<=0;
      message_addr_q<=0;message_bytes_q<=0;hidx<=0;hinput_len<=0;houtput_idx<=0;hint_count<=0;
      second_pass<=0;reject_acc<=0;sample_hash<=0;hash_seen<=0;sample_seen<=0;attempt_active<=0;
      poly_op<=0;poly_src<=0;poly_src2<=0;poly_dst<=0;codec_op<=0;codec_bits<=0;codec_src<=0;codec_src2<=0;codec_dst<=0;codec_gamma2<=0;
      sampler_mode<=0;sampler_eta<=0;sampler_dst<=0;hash_function<=0;hash_length<=0;
      for(int n=0;n<32;n++) begin rho[n]<=0;key_seed[n]<=0;rnd[n]<=0;end
      for(int n=0;n<64;n++) begin tr[n]<=0;mu[n]<=0;rhoprime[n]<=0;ctilde[n]<=0;end
      for(int n=0;n<88;n++) hint[n]<=0;
    end else begin
      if(busy) cycles<=cycles+1'b1;
      if(attempt_active) attempt_cycles<=attempt_cycles+1'b1;
      if(busy && (cycles>=MAX_CYCLES-1 || (attempt_active && attempt_cycles>=attempt_limit && state!=BOUNDARY))) state<=FAILED;
      else case(state)
        IDLE:if(start) begin
          pset_q<=pset;k<=pset==4?4:pset==5?6:8;l<=pset==4?4:pset==5?5:7;
          eta_q<=pset==5?4:2;eta_bits<=pset==5?4:3;z_bits<=pset==4?18:20;w1_bits<=pset==4?6:4;
          ct_bytes<=pset==4?32:pset==5?48:64;omega<=pset==4?80:pset==5?55:75;beta<=pset==4?78:pset==5?196:120;
          gamma1<=pset==4?131072:524288;gamma2<=pset==4?95232:261888;codec_gamma2<=pset==4?0:1;
          message_addr_q<=message_addr;message_bytes_q<=message_bytes;context_q<=context_bytes;idx<=0;row<=0;col<=0;
          cycles<=0;attempt_cycles<=0;attempt_active<=0;attempt<=0;kappa<=0;nonce<=0;entropy_word<=0;
          for(int n=0;n<32;n++) rnd[n]<=0;
          state<=(pset>=4 && pset<=6)?HEADER:FAILED;
        end
        HEADER:read_key(idx,HEADER_READ);
        HEADER_READ:begin
          for(int b=0;b<4;b++) begin
            if(idx<8) rho[4*idx+b]<=rd[8*b+:8];else if(idx<16) key_seed[4*(idx-8)+b]<=rd[8*b+:8];else tr[4*(idx-16)+b]<=rd[8*b+:8];
          end
          if(idx==31) begin idx<=0;state<=hedged?ENTROPY:HASH_MU;end else begin idx<=idx+1'b1;state<=HEADER;end
        end
        ENTROPY:if(entropy_valid && entropy_ready) begin
          for(int b=0;b<8;b++) rnd[8*entropy_word+b]<=entropy_data[8*b+:8];
          if(entropy_word==3) state<=HASH_MU;else entropy_word<=entropy_word+1'b1;
        end
        HASH_MU:hash(KEC_SHAKE256,0,64'd66+{56'd0,context_q}+message_bytes_q,64,0,DERIVE);
        DERIVE:hash(KEC_SHAKE256,1,128,64,0,LOAD_S);
        LOAD_S:load_sk(0,8'(row),16'd32+16'(row)*16'(eta_bits)*8,SK_RETURN);
        LOAD_SK:read_key(key_offset+idx,LOAD_SK_READ);
        LOAD_SK_READ:write_word(16'd6656+idx,rd,LOAD_SK_WRITE);
        LOAD_SK_WRITE:if(idx+1==packed_words) begin idx<=0;state<=UNPACK_SK;end else begin idx<=idx+1'b1;state<=LOAD_SK;end
        UNPACK_SK:codec(1,key_kind==2?5'd13:eta_bits,26,key_page,CONVERT_SK);
        CONVERT_SK:read_word({key_page,8'd0}+idx,CONVERT_SK_READ);
        CONVERT_SK_READ:begin
          if(key_kind!=2 && rd>2*32'(eta_q)) state<=FAILED;
          else write_word({key_page,8'd0}+idx,rd>(key_kind==2?4096:32'(eta_q)) ? Q+(key_kind==2?4096:32'(eta_q))-rd : (key_kind==2?4096:32'(eta_q))-rd,CONVERT_SK_NEXT);
        end
        CONVERT_SK_NEXT:if(idx==255) state<=NTT_SK;else begin idx<=idx+1'b1;state<=CONVERT_SK;end
        NTT_SK:poly(PRIM_NTT_FWD,key_page,0,0,load_ret);
        SK_RETURN:if(row+1<l) begin row<=row+1'b1;state<=LOAD_S;end else state<=ATTEMPT;
        ATTEMPT:begin
          attempt_active<=1;attempt_cycles<=0;reject_acc<=0;hint_count<=0;row<=0;col<=0;nonce<=kappa;second_pass<=0;
          for(int n=0;n<88;n++) hint[n]<=0;
          state<=Y_SAMPLE;
        end
        Y_SAMPLE:begin sampler_mode<=SAMP_EXPAND_MASK;sampler_eta<=eta_q;sampler_dst<=8'd7+8'(row);hash(KEC_SHAKE256,2,66,4096,1,Y_NTT);end
        Y_NTT:poly(PRIM_NTT_FWD,8'd7+8'(row),0,0,Y_NEXT);
        Y_NEXT:if(row+1<l) begin row<=row+1'b1;nonce<=nonce+1'b1;state<=Y_SAMPLE;end else begin row<=0;col<=0;idx<=0;state<=ZERO_ACC;end
        ZERO_ACC:write_word(16'd3584+idx,0,ZERO_NEXT);
        ZERO_NEXT:if(idx==255) begin idx<=0;state<=MATRIX;end else begin idx<=idx+1'b1;state<=ZERO_ACC;end
        MATRIX:begin sampler_mode<=SAMP_EXPAND_A;sampler_eta<=eta_q;sampler_dst<=15;hash(KEC_SHAKE128,3,34,4096,1,MATRIX_MAC);end
        MATRIX_MAC:poly(PRIM_PW_MAC,15,8'd7+8'(col),14,MATRIX_NEXT);
        MATRIX_NEXT:if(col+1<l) begin col<=col+1'b1;state<=MATRIX;end else state<=INV_W;
        INV_W:begin idx<=0;poly(PRIM_NTT_INV,14,0,0,HIGH_W);end
        HIGH_W:if(second_pass) load_sk(1,17,16'd32+(16'(l)+16'(row))*16'(eta_bits)*8,CS_ZERO);
          else read_word(16'd3584+idx,HIGH_READ);
        HIGH_READ:write_word(16'd4608+idx,high_bits(rd),HIGH_NEXT);
        HIGH_NEXT:if(idx==255) begin idx<=0;state<=PACK_W;end else begin idx<=idx+1'b1;state<=HIGH_W;end
        PACK_W:codec(0,w1_bits,18,26,COPY_W);
        COPY_W:read_word(16'd6656+idx,COPY_W_READ);
        COPY_W_READ:write_word(16'd6144+16'(row)*16'(w1_bits)*8+idx,rd,COPY_W_NEXT);
        COPY_W_NEXT:if(idx+1==16'(w1_bits)*8) state<=W_ROW_NEXT;else begin idx<=idx+1'b1;state<=COPY_W;end
        W_ROW_NEXT:if(row+1<k) begin row<=row+1'b1;col<=0;idx<=0;state<=ZERO_ACC;end else state<=HASH_C;
        HASH_C:hash(KEC_SHAKE256,4,64'd64+64'(k)*64'(w1_bits)*32,32'(ct_bytes),0,CHALLENGE);
        CHALLENGE:begin sampler_mode<=SAMP_IN_BALL;sampler_dst<=16;sampler_eta<=eta_q;hash(KEC_SHAKE256,5,{56'd0,ct_bytes},4096,1,C_NTT);end
        C_NTT:begin row<=0;idx<=0;poly(PRIM_NTT_FWD,16,0,0,Z_ZERO);end
        Z_ZERO:write_word(16'd4352+idx,0,Z_ZERO_NEXT);
        Z_ZERO_NEXT:if(idx==255) begin idx<=0;state<=Z_MAC;end else begin idx<=idx+1'b1;state<=Z_ZERO;end
        Z_MAC:poly(PRIM_PW_MAC,16,8'(row),17,Z_INV);
        Z_INV:poly(PRIM_NTT_INV,17,0,0,Y_COPY);
        Y_COPY:read_word(16'd1792+16'(row)*256+idx,Y_COPY_READ);
        Y_COPY_READ:write_word(16'd4608+idx,rd,Y_COPY_NEXT);
        Y_COPY_NEXT:if(idx==255) begin idx<=0;state<=Y_INV;end else begin idx<=idx+1'b1;state<=Y_COPY;end
        Y_INV:poly(PRIM_NTT_INV,18,0,0,Z_ADD);
        Z_ADD:poly(PRIM_ADD,17,18,17,Z_SCAN);
        Z_SCAN:read_word(16'd4352+idx,Z_SCAN_READ);
        Z_SCAN_READ:begin
          if(abs_center(rd)>=gamma1-32'(beta)) reject_acc<=1;
          write_word(16'd4608+idx,gamma1-32'(centered(rd)),Z_SCAN_NEXT);
        end
        Z_SCAN_NEXT:if(idx==255) begin idx<=0;state<=Z_PACK;end else begin idx<=idx+1'b1;state<=Z_SCAN;end
        Z_PACK:codec(0,z_bits,18,26,Z_COPY);
        Z_COPY:read_word(16'd6656+idx,Z_COPY_READ);
        Z_COPY_READ:write_word(16'd4864+16'(ct_bytes)/4+16'(row)*16'(z_bits)*8+idx,rd,Z_COPY_NEXT);
        Z_COPY_NEXT:if(idx+1==16'(z_bits)*8) state<=Z_NEXT;else begin idx<=idx+1'b1;state<=Z_COPY;end
        Z_NEXT:begin idx<=0;if(row+1<l) begin row<=row+1'b1;state<=Z_ZERO;end else begin row<=0;col<=0;second_pass<=1;state<=ZERO_ACC;end end
        CS_ZERO:begin idx<=0;state<=CS_ZERO_NEXT;end
        CS_ZERO_NEXT:write_word(16'd4608+idx,0,CS_MAC);
        CS_MAC:if(idx==255) begin idx<=0;poly(PRIM_PW_MAC,16,17,18,CS_INV);end else begin idx<=idx+1'b1;state<=CS_ZERO_NEXT;end
        CS_INV:poly(PRIM_NTT_INV,18,0,0,CS_SUB);
        CS_SUB:poly(PRIM_SUB,14,18,14,R_SCAN);
        R_SCAN:read_word(16'd3584+idx,R_SCAN_READ);
        R_SCAN_READ:begin if(low_abs(rd)>=gamma2-32'(beta)) reject_acc<=1;state<=R_SCAN_NEXT;end
        R_SCAN_NEXT:if(idx==255) load_sk(2,17,16'd32+(16'(l)+16'(k))*16'(eta_bits)*8+16'(row)*104,CT_ZERO);
          else begin idx<=idx+1'b1;state<=R_SCAN;end
        CT_ZERO:begin idx<=0;state<=CT_ZERO_NEXT;end
        CT_ZERO_NEXT:write_word(16'd4608+idx,0,CT_MAC);
        CT_MAC:if(idx==255) begin idx<=0;poly(PRIM_PW_MAC,16,17,18,CT_INV);end else begin idx<=idx+1'b1;state<=CT_ZERO_NEXT;end
        CT_INV:poly(PRIM_NTT_INV,18,0,0,H_SCAN);
        H_SCAN:read_word(16'd3584+idx,H_SCAN_READ);
        H_SCAN_READ:begin held_coeff<=rd;read_word(16'd4608+idx,H_SCAN_PAIR);end
        H_SCAN_PAIR:begin
          if(abs_center(rd)>=gamma2) reject_acc<=1;
          if(high_bits(held_coeff)!=high_bits(add_mod(held_coeff,rd))) begin
            if(hint_count<12'(omega)) hint[hint_count]<=idx[7:0];
            hint_count<=hint_count+1'b1;
          end
          state<=H_SCAN_NEXT;
        end
        H_SCAN_NEXT:if(idx==255) state<=H_ROW_NEXT;else begin idx<=idx+1'b1;state<=H_SCAN;end
        H_ROW_NEXT:begin
          hint[omega+row]<=hint_count[7:0];
          if(row+1<k) begin row<=row+1'b1;col<=0;idx<=0;state<=ZERO_ACC;end else begin if(hint_count>12'(omega)) reject_acc<=1;state<=BOUNDARY;end
        end
        BOUNDARY:if(attempt_cycles>=attempt_limit) begin
          attempt_active<=0;
          if(!reject_acc) begin idx<=0;state<=SAVE_C;end
          else if(attempt+1>=MAX_ATTEMPTS || {1'b0,kappa}+{13'd0,l}>17'd65528) state<=FAILED;
          else begin attempt<=attempt+1'b1;kappa<=kappa+16'(l);state<=ATTEMPT;end
        end
        SAVE_C:write_word(16'd4864+idx,{ctilde[4*idx+3],ctilde[4*idx+2],ctilde[4*idx+1],ctilde[4*idx]},SAVE_C_NEXT);
        SAVE_C_NEXT:if(idx+1==16'(ct_bytes)/4) begin idx<=0;state<=SAVE_H;end else begin idx<=idx+1'b1;state<=SAVE_C;end
        SAVE_H:write_word(16'd4864+16'(ct_bytes)/4+16'(l)*16'(z_bits)*8+idx,
          {hint[4*idx+3],hint[4*idx+2],hint[4*idx+1],hint[4*idx]},SAVE_H_NEXT);
        SAVE_H_NEXT:if(4*(idx+1)>=16'(omega)+16'(k)) begin idx<=0;state<=WIPE;end else begin idx<=idx+1'b1;state<=SAVE_H;end
        WIPE:if(idx==4864) begin idx<=16'd4864+16'(ct_bytes)/4+16'(l)*16'(z_bits)*8+(16'(omega)+16'(k)+3)/4;end else write_word(idx,0,WIPE_NEXT);
        WIPE_NEXT:if(idx==8191) state<=FINISH;else begin idx<=idx+1'b1;state<=WIPE;end
        MREAD:if(mem_ready) begin rd<=mem_rdata;state<=ret;end
        MWRITE:if(mem_ready) state<=ret;
        WK_REQ:state<=WK_WAIT;
        WK_WAIT:if(wk_read_error) state<=FAILED;else if(wk_read_valid) begin rd<=wk_read_data;state<=ret;end
        PSTART:state<=PWAIT;PWAIT:if(poly_done) state<=ret;
        CSTART:state<=CWAIT;CWAIT:if(codec_done) state<=ret;
        HSTART:state<=H_BYTE;
        H_MEM:if(mem_ready) begin rd<=mem_rdata;state<=H_BYTE;end
        MESSAGE_DMA:if(message_dma_error) state<=FAILED;else if(message_dma_done) state<=H_MEM;
        H_BYTE:if(hash_in_ready) begin
          hidx<=hidx+1'b1;
          if(hash_in_last) state<=H_OUT;
          else if(hash_kind==0 && hidx+1>=66) begin
            if(hidx+1>=64'd66+{56'd0,context_q} && 10'(hidx+1-66-{56'd0,context_q})==0) state<=MESSAGE_DMA;else state<=H_MEM;
          end else if(hash_kind==4 && hidx+1>=64) state<=H_MEM;
        end
        H_OUT:begin
          if(hash_out_valid && hash_out_ready) begin
            if(!sample_hash) case(hash_kind)
              0:mu[houtput_idx[5:0]]<=hash_out_data;
              1:rhoprime[houtput_idx[5:0]]<=hash_out_data;
              4:ctilde[houtput_idx[5:0]]<=hash_out_data;
              default:;
            endcase
            houtput_idx<=houtput_idx+1'b1;
          end
          if(hash_done) hash_seen<=1;if(sampler_done) sample_seen<=1;
          if(sampler_error) state<=FAILED;
          else if((hash_seen || hash_done) && (!sample_hash || sample_seen || sampler_done)) state<=H_DONE;
          else if(hash_seen && sample_hash && !sample_seen && !sampler_done && sampler_ready) state<=FAILED;
        end
        H_DONE:state<=hash_ret;
        FINISH:begin
          for(int n=0;n<32;n++) begin rho[n]<=0;key_seed[n]<=0;rnd[n]<=0;end
          for(int n=0;n<64;n++) begin tr[n]<=0;mu[n]<=0;rhoprime[n]<=0;ctilde[n]<=0;end
          for(int n=0;n<88;n++) hint[n]<=0;
          rd<=0;write_data<=0;held_coeff<=0;state<=IDLE;
        end
        FAILED:state<=FAILED;
        default:state<=FAILED;
      endcase
    end
  end
endmodule
