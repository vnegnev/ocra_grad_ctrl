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
		   input clk,

		   // data words from gradient memory core
		   input [23:0] datax_i,
		   input [23:0] datay_i,
		   input [23:0] dataz_i,
		   input [23:0] dataz2_i,

		   // data valid flag, should be held high for 1 cycle to initiate a transfer		   
		   input valid_i,

		   // OCRA1 interface
		   output reg oc1_clk_o,
		   output reg oc1_syncn_o,
		   output reg oc1_ldacn_o,
		   output reg oc1_sdox_o,
		   output reg oc1_sdoy_o,
		   output reg oc1_sdoz_o,
		   output reg oc1_sdoz2_o,

		   output reg busy_o // should be held high while module is carrying out an SPI transfer
		   );

   always @(posedge clk) begin
      // serialiser FSM etc
   end

endmodule // ocra1_iface
`endif //  `ifndef _OCRA1_IFACE_
