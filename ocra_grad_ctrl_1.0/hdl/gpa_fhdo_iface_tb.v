//-----------------------------------------------------------------------------
// Title         : gpa_fhdo_iface_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : gpa_fhdo_iface_tb.v
// Author        :   <benjamin.menkuec@fh-dortmund.de>
// Created       : 03.09.2020
// Last modified : 03.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Testbench for GPA-FHDO interface and GPA-FHDO board model
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 05.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GPA_FHDO_IFACE_TB_
 `define _GPA_FHDO_IFACE_TB_

 `include "gpa_fhdo_iface.v"
 `include "dac80504_model.v"

 `timescale 1ns/1ns

module gpa_fhdo_iface_tb;
   
   reg			clk;			
   reg [31:0]		data_i;	
   reg [5:0]		spi_clk_div_i;	   
   reg			valid_i;		

   //
   wire			busy_o;			
   wire			ldacn;			
   wire			sclk;			
   wire			sdo;			
   wire			sdi;			
   wire			csn;			
   wire [17:0]		voutx;		
   wire [17:0]		vouty;		
   wire [17:0]		voutz;		
   wire [17:0]		voutz2;		

   initial begin
      $dumpfile("icarus_compile/000_gpa_fhdo_iface_tb.lxt");
      $dumpvars(0, gpa_fhdo_iface_tb);

      // initialisation
      clk = 1;
      data_i = 0;
      valid_i = 0;
	  spi_clk_div_i = 32;

      #100 send(1,2,3,4);
      #20000 send(5,6,7,8);
 
      #20000 $finish;
   end // initial begin

   task send; // send data to OCRA1 interface core
      input [23:0] inx, iny, inz, inz2;
      begin
	 // TODO: perform a check to see whether the busy line is set before trying to send data
	 #10 data_i = {5'd0, 2'd0, 1'd0, inx};
	 valid_i = 1;
	 #10 valid_i = 0;
	 #80000 data_i = {5'd0, 2'd1, 1'd0, iny};
	 valid_i = 1;
	 #20000 valid_i = 0;
	 #80000 data_i = {5'd0, 2'd2, 1'd0, inz};
	 valid_i = 1;
	 #10 valid_i = 0; 	 
	 #80000 data_i = {5'd0, 2'd3, 1'd1, inz2};
 	 valid_i = 1;
	 #10 valid_i = 0;
      end
   endtask // send

   always #5 clk = !clk;

   gpa_fhdo_iface UUT(
			.clk		(clk),
			/*AUTOINST*/
			// Outputs
		    .busy_o		(busy_o),
		    .fhd_sdo_o	(sdo),
		    .fhd_clk_o  (sclk),
			.fhd_csn_o	(csn),
			// Inputs		     
		    .data_i		(data_i),		
		    .valid_i	(valid_i),
		    .fhd_sdi_i		(sdi),
			.spi_clk_div_i	(spi_clk_div_i[5:0]));

   dac80504_model GPA_FHDO(
		     .sclk		(sclk),
		     /*AUTOINST*/
		     // Outputs
		     .sdo		(sdi),			 
		     .vout0		(voutx[15:0]),
		     .vout1		(vouty[15:0]),
		     .vout2		(voutz[15:0]),
		     .vout3		(voutz2[15:0]),
		     // Inputs
             .ldacn		(ldacn),
		     .csn		(csn),
		     .sdi		(sdo));


endmodule // gpa_fhdo_iface_tb
`endif //  `ifndef _GPA_FHDO_IFACE_TB_
