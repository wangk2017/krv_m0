/*
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
  Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.      
*/

//==============================================================||
// File Name: 		DAHB.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		data AHB interface                	|| 
// History:   							||
//                      2017/10/25 				||
//                      First version				||
//===============================================================
`define WRITE_BUFFER

`include "core_defines.vh"
`include "top_defines.vh"
`include "ahb_defines.vh"
module DAHB (
//AHB MASTER IF
	input wire HCLK,
	input wire HRESETn,
	input wire HGRANT,
	input wire HREADY,
	input wire [1:0] HRESP,
	input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA,
	output wire HBUSREQ,
	output wire HLOCK,
	output wire [1:0] HTRANS,
	output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR,
	output wire HWRITE,
	output wire [2:0] HSIZE,
	output wire [2:0] HBURST,
	output wire [3:0] HPROT,
	output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA,
//with core IF
	input wire cpu_clk,
	input wire cpu_resetn,
	input wire DAHB_access,		//External memory and I/O access
	input wire DAHB_rd0_wr1,			//read: 0 write:1
	input wire [`DATA_WIDTH - 1 : 0]  DAHB_write_data,
	input wire [`ADDR_WIDTH - 1 : 0] DAHB_addr,
	output wire DAHB_trans_buffer_full,
	output wire [`DATA_WIDTH - 1 : 0] DAHB_read_data,
	output wire DAHB_read_data_valid
);

parameter WAIT_FOR_GRANT_S 	= 2'b00;
parameter ADDR_S		= 2'b01;
parameter DATA_S		= 2'b10;

parameter FIFO_DEPTH = 8;
parameter PTR_WIDTH = 3;

reg[1:0] state, next_state;
wire hwrite_i;
reg hwrite_r;
reg hwrite;
wire load_bypass;

always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		state <= WAIT_FOR_GRANT_S;
		hwrite_r <= 1'b0;
	end
	else
	begin
		state <= next_state;
		hwrite_r <= hwrite;
	end
end

always @ *
begin
	case(state)
		WAIT_FOR_GRANT_S: 
		begin
			if(load_bypass && HGRANT && HREADY)
			begin
				next_state = DATA_S;
				hwrite = hwrite_i;
			end
			else if(HBUSREQ && HGRANT && HREADY)
			begin
				next_state = ADDR_S;
				hwrite = hwrite_i;
			end
			else
			begin
				next_state = WAIT_FOR_GRANT_S;
				hwrite = hwrite_r;
			end
		end
		ADDR_S:
		begin
			hwrite = hwrite_i;
			if(HREADY)
			begin
				next_state = DATA_S;
			end
			else
			begin
				next_state = ADDR_S;
			end
		end
		DATA_S:
		begin	
			hwrite = hwrite_r;
			if(HREADY)
			begin
				next_state = WAIT_FOR_GRANT_S;
			end
			else
			begin
				next_state = DATA_S;
			end
		end
		default:
		begin
			hwrite = hwrite_r;
			next_state = WAIT_FOR_GRANT_S;
		end
	endcase
end

//Transaction Buffer
//There is a depth =8 FIFO to store the transaction to hide bus delays
//you can also choose not to use a transaction buffer
//	|-----------------------------|
//	|HCLK vs cpu_clk | fifo_used  |
//	|-----------------------------|
//	|async           | async_fifo |
//	|-----------------------------|
//	|sync	         | sync_fifo  |
//	|-----------------------------|
wire DAHB_trans_buffer_wr_valid;
wire [`EMEM_BUFFER_WIDTH - 1 : 0] DAHB_trans_buffer_wr_data;
wire DAHB_trans_buffer_rd_ready;
wire DAHB_trans_buffer_rd_valid;
wire [`EMEM_BUFFER_WIDTH - 1 : 0] DAHB_trans_buffer_rd_data;

assign DAHB_trans_buffer_wr_valid = DAHB_access;
assign DAHB_trans_buffer_wr_data = {DAHB_rd0_wr1,DAHB_write_data,DAHB_addr};
//assign DAHB_trans_buffer_rd_ready = (state==ADDR_S) && HREADY;
assign DAHB_trans_buffer_rd_ready = (state==ADDR_S);

wire DAHB_trans_buffer_empty;
wire [`ADDR_WIDTH - 1 : 0] DAHB_trans_buffer_out_addr; 
wire [`DATA_WIDTH - 1 : 0] DAHB_trans_buffer_out_data; 
wire DAHB_trans_buffer_out_rd0_wr1;
assign DAHB_trans_buffer_out_addr = DAHB_trans_buffer_rd_valid ? DAHB_trans_buffer_rd_data[`ADDR_WIDTH - 1 : 0] : {`ADDR_WIDTH{1'b0}};
assign DAHB_trans_buffer_out_data = DAHB_trans_buffer_rd_valid ? DAHB_trans_buffer_rd_data[`EMEM_BUFFER_WIDTH - 2 : `ADDR_WIDTH] : {`DATA_WIDTH{1'b0}};
assign DAHB_trans_buffer_out_rd0_wr1 = DAHB_trans_buffer_rd_valid ? DAHB_trans_buffer_rd_data[`EMEM_BUFFER_WIDTH-1] : 1'b0;

`ifdef WRITE_BUFFER
// For the load instruction, if there is no incomplete transaction in the
// transaction buffer, the load can bypass the buffer and directly request for
// the bus
wire sync_trans_buffer_empty; 
wire sync_trans_buffer_wr_valid;
wire sync_trans_buffer_rd_valid;
wire [`EMEM_BUFFER_WIDTH - 1 : 0] sync_trans_buffer_rd_data;

assign load_bypass = DAHB_access && !DAHB_rd0_wr1 && sync_trans_buffer_empty && (state == WAIT_FOR_GRANT_S); 
assign sync_trans_buffer_wr_valid = DAHB_trans_buffer_wr_valid && !load_bypass;
assign DAHB_trans_buffer_rd_valid = sync_trans_buffer_rd_valid || (load_bypass && HGRANT /*&& HREADY*/);
assign DAHB_trans_buffer_rd_data = load_bypass ? DAHB_trans_buffer_wr_data : sync_trans_buffer_rd_data;
assign DAHB_trans_buffer_empty = sync_trans_buffer_empty && !(DAHB_access && load_bypass);
	
sync_fifo #(.DATA_WIDTH (`EMEM_BUFFER_WIDTH), .FIFO_DEPTH(FIFO_DEPTH),.PTR_WIDTH(PTR_WIDTH))  DAHB_trans_buffer(
//write side signals
.wr_clk		(cpu_clk),
.wr_rstn	(cpu_resetn),
.wr_valid	(sync_trans_buffer_wr_valid),
.wr_data	(DAHB_trans_buffer_wr_data),
//read side signals
.rd_clk		(HCLK),
.rd_rstn	(HRESETn),
.rd_ready	(DAHB_trans_buffer_rd_ready),
.rd_valid	(sync_trans_buffer_rd_valid),
.rd_data	(sync_trans_buffer_rd_data),
.full		(DAHB_trans_buffer_full),
.empty		(sync_trans_buffer_empty)
);


`endif

`ifdef NO_TRANS_BUFFER
assign DAHB_trans_buffer_empty = DAHB_access;
assign DAHB_trans_buffer_full = DAHB_access && (!(HGRANT&&HREADY));
assign DAHB_trans_buffer_rd_valid = DAHB_access && HGRANT; //&& HREADY;
assign DAHB_trans_buffer_rd_data = {DAHB_rd0_wr1,DAHB_write_data,DAHB_addr};
`endif

//Read Buffer
//an async fifo is used to deal with the clock domain crossing when HCLK and
//cpu_clk is asynchronous

wire [1:0] htrans_i;
wire [`AHB_ADDR_WIDTH - 1 : 0] haddr_i;
reg [`AHB_DATA_WIDTH - 1 : 0] hwdata_i;

wire fifo_empty;
assign fifo_empty = DAHB_trans_buffer_empty;

assign HBUSREQ 	 = (!fifo_empty) && !HLOCK;
assign HLOCK 	 = |state;
assign HTRANS	 = htrans_i;
assign HADDR	 = haddr_i;
assign HWRITE	 = hwrite_i;
assign HSIZE  	 = 3'b010;
assign HBURST	 = 3'b000;
assign HPROT 	 = 4'b1111;
assign HWDATA	 = hwdata_i;


assign haddr_i = DAHB_trans_buffer_out_addr;
assign htrans_i = DAHB_trans_buffer_rd_valid ? `NONSEQ : `IDLE;
assign hwrite_i = DAHB_trans_buffer_out_rd0_wr1; 



always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		hwdata_i <= {`AHB_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if(DAHB_trans_buffer_rd_valid)
		begin
			hwdata_i <= DAHB_trans_buffer_out_data;
		end
		else
		begin
			hwdata_i <= hwdata_i;
		end
	end
end

assign DAHB_read_data_valid = (state == DATA_S) && HREADY && !hwrite_r;
assign DAHB_read_data = HRDATA;




endmodule
