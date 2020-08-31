//-----------------------------------------------------------------------------
// Title         : ocra_grad_ctrl_tb
// Project       : OCRA
//-----------------------------------------------------------------------------
// File          : ocra_grad_ctrl_tb.v
// Author        :   <vlad@arch-ssd>
// Created       : 31.08.2020
// Last modified : 31.08.2020
//-----------------------------------------------------------------------------
// Description :
// Generic Verilog-2001 testbench for ocra_grad_ctrl
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 31.08.2020 : created
//-----------------------------------------------------------------------------

`ifndef _OCRA_GRAD_CTRL_TB_
 `define _OCRA_GRAD_CTRL_TB_

 `include "ocra_grad_ctrl.v"

 `timescale 1ns / 1ns

module ocra_grad_ctrl_tb;
   // Parameters copied from ocra_grad_ctrl for now (duplication of information, I know)
   localparam integer 			      C_S00_AXI_DATA_WIDTH = 32;
   localparam integer 			      C_S00_AXI_ADDR_WIDTH = 14;

   // Localparams of Axi Slave Bus Interface S_AXI_INTR
   localparam integer 			      C_S_AXI_INTR_DATA_WIDTH = 32;
   localparam integer 			      C_S_AXI_INTR_ADDR_WIDTH = 5;
   localparam integer 			      C_NUM_OF_INTR = 1;
   localparam C_INTR_SENSITIVITY = 32'hffffffff;
   localparam C_INTR_ACTIVE_STATE = 32'hffffffff;
   localparam integer 			      C_IRQ_SENSITIVITY = 1;
   localparam integer 			      C_IRQ_ACTIVE_STATE = 1;   
   
   reg clk, rstn;
   wire s00_axi_aclk = clk, s_axi_intr_aclk = clk;
   wire s00_axi_aresetn = rstn;
   reg 	err; // error flag in testbench
   
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s00_axi_arprot;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_arvalid;	// To UUT of ocra_grad_ctrl.v
   reg [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s00_axi_awprot;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_awvalid;	// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_bready;		// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_rready;		// To UUT of ocra_grad_ctrl.v
   reg [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata;// To UUT of ocra_grad_ctrl.v
   reg [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb;// To UUT of ocra_grad_ctrl.v
   reg			s00_axi_wvalid;		// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_ADDR_WIDTH-1:0] s_axi_intr_araddr;// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_aresetn;	// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s_axi_intr_arprot;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_arvalid;	// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_ADDR_WIDTH-1:0] s_axi_intr_awaddr;// To UUT of ocra_grad_ctrl.v
   reg [2:0]		s_axi_intr_awprot;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_awvalid;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_bready;	// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_rready;	// To UUT of ocra_grad_ctrl.v
   reg [C_S_AXI_INTR_DATA_WIDTH-1:0] s_axi_intr_wdata;// To UUT of ocra_grad_ctrl.v
   reg [(C_S_AXI_INTR_DATA_WIDTH/8)-1:0] s_axi_intr_wstrb;// To UUT of ocra_grad_ctrl.v
   reg			s_axi_intr_wvalid;	// To UUT of ocra_grad_ctrl.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			irq;			// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_arready;	// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_awready;	// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s00_axi_bresp;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_bvalid;		// From UUT of ocra_grad_ctrl.v
   wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata;// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s00_axi_rresp;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_rvalid;		// From UUT of ocra_grad_ctrl.v
   wire			s00_axi_wready;		// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_arready;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_awready;	// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s_axi_intr_bresp;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_bvalid;	// From UUT of ocra_grad_ctrl.v
   wire [C_S_AXI_INTR_DATA_WIDTH-1:0] s_axi_intr_rdata;// From UUT of ocra_grad_ctrl.v
   wire [1:0]		s_axi_intr_rresp;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_rvalid;	// From UUT of ocra_grad_ctrl.v
   wire			s_axi_intr_wready;	// From UUT of ocra_grad_ctrl.v
   // End of automatics

   initial begin

   end

   // Tasks for AXI bus reads and writes, later interrupt control (if we choose to use it)
   task wr32; //write to bus
      input [31:0] addr;
      input [31:0] data;
      begin
         #1 s00_axi_wdata = data;
         s00_axi_awaddr = addr;
         s00_axi_awvalid = 1;
         s00_axi_wvalid = 1;
         fork
            begin: wait_axi_write
               wait(s00_axi_awready && s00_axi_wready);
               disable axi_write_timeout;
            end
            begin: axi_write_timeout
               // #10000 disable wait_axi_write;
            end
         join
         #1.3 s00_axi_awvalid = 0;
         s00_axi_wvalid = 0;
      end
   endtask // wr32

   task rd32; //read from bus
      input [31:0] addr;
      input [31:0] expected;
      begin
         #1 s00_axi_arvalid = 1;
         s00_axi_araddr = addr;
         wait(s00_axi_arready);
         #1.3 s00_axi_arvalid = 0;
         wait(s00_axi_rvalid);
         #1.3 if (expected !== s00_axi_rdata) begin
            $display("%d ns: Bus read error, address %x, expected output %x, read %x.",
		     $time, addr, expected, s00_axi_rdata);
            err <= 1'd1;
         end
         s00_axi_rready = 1;
         s00_axi_arvalid = 0;
         #1 s00_axi_rready = 0;
      end
   endtask // rd32   

   // Clock generation: assuming 100 MHz for convenience (in real design it'll be 122.88, 125 or 144 MHz depending on what's chosen)
   always #0.5 clk = !clk;
   
   ocra_grad_ctrl UUT(
		      /*AUTOINST*/
		      // Outputs
		      .s00_axi_awready	(s00_axi_awready),
		      .s00_axi_wready	(s00_axi_wready),
		      .s00_axi_bresp	(s00_axi_bresp[1:0]),
		      .s00_axi_bvalid	(s00_axi_bvalid),
		      .s00_axi_arready	(s00_axi_arready),
		      .s00_axi_rdata	(s00_axi_rdata[C_S00_AXI_DATA_WIDTH-1:0]),
		      .s00_axi_rresp	(s00_axi_rresp[1:0]),
		      .s00_axi_rvalid	(s00_axi_rvalid),
		      .s_axi_intr_awready(s_axi_intr_awready),
		      .s_axi_intr_wready(s_axi_intr_wready),
		      .s_axi_intr_bresp	(s_axi_intr_bresp[1:0]),
		      .s_axi_intr_bvalid(s_axi_intr_bvalid),
		      .s_axi_intr_arready(s_axi_intr_arready),
		      .s_axi_intr_rdata	(s_axi_intr_rdata[C_S_AXI_INTR_DATA_WIDTH-1:0]),
		      .s_axi_intr_rresp	(s_axi_intr_rresp[1:0]),
		      .s_axi_intr_rvalid(s_axi_intr_rvalid),
		      .irq		(irq),
		      // Inputs
		      .s00_axi_aclk	(s00_axi_aclk),
		      .s00_axi_aresetn	(s00_axi_aresetn),
		      .s00_axi_awaddr	(s00_axi_awaddr[C_S00_AXI_ADDR_WIDTH-1:0]),
		      .s00_axi_awprot	(s00_axi_awprot[2:0]),
		      .s00_axi_awvalid	(s00_axi_awvalid),
		      .s00_axi_wdata	(s00_axi_wdata[C_S00_AXI_DATA_WIDTH-1:0]),
		      .s00_axi_wstrb	(s00_axi_wstrb[(C_S00_AXI_DATA_WIDTH/8)-1:0]),
		      .s00_axi_wvalid	(s00_axi_wvalid),
		      .s00_axi_bready	(s00_axi_bready),
		      .s00_axi_araddr	(s00_axi_araddr[C_S00_AXI_ADDR_WIDTH-1:0]),
		      .s00_axi_arprot	(s00_axi_arprot[2:0]),
		      .s00_axi_arvalid	(s00_axi_arvalid),
		      .s00_axi_rready	(s00_axi_rready),
		      .s_axi_intr_aclk	(s_axi_intr_aclk),
		      .s_axi_intr_aresetn(s_axi_intr_aresetn),
		      .s_axi_intr_awaddr(s_axi_intr_awaddr[C_S_AXI_INTR_ADDR_WIDTH-1:0]),
		      .s_axi_intr_awprot(s_axi_intr_awprot[2:0]),
		      .s_axi_intr_awvalid(s_axi_intr_awvalid),
		      .s_axi_intr_wdata	(s_axi_intr_wdata[C_S_AXI_INTR_DATA_WIDTH-1:0]),
		      .s_axi_intr_wstrb	(s_axi_intr_wstrb[(C_S_AXI_INTR_DATA_WIDTH/8)-1:0]),
		      .s_axi_intr_wvalid(s_axi_intr_wvalid),
		      .s_axi_intr_bready(s_axi_intr_bready),
		      .s_axi_intr_araddr(s_axi_intr_araddr[C_S_AXI_INTR_ADDR_WIDTH-1:0]),
		      .s_axi_intr_arprot(s_axi_intr_arprot[2:0]),
		      .s_axi_intr_arvalid(s_axi_intr_arvalid),
		      .s_axi_intr_rready(s_axi_intr_rready));
   
endmodule // ocra_grad_ctrl_tb
`endif //  `ifndef _OCRA_GRAD_CTRL_TB_

