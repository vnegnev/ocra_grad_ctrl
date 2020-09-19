//-----------------------------------------------------------------------------
// Title         : grad_bram
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : grad_bram.v
// Author        :   <vlad@arch-ssd>
// Created       : 06.09.2020
// Last modified : 06.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Gradient BRAM and output data FSM.  Local memory space: 64K. Lower
// 32K: control regs (addresses 0 - 8). Upper 32K: BRAM address
// space (depending on BRAM size selected). 32b addressability
//
// (note that addresses aligned to 4B; 16b address bus, of which only
// upper 14b are used)
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 06.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GRAD_BRAM_
 `define _GRAD_BRAM_

 `timescale 1ns / 1ns

module grad_bram #
  (
   // Users to add parameters here

   // User parameters ends
   // Do not modify the parameters beyond this line

   // Width of S_AXI data bus
   parameter integer C_S_AXI_DATA_WIDTH = 32,
   // Width of S_AXI address bus
   parameter integer C_S_AXI_ADDR_WIDTH = 16
   )
   (
    // Users to add ports here
    input [15:0] 			 offset_i, // BRAM address offset, when data output is started
    input 				 data_enb_i, // enable data outputs (i.e. run gradient waveforms)
    input 				 serial_busy_i, // serialiser/s busy with last data output
    output reg [31:0] 			 data_o, // Gradient data
    output reg 				 valid_o, // Gradient data valid

    // User ports end
    // Ports beyond this line were auto-generated by Xilinx

    // Global Clock Signal
    input 				 S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input 				 S_AXI_ARESETN,
    // Write address (issued by master, acceped by Slave)
    input [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_AWADDR,
    // Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    input [2 : 0] 			 S_AXI_AWPROT,
    // Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
    input 				 S_AXI_AWVALID,
    // Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
    output 				 S_AXI_AWREADY,
    // Write data (issued by master, acceped by Slave) 
    input [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.    
    input [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    // data and strobes are available.
    input 				 S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    output 				 S_AXI_WREADY,
    // Write response. This signal indicates the status
    // of the write transaction.
    output [1 : 0] 			 S_AXI_BRESP,
    // Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
    output 				 S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    // can accept a write response.
    input 				 S_AXI_BREADY,
    // Read address (issued by master, acceped by Slave)
    input [C_S_AXI_ADDR_WIDTH-1 : 0] 	 S_AXI_ARADDR,
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
    input [2 : 0] 			 S_AXI_ARPROT,
    // Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
    input 				 S_AXI_ARVALID,
    // Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
    output 				 S_AXI_ARREADY,
    // Read data (issued by slave)
    output [C_S_AXI_DATA_WIDTH-1 : 0] 	 S_AXI_RDATA,
    // Read response. This signal indicates the status of the
    // read transfer.
    output [1 : 0] 			 S_AXI_RRESP,
    // Read valid. This signal indicates that the channel is
    // signaling the required read data.
    output 				 S_AXI_RVALID,
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    input 				 S_AXI_RREADY
    );

   // AXI4LITE signals
   reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	      axi_awaddr;
   reg 					      axi_awready;
   reg 					      axi_wready;
   reg [1 : 0] 				      axi_bresp;
   reg 					      axi_bvalid;
   reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	      axi_araddr;
   reg 					      axi_arready;
   reg [C_S_AXI_DATA_WIDTH-1 : 0] 	      axi_rdata;
   reg [1 : 0] 				      axi_rresp;
   reg 					      axi_rvalid;

   // Example-specific design signals
   // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
   // ADDR_LSB is used for addressing 32/64 bit registers/memories
   // ADDR_LSB = 2 for 32 bits (n downto 2)
   // ADDR_LSB = 3 for 64 bits (n downto 3)
   localparam integer 			      ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
   localparam integer 			      OPT_MEM_ADDR_BITS = C_S_AXI_ADDR_WIDTH - ADDR_LSB - 1; // default: 16 - 2 - 1 = 13
   //----------------------------------------------
   //-- Signals for user logic register space example
   //------------------------------------------------
   //-- Number of Slave Registers 8
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg0 = {22'd0, 10'd303}; // 10 LSBs: interval divisor
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg1;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg2;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg3;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg4 = 0; // read-only
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg5;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg6;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      slv_reg7;
   wire 				      slv_reg_rden;
   wire 				      slv_reg_wen;
   reg [C_S_AXI_DATA_WIDTH-1:0] 	      reg_data_out;
   integer 				      byte_index;
   reg 					      aw_en;

   // I/O Connections assignments

   assign S_AXI_AWREADY	= axi_awready;
   assign S_AXI_WREADY	= axi_wready;
   assign S_AXI_BRESP	= axi_bresp;
   assign S_AXI_BVALID	= axi_bvalid;
   assign S_AXI_ARREADY	= axi_arready;
   assign S_AXI_RDATA	= axi_rdata;
   assign S_AXI_RRESP	= axi_rresp;
   assign S_AXI_RVALID	= axi_rvalid;
   // Implement axi_awready generation
   // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
   // de-asserted when reset is low.

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_awready <= 1'b0;
	 aw_en <= 1'b1;
      end else begin    
	 if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
	    // slave is ready to accept write address when 
	    // there is a valid write address and write data
	    // on the write address and data bus. This design 
	    // expects no outstanding transactions. 
	    axi_awready <= 1'b1;
	    aw_en <= 1'b0;
	 end
	 else if (S_AXI_BREADY && axi_bvalid) begin
	    aw_en <= 1'b1;
	    axi_awready <= 1'b0;
	 end else begin
	    axi_awready <= 1'b0;
	 end
      end 
   end       

   // Implement axi_awaddr latching
   // This process is used to latch the address when both 
   // S_AXI_AWVALID and S_AXI_WVALID are valid. 

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_awaddr <= 0;
      end else begin    
	 if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
	    // Write Address latching 
	    axi_awaddr <= S_AXI_AWADDR;
	 end
      end 
   end       

   // Implement axi_wready generation
   // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
   // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
   // de-asserted when reset is low. 

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_wready <= 1'b0;
      end else begin    
	 if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en ) begin
	    // slave is ready to accept write data when 
	    // there is a valid write address and write data
	    // on the write address and data bus. This design 
	    // expects no outstanding transactions. 
	    axi_wready <= 1'b1;
	 end else begin
	    axi_wready <= 1'b0;
	 end
      end 
   end       

   // Implement memory mapped register select and write logic generation
   // The write data is accepted and written to memory mapped registers when
   // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
   // select byte enables of slave registers while writing.
   // These registers are cleared when reset (active low) is applied.
   // Slave register write enable is asserted when valid address and data are available
   // and the slave is ready to accept the write address and write data.
   assign slv_reg_wen = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

   reg [31:0] grad_bram [2**OPT_MEM_ADDR_BITS-1:0]; // main BRAM; 8192 locations by default
   reg [31:0] grad_bram_wdata = 0, grad_bram_wdata_r = 0; // pipelining
   reg 	      grad_bram_wen = 0, grad_bram_wen_r = 0, grad_bram_rd = 0, grad_bram_rd_r1 = 0, grad_bram_rd_r2 = 0; // pipelining
   reg [OPT_MEM_ADDR_BITS-1:0] grad_bram_waddr = 0, grad_bram_waddr_r = 0, grad_bram_raddr = 0, grad_bram_raddr_r = 0; // pipelining
   reg [31:0] 		       grad_bram_rdata = 0, grad_bram_rdata_r = 0, grad_bram_rdata_r2 = 0;
   wire [OPT_MEM_ADDR_BITS:0] axi_addr = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB];
   
   /**** Grad mem and general register write logic ****/
   always @(posedge S_AXI_ACLK) begin

      // defaults and pipelining
      grad_bram_wen <= 0;
      if (grad_bram_wen) grad_bram[grad_bram_waddr] <= grad_bram_wdata;
   
      if (slv_reg_wen) begin
	 if (axi_addr[OPT_MEM_ADDR_BITS]) begin // upper range: write to BRAM
	    grad_bram_wen <= 1;
	    grad_bram_waddr <= axi_addr[OPT_MEM_ADDR_BITS-1:0]; // BRAM has 13-bit address space by default
	    grad_bram_wdata <= S_AXI_WDATA;
	 end else begin // lower range: write to config register
	    case (axi_addr[2:0]) // TODO: look at more than lower 3 bits if this is ever expanded
	      // no resets
	      2'd0: slv_reg0 <= S_AXI_WDATA;
	      2'd1: slv_reg1 <= S_AXI_WDATA;
	      2'd2: slv_reg2 <= S_AXI_WDATA;
	      2'd3: slv_reg3 <= S_AXI_WDATA;
	    endcase // case (axi_addr[1:0])
	 end
      end // if (slv_reg_wen)
   end // always @ (posedge S_AXI_ACLK)

   /**** Grad mem read logic ****/
   /* Behaviour: send data every interval (whose minimum value depends
    on the serialiser clock) to the serialiser cores, IF the reset
    is inactive, AND the cores are not busy.
    
    If the cores are busy, wait until they leave the busy state, then
    resume sending data - as long as data is still sent once per
    interval, there is no error. If data cannot be sent for an entire
    interval, flag an error. For a 400.2 ksps interval with a 122.88
    MHz clock, the divisor 307, so data_interval_max = 303. For a
    400.6 ksps interval with a 125 MHz clock, the divisor is 312, so
    data_interval_max = 308 (i.e. n - 4 in both cases, due to
    four cycles of delay in HDL logic).
    */

   wire [9:0] data_interval_max = slv_reg0[9:0];
   reg [9:0]  data_interval_cnt = 0;
   wire       data_interval_done = data_interval_cnt > data_interval_max;
   reg 	      data_interval_done_r = 0, data_interval_done_r2 = 0, data_interval_done_p = 0;
   reg [15:0] data_wait_cnt = 0, data_wait_max = 0; // longer waits, in units of data interval
   wire       data_wait_done = data_wait_cnt == data_wait_max;
   reg 	      data_wait_done_r = 0;
   wire       data_int_and_wait_done = data_wait_done_r && data_interval_done_p;
   reg 	      busy_error = 0;

   localparam IDLE = 0, READ = 1, BUSY = 2;
   reg [1:0]  state = IDLE;
   
   always @(posedge S_AXI_ACLK) begin
      // pipelining
      {grad_bram_rd_r2, grad_bram_rd_r1} <= {grad_bram_rd_r1, grad_bram_rd};
      grad_bram_raddr_r <= grad_bram_raddr;
      // pipelining, to avoid busy-vs-done logic issues
      {data_interval_done_r2, data_interval_done_r} <= {data_interval_done_r, data_interval_done};
      data_interval_done_p <= !data_interval_done_r2 && data_interval_done_r; // capture posedges, to ensure it's high for only 1 cycle
      data_wait_done_r <= data_wait_done;
      
      // BRAM read address and delay counter logic
      if (!data_enb_i) begin
	 grad_bram_raddr <= offset_i[OPT_MEM_ADDR_BITS-2:0];
	 // didn't use data_interval_cnt <= 0 so that grad_bram_rd will be set on the first cycle after data_enb_i
	 data_interval_cnt <= data_interval_max;
	 data_wait_cnt <= 0;
      end else begin
	 // data interval counter logic
	 if (data_interval_done_p) data_interval_cnt <= 0;
	 else data_interval_cnt <= data_interval_cnt + 1;

	 // data wait counter logic (recall the last statement takes priority in Verilog
	 if (data_interval_done_p) data_wait_cnt <= data_wait_cnt + 1;
	 if (data_wait_done_r) data_wait_cnt <= 0;
      end

      // data output logic
      state <= IDLE; // default state      
      grad_bram_rd <= 0; // default
      valid_o <= 0; // default
      // always read from BRAM
      grad_bram_rdata <= grad_bram[grad_bram_raddr_r]; // pipelined rdaddr; probably unnecessary
      grad_bram_rdata_r <= grad_bram_rdata;
      case (state)
	READ: begin
	   if (serial_busy_i) begin // make sure busy ends before next cycle is meant to begin
	      state <= BUSY;
	   end else begin // output data immediately
	      valid_o <= 1;
	      state <= IDLE;
	   end
	end
	BUSY: begin // remain in this state unless the busy condition ends or the window to send data is over
	   if (!serial_busy_i) begin
	      valid_o <= 1;
	      state <= IDLE;
	   end else if (data_interval_done_r) begin
	      // check occurs two clock cycles before usual data output, to avoid possible race condition
	      // save the error condition; missed output word
	      busy_error <= 1;
	      state <= IDLE;
	   end else state <= BUSY;
	end
	default: begin // IDLE state
	   if (data_interval_done_p) begin
	      state <= READ;
	      data_o <= grad_bram_rdata_r;
	      data_wait_max <= {13'd0, grad_bram_rdata_r[29:27]}; // TODO: implement longer delays using grad_bram_data_r[30]
	      grad_bram_raddr <= grad_bram_raddr + 1; // next address
	   end
	   if (!S_AXI_ARESETN) busy_error <= 0; // clear busy errors if core is reset
	end
      endcase // case (state)
     
      // Slave register 4 will contain monitoring info; just the busy error for now
      slv_reg4 <= {31'd0, busy_error};
   end
   
   // VN: below is left in for reference, but won't be used in its current form
   // always @( posedge S_AXI_ACLK ) begin
   //    if ( S_AXI_ARESETN == 1'b0 ) begin
   // 	 slv_reg0 <= 0;
   // 	 slv_reg1 <= 0;
   // 	 slv_reg2 <= 0;
   // 	 slv_reg3 <= 0;
   // 	 slv_reg4 <= 0;
   // 	 slv_reg5 <= 0;
   // 	 slv_reg6 <= 0;
   // 	 slv_reg7 <= 0;
   //    end else begin
   // 	 if (slv_reg_wen) begin
   // 	    case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
   // 	      3'h0:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 0
   // 	             slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h1:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 1
   // 	             slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h2:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 2
   // 	             slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h3:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 3
   // 	             slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h4:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 4
   // 	             slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h5:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 5
   // 	             slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h6:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 6
   // 	             slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end  
   // 	      3'h7:
   // 	        for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
   // 	          if ( S_AXI_WSTRB[byte_index] == 1 ) begin
   // 	             // Respective byte enables are asserted as per write strobes 
   // 	             // Slave register 7
   // 	             slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
   // 	          end
   // 	      default : begin
   // 	         slv_reg0 <= slv_reg0;
   // 	         slv_reg1 <= slv_reg1;
   // 	         slv_reg2 <= slv_reg2;
   // 	         slv_reg3 <= slv_reg3;
   // 	         slv_reg4 <= slv_reg4;
   // 	         slv_reg5 <= slv_reg5;
   // 	         slv_reg6 <= slv_reg6;
   // 	         slv_reg7 <= slv_reg7;
   // 	      end
   // 	    endcase
   // 	 end
   //    end
   // end

   // Implement write response logic generation
   // The write response and response valid signals are asserted by the slave 
   // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
   // This marks the acceptance of address and indicates the status of 
   // write transaction.

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_bvalid  <= 0;
	 axi_bresp   <= 2'b0;
      end else begin    
	 if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin
	    // indicates a valid write response is available
	    axi_bvalid <= 1'b1;
	    axi_bresp  <= 2'b0; // 'OKAY' response 
	 end else begin                  // work error responses in future
	    if (S_AXI_BREADY && axi_bvalid) begin
	       //check if bready is asserted while bvalid is high) 
	       //(there is a possibility that bready is always asserted high)   
	       axi_bvalid <= 1'b0; 
	    end  
	 end
      end
   end   

   // Implement axi_arready generation
   // axi_arready is asserted for one S_AXI_ACLK clock cycle when
   // S_AXI_ARVALID is asserted. axi_awready is 
   // de-asserted when reset (active low) is asserted. 
   // The read address is also latched when S_AXI_ARVALID is 
   // asserted. axi_araddr is reset to zero on reset assertion.

   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_arready <= 1'b0;
	 axi_araddr  <= 32'b0;
      end else begin    
	 if (~axi_arready && S_AXI_ARVALID) begin
	    // indicates that the slave has acceped the valid read address
	    axi_arready <= 1'b1;
	    // Read address latching
	    axi_araddr  <= S_AXI_ARADDR;
	 end else begin
	    axi_arready <= 1'b0;
	 end
      end 
   end       

   // Implement axi_arvalid generation
   // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
   // S_AXI_ARVALID and axi_arready are asserted. The slave registers 
   // data are available on the axi_rdata bus at this instance. The 
   // assertion of axi_rvalid marks the validity of read data on the 
   // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
   // is deasserted on reset (active low). axi_rresp and axi_rdata are 
   // cleared to zero on reset (active low).  
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) begin
	 axi_rvalid <= 0;
	 axi_rresp  <= 0;
      end else begin    
	 if (axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin
	    // Valid read data is available at the read data bus
	    axi_rvalid <= 1'b1;
	    axi_rresp  <= 2'b0; // 'OKAY' response
	 end   
	 else if (axi_rvalid && S_AXI_RREADY)
	   begin
	      // Read data is accepted by the master
	      axi_rvalid <= 1'b0;
	   end                
      end
   end    

   // Implement memory mapped register select and read logic generation
   // Slave register read enable is asserted when valid address is available
   // and the slave is ready to accept the read address.
   assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
   always @(*) begin
      // Address decoding for reading registers
      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	3'h0   : reg_data_out <= slv_reg0;
	3'h1   : reg_data_out <= slv_reg1;
	3'h2   : reg_data_out <= slv_reg2;
	3'h3   : reg_data_out <= slv_reg3;
	3'h4   : reg_data_out <= slv_reg4;
	3'h5   : reg_data_out <= slv_reg5;
	3'h6   : reg_data_out <= slv_reg6;
	3'h7   : reg_data_out <= slv_reg7;
	default : reg_data_out <= 0;
      endcase
   end

   // Output register or memory read data
   always @( posedge S_AXI_ACLK ) begin
      if ( S_AXI_ARESETN == 1'b0 ) axi_rdata  <= 0;
      else begin    
	 // When there is a valid read address (S_AXI_ARVALID) with 
	 // acceptance of read address by the slave (axi_arready), 
	 // output the read dada 
	 if (slv_reg_rden) axi_rdata <= reg_data_out;     // register read data
      end
   end    

   // Add user logic here

   // User logic ends

endmodule
`endif //  `ifndef _GRAD_BRAM_
