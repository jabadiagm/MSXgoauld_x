// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue May 21 19:43:43 2024
// Host        : DELL running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top ila_0 -prefix
//               ila_0_ ila_0_stub.v
// Design      : ila_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg325-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2019.1" *)
module ila_0(clk, probe0, probe1, probe2, probe3, probe4, probe5, 
  probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, probe14, probe15, probe16, probe17, 
  probe18, probe19, probe20, probe21, probe22, probe23, probe24, probe25, probe26, probe27)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[24:0],probe1[23:0],probe2[7:0],probe3[0:0],probe4[0:0],probe5[3:0],probe6[24:0],probe7[0:0],probe8[0:0],probe9[7:0],probe10[15:0],probe11[0:0],probe12[0:0],probe13[3:0],probe14[7:0],probe15[0:0],probe16[0:0],probe17[0:0],probe18[0:0],probe19[0:0],probe20[0:0],probe21[0:0],probe22[0:0],probe23[0:0],probe24[15:0],probe25[7:0],probe26[0:0],probe27[0:0]" */;
  input clk;
  input [24:0]probe0;
  input [23:0]probe1;
  input [7:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [3:0]probe5;
  input [24:0]probe6;
  input [0:0]probe7;
  input [0:0]probe8;
  input [7:0]probe9;
  input [15:0]probe10;
  input [0:0]probe11;
  input [0:0]probe12;
  input [3:0]probe13;
  input [7:0]probe14;
  input [0:0]probe15;
  input [0:0]probe16;
  input [0:0]probe17;
  input [0:0]probe18;
  input [0:0]probe19;
  input [0:0]probe20;
  input [0:0]probe21;
  input [0:0]probe22;
  input [0:0]probe23;
  input [15:0]probe24;
  input [7:0]probe25;
  input [0:0]probe26;
  input [0:0]probe27;
endmodule
