//-----------------------------------------------------------------------------
// Title         : dac80504_model_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : ads8684_model_tb.v
// Author        : benjamin menkuec
// Created       : 20.10.2020
// Last modified : 20.10.2020
//-----------------------------------------------------------------------------
// Description :
// Simple testbench for ADS8684 model
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 05.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _ADS8684_MODEL_TB_
 `define _ADS8684_MODEL_TB_

 `include "ads8684_model.v"

 `timescale 1ns/1ns

module ads8684_model_tb;
	reg			csn;		
	reg			ldacn;			
	reg			sclk;		
	reg			sdi;		
	reg			ain_0p[15:0];
	reg			ain_1p[15:0];
	reg			ain_2p[15:0];
	reg			ain_3p[15:0];

	wire			sdo;	


	reg [31:0] 		word_to_send;
	reg [31:0]		received_data;
	reg 			err = 0;
	integer 		k;

	initial begin
		$dumpfile("icarus_compile/000_ads8684_model_tb.lxt");
		$dumpvars(0, ads8684_model_tb);

		csn = 0;
		sclk = 0;
		sdi = 0;

		// prepare for incoming data
		#100 csn = 1;

		// read channel 0
		word_to_send = {16'hC000, 16'h0000};
		#20 csn = 0;
		for (k = 23; k >= 0; k = k - 1) begin
			#10 sclk = 1;
			sdi = word_to_send[k];
			#10 sclk = 0;
		end
		#10 csn = 1;
		#10
		for (k = 23; k >= 0; k = k - 1) begin
			#10 sclk = 1;
			received_data[k] = sdo;
			#10 sclk = 0;
		end


		// check DAC output word is as expected before and after cs
		#10 if (received_data[31:16] != ain_0p) begin
			$display("%d ns: Unexpected ADC output, expected %x, saw %x.", $time, ain_0p, received_data);
			err <= 1;
		end      

      
		#1000 if (err) begin
			$display("THERE WERE ERRORS");
			$stop; // to return a nonzero error code if the testbench is later scripted at a higher level
		end
		$finish;
   end
   
	ads8684_model UUT(/*autoinst*/
		// Outputs
		.sdo		(sdo),
		// Inputs
		.csn		(csn),
		.sclk		(sclk),
		.sdi		(sdi)),
		.ain_0p		(ain_0p[15:0]),
		.ain_1p		(ain_1p[15:0]),
		.ain_2p		(ain_2p[15:0]),
		.ain_3p		(ain_3p[15:0]);
   
endmodule // dac80504_model_tb
`endif //  `ifndef _DAC80504_MODEL_TB_
