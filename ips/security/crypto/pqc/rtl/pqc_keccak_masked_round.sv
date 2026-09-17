// Registered two-share Keccak round. No share reconstruction in production RTL.
module pqc_keccak_masked_round #(
  parameter int unsigned TOKEN_WIDTH=96
)(
  input logic clk,rst_n,
  input logic in_valid,
  output logic in_ready,
  input logic [1599:0] in_share0,in_share1,
  input logic [63:0] round_constant,
  input logic [TOKEN_WIDTH-1:0] in_token,
  input logic random_valid,
  output logic random_ready,
  input logic [1599:0] random_r,random_s,random_m,
  input logic [TOKEN_WIDTH-1:0] random_token,
  output logic random_release,
  output logic [TOKEN_WIDTH-1:0] release_token,
  output logic out_valid,
  input logic out_ready,
  output logic [1599:0] out_share0,out_share1,
  output logic [TOKEN_WIDTH-1:0] out_token,
  input logic zeroize_req,
  output logic zeroize_done,
  output logic fault
);
  typedef enum logic [3:0] {IDLE=4'b0001,CHI_REQ=4'b0010,CHI_WAIT=4'b0100,RESULT=4'b1000} state_t;
  state_t state;
  logic [1599:0] linear0,linear1,and_a0,and_a1,and_b0,and_b1;
  logic [1599:0] and_c0,and_c1,result0,result1;
  logic [63:0] rc_q;
  logic [TOKEN_WIDTH-1:0] token_q,and_token;
  logic and_iv,and_ir,and_ov,and_or,and_clear,and_cleared,local_cleared;
  logic active,bad_random,bad_result,bad_state;

  function automatic logic [63:0] rol(input logic [63:0] v,input int n);
    return n==0 ? v : (v<<n)|(v>>(64-n));
  endfunction
  function automatic int rho(input int x,input int y);
    case (x+5*y)
      0:rho=0;1:rho=1;2:rho=62;3:rho=28;4:rho=27;
      5:rho=36;6:rho=44;7:rho=6;8:rho=55;9:rho=20;
      10:rho=3;11:rho=10;12:rho=43;13:rho=25;14:rho=39;
      15:rho=41;16:rho=45;17:rho=15;18:rho=21;19:rho=8;
      20:rho=18;21:rho=2;22:rho=61;23:rho=56;default:rho=14;
    endcase
  endfunction
  function automatic logic [1599:0] linear(input logic [1599:0] a);
    logic [63:0] c[0:4],d[0:4];
    logic [1599:0] b;
    for(int x=0;x<5;x++)begin
      c[x]='0;
      for(int y=0;y<5;y++)c[x]=c[x]^a[(x+5*y)*64+:64];
    end
    for(int x=0;x<5;x++)d[x]=c[(x+4)%5]^rol(c[(x+1)%5],1);
    for(int x=0;x<5;x++)for(int y=0;y<5;y++)
      b[(y+5*((2*x+3*y)%5))*64+:64]=rol(a[(x+5*y)*64+:64]^d[x],rho(x,y));
    return b;
  endfunction
  always_comb begin
    for(int y=0;y<5;y++)for(int x=0;x<5;x++)begin
      and_a0[(x+5*y)*64+:64]=~linear0[((x+1)%5+5*y)*64+:64];
      and_a1[(x+5*y)*64+:64]= linear1[((x+1)%5+5*y)*64+:64];
      and_b0[(x+5*y)*64+:64]= linear0[((x+2)%5+5*y)*64+:64];
      and_b1[(x+5*y)*64+:64]= linear1[((x+2)%5+5*y)*64+:64];
    end
  end
  assign bad_random=state==CHI_REQ && random_valid && random_token!=token_q;
  assign bad_result=state==CHI_WAIT && and_ov && and_token!=token_q;
  assign bad_state=!(state==IDLE||state==CHI_REQ||state==CHI_WAIT||state==RESULT);
  assign active=rst_n&&!zeroize_req&&!fault&&!bad_random&&!bad_result&&!bad_state;
  assign in_ready=active&&state==IDLE;
  assign random_ready=active&&state==CHI_REQ&&and_ir;
  assign and_iv=active&&state==CHI_REQ&&random_valid;
  assign and_or=active&&state==CHI_WAIT;
  assign random_release=and_ov&&and_or;
  assign release_token=token_q;
  assign out_valid=active&&state==RESULT;
  assign out_share0=out_valid?result0:1600'd0;
  assign out_share1=out_valid?result1:1600'd0;
  assign out_token=token_q;
  assign and_clear=zeroize_req||fault||state==RESULT;
  assign zeroize_done=rst_n&&local_cleared&&and_cleared;
  pqc_masked_and #(.WIDTH(1600),.TOKEN_WIDTH(TOKEN_WIDTH)) chi(
    .clk(clk),.rst_n(rst_n),.in_valid(and_iv),.in_ready(and_ir),
    .a0(and_a0),.a1(and_a1),.b0(and_b0),.b1(and_b1),
    .random_r(random_r),.random_s(random_s),.random_m(random_m),.in_token(token_q),
    .out_valid(and_ov),.out_ready(and_or),.c0(and_c0),.c1(and_c1),.out_token(and_token),
    .zeroize_req(and_clear),.zeroize_done(and_cleared));
  always_ff @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
      state<=IDLE;linear0<='0;linear1<='0;rc_q<='0;token_q<='0;
      result0<='0;result1<='0;fault<=0;local_cleared<=0;
    end else if(zeroize_req||fault||bad_random||bad_result||bad_state)begin
      state<=IDLE;linear0<='0;linear1<='0;rc_q<='0;token_q<='0;
      result0<='0;result1<='0;local_cleared<=1;
      if(bad_random||bad_result||bad_state)fault<=1;
    end else begin
      local_cleared<=0;
      case(state)
        IDLE:if(in_valid&&in_ready)begin
          linear0<=linear(in_share0);linear1<=linear(in_share1);
          rc_q<=round_constant;token_q<=in_token;state<=CHI_REQ;
        end
        CHI_REQ:if(random_valid&&random_ready)state<=CHI_WAIT;
        CHI_WAIT:if(and_ov&&and_or)begin
          result0<=linear0^and_c0^{1536'd0,rc_q};result1<=linear1^and_c1;
          linear0<='0;linear1<='0;rc_q<='0;state<=RESULT;
        end
        RESULT:if(out_ready)begin
          result0<='0;result1<='0;token_q<='0;state<=IDLE;
        end
        default:begin state<=IDLE;fault<=1;end
      endcase
    end
  end
endmodule
