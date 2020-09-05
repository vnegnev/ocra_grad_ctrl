//-----------------------------------------------------------------------------
// Title         : gpa_fhdo_iface
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : gpa_fhdo_iface.v
// Author        :   <vlad@arch-ssd>
// Created       : 03.09.2020
// Last modified : 03.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Interface between gradient BRAM module and the GPA-FHDO board, with
// an SPI serialiser for the 4-channel DAC and associated FSM logic.
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 03.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GPA_FHDO_IFACE_
 `define _GPA_FHDO_IFACE_

 `timescale 1ns/1ns

module gpa_fhdo_iface(
		   input 	clk,

		   // data words from gradient memory core
		   input [23:0] datax_i,
		   input [23:0] datay_i,
		   input [23:0] dataz_i,
		   input [23:0] dataz2_i,

		   // data valid flag, should be held high for 1 cycle to initiate a transfer		   
		   input 	valid_i,

		   // GPA-FHDO interface
		   output reg 	fhd_clk_o,
		   output reg 	fhd_sdo_o,
		   output reg 	fhd_csn_o,
		   input 	fhd_sdi_i, // not used yet, but will add an SPI readback feature later

		   output reg 	busy_o // should be held high while module is carrying out an SPI transfer
		   );

   always @(posedge clk) begin
      // serialiser FSM etc
   end

endmodule // gpa_fhdo_iface
`endif //  `ifndef _GPA_FHDO_IFACE_
