`timescale 1ns/1ps
module ut_gpio_capture;
  bit clk=0; always #5 clk=~clk;
  bit rst=0, sw=0, hw=0, sample=0, clear=0;
  bit [3:0] data=0, valid=0, sync_data=0, sync_valid=0;
  wire [3:0] snap, snap_valid, strap; wire [31:0] seq;
  wire strap_valid, early;
  int errors=0;
  gpio_capture #(.N_GPIO(4),.INPUT_CAP_MASK(4'b0101)) dut(.clk_i(clk),.rst_ni(rst),
    .data_i(data),.valid_i(valid),.sync_i(sync_data),.sync_valid_i(sync_valid),
    .snapshot_sw_i(sw),.snapshot_hw_i(hw),.strap_sample_i(sample),.clear_early_i(clear),
    .snapshot_data_o(snap),.snapshot_valid_o(snap_valid),.strap_data_o(strap),
    .sequence_o(seq),.strap_valid_o(strap_valid),.strap_early_o(early));
  task check(bit ok,string msg); if(!ok)begin errors++;$display("FAIL %s",msg);end endtask
  task step; @(posedge clk); #1; @(negedge clk); endtask
  initial begin
    repeat(2) step();check(seq===0&&!strap_valid,"reset");rst=1;
    data=10;valid=3;sw=1;hw=1;step();sw=0;hw=0;
    check(seq===1&&snap===10&&snap_valid===3,"simultaneous captures count once");
    data=5;valid=15;step();check(snap===10,"snapshot holds");hw=1;step();hw=0;
    check(seq===2&&snap===5&&snap_valid===15,"hardware snapshot");
    sample=1;clear=1;step();check(early&&!strap_valid,"early set wins clear");
    sample=0;step();clear=0;check(!early,"early clear");
    sync_data=15;sync_valid=5;sample=1;step();sample=0;
    check(strap_valid&&strap===5,"strap requires only capability pins");
    sync_data=0;sample=1;step();check(strap===5,"strap one shot");
    if(errors)$fatal(1,"UT_GPIO_CAPTURE: FAIL (errors=%0d)",errors);
    $display("UT_GPIO_CAPTURE: PASS (errors=0)");$finish;
  end
  initial begin #10000;$fatal(1,"TIMEOUT");end
endmodule
