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
// File Name: 		itcm.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		tightly coupled memory for instruction  || 
// History:   							||
//===============================================================

`include "top_defines.vh"
`include "core_defines.vh"

module itcm (

//global signals
	input clk,						//clock
	input rstn,						//reset,active low

//read request from instruction IF
	input [`ADDR_WIDTH - 1 : 0] instr_itcm_addr,		//address
	input instr_itcm_access,				//valid access 
	output reg [`DATA_WIDTH - 1 : 0] instr_itcm_read_data,	//read data
	output reg instr_itcm_read_data_valid,			//read data valid

//read/write request from data IF
	output wire data_itcm_ready,				//indication of itcm ready for data IF
	input data_itcm_access,					//valid access
	input data_itcm_rd0_wr1,				//access cmd, wr=1; rd=0;
	input [`ADDR_WIDTH - 1 : 0] data_itcm_addr,		//address
	input wire [3:0] data_itcm_byte_strobe,			//write strobe
	input wire [`DATA_WIDTH - 1 : 0] data_itcm_write_data,	//write data
	output reg [`DATA_WIDTH - 1 : 0] data_itcm_read_data,	//read data
	output reg data_itcm_read_data_valid,			//read data valid

//for auto-load
	input wire IAHB_ready,					//IAHB is ready
	input wire [`DATA_WIDTH - 1 : 0] IAHB_read_data,	//IAHB read data
	input wire IAHB_read_data_valid,			//IAHB read data valid
	output reg itcm_auto_load,				//ITCM is in the process of auto load
	output reg[`ADDR_WIDTH - 1 : 0 ] itcm_auto_load_addr	//ITCM auto load address

);


//------------------------------------------------------------------------------//
//1: ITCM auto-load
//------------------------------------------------------------------------------//

wire [`ADDR_WIDTH - 1 : 0] itcm_size = `ITCM_SIZE;
wire itcm_size_nz = (itcm_size!=0);

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		itcm_auto_load <= itcm_size_nz;
	end
	else
	begin
		if(itcm_size_nz)
		begin
			if(itcm_auto_load_addr == `ITCM_START_ADDR + `ITCM_SIZE - 4)
			begin
				itcm_auto_load <= 1'b0;
			end
			else
			begin
				itcm_auto_load <= 1'b1;
			end
		end
		else //itcm_size = 0
		begin
			itcm_auto_load <= 1'b0;
		end
	end
end

reg itcm_auto_load_d1;
always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		itcm_auto_load_d1 <= 1'b0;
	end
	else
	begin
		itcm_auto_load_d1 <= itcm_auto_load;
	end

end



reg addr_s;
always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		addr_s <= 1'b0;
	end
	else
	begin
		if(~itcm_auto_load)
		begin
			addr_s <= 1'b0;
		end
		if(IAHB_ready)
		begin
			addr_s <= 1'b1;
		end
		else
		begin
			addr_s <= addr_s;
		end
	end
end

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		itcm_auto_load_addr <= `ITCM_START_ADDR;
	end
	else
	begin
		if(itcm_auto_load_addr ==`ITCM_START_ADDR + `ITCM_SIZE - 4)
		begin
			itcm_auto_load_addr <=`ITCM_START_ADDR + `ITCM_SIZE - 4; 
		end
		else if(addr_s)
		begin
			if(IAHB_ready)
			begin
				itcm_auto_load_addr <= itcm_auto_load_addr + 32'h4;
			end
			else
			begin
				itcm_auto_load_addr <= itcm_auto_load_addr;
			end
		end
	end
end

wire itcm_write_en;
wire[`ADDR_WIDTH - 1 : 0 ] itcm_write_addr;
wire[`ADDR_WIDTH - 1 : 0 ] itcm_write_addr_from_0;
wire [3:0] itcm_byte_strobe;
wire [`DATA_WIDTH - 1 : 0] itcm_write_data;

wire auto_load_wr = (IAHB_read_data_valid && (itcm_auto_load  || itcm_auto_load_d1));
wire [3:0] auto_load_byte_strobe = 4'hf;

reg[`ADDR_WIDTH - 1 : 0 ] itcm_auto_write_addr;

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		itcm_auto_write_addr <= `ITCM_START_ADDR;
	end
	else
	begin
		if(~itcm_auto_load)
		begin
			itcm_auto_write_addr <= `ITCM_START_ADDR;
		end
		else 
		begin
			if(IAHB_read_data_valid)
			begin
				itcm_auto_write_addr <= itcm_auto_write_addr + 32'h4;
			end
			else
			begin
				itcm_auto_write_addr <= itcm_auto_write_addr;
			end
		end
	end
end

//------------------------------------------------------------------------------//
//ITCM read/write operation
//------------------------------------------------------------------------------//
assign itcm_write_en = auto_load_wr || (data_itcm_access && data_itcm_rd0_wr1);
assign itcm_write_data = auto_load_wr? IAHB_read_data : data_itcm_write_data;
assign itcm_write_addr = auto_load_wr? itcm_auto_write_addr : data_itcm_addr;
assign itcm_write_addr_from_0 = itcm_write_addr - `ITCM_START_ADDR;
assign itcm_byte_strobe = auto_load_wr? auto_load_byte_strobe : data_itcm_byte_strobe;


wire [14 : 2 ] itcm_word_addr_wr = itcm_write_addr_from_0[14 : 2 ];
wire [`ADDR_WIDTH - 1 : 0 ] itcm_addr_rd = data_itcm_access ? data_itcm_addr : instr_itcm_addr;
wire [`ADDR_WIDTH - 1 : 0 ] itcm_addr_rd_from_0 = itcm_addr_rd - `ITCM_START_ADDR;
wire [14 : 2 ] itcm_word_addr_rd = itcm_addr_rd_from_0[14 : 2 ];
`ifndef SIM
wire [`DATA_WIDTH - 1 : 0] itcm_read_data;
sram_4Kx32 itcm (
    .CLK	(clk),
    .RADDR	(itcm_word_addr_rd),
    .WADDR	(itcm_word_addr_wr),
    .WD		(itcm_write_data),
    .WEN	(itcm_write_en),
    .RD		(itcm_read_data)
);
`else
reg [`DATA_WIDTH - 1 : 0] itcm [`ITCM_SIZE - 1:0];
always @ (posedge clk)
begin
	if (itcm_write_en)
	begin
		if(itcm_byte_strobe[3])
		itcm[itcm_word_addr_wr][31:24] <= itcm_write_data[31:24];
		if(itcm_byte_strobe[2])
		itcm[itcm_word_addr_wr][23:16] <= itcm_write_data[23:16];
		if(itcm_byte_strobe[1])
		itcm[itcm_word_addr_wr][15:8] <= itcm_write_data[15:8];
		if(itcm_byte_strobe[0])
		itcm[itcm_word_addr_wr][7:0] <= itcm_write_data[7:0];
	end
end

reg [`DATA_WIDTH - 1 : 0] itcm_read_data;

reg itcm_read_data_valid;

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		itcm_read_data <= 32'h0;
	end
	else
	begin
		itcm_read_data <= itcm[itcm_word_addr_rd];
	end

end
`endif

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		instr_itcm_read_data_valid <= 1'b0;	
	end
	else 
	begin
		instr_itcm_read_data_valid <= instr_itcm_access && (~data_itcm_access) && (~itcm_auto_load);
	end
end

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		data_itcm_read_data_valid <= 1'b0;	
	end
	else 
	begin
		data_itcm_read_data_valid <= data_itcm_access && (~data_itcm_rd0_wr1) && (~itcm_auto_load);
	end
end


always @ *
begin
		instr_itcm_read_data = itcm_read_data;
end

always @ *
begin
		data_itcm_read_data = itcm_read_data;
end


assign data_itcm_ready = ~itcm_auto_load;

endmodule
