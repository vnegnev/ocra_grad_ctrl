//-----------------------------------------------------------------------------
// Title         : ocra1_iface
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : ocra1_iface.v
// Author        :   <vlad@arch-ssd>
// Created       : 03.09.2020
// Last modified : 03.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Interface between gradient BRAM module and OCRA1 GPA board, with a
// four-channel SPI serialiser and associated FSM logic.
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 03.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _OCRA1_IFACE_
 `define _OCRA1_IFACE_

 `timescale 1ns/1ns

module ocra1_iface(
		   input 	clk,

		   // data words from gradient memory core
		   input [23:0] datax_i,
		   input [23:0] datay_i,
		   input [23:0] dataz_i,
		   input [23:0] dataz2_i,

		   // data valid flag, should be held high for 1 cycle to initiate a transfer		   
		   input 	valid_i,

		   // OCRA1 interface (startup values are set here as well)
		   output reg 	oc1_clk_o = 0,
		   output reg 	oc1_syncn_o = 1,
		   output reg 	oc1_ldacn_o = 0,
		   output reg 	oc1_sdox_o = 0,
		   output reg 	oc1_sdoy_o = 0,
		   output reg 	oc1_sdoz_o = 0,
		   output reg 	oc1_sdoz2_o = 0,

		   output reg 	busy_o = 0 // should be held high while module is carrying out an SPI transfer
		   );

   // 122.88 -> 3.84 MHz clock freq - ~150 ksps update rate possible
   // spi_clk_edge_div used for toggling the SPI clock
   localparam spi_clk_div = 32, spi_clk_edge_div = 16;

   localparam IDLE = 25, START = 24, END = 0;
   
   reg [5:0] 			state = IDLE;
   reg [5:0] 			div_ctr = 0;
   reg [23:0] 			datax_r = 0, datay_r = 0, dataz_r = 0, dataz2_r = 0;
   
   always @(posedge clk) begin
      // default assignments, which will take place unless overridden by other assignments in the FSM
//       oc1_clk_o <= 1;
      oc1_syncn_o <= 0;
      oc1_ldacn_o <= 0;
      busy_o <= 1;

      // could use a wire, but deliberately adding a clocked register stage to help with timing
      {oc1_sdox_o, oc1_sdoy_o, oc1_sdoz_o, oc1_sdoz2_o} <= {datax_r[23], datay_r[23], dataz_r[23], dataz2_r[23]};
      
      case (state)
	IDLE: begin
	   oc1_syncn_o <= 1;
	   busy_o <= 0;
	   state <= IDLE;
	   if (valid_i) begin
	      {datax_r, datay_r, dataz_r, dataz2_r} <= {datax_i, datay_i, dataz_i, dataz2_i};
	      state <= START;
	   end
	end
	END: begin
	   // all the data has been clocked out; just go back to IDLE
	   state <= IDLE;
	end
	default: begin // covers the START state and all the states down to 0	   
	   oc1_clk_o <= div_ctr < spi_clk_edge_div; //
	   // divisor logic	  
	   if (div_ctr == spi_clk_div) begin
	      div_ctr <= 0;
	      {datax_r, datay_r, dataz_r, dataz2_r} <= {datax_r << 1, datay_r << 1, dataz_r << 1, dataz2_r << 1};
	      state <= state - 1; // eventually will hit the END state
	   end else begin
	      div_ctr <= div_ctr + 1;
	   end
	end // case: default

      endcase // case (state)
   end // always @ (posedge clk)   

endmodule // ocra1_iface
`endif //  `ifndef _OCRA1_IFACE_
