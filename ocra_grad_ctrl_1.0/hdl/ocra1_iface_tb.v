//-----------------------------------------------------------------------------
// Title         : ocra1_iface_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : ocra1_iface_tb.v
// Author        :   <vlad@arch-ssd>
// Created       : 03.09.2020
// Last modified : 03.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Testbench for OCRA1 interface and OCRA1 board model
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 03.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _OCRA1_IFACE_TB_
 `define _OCRA1_IFACE_TB_

 `include "ocra1_iface.v"
 `include "ad5781_model.v"

 `timescale 1ns/1ns

module ocra1_iface_tb;

   reg oc1_clrn = 1,  // not connected in the current ocra firmware, though it could be
       oc1_resetn = 1; // not connected to RP by OCRA1 board
   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To UUT of ocra1_iface.v
   reg [23:0]		datax_i;		// To UUT of ocra1_iface.v
   reg [23:0]		datay_i;		// To UUT of ocra1_iface.v
   reg [23:0]		dataz2_i;		// To UUT of ocra1_iface.v
   reg [23:0]		dataz_i;		// To UUT of ocra1_iface.v
   reg			valid_i;		// To UUT of ocra1_iface.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy_o;			// From UUT of ocra1_iface.v
   wire			oc1_clk_o;		// From UUT of ocra1_iface.v
   wire			oc1_ldacn_o;		// From UUT of ocra1_iface.v
   wire			oc1_sdox_o;		// From UUT of ocra1_iface.v
   wire			oc1_sdoy_o;		// From UUT of ocra1_iface.v
   wire			oc1_sdoz2_o;		// From UUT of ocra1_iface.v
   wire			oc1_sdoz_o;		// From UUT of ocra1_iface.v
   wire			oc1_syncn_o;		// From UUT of ocra1_iface.v
   // End of automatics

   wire [17:0] 		oc1_voutx, oc1_vouty, oc1_voutz, oc1_voutz2;

   initial begin
      $dumpfile("icarus_compile/000_ocra1_iface_tb.lxt");
      $dumpvars(0, ocra1_iface_tb);

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

   task send; // send data to OCRA1 interface core
      input [23:0] inx, iny, inz, inz2;
      begin
	 // TODO: perform a check to see whether the busy line is set before trying to send data
	 #10 datax_i = inx; datay_i = iny; dataz_i = inz; dataz2_i = inz2; valid_i = 1;
	 #10 valid_i = 0;
      end
   endtask // send   

   always #5 clk = !clk;

   ocra1_iface UUT(/*AUTOINST*/
		   // Outputs
		   .oc1_clk_o		(oc1_clk_o),
		   .oc1_syncn_o		(oc1_syncn_o),
		   .oc1_ldacn_o		(oc1_ldacn_o),
		   .oc1_sdox_o		(oc1_sdox_o),
		   .oc1_sdoy_o		(oc1_sdoy_o),
		   .oc1_sdoz_o		(oc1_sdoz_o),
		   .oc1_sdoz2_o		(oc1_sdoz2_o),
		   .busy_o		(busy_o),
		   // Inputs
		   .clk			(clk),
		   .datax_i		(datax_i[23:0]),
		   .datay_i		(datay_i[23:0]),
		   .dataz_i		(dataz_i[23:0]),
		   .dataz2_i		(dataz2_i[23:0]),
		   .valid_i		(valid_i));

   ad5781_model DACX(
		     // Outputs
		     .sdo		(),
		     .vout		(oc1_voutx),
		     // Inputs
		     .sdin		(oc1_sdox_o),
		     .sclk		(oc1_clk_o),
		     .syncn		(oc1_syncn_o),
		     .ldacn		(oc1_ldacn_o),
		     .clrn		(oc1_clrn),
		     .resetn		(oc1_resetn));

   ad5781_model DACY(
		     // Outputs
		     .sdo		(),
		     .vout		(oc1_vouty),
		     // Inputs
		     .sdin		(oc1_sdoy_o),
		     .sclk		(oc1_clk_o),
		     .syncn		(oc1_syncn_o),
		     .ldacn		(oc1_ldacn_o),
		     .clrn		(oc1_clrn),
		     .resetn		(oc1_resetn)); // not connected to RP by OCRA1 board

   ad5781_model DACZ(
		     // Outputs
		     .sdo		(),
		     .vout		(oc1_voutz),
		     // Inputs
		     .sdin		(oc1_sdoz_o),
		     .sclk		(oc1_clk_o),
		     .syncn		(oc1_syncn_o),
		     .ldacn		(oc1_ldacn_o),
		     .clrn		(oc1_clrn),
		     .resetn		(oc1_resetn));
   
   ad5781_model DACZ2(
		     // Outputs
		     .sdo		(),
		     .vout		(oc1_voutz2),
		     // Inputs
		     .sdin		(oc1_sdoz2_o),
		     .sclk		(oc1_clk_o),
		     .syncn		(oc1_syncn_o),
		     .ldacn		(oc1_ldacn_o),
		     .clrn		(oc1_clrn),
		     .resetn		(oc1_resetn));


endmodule // ocra1_iface_tb
`endif //  `ifndef _OCRA1_IFACE_TB_

