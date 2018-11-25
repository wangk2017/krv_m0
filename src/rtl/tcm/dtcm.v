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
// File Name: 		dtcm.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		tightly coupled memory for data		||
// History:   							||
//===============================================================
`include "top_defines.vh"
`include "core_defines.vh"
module dtcm (
	//global signals
	input clk,						//clock
	input rstn,						//reset, active low

	//with core data interface
	input data_dtcm_access,					//access signal
	output wire data_dtcm_ready,				//DTCM is ready to data IF
	input data_dtcm_rd0_wr1,				//access cmd, rd=0;wr=1
	input wire [3:0] data_dtcm_byte_strobe,			//write strobe
	input [`ADDR_WIDTH - 1 : 0] data_dtcm_addr,		//access address
	input wire [`DATA_WIDTH - 1 : 0] data_dtcm_wdata,	//write data
	output wire [`DATA_WIDTH - 1 : 0] data_dtcm_rdata,	//read data
	output reg data_dtcm_rdata_valid,			//read data valid

	//with core instruction interface
	input instr_dtcm_access,				//access signal
	input [`ADDR_WIDTH - 1 : 0] instr_dtcm_addr,		//address
	output wire [`DATA_WIDTH - 1 : 0] instr_dtcm_rdata,	//read data
	output reg instr_dtcm_rdata_valid,			//read data valid

	//with DMA
	input dma_dtcm_access,					//access signal	
	output wire dma_dtcm_ready,				//DTCM ready to DMA
	input dma_dtcm_rd0_wr1,					//access cmd, rd=0; wr=1
	input [`ADDR_WIDTH - 1 : 0] dma_dtcm_addr,		//access address
	input wire [`DATA_WIDTH - 1 : 0] dma_dtcm_wdata,	//write data
	output wire [`DATA_WIDTH - 1 : 0] dma_dtcm_rdata,	//read data
	output reg dma_dtcm_rdata_valid			//read data valid

);


//----------------------------------------------------------------//
//DTCM access operation
//----------------------------------------------------------------//
	wire dtcm_access;			
	wire dtcm_rd0_wr1;		
	wire dtcm_wen;
	wire [`ADDR_WIDTH - 1 : 0] dtcm_addr;	
	wire [`DATA_WIDTH - 1 : 0] dtcm_wdata;	

	assign dtcm_access = data_dtcm_access || dma_dtcm_access;
	assign dtcm_rd0_wr1 = data_dtcm_rd0_wr1 || dma_dtcm_rd0_wr1;
	assign dtcm_wen = dtcm_access & dtcm_rd0_wr1;
	assign dtcm_addr = dma_dtcm_access? dma_dtcm_addr : (data_dtcm_access? data_dtcm_addr : instr_dtcm_addr);
	assign dtcm_wdata = dma_dtcm_access? dma_dtcm_wdata : data_dtcm_wdata;

	assign data_dtcm_ready = (!(dma_dtcm_access && dma_dtcm_rd0_wr1)) || (!data_dtcm_rd0_wr1 && (!(dma_dtcm_access && dma_dtcm_rd0_wr1 && (dma_dtcm_addr == data_dtcm_addr)))) ;
	assign dma_dtcm_ready = dma_dtcm_access;

wire[14 : 2] dtcm_word_addr = dtcm_addr[14 : 2];
`ifndef SIM
wire [`DATA_WIDTH - 1 : 0] dtcm_rdata;
sram_4Kx32 dtcm (
    .CLK	(clk),
    .RADDR	(dtcm_word_addr),
    .WADDR	(dtcm_word_addr),
    .WD		(dtcm_wdata),
    .WEN	(dtcm_wen),
    .RD		(dtcm_rdata)
);
`else
reg [`DATA_WIDTH - 1 : 0] dtcm [`DTCM_SIZE - 1 : 0];
always @ (posedge clk or negedge rstn)
begin
	if(dtcm_wen)
	begin
		if(data_dtcm_byte_strobe[3])
			dtcm[dtcm_word_addr][31:24] <= dtcm_wdata[31:24];
		if(data_dtcm_byte_strobe[2])
			dtcm[dtcm_word_addr][23:16] <= dtcm_wdata[23:16];
		if(data_dtcm_byte_strobe[1])
			dtcm[dtcm_word_addr][15:8]  <= dtcm_wdata[15:8];
		if(data_dtcm_byte_strobe[0])
			dtcm[dtcm_word_addr][7:0]   <= dtcm_wdata[7:0];
	end

end

reg [`DATA_WIDTH - 1 : 0] dtcm_rdata;
always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		dtcm_rdata <= 32'h0;
	end
	else
	begin
		dtcm_rdata <= dtcm[dtcm_word_addr];
	end
end
`endif

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		data_dtcm_rdata_valid <= 1'b0;
	end
	else
	begin
		data_dtcm_rdata_valid <= data_dtcm_access & (!data_dtcm_rd0_wr1);
	end
end

always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		instr_dtcm_rdata_valid <= 1'b0;
	end
	else
	begin
		instr_dtcm_rdata_valid <= instr_dtcm_access && !data_dtcm_access;
	end
end


always @ (posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		dma_dtcm_rdata_valid <= 1'b0;
	end
	else
	begin
		dma_dtcm_rdata_valid <= dma_dtcm_access & (!dma_dtcm_rd0_wr1);
	end
end



assign data_dtcm_rdata = dtcm_rdata;

assign instr_dtcm_rdata = dtcm_rdata;

assign dma_dtcm_rdata = dtcm_rdata;


endmodule
