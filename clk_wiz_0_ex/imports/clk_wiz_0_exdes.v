
// file: clk_wiz_0_exdes.v
//----------------------------------------------------------------------------
// Clocking wizard example design
//----------------------------------------------------------------------------
// This example design instantiates the created clocking network, where each
//   output clock drives a counter. The high bit of each counter is ported.
//----------------------------------------------------------------------------

`timescale 1ps/1ps
`define wait_lock @(posedge locked)
module clk_wiz_0_exdes
#(parameter time PER_DAC_CLK,
  parameter time PER_PCIE_CLK)
 (
  output [1:1]  CLK_OUT,
  input         reset,
  input         power_down,
  output        input_clk_stopped,
  output        locked,
  input         pcie_clk,
  input         dac_clk 
 );

  // Declare the clocks and counter
  wire           clk_int;
  wire           clk_in1;
 //-------------Internal Constants--------------------------
 parameter SIZE = 3 ;

parameter STATE_IDLE = 3'b000 ;
parameter STATE_DAC_CLK_DETECTED  = 3'b001 ;
parameter STATE_WAIT_DAC_LOCKED   = 3'b010 ;
parameter STATE_DAC_CLK_LOCKED    = 3'b011 ;
parameter STATE_PCIE_CLK_DETECTED = 3'b100 ;
parameter STATE_WAIT_PCIE_LOCKED  = 3'b101 ;
parameter STATE_PCIE_CLK_LOCKED   = 3'b110 ;

 //-------------Internal Variables---------------------------
 reg   [SIZE-1:0]          state        ;        // Seq part of the FSM
 reg   [SIZE-1:0]          next_state   ;        // combo part of FSM
 reg   [15:0]              counter =0   ;        // counter to wait for locked signal
 reg   [15:0]              counter_limit = 100;  // 100 clk cycle 
 reg                       counter_expired = 0 ;
 reg                       rst_counter     = 1 ;
 reg                       select_dac_clk      = 1 ;
 reg                       select_clk      = 0 ;
 reg [31*8-1:0]            currState = "";
 //----------State Machine startes Here------------------------
 
always @* begin
  case (state)
    STATE_IDLE:      
      select_dac_clk  <=  1'b0 ;
    STATE_DAC_CLK_DETECTED:      
      select_dac_clk <=  1'b1 ;
    STATE_WAIT_DAC_LOCKED:      
      select_dac_clk <=  1'b1 ;
    STATE_DAC_CLK_LOCKED:
      select_dac_clk <=  1'b1 ;
    STATE_PCIE_CLK_DETECTED:       
      select_dac_clk <=  1'b0 ;
    STATE_WAIT_PCIE_LOCKED:      
      select_dac_clk <=  1'b0 ;
    STATE_PCIE_CLK_LOCKED:      
      select_dac_clk <=  1'b1 ;
    default:      
      select_dac_clk <=  1'b0 ;
  endcase
end

always @* begin
  case (state)
    STATE_IDLE:   
      select_clk  <=  1'b0 ;
    STATE_DAC_CLK_DETECTED:
      select_clk <= 1'b1 ;      
    STATE_WAIT_DAC_LOCKED:
      select_clk <= 1'b1 ;   
    STATE_PCIE_CLK_DETECTED:
      select_clk <= 1'b1 ;      
    STATE_WAIT_PCIE_LOCKED:
      select_clk <= 1'b1 ;      
    default:
      select_clk <= 1'b0 ;     
  endcase
end

always @* begin
  case (state)
    STATE_IDLE:   
      currState   <= "STATE_IDLE" ;
    STATE_DAC_CLK_DETECTED:
      currState   <= "STATE_DAC_CLK_DETECTED" ;
    STATE_WAIT_DAC_LOCKED:
      currState   <= "STATE_WAIT_DAC_LOCKED" ; 
    STATE_DAC_CLK_LOCKED:
      currState   <= "STATE_DAC_CLK_LOCKED" ;
    STATE_PCIE_CLK_DETECTED:
      currState   <= "STATE_PCIE_CLK_DETECTED" ; 
    STATE_WAIT_PCIE_LOCKED:
      currState   <= "STATE_WAIT_PCIE_LOCKED" ;
    STATE_PCIE_CLK_LOCKED: 
      currState   <= "STATE_PCIE_CLK_LOCKED" ;
    default:
      currState   <= "STATE_IDLE" ; 
  endcase
end

// Clock select Mux 
assign clk_in1 = (select_clk) ? ( (select_dac_clk) ? dac_clk : pcie_clk ) : 1'b0 ; 

always @(posedge dac_clk or posedge pcie_clk or posedge reset) begin : STATE_MACHINE
     // next_state = 3'b000;
  if (reset) begin 
    state      = STATE_IDLE;
    next_state = STATE_IDLE ;
  end else begin 
    case (state)

      STATE_IDLE:
        if ( counter_expired == 1'b1 ) begin
          if ( dac_clk == 1'b1 ) begin           
            rst_counter <= 1'b1;
            select_dac_clk  <=  1'b1 ;  // if here then mux select dac clk
            next_state  <= STATE_DAC_CLK_DETECTED ;
          end else if (pcie_clk == 1'b1) begin
            rst_counter <= 1'b1;
            select_dac_clk  <=  1'b0 ;  // if here then mux select pcie clk
            next_state  <= STATE_PCIE_CLK_DETECTED ;
          end          
        end else if ( rst_counter == 1'b1)  begin
          rst_counter <= 1'b0 ; //  Start counter to hold Ideal state for known period of time
          next_state  <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end

      STATE_DAC_CLK_DETECTED:
        if ( dac_clk == 1'b1) begin
          rst_counter <= 1'b0; //  Start counter to wait for locked signal from mmcm
          next_state  <= STATE_WAIT_DAC_LOCKED;          
        end else begin
          next_state <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end

      STATE_WAIT_DAC_LOCKED:
        if ( locked == 1'b1) begin                    
          rst_counter <= 1'b1;
          next_state <= STATE_DAC_CLK_LOCKED;
        end else if ( counter_expired == 1'b1 ) begin
            next_state  <= STATE_IDLE ;
            select_clk  <=  1'b0 ;
        end

      STATE_DAC_CLK_LOCKED:
        if ( dac_clk == 1'b0) begin  // lost of dac clk 
          rst_counter <= 1'b1;
          next_state  <= STATE_IDLE;
          select_clk  <=  1'b0 ;  // clk mux will select zero input
        end

      STATE_PCIE_CLK_DETECTED:
        if ( pcie_clk == 1'b1) begin
          rst_counter <= 1'b0;
          next_state <= STATE_PCIE_CLK_LOCKED;
        end else begin
          next_state <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end

      STATE_WAIT_PCIE_LOCKED:
        if ( locked == 1'b1) begin
          rst_counter <= 1'b1;
          next_state <= STATE_WAIT_PCIE_LOCKED;
        end  else if ( dac_clk == 1'b1 ) begin
          next_state <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end else if ( counter_expired == 1'b1) begin
          next_state  <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end        

      STATE_PCIE_CLK_LOCKED:        
        if ( dac_clk == 1'b1 ) begin
          next_state <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end else if (locked == 1'b0) begin 
          next_state <= STATE_IDLE;
          select_clk  <=  1'b0 ;
        end
      default : next_state = STATE_IDLE;
    endcase
  end
end

// counter 
always @ ( posedge pcie_clk) begin : COUNTER_SEQ
  if ( rst_counter == 1'b1) begin  // reset == 1'b1 or
    counter_expired <= 1'b0;
    counter         <= 0;
  end else if (state == STATE_IDLE ) begin
    counter <= counter + 1'b1;
    if ( counter == counter_limit) begin 
      counter_expired <= 1'b1;
      rst_counter     <= 1'b1 ;
    end
  end else if (state == STATE_WAIT_DAC_LOCKED ) begin
    counter <= counter + 1'b1;
    if ( counter == counter_limit) begin 
      counter_expired <= 1'b1;
      rst_counter     <= 1'b1 ;
    end
  end else if (state == STATE_WAIT_PCIE_LOCKED) begin 
    counter <= counter + 1'b1;
    if ( counter == counter_limit) begin 
      counter_expired <= 1'b1;
      rst_counter     <= 1'b1 ;
    end
  end
end

//----------Seq Logic-----------------------------

 always @ (posedge pcie_clk) begin : FSM_SEQ
   if (reset == 1'b1) begin
     state <= #1  STATE_IDLE;
   end else begin
     state <= #1  next_state;
   end
 end
/* ################################################## */

  // Instantiation of the clocking network
  //--------------------------------------
  clk_wiz_0 clknetwork
   (
    .clk_out1           (clk_int),
    .reset              (reset),
    .power_down         (1'b0),
    .input_clk_stopped  (input_clk_stopped),
    .locked             (locked),
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
