// Working-state private key store. Long-term ownership remains with the trusted
// external Key Manager. No APB/AXI/export port exists. Each imported key is bound
// to the full external handle, family, parameter set and operation usage mask.
// Storage is scrubbed on reset, revoke/zeroize and command retirement.
module pqc_work_key_ram #(
  parameter int unsigned KEY_BYTES = 8192
)(
  input logic clk, rst_n,
  input logic load_begin,
  output logic load_begin_ready,
  input logic [31:0] load_handle,
  input logic [3:0] load_algo, load_pset,
  input logic [7:0] load_usage,
  input logic [15:0] load_bytes,
  input logic load_valid,
  output logic load_ready,
  input logic [31:0] load_data,
  input logic load_last,
  output logic load_done, load_error,
  input logic [31:0] check_handle,
  input logic [3:0] check_algo, check_pset,
  input logic [7:0] check_usage,
  output logic check_ok,
  input logic read_req,
  input logic [15:0] read_word,
  output logic read_valid, read_error,
  output logic [31:0] read_data,
  input logic retire,
  input logic zeroize_req,
  output logic zeroize_done,
  output logic integrity_error
);
  `include "pqc_secded_functions.svh"
  localparam int WORDS=(KEY_BYTES+3)/4;
  typedef enum logic[2:0] {K_WIPE,K_EMPTY,K_LOAD,K_SCAN,K_READY} state_e;
  state_e state;
  logic [38:0] mem[0:WORDS-1];
  logic [$clog2(WORDS+1)-1:0] index;
  logic [31:0] handle_q;
  logic [3:0] algo_q,pset_q;
  logic [7:0] usage_q;
  logic [15:0] bytes_q;
  logic read_allowed;
  assign load_begin_ready=(state==K_EMPTY) && !zeroize_req && !retire && !integrity_error;
  assign load_ready=(state==K_LOAD) && !zeroize_req && !retire;
  assign check_ok=(state==K_READY) && !zeroize_req && !retire && !integrity_error &&
    check_handle==handle_q && check_algo==algo_q && check_pset==pset_q &&
    check_usage!=0 && (check_usage & usage_q)==check_usage;
  assign read_allowed=check_ok && ({16'd0,read_word}*4 < bytes_q) && read_word<WORDS;
  function automatic logic [15:0] private_key_bytes(input logic[3:0] ps);
    case(ps)
      1:return 1632; 2:return 2400; 3:return 3168;
      4:return 2560; 5:return 4032; 6:return 4896;
      default:return 0;
    endcase
  endfunction
  // Synchronous memory read. Responses are invalidated by revocation immediately.
  logic read_valid_q,read_error_q,raw_valid,raw_private_read;
  logic [38:0] raw_q;
  logic [5:0] syndrome;
  logic uncorrectable;
  assign syndrome=secded_syn(raw_q);
  assign uncorrectable=!(^raw_q) && syndrome!=0;
  logic [31:0] read_data_q;
  assign read_valid=read_valid_q && check_ok;
  assign read_error=read_error_q;
  assign read_data=read_valid ? read_data_q : 32'd0;
  always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state<=K_WIPE; index<=0;handle_q<=0;algo_q<=0;pset_q<=0;usage_q<=0;bytes_q<=0;
      zeroize_done<=0;load_done<=0;load_error<=0;
      read_valid_q<=0;read_error_q<=0;read_data_q<=0;raw_valid<=0;raw_private_read<=0;raw_q<=0;integrity_error<=0;
    end else begin
      load_done<=0;load_error<=0;
      raw_valid<=read_req && read_allowed;
      raw_private_read<=read_req && read_allowed;
      if(read_req && read_allowed) raw_q<=mem[read_word];
      else raw_q<=0;
      if(state==K_SCAN && 32'(index)*4 < bytes_q) begin
        raw_q<=mem[index];raw_valid<=1;raw_private_read<=0;
      end
      read_valid_q<=raw_valid && raw_private_read && !uncorrectable && check_ok;
      read_error_q<=(read_req && !read_allowed) || (raw_valid && raw_private_read && uncorrectable);
      if(raw_valid && raw_private_read && !uncorrectable && check_ok)
        read_data_q <= ((^raw_q) && syndrome!=0) ? secded_corr(raw_q,syndrome) : secded_data(raw_q);
      else read_data_q<=0;
      if(raw_valid && uncorrectable) integrity_error<=1;
      if((zeroize_req || retire) && state!=K_WIPE && state!=K_EMPTY) begin
        state<=K_WIPE;index<=0;zeroize_done<=0;
        handle_q<=0;algo_q<=0;pset_q<=0;usage_q<=0;bytes_q<=0;
        read_valid_q<=0;read_data_q<=0;raw_valid<=0;raw_private_read<=0;raw_q<=0;
      end else case(state)
        K_WIPE: begin
          if(index==WORDS-1) begin state<=K_EMPTY;index<=0;zeroize_done<=1;end
          else index<=index+1'b1;
        end
        K_EMPTY: if(load_begin && load_begin_ready) begin
          zeroize_done<=0;
          if(load_bytes==0 || load_bytes>KEY_BYTES || load_bytes!=private_key_bytes(load_pset) || load_usage==0 ||
            !((load_algo==1 && load_pset>=1 && load_pset<=3) ||
              (load_algo==2 && load_pset>=4 && load_pset<=6))) begin
            load_error<=1;state<=K_WIPE;index<=0;
          end else begin
            handle_q<=load_handle;algo_q<=load_algo;pset_q<=load_pset;
            usage_q<=load_usage;bytes_q<=load_bytes;index<=0;state<=K_LOAD;
          end
        end
        K_LOAD: if(load_valid && load_ready) begin
          if(load_last != ((32'(index)+1)*4 >= bytes_q)) begin
            load_error<=1;state<=K_WIPE;index<=0;
            handle_q<=0;algo_q<=0;pset_q<=0;usage_q<=0;bytes_q<=0;
          end else if(load_last) begin state<=K_SCAN;index<=0;end
          else index<=index+1'b1;
        end
        K_SCAN: begin
          if(32'(index)*4 < bytes_q) index<=index+1'b1;
          else if(raw_valid) begin
            if(integrity_error || uncorrectable) begin
              state<=K_WIPE;index<=0;load_error<=1;
              handle_q<=0;algo_q<=0;pset_q<=0;usage_q<=0;bytes_q<=0;
            end else begin state<=K_READY;load_done<=1;end
          end
        end
        default: begin end
      endcase
    end
  end
  // No array reset. A complete sweep runs before the first import is accepted.
  // Fixed byte lanes suppress unused bytes in the last imported word.
  always_ff @(posedge clk) begin
    if(state==K_WIPE) mem[index]<=secded_enc(0);
    else if(load_valid && load_ready) begin : store_word
      logic [31:0] masked_data;
      for(int b=0;b<4;b++) masked_data[b*8+:8] =
        (32'(index)*4+b < bytes_q) ? load_data[b*8+:8] : 8'd0;
      mem[index] <= secded_enc(masked_data);
    end
  end
endmodule
