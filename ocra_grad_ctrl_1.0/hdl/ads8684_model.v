//-----------------------------------------------------------------------------
// Title         : dac80504_model
// Project       : OCRA
//-----------------------------------------------------------------------------
// File          : ads8684_model.v
// Author        : benjamin menkuec
// Created       : 18.10.2020
// Last modified : 18.10.2020
//-----------------------------------------------------------------------------
// Description :
// Behavioural model of the TI ADS8684
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 18.10.2020 : created
//-----------------------------------------------------------------------------

`ifndef _ADS8684_MODEL_
 `define _ADS8684_MODEL_

 `timescale 1ns/1ns

module ads8684_model(
		// pin labelling as in the ADS8684 datasheet
		input 	      csn,
		input 	      sclk,
		input 	      sdi,
		input [15:0] ain_0p, ain_1p, ain_2p, ain_3p,

		output reg 	      sdo
		);

	// internal ADC registers
	reg [7:0] 	AUTO_SEQ_EN = 8'hff, 
				Channel_Power_Down = 8'h00,
				Feature_Select = 8'h00,
				Channel_0_Input_Range = 8'h00,
				Channel_1_Input_Range = 8'h00,
				Channel_2_Input_Range = 8'h00,
				Channel_3_Input_Range = 8'h00;
	reg	[7:0]	Operating_Mode = 0;



	reg [15:0] 			  spi_input = 0;
	wire [15:0] 		  spi_payload = spi_input[15:0];
	wire [6:0] 			  spi_addr = spi_input[15:9];
	wire [7:0] 			  spi_cmd = spi_input[15:8];
	reg [5:0] 			  spi_counter = 0;
	reg [7:0]			  output_bits_left = 32;
	reg [15:0]			  spi_output = 0;
	wire 			  	  spi_transfer_done = spi_counter == 16; 

	always @(negedge sclk or posedge csn) begin
		if (csn) begin
			spi_counter <= 0;
			spi_input <= 0;
			if (spi_transfer_done) begin // executed only once after CS went high
			// $display("addr %d payload %d",spi_addr,spi_payload);
				case(spi_addr)
					8'h01: AUTO_SEQ_EN = spi_payload[7:0];
					8'h02: Channel_Power_Down = spi_payload[7:0];
					8'h03: Feature_Select = spi_payload[7:0];
					8'h05: Channel_0_Input_Range = spi_payload[7:0];
					8'h06: Channel_1_Input_Range = spi_payload[7:0];
					8'h07: Channel_2_Input_Range = spi_payload[7:0];
					8'h08: Channel_3_Input_Range = spi_payload[7:0];
				endcase
				if (spi_cmd & 8'h80) begin
					Operating_Mode <= spi_cmd; 
				end
			end
			if (output_bits_left == 17) begin
				// TODO: implement other operating modes
				if (Operating_Mode == 8'hC0) begin
					spi_output <= ain_0p;
				end
				else if (Operating_Mode == 8'hC1) begin
					spi_output <= ain_1p;
				end
				else if (Operating_Mode == 8'hC2) begin
					spi_output <= ain_2p;
				end
				else if (Operating_Mode == 8'hC3) begin
					spi_output <= ain_3p;
				end
				else begin
					output_bits_left <= 0;
				end
			end
			// output starts 16 bits after CS went high
			// OUTPUT
			else if (output_bits_left < 17) begin
				sdo <= spi_output[15];
				spi_output <= {spi_output[14:0], 1'b0};
			end
			else begin
				sdo <= 0;
			end
			output_bits_left <= output_bits_left - 1;
		end 
		// INPUT
		else begin
			if (spi_counter != 16) begin
				spi_input <= {spi_input[14:0], sdi}; // clock in data only when syncn low
				spi_counter <= spi_counter + 1;
			end
			output_bits_left <= 32;
		end 
	end 
   
endmodule 
`endif 