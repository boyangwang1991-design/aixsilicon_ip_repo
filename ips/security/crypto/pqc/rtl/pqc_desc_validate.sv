// Public descriptor validation; the FE owns the only descriptor shadow.
module pqc_desc_validate #(
  parameter int unsigned DMA_DATA_WIDTH=128,
  parameter logic [63:0] DMA_WINDOW_BASE=64'd0,
  parameter logic [63:0] DMA_WINDOW_LIMIT=64'h000000ffffffffff
)(
  input logic [1023:0] descriptor,
  input logic [39:0] descriptor_addr,
  input logic crc_ok, cap_enabled,
  input logic [5:0] cap_algo_mask,
  output logic valid,
  output pqc_pkg::error_code_e error,
  output pqc_pkg::pqc_command_t command
);
  import pqc_pkg::*;
  pqc_command_t decoded;
  logic abi_ok, opcode_ok, pset_ok, capability_ok, length_ok, capacity_ok;
  logic alignment_ok, range_ok, overlap_ok;
  logic [15:0] kem_pk, kem_ct, dsa_pk, dsa_sig;
  logic [63:0] expected_src0, expected_src1;
  logic variable_message;
  logic [63:0] addr[0:6], bytes[0:6];
  logic [64:0] last_byte[0:6];

  always_comb begin
    decoded='0;
    decoded.opcode=descriptor[0+:8];
    decoded.pset=descriptor[8+:4];
    decoded.command_id=descriptor[32+:32];
    decoded.key_handle=descriptor[64+:32];
    decoded.src0_addr=descriptor[8*'h10+:64];
    decoded.src0_len=descriptor[8*'h18+:64];
    decoded.src1_addr=descriptor[8*'h20+:64];
    decoded.src1_len=descriptor[8*'h28+:64];
    decoded.context_addr=descriptor[8*'h30+:64];
    decoded.context_len=descriptor[8*'h38+:32];
    decoded.entropy_policy=descriptor[8*'h3c+:32];
    decoded.dst0_addr=descriptor[8*'h40+:64];
    decoded.dst0_capacity=descriptor[8*'h48+:64];
    decoded.dst1_addr=descriptor[8*'h50+:64];
    decoded.dst1_capacity=descriptor[8*'h58+:64];
    decoded.completion_addr=descriptor[8*'h60+:64];
    decoded.timeout_hint=descriptor[8*'h68+:32];

    kem_pk=0;kem_ct=0;dsa_pk=0;dsa_sig=0;
    case(decoded.pset)
      1:begin kem_pk=800;kem_ct=768;end
      2:begin kem_pk=1184;kem_ct=1088;end
      3:begin kem_pk=1568;kem_ct=1568;end
      4:begin dsa_pk=1312;dsa_sig=2420;end
      5:begin dsa_pk=1952;dsa_sig=3309;end
      6:begin dsa_pk=2592;dsa_sig=4627;end
      default:begin end
    endcase
    expected_src0=0;expected_src1=0;variable_message=0;
    opcode_ok=1;pset_ok=0;
    case(decoded.opcode)
      OP_KEM_KEYGEN:begin
        pset_ok=kem_pk!=0;decoded.output0_bytes=kem_pk;decoded.output1_bytes=4;
      end
      OP_KEM_ENCAPS:begin
        pset_ok=kem_pk!=0;decoded.operation=1;expected_src0={48'd0,kem_pk};
        decoded.output0_bytes=kem_ct;decoded.output1_bytes=32;
      end
      OP_KEM_DECAPS:begin
        pset_ok=kem_pk!=0;decoded.operation=2;expected_src0={48'd0,kem_ct};
        decoded.output0_bytes=32;decoded.needs_private_key=1;
      end
      OP_DSA_KEYGEN:begin
        pset_ok=dsa_pk!=0;decoded.is_dsa=1;
        decoded.output0_bytes=dsa_pk;decoded.output1_bytes=4;
      end
      OP_DSA_SIGN:begin
        pset_ok=dsa_pk!=0;decoded.is_dsa=1;decoded.operation=1;
        variable_message=1;decoded.output0_bytes=dsa_sig;decoded.needs_private_key=1;
      end
      OP_DSA_VERIFY:begin
        pset_ok=dsa_pk!=0;decoded.is_dsa=1;decoded.operation=2;variable_message=1;
        expected_src1={48'd0,dsa_pk}+{48'd0,dsa_sig};
      end
      default:opcode_ok=0;
    endcase
    abi_ok=crc_ok && descriptor[24+:8]==8'h10 && descriptor[12+:12]==12'd0 &&
           descriptor[8*'h0c+:32]==32'd0 && descriptor[8*'h6c+:128]==128'd0;
    capability_ok=cap_enabled && decoded.pset>=1 && decoded.pset<=6 &&
                  (({2'b0,cap_algo_mask} >> (decoded.pset-1)) & 8'd1)!=0;
    length_ok=(variable_message || decoded.src0_len==expected_src0) &&
              decoded.src1_len==expected_src1 && decoded.context_len<=255 &&
              (variable_message || decoded.context_len==0) && decoded.entropy_policy<=2;
    if(decoded.opcode==OP_KEM_KEYGEN || decoded.opcode==OP_KEM_ENCAPS || decoded.opcode==OP_DSA_KEYGEN)
      length_ok=length_ok && decoded.entropy_policy==2;
    capacity_ok=decoded.dst0_capacity>={48'd0,decoded.output0_bytes} &&
                decoded.dst1_capacity>={48'd0,decoded.output1_bytes} &&
                (decoded.output0_bytes!=0 || decoded.dst0_capacity==0) &&
                (decoded.output1_bytes!=0 || decoded.dst1_capacity==0);

    addr[0]=decoded.src0_addr;bytes[0]=decoded.src0_len;
    addr[1]=decoded.src1_addr;bytes[1]=decoded.src1_len;
    addr[2]=decoded.context_addr;bytes[2]={32'd0,decoded.context_len};
    addr[3]=decoded.dst0_addr;bytes[3]=decoded.dst0_capacity;
    addr[4]=decoded.dst1_addr;bytes[4]=decoded.dst1_capacity;
    addr[5]=decoded.completion_addr;bytes[5]=32;
    addr[6]={24'd0,descriptor_addr};bytes[6]=128;
    alignment_ok=1;range_ok=1;overlap_ok=1;
    for(int i=0;i<7;i++)begin
      last_byte[i]={1'b0,addr[i]};
      if(bytes[i]!=0)begin
        last_byte[i]={1'b0,addr[i]}+{1'b0,bytes[i]}-65'd1;
        range_ok=range_ok && !last_byte[i][64] && addr[i]>=DMA_WINDOW_BASE &&
                 last_byte[i]<={1'b0,DMA_WINDOW_LIMIT} && addr[i][63:40]==0 && last_byte[i][63:40]==0;
        if(i==6)alignment_ok=alignment_ok && addr[i][6:0]==0;
        else if(i==5)alignment_ok=alignment_ok && addr[i][4:0]==0;
        else alignment_ok=alignment_ok && (addr[i] & 64'(DMA_DATA_WIDTH/8-1))==0;
      end
    end
    for(int w=3;w<=5;w++)for(int r=0;r<7;r++)
      if(w!=r && bytes[w]!=0 && bytes[r]!=0 &&
         {1'b0,addr[w]}<=last_byte[r] && {1'b0,addr[r]}<=last_byte[w])overlap_ok=0;

    error=ERR_NONE;
    if(!abi_ok)error=ERR_BAD_ABI;
    else if(!opcode_ok)error=ERR_BAD_OPCODE;
    else if(!pset_ok || !capability_ok)error=ERR_BAD_PARAMSET;
    else if(!length_ok)error=ERR_BAD_LENGTH;
    else if(!capacity_ok)error=ERR_BAD_CAPACITY;
    else if(!alignment_ok)error=ERR_BAD_ALIGN;
    else if(!range_ok || !overlap_ok)error=ERR_PERMISSION;
    valid=error==ERR_NONE;
    command=valid?decoded:'0;
  end
endmodule
