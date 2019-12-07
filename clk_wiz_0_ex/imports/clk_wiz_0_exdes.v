
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
  // Reset that only drives logic in example design
  input         COUNTER_RESET,
  output [1:1]   CLK_OUT,
  // High bits of counters driven by clocks
  output        COUNT,
  // Status and control signals
  input         reset,
  input         power_down,
  output        input_clk_stopped,
  output        locked,
 // Clock in ports
  input         clk_in1
 );

  // Parameters for the counters
  //-------------------------------
 localparam  ONE_NS      = 1000;
 localparam time PER1    = 10*ONE_NS;
 localparam time PER1_1  = PER1/2;  
 // Counter width
  localparam    C_W       = 16;
  // Clock to Q delay of 100ps
  localparam TCQ  = 100;
  // When the clock goes out of lock, reset the counters
  wire          reset_int = (!locked)  || reset  || COUNTER_RESET;

  (* ASYNC_REG = "TRUE" *)  reg rst_sync;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int1;
  (* ASYNC_REG = "TRUE" *)  reg rst_sync_int2;



  // Declare the clocks and counter
  wire           clk_int;
  wire           clk;
  reg  [C_W-1:0] counter;
  wire      clk_in1_buf;
  wire      clk_in2_buf;
  wire      clkfb_in_buf;





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


  // Connect the output clocks to the design
  //-----------------------------------------
  assign clk = clk_int;


  // Reset synchronizer
  //-----------------------------------
    always @(posedge reset_int or posedge clk) begin
       if (reset_int) begin
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;     
            rst_sync_int1 <= rst_sync_int; 
            rst_sync_int2 <= rst_sync_int1;
       end
    end

  // Output clock sampling
  //-----------------------------------
  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // alias the high bit to the output
  assign COUNT = counter[C_W-1];

endmodule
