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
 `include "ocra1_model.v"

 `timescale 1ns/1ns

module ocra1_iface_tb;
   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			clk;			// To UUT of ocra1_iface.v
   reg [31:0]		data_i;			// To UUT of ocra1_iface.v
   reg [5:0]		spi_clk_div_i;		// To UUT of ocra1_iface.v
   reg			valid_i;		// To UUT of ocra1_iface.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			busy_o;			// From UUT of ocra1_iface.v
   wire			ldacn;			// From UUT of ocra1_iface.v
   wire			sclk;			// From UUT of ocra1_iface.v
   wire			sdox;			// From UUT of ocra1_iface.v
   wire			sdoy;			// From UUT of ocra1_iface.v
   wire			sdoz;			// From UUT of ocra1_iface.v
   wire			sdoz2;			// From UUT of ocra1_iface.v
   wire			syncn;			// From UUT of ocra1_iface.v
   wire [17:0]		voutx;			// From OCRA1 of ocra1_model.v
   wire [17:0]		vouty;			// From OCRA1 of ocra1_model.v
   wire [17:0]		voutz;			// From OCRA1 of ocra1_model.v
   wire [17:0]		voutz2;			// From OCRA1 of ocra1_model.v
   // End of automatics
   
   initial begin
      $dumpfile("icarus_compile/000_ocra1_iface_tb.lxt");
      $dumpvars(0, ocra1_iface_tb);

      // initialisation
      clk = 1;
      data_i = 0;
      valid_i = 0;
      spi_clk_div_i = 32;

      #100 send(24'h200002, 24'h200002, 24'h200002, 24'h200002); // initialise all DACs
      #10000 sendV(1,2,3,4);
      #10000 sendV(5,6,7,8);
      #10000 sendV(-1,-2,-3,-4);      

      #10000 $finish;
   end // initial begin

   // check voltages
   initial begin
      #16556 checkV(0,0,0,0);
      #8 checkV(1,2,3,4);
   end
   initial begin
      #26604 checkV(1,2,3,4);
      #8 checkV(5,6,7,8);
   end
   initial begin
      #36660 checkV(5,6,7,8);
      #8 checkV(-1,-2,-3,-4);
   end   

   task send; // send data to OCRA1 interface core
      input [23:0] inx, iny, inz, inz2;
      begin
	 // TODO: perform a check to see whether the busy line is set before trying to send data
	 #10 data_i = {5'd0, 2'd0, 1'd0, inx};
	 valid_i = 1; 
	 #10 data_i = {5'd0, 2'd1, 1'd0, iny};
	 #10 data_i = {5'd0, 2'd2, 1'd0, inz}; 	 
	 #10 data_i = {5'd0, 2'd3, 1'd1, inz2};
	 #10 valid_i = 0;
      end
   endtask // send

   task sendV; // send DAC voltage data to OCRA1 interface core
      input [17:0] inx, iny, inz, inz2;
      begin
	 send({4'h1, inx, 2'd0}, {4'h1, iny, 2'd0}, {4'h1, inz, 2'd0}, {4'h1, inz2, 2'd0});
      end
   endtask // sendV

   task checkV;
      input [17:0] vx, vy, vz, vz2;
      begin
	 if (voutx != vx) $display("%d ns: X expected %x, read %x.", $time, vx, voutx);
	 if (vouty != vy) $display("%d ns: Y expected %x, read %x.", $time, vy, vouty);
	 if (voutz != vz) $display("%d ns: Z expected %x, read %x.", $time, vz, voutz);
	 if (voutz2 != vz2) $display("%d ns: Z2 expected %x, read %x.", $time, vz2, voutz2);
      end
   endtask // checkV   

   always #4 clk = !clk; // 125 MHz clock

   ocra1_iface UUT(
		   // Outputs
		   .oc1_clk_o		(sclk),
		   .oc1_syncn_o		(syncn),
		   .oc1_ldacn_o		(ldacn),
		   .oc1_sdox_o		(sdox),
		   .oc1_sdoy_o		(sdoy),
		   .oc1_sdoz_o		(sdoz),
		   .oc1_sdoz2_o		(sdoz2),
		   /*AUTOINST*/
		   // Outputs
		   .busy_o		(busy_o),
		   // Inputs
		   .clk			(clk),
		   .data_i		(data_i[31:0]),
		   .valid_i		(valid_i),
		   .spi_clk_div_i	(spi_clk_div_i[5:0]));

   ocra1_model OCRA1(
		     .clk		(sclk),
		     /*AUTOINST*/
		     // Outputs
		     .voutx		(voutx[17:0]),
		     .vouty		(vouty[17:0]),
		     .voutz		(voutz[17:0]),
		     .voutz2		(voutz2[17:0]),
		     // Inputs
		     .syncn		(syncn),
		     .ldacn		(ldacn),
		     .sdox		(sdox),
		     .sdoy		(sdoy),
		     .sdoz		(sdoz),
		     .sdoz2		(sdoz2));

endmodule // ocra1_iface_tb
`endif //  `ifndef _OCRA1_IFACE_TB_
