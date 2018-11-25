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
// File Name: 		IAHB.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		instruction AHB IF                	|| 
// History:   							||
//                      2017/10/25 				||
//                      First version				||
//===============================================================
`define WRITE_BUFFER

`include "top_defines.vh"
`include "core_defines.vh"
`include "ahb_defines.vh"
module IAHB (
//AHB MASTER IF
	input wire HCLK,
	input wire HRESETn,
	output wire HBUSREQ,
	output wire HLOCK,
	input wire HGRANT,
	input wire HREADY,
	input wire [1:0] HRESP,
	input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA,
	output wire [1:0] HTRANS,
	output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR,
	output wire HWRITE,
//with core IF
	input wire itcm_auto_load,
	input wire[`ADDR_WIDTH - 1 : 0 ] itcm_auto_load_addr,
	input wire IAHB_access,		//External memory and I/O access
	input wire [`ADDR_WIDTH - 1 : 0] IAHB_addr,
	output wire IAHB_ready,
	output wire [`DATA_WIDTH - 1 : 0] IAHB_read_data,
	output wire IAHB_read_data_valid
);

parameter WAIT_FOR_GRANT_S 	= 2'b00;
parameter ADDR_S		= 2'b01;
parameter DATA_S		= 2'b10;

parameter FIFO_DEPTH = 8;
parameter PTR_WIDTH = 3;

reg[1:0] state, next_state;

always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		state <= WAIT_FOR_GRANT_S;
	end
	else
	begin
		state <= next_state;
	end
end

always @ *
begin
	case(state)
		WAIT_FOR_GRANT_S: 
		begin
			if(HBUSREQ && HGRANT && HREADY)
			begin
				next_state = ADDR_S;
			end
			else
			begin
				next_state = WAIT_FOR_GRANT_S;
			end
		end
		ADDR_S:
		begin
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
			if(HREADY)
			begin
				if(itcm_auto_load)
				begin
					next_state = DATA_S;
				end
				else
				begin
					next_state = WAIT_FOR_GRANT_S;
				end
			end
			else
			begin
				next_state = DATA_S;
			end
		end
		default:
		begin
			next_state = WAIT_FOR_GRANT_S;
		end
	endcase
end




assign HBUSREQ 	 = (IAHB_access && !HLOCK) || itcm_auto_load;
assign HTRANS	 = itcm_auto_load? `NONSEQ : ((state == ADDR_S) ? `NONSEQ : `IDLE);
assign HADDR	 = itcm_auto_load? itcm_auto_load_addr : ((state == ADDR_S) ? IAHB_addr : 32'h0);
assign HWRITE	 = 1'b0;
assign HLOCK     = |state;


assign IAHB_ready = HGRANT && HREADY;
assign IAHB_read_data_valid = (state == DATA_S) && HREADY;
assign IAHB_read_data = HRDATA;




endmodule
