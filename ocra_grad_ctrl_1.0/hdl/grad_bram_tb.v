//-----------------------------------------------------------------------------
// Title         : grad_bram_tb
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : grad_bram_tb.v
// Author        :   <vlad@arch-ssd>
// Created       : 13.09.2020
// Last modified : 13.09.2020
//-----------------------------------------------------------------------------
// Description :
// 
// Testbench for grad_bram, testing out the various features of the core
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 13.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GRAD_BRAM_TB_
 `define _GRAD_BRAM_TB_

 `include "grad_bram.v"

 `timescale 1ns/1ns

module grad_bram_tb;
   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH = 32;
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH = 16;
   reg 		     err = 0;
		     
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg			S_AXI_ACLK;		// To UUT of grad_bram.v
   reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR;	// To UUT of grad_bram.v
   reg			S_AXI_ARESETN;		// To UUT of grad_bram.v
   reg [2:0]		S_AXI_ARPROT;		// To UUT of grad_bram.v
   reg			S_AXI_ARVALID;		// To UUT of grad_bram.v
   reg [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR;	// To UUT of grad_bram.v
   reg [2:0]		S_AXI_AWPROT;		// To UUT of grad_bram.v
   reg			S_AXI_AWVALID;		// To UUT of grad_bram.v
   reg			S_AXI_BREADY;		// To UUT of grad_bram.v
   reg			S_AXI_RREADY;		// To UUT of grad_bram.v
   reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA;	// To UUT of grad_bram.v
   reg [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB;// To UUT of grad_bram.v
   reg			S_AXI_WVALID;		// To UUT of grad_bram.v
   reg			data_enb_i;		// To UUT of grad_bram.v
   reg [15:0]		offset_i;		// To UUT of grad_bram.v
   reg			serial_busy_i;		// To UUT of grad_bram.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			S_AXI_ARREADY;		// From UUT of grad_bram.v
   wire			S_AXI_AWREADY;		// From UUT of grad_bram.v
   wire [1:0]		S_AXI_BRESP;		// From UUT of grad_bram.v
   wire			S_AXI_BVALID;		// From UUT of grad_bram.v
   wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA;	// From UUT of grad_bram.v
   wire [1:0]		S_AXI_RRESP;		// From UUT of grad_bram.v
   wire			S_AXI_RVALID;		// From UUT of grad_bram.v
   wire			S_AXI_WREADY;		// From UUT of grad_bram.v
   wire [31:0]		data_o;			// From UUT of grad_bram.v
   wire			valid_o;		// From UUT of grad_bram.v
   // End of automatics

   // Clock generation: assuming 100 MHz for convenience (in real design it'll be 122.88, 125 or 144 MHz depending on what's chosen)   
   always #5 S_AXI_ACLK = !S_AXI_ACLK;

   integer 		k;
   
   initial begin
      $dumpfile("icarus_compile/000_grad_bram_tb.lxt");
      $dumpvars(0, grad_bram_tb);

      S_AXI_ACLK = 1;
      S_AXI_ARADDR = 0;
      S_AXI_ARESETN = 0;
      S_AXI_ARPROT = 0;
      S_AXI_ARVALID = 0;
      S_AXI_AWADDR = 0;
      S_AXI_AWPROT = 0;
      S_AXI_AWVALID = 0;
      S_AXI_BREADY = 0;
      S_AXI_RREADY = 0;
      S_AXI_WDATA = 0;
      S_AXI_WSTRB = 0;
      S_AXI_WVALID = 0;
      
      data_enb_i = 0;
      offset_i = 0;
      serial_busy_i = 0;

      #107 S_AXI_ARESETN = 1; // extra 7ns to ensure that TB stimuli occur a bit before the positive clock edges
      S_AXI_BREADY = 1; // TODO: make this more fine-grained if bus reads/writes don't work properly in hardware
      #10 wr32(16'd4, 32'hdeadbeef); // reg 1
      wr32(16'd8, 32'hcafebabe); // reg 2
      wr32(16'd12, 32'habcd0123); // reg 3
      wr32(16'd16, 32'h12345678); // reg 4 -- this write shouldn't do anything, since reg4 is read-only

      // register readback tests
      #10 rd32(16'd0, {22'd0, 10'd303});
      rd32(16'd4, 32'hdeadbeef);
      rd32(16'd8, 32'hcafebabe);
      rd32(16'd12, 32'habcd0123);
      rd32(16'd16, 32'd0);

      // BRAM writes
      for (k = 0; k < 8192; k = k + 1) begin // should overflow 1 location
	 wr32(16'h8000 + (k << 2), k);
      end

      // Start outputting data; address 0
      #100 data_enb_i = 1;

      // Change output rate to be maximally fast (one output per 4 clock cycles), then change back to normal
      #29300 wr32(16'd0, {22'd0, 10'd0});
      #200 wr32(16'd0, {22'd0, 10'd303});

      // Change BRAM offset (before previous output is finished)
      #5000 offset_i = 10;
      #5000 data_enb_i = 0;
      #10 data_enb_i = 1;

      // Simulate a 'busy' condition that doesn't stay for very long
      #10000 serial_busy_i = 1;
      #3000 serial_busy_i = 0;
      #10 rd32(16'd16, 32'd0);

      // Simulate a longer 'busy' condition that will compromise the output integrity
      #10000 serial_busy_i = 1;
      #10000 serial_busy_i = 0;
      #10 rd32(16'd16, 32'd1);

      // Reset core, make sure it resumes correctly
      #500 S_AXI_ARESETN = 0;
      #10 S_AXI_ARESETN = 1;

      // TODO: continue here -- reset behaviour in response to momentary reset isn't entirely clear.
      #20000 $finish;
   end

   // Tasks for AXI bus reads and writes
   task wr32; //write to bus
      input [31:0] addr, data;
      begin
         #10 S_AXI_WDATA = data;
	 S_AXI_WSTRB = 'hf;
         S_AXI_AWADDR = addr;
         S_AXI_AWVALID = 1;
         S_AXI_WVALID = 1;
         fork
            begin: wait_axi_write
               wait(S_AXI_AWREADY && S_AXI_WREADY);
               disable axi_write_timeout;
            end
            begin: axi_write_timeout
               #10000 disable wait_axi_write;
	       $display("%d ns: AXI write timed out", $time);
            end
         join
         #13 S_AXI_AWVALID = 0;
         S_AXI_WVALID = 0;
      end
   endtask // wr32

   task rd32; //read from bus
      input [31:0] addr;
      input [31:0] expected;
      begin
         #10 S_AXI_ARVALID = 1;
         S_AXI_ARADDR = addr;
         wait(S_AXI_ARREADY);
         #13 S_AXI_ARVALID = 0;
         wait(S_AXI_RVALID);
         #13 if (expected !== S_AXI_RDATA) begin
            $display("%d ns: Bus read error, address %x, expected output %x, read %x.",
		     $time, addr, expected, S_AXI_RDATA);
            err <= 1'd1;
         end
         S_AXI_RREADY = 1;
         S_AXI_ARVALID = 0;
         #10 S_AXI_RREADY = 0;
      end
   endtask // rd32
   
   grad_bram UUT(/*AUTOINST*/
		 // Outputs
		 .data_o		(data_o[31:0]),
		 .valid_o		(valid_o),
		 .S_AXI_AWREADY		(S_AXI_AWREADY),
		 .S_AXI_WREADY		(S_AXI_WREADY),
		 .S_AXI_BRESP		(S_AXI_BRESP[1:0]),
		 .S_AXI_BVALID		(S_AXI_BVALID),
		 .S_AXI_ARREADY		(S_AXI_ARREADY),
		 .S_AXI_RDATA		(S_AXI_RDATA[C_S_AXI_DATA_WIDTH-1:0]),
		 .S_AXI_RRESP		(S_AXI_RRESP[1:0]),
		 .S_AXI_RVALID		(S_AXI_RVALID),
		 // Inputs
		 .offset_i		(offset_i[15:0]),
		 .data_enb_i		(data_enb_i),
		 .serial_busy_i		(serial_busy_i),
		 .S_AXI_ACLK		(S_AXI_ACLK),
		 .S_AXI_ARESETN		(S_AXI_ARESETN),
		 .S_AXI_AWADDR		(S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1:0]),
		 .S_AXI_AWPROT		(S_AXI_AWPROT[2:0]),
		 .S_AXI_AWVALID		(S_AXI_AWVALID),
		 .S_AXI_WDATA		(S_AXI_WDATA[C_S_AXI_DATA_WIDTH-1:0]),
		 .S_AXI_WSTRB		(S_AXI_WSTRB[(C_S_AXI_DATA_WIDTH/8)-1:0]),
		 .S_AXI_WVALID		(S_AXI_WVALID),
		 .S_AXI_BREADY		(S_AXI_BREADY),
		 .S_AXI_ARADDR		(S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:0]),
		 .S_AXI_ARPROT		(S_AXI_ARPROT[2:0]),
		 .S_AXI_ARVALID		(S_AXI_ARVALID),
		 .S_AXI_RREADY		(S_AXI_RREADY));

   // Wires purely for debugging (since GTKwave can't access a single RAM word directly)
   wire [31:0] bram_a0 = UUT.grad_bram[0], bram_a1 = UUT.grad_bram[1], bram_a1024 = UUT.grad_bram[1024], bram_amax = UUT.grad_bram[8191];
endmodule // grad_bram_tb
`endif //  `ifndef _GRAD_BRAM_TB_

