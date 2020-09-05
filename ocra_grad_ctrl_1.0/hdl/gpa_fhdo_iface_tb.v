//-----------------------------------------------------------------------------
// Title         : gpa_fhdo_iface_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : gpa_fhdo_iface_tb.v
// Author        :   <vlad@arch-ssd>
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
   reg [23:0]		datax_i;
   reg [23:0]		datay_i;
   reg [23:0]		dataz2_i;		
   reg [23:0]		dataz_i;		
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
      datax_i = 0;
      datay_i = 0;
      dataz_i = 0;
      dataz2_i = 0;
      valid_i = 0;

      #100 send(1,2,3,4);
      #1000 send(5,6,7,8);

      #1000 $finish;
   end // initial begin

   task send; // send data to GPA-FHDO interface core
      input [23:0] inx, iny, inz, inz2;
      begin
	 // TODO: perform a check to see whether the busy line is set before trying to send data
	 #10 datax_i = inx; datay_i = iny; dataz_i = inz; dataz2_i = inz2; valid_i = 1;
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
		    .datax_i		(datax_i),
		    .datay_i		(datay_i),
		    .dataz_i            (dataz_i),
		    .dataz2_i		(dataz2_i),			
		    .valid_i	(valid_i),
		    .fhd_sdi_i		(sdi));

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
