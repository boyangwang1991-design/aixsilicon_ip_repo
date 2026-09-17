`timescale 1ns/1ps
module ut_pqc_pkg;
  import pqc_pkg::*;
  bit visited[0:255];
  int location;
  logic[7:0] reverse;
  initial begin
    for(int i=0;i<256;i++) visited[i]=0;
    for(int i=0;i<256;i++) begin
      location=(i>>3)*8+int'(bank_hash(8'(i)));
      if(visited[location]) $fatal(1,"bank/row mapping alias");
      visited[location]=1;
      for(int bit_index=0;bit_index<8;bit_index++) begin
        if(bank_hash(8'(i))==bank_hash(8'(i^(1<<bit_index))))
          $fatal(1,"butterfly endpoints share bank");
        reverse[bit_index]=1'(i>>(7-bit_index));
      end
      if(bitrev8(8'(i))!=={8'h00,reverse}) $fatal(1,"bit reversal width/order");
    end
    $display("UT_pqc_pkg: PASS (errors=0)");$finish;
  end
endmodule
