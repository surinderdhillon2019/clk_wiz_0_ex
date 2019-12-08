
// file: clk_wiz_0_tb.v
//----------------------------------------------------------------------------
// Clocking wizard demonstration testbench
//----------------------------------------------------------------------------
// This demonstration testbench instantiates the example design for the 
//   clocking wizard. Input clocks are toggled, which cause the clocking
//   network to lock and the counters to increment.
//----------------------------------------------------------------------------

`timescale 1ps/1ps

`define wait_lock @(posedge locked)

module clk_wiz_0_tb ();

  localparam  ONE_NS      = 1000;
  localparam  PHASE_ERR_MARGIN   = 100; // 100ps

  localparam  COUNT_PHASE = 128;
  // we'll be using the period in many locations
  parameter time PER1    = 3.125*ONE_NS;
  localparam time PER1_1  = PER1/2;
  localparam time PER1_2  = PER1 - PER1/2;

  parameter time PER2    = 3.125*ONE_NS;
  localparam time PER2_1  = PER1/2;
  localparam time PER2_2  = PER1 - PER1/2;
  reg [7:0]  i = 0;

  // Declare the input clock signals
  reg         pcie_clk        = 1'b0;
  reg         dac_clk         = 1'b0;
  reg         pcie_clk_reset  = 0;
  reg         dac_clk_reset   = 0;
 
  // Status and control signals
  reg         reset      = 0;
  reg         power_down = 0;
  wire        input_clk_stopped;
  wire        locked;
  wire [1:1]   CLK_OUT;

//Freq Check using the M & D values setting and actual Frequency generated
  real period1;
  localparam ref_period1_clkin1 = (3.125*1*3.750*1000/3.750);
  time prev_rise1;

  // Input clock generation
  //------------------------------------
  always begin
    if (pcie_clk_reset) begin 
      pcie_clk = #PER1 1'b0; 
    end else begin
      pcie_clk = #PER1_1 ~pcie_clk;
      pcie_clk = #PER1_2 ~pcie_clk;
    end
  end
  // Input clock generation
  //------------------------------------
  always begin
    if (dac_clk_reset) begin 
      dac_clk = #PER2 1'b0; 
    end else begin
      dac_clk = #PER2_1 ~dac_clk;
      dac_clk = #PER2_2 ~dac_clk;
    end
  end

  // Test sequence
  reg [15*8-1:0] test_phase = "";
  initial begin
    // Set up any display statements using time to be readable
    $timeformat(-12, 2, "ps", 10);
    
    dac_clk_reset = 1;
    test_phase = "reset";
    reset = 1;
    #(PER1*200);

    reset = 0;
    #(PER1*200);
    dac_clk_reset = 0;    
    test_phase = "wait lock";
    // `wait_lock;
    #(PER1*20);

    // toggle dac clk on/off 
    for ( i =0; i < 2 ; i = i +1) begin 
      // dac_clk_reset = ~dac_clk_reset;
      #(PER1*COUNT_PHASE);
    end

    if ((period1 -ref_period1_clkin1) <= 100 && (period1 -ref_period1_clkin1) >= -100) begin
      $display("Freq of CLK_OUT[1] ( in MHz ) : %0f\n", 1000000/period1);
    end else begin
      $display("ERROR: Freq of CLK_OUT[1] is not correct"); 
      $finish;
    end 
    $display("SIMULATION PASSED");
    $display("Test Completed Successfully");
    $display("SYSTEM_CLOCK_COUNTER : %0d\n",$time/PER1);
    $finish;
  end

  // Instantiation of the example design containing the clock
  //    network and sampling counters
  //---------------------------------------------------------

  clk_wiz_0_exdes
  #(.PER_DAC_CLK  (PER1) , 
    .PER_PCIE_CLK (PER2) )
    dut
   (
    .CLK_OUT            (CLK_OUT),
    .reset              (reset),
    .power_down         (power_down),
    .input_clk_stopped  (input_clk_stopped),
    .locked             (locked),
    .pcie_clk           (pcie_clk),
    .dac_clk            (dac_clk)
);


// Freq Check 
initial
  prev_rise1 = 0;

always @(posedge CLK_OUT[1])
begin
  if (prev_rise1 != 0)
    period1 = $time - prev_rise1;
  prev_rise1 = $time;
end

endmodule