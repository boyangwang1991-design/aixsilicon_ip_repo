`timescale 1ns/1ps
module ut_pqc_desc_validate;
  import pqc_pkg::*;
  logic [1023:0] descriptor;
  logic [39:0] descriptor_addr=40'h1000;
  logic crc_ok=1,cap_enabled=1;
  logic [5:0] cap_algo_mask=63;
  logic valid;
  error_code_e error;
  pqc_command_t command;
  pqc_desc_validate #(.DMA_WINDOW_LIMIT(64'hffffffff)) dut(.*);
  int checks=0;
  int pk,ct,sig,o0,o1,in0,in1;
  task automatic put32(input int off,input logic[31:0] value);
    descriptor[8*off+:32]=value;
  endtask
  task automatic put64(input int off,input logic[63:0] value);
    descriptor[8*off+:64]=value;
  endtask
  task automatic fixture(input int op,input int ps);
    descriptor=0;descriptor_addr='h1000;crc_ok=1;cap_enabled=1;cap_algo_mask=63;
    descriptor[0+:8]=8'(op);descriptor[8+:4]=4'(ps);descriptor[24+:8]='h10;
    put32('h04,'hf1234567);put32('h08,'hfedcba98);put32('h3c,2);put32('h68,'h13579bdf);
    case(ps)
      1:begin pk=800;ct=768;sig=0;end
      2:begin pk=1184;ct=1088;sig=0;end
      3:begin pk=1568;ct=1568;sig=0;end
      4:begin pk=1312;ct=0;sig=2420;end
      5:begin pk=1952;ct=0;sig=3309;end
      default:begin pk=2592;ct=0;sig=4627;end
    endcase
    o0=0;o1=0;in0=0;in1=0;
    case(op)
      'h00,'h10:begin o0=pk;o1=4;end
      'h01:begin in0=pk;o0=ct;o1=32;end
      'h02:begin in0=ct;o0=32;end
      'h11:begin in0=64;o0=sig;end
      'h12:begin in0=64;in1=pk+sig;end
      default:begin end
    endcase
    put64('h10,'h10000);put64('h18,64'(in0));
    put64('h20,'h20000);put64('h28,64'(in1));
    put64('h30,'h30000);put32('h38,(op=='h11||op=='h12)?255:0);
    put64('h40,'h40000);put64('h48,64'(o0));put64('h50,'h50000);put64('h58,64'(o1));
    put64('h60,'h60000);
  endtask
  task automatic check(input error_code_e expected,input string what);
    #1;checks++;
    if(error!==expected || valid!==(expected==ERR_NONE))
      $fatal(1,"FAIL %s error=%h expected=%h valid=%b",what,error,expected,valid);
    if(expected!=ERR_NONE && command!=='0)$fatal(1,"FAIL invalid command exposed: %s",what);
  endtask
  initial begin
    for(int family=0;family<2;family++)for(int ps=1;ps<=3;ps++)for(int op=0;op<3;op++)begin
      int code,p;
      code=(family?16:0)+op;p=family*3+ps;fixture(code,p);check(ERR_NONE,"legal operation/parameter");
      if(command.output0_bytes!=o0 || command.output1_bytes!=o1 || command.command_id!==32'hf1234567 ||
         command.key_handle!==32'hfedcba98 || command.operation!=op || command.pset!=p ||
         command.is_dsa!=family || command.src0_len!=in0 || command.src1_len!=in1 ||
         command.timeout_hint!==32'h13579bdf)$fatal(1,"FAIL decoded command");
      cap_algo_mask=6'(63 & ~(1<<(p-1)));check(ERR_BAD_PARAMSET,"disabled parameter");cap_algo_mask=63;
      cap_enabled=0;check(ERR_BAD_PARAMSET,"disabled IP");cap_enabled=1;
      if(o0)begin put64('h48,64'(o0-1));check(ERR_BAD_CAPACITY,"short output0");put64('h48,64'(o0));end
      if(o1)begin put64('h58,64'(o1-1));check(ERR_BAD_CAPACITY,"short output1");put64('h58,64'(o1));end
      if(family && op!=0)begin
        put64('h18,0);put32('h38,0);check(ERR_NONE,"empty DSA message/context");
        put32('h38,1);check(ERR_NONE,"one-byte context");put32('h38,256);check(ERR_BAD_LENGTH,"oversize context");
      end else begin
        put64('h18,64'(in0+1));check(ERR_BAD_LENGTH,"fixed input extra byte");
        put64('h18,64'(in0));put32('h38,1);check(ERR_BAD_LENGTH,"context on non-message operation");
      end
      fixture(code,p);put64('h28,64'(in1+1));check(ERR_BAD_LENGTH,"secondary input wrong length");
      fixture(code,p);put32('h3c,3);check(ERR_BAD_LENGTH,"unknown entropy policy");
    end
    for(int op=0;op<256;op++)if(!(op inside {0,1,2,16,17,18}))begin
      fixture(op,1);check(ERR_BAD_OPCODE,"unknown/unimplemented opcode");
    end
    for(int ps=0;ps<16;ps++)begin
      fixture(0,ps);check((ps>=1&&ps<=3)?ERR_NONE:ERR_BAD_PARAMSET,"KEM parameter domain");
      fixture(16,ps);check((ps>=4&&ps<=6)?ERR_NONE:ERR_BAD_PARAMSET,"DSA parameter domain");
    end
    fixture(1,2);crc_ok=0;check(ERR_BAD_ABI,"CRC failure");crc_ok=1;
    for(int bit_id=12;bit_id<24;bit_id++)begin
      descriptor[bit_id]=1;check(ERR_BAD_ABI,"unknown header flag");descriptor[bit_id]=0;
    end
    for(int byte_id=0;byte_id<128;byte_id++)if((byte_id>=12&&byte_id<16)||(byte_id>=108&&byte_id<124))begin
      descriptor[8*byte_id+:8]=1;check(ERR_BAD_ABI,"reserved byte");descriptor[8*byte_id+:8]=0;
    end
    for(int off='h10;off<='h60;off+=16)begin
      fixture('h12,5);
      if(off=='h40 || off=='h50)fixture(1,2);
      put64(off,64'h100000000);check(ERR_PERMISSION,"address outside trusted window");
      put64(off,64'h10000000000);check(ERR_PERMISSION,"64-bit address must not truncate to AXI");
      put64(off,64'hfffffffffffffff0);check(off == 'h60 ? ERR_BAD_ALIGN:ERR_PERMISSION,"address addition overflow");
      put64(off,64'h70001);check(ERR_BAD_ALIGN,"unaligned active region");
    end
    fixture(1,2);put64('h48,64'hffffffffffffffff);check(ERR_PERMISSION,"capacity addition overflow");
    fixture('h11,5);put64('h18,64'h100000000);check(ERR_PERMISSION,"full 64-bit message range");
    fixture(1,2);descriptor_addr++;check(ERR_BAD_ALIGN,"descriptor alignment");
    fixture(1,2);put64('h40,'h10000);check(ERR_PERMISSION,"output overlaps source");
    fixture(1,2);put64('h50,'h40000);check(ERR_PERMISSION,"outputs overlap");
    fixture(1,2);put64('h60,'h40000);check(ERR_PERMISSION,"completion overlaps output");
    fixture(1,2);put64('h60,'h1000);check(ERR_PERMISSION,"completion overlaps descriptor");
    fixture('h11,5);put64('h40,'h30000);check(ERR_PERMISSION,"output overlaps context");
    fixture(1,2);put64('h40,'h10000+1184);check(ERR_NONE,"adjacent read/write buffers");
    fixture('h12,5);put64('h20,'h10000);check(ERR_NONE,"read-only buffers may overlap");
    fixture('h11,5);put32('h3c,0);check(ERR_NONE,"deterministic Sign");
    put32('h3c,1);check(ERR_NONE,"hedged Sign");
    fixture(1,2);put32('h3c,0);check(ERR_BAD_LENGTH,"ordinary descriptor cannot supply KAT seed");
    $display("validated descriptor checks=%0d",checks);
    $display("UT_pqc_desc_validate: PASS (errors=0)");$finish;
  end
endmodule
