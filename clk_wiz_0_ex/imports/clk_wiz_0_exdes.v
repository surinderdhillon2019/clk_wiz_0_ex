
// file: clk_wiz_0_exdes.v
//----------------------------------------------------------------------------
// Clocking wizard example design
//----------------------------------------------------------------------------
// This example design instantiates the created clocking network, where each
//   output clock drives a counter. The high bit of each counter is ported.
//----------------------------------------------------------------------------

`timescale 1ps/1ps

module clk_wiz_0_exdes 
 (
  output [1:1]   CLK_OUT,
  input         reset,
  input         power_down,
  output        input_clk_stopped,
  output        locked,
 // Clock in ports
  input         clk_in1
 );


  // Declare the clocks and counter
  wire           clk_int;
  wire           clk;

  // Instantiation of the clocking network
  //--------------------------------------
  clk_wiz_0 clknetwork
   (
    // Clock out ports
    .clk_out1           (clk_int),
    // Status and control signals
    .reset              (reset),
    .power_down         (1'b0),
    .input_clk_stopped  (input_clk_stopped),
    .locked             (locked),
   // Clock in ports
    .clk_in1            (clk_in1)
);
  ODDRE1 
  clkout_oddr
    (.Q  (CLK_OUT[1]),
     .C  (clk_int),
     .D1 (1'b1),
     .D2 (1'b0),
     .SR (1'b0));

endmodule
