//-----------------------------------------------------------------------------
// Title         : ad5781_model
// Project       : sdf
//-----------------------------------------------------------------------------
// File          : ad5781_model.v
// Author        :   <vlad@arch-ssd>
// Created       : 31.08.2020
// Last modified : 31.08.2020
//-----------------------------------------------------------------------------
// Description :
// Behavioural model of the Analog Devices AD5781 DAC
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 31.08.2020 : created
//-----------------------------------------------------------------------------

`ifndef _AD5781_MODEL_
 `define _AD5781_MODEL_

 `timescale 1ns/1ns

module ad5781_model(
		    input clk,
		    input syncn,
		    input ldacn,
		    input sdo,

		    output [17:0] dac_out,
		    );

   reg [23:0] 			  dac_reg, ctrl_reg, soft_ctrl_reg;


   always @(posedge clk) begin
      

endmodule // ad5781_model
`endif //  `ifndef _AD5781_MODEL_

