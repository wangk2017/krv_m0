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
// File Name: 		ahb_decoder.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		AHB bus address decoder and RDATA MUX   || 
// History:   							||
//                      2017/10/30 				||
//                      First version				||
//===============================================================

`include "ahb_defines.vh"
module ahb_decoder (
input wire HCLK,
input wire HRESETn,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_M,
input wire [1:0] HTRANS_M,
output wire HSEL_S0,
output wire HSEL_S1,
output wire HSEL_S2,
output wire HSEL_S3,
output wire HSEL_S4,
output wire HSEL_S5,
output wire HSEL_S6,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S0,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S1,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S2,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S3,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S4,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S5,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S6,
input wire [1:0] HRESP_S0,
input wire [1:0] HRESP_S1,
input wire [1:0] HRESP_S2,
input wire [1:0] HRESP_S3,
input wire [1:0] HRESP_S4,
input wire [1:0] HRESP_S5,
input wire [1:0] HRESP_S6,
input wire HREADY_S0,
input wire HREADY_S1,
input wire HREADY_S2,
input wire HREADY_S3,
input wire HREADY_S4,
input wire HREADY_S5,
input wire HREADY_S6,
output reg [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S,
output reg [1:0] HRESP_S,
output reg HREADY_S
);


//Logic Start
/*
//---------------------------------------------------------------------//
Port-Name	Block Name		Description
M0		IAHB			Instruction AHB
M1		DAHB			Data AHB
M2		Reserved		For future use
S0		Reserved for FLASH	0x0000_0000 ~ 0x3FFF_FFFF
S1		KPLIC			0x4000_0000 ~ 0x43FF_FFFF
S2		MTIMER			0x4400_0000 ~ 0x4FFF_FFFF
S3		Reserved		0x5000_0000 ~ 0x6FFF_FFFF
S4		APB			0x7000_0000 ~ 0x7FFF_FFFF
S5		Reserved		0x8000_0000 ~ 0x9FFF_FFFF
S6		Reserved		0xA000_0000 ~ 0xFFFF_FFFF
//---------------------------------------------------------------------//
*/

wire trans;
wire[3:0] nibble_0;
wire[3:0] nibble_1;
wire[3:0] nibble_2;
wire[3:0] nibble_3;
wire[3:0] nibble_4;
wire[3:0] nibble_5;
wire[3:0] nibble_6;
wire[3:0] nibble_7;
assign nibble_0 = HADDR_M[3:0];
assign nibble_1 = HADDR_M[7:4];
assign nibble_2 = HADDR_M[11:8];
assign nibble_3 = HADDR_M[15:12];
assign nibble_4 = HADDR_M[19:16];
assign nibble_5 = HADDR_M[23:20];
assign nibble_6 = HADDR_M[27:24];
assign nibble_7 = HADDR_M[31:28];

assign trans = (HTRANS_M != `IDLE);

assign HSEL_S0 = trans && (
	(nibble_7 < 4'h4)
);	

assign HSEL_S1 = trans && (
	(nibble_7 == 4'h4) &&
	(nibble_6 < 4'h4)
);

assign HSEL_S2 = trans && (
	(nibble_7 == 4'h4) &&
	(nibble_6 >= 4'h4)
);

assign HSEL_S3 = trans && (
	(nibble_7 == 4'h5) || (nibble_7 == 4'h6)
);

assign HSEL_S4 = trans && (
	nibble_7 == 4'h7
);

assign HSEL_S5 = trans && (
	(nibble_7 == 4'h8) || (nibble_7 == 4'h9)
);
assign HSEL_S6 = trans && (
	(nibble_7 >= 4'ha)
);

//State control
parameter ADDR_S = 1'b0;
parameter DATA_S = 1'b1;

reg state, next_state;
wire [6:0] HSLAVE_A;
reg [6:0] HSLAVE_D;
reg [6:0] HSLAVE;
assign HSLAVE_A = {HSEL_S6, HSEL_S5, HSEL_S4, HSEL_S3, HSEL_S2, HSEL_S1, HSEL_S0};

always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		state <= ADDR_S;
	end
	else
	begin
		state <= next_state;
	end
end

always @ *
begin
	case (state)
		ADDR_S: begin
			if((|(HSLAVE_A)) && HREADY_S)
			begin
				next_state = DATA_S;
			end
			else
			begin
				next_state = ADDR_S;
			end
		end
		DATA_S: begin
			if(HREADY_S)
			begin
				next_state = ADDR_S;
			end
			else
			begin
				next_state = DATA_S;
			end
		end
	endcase
end

always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		HSLAVE_D <= 6'h0;
	end
	else
	begin
		if ((|(HSLAVE_A)) && HREADY_S)
		begin
			HSLAVE_D <= HSLAVE_A;
		end
		else
		begin
			HSLAVE_D <= HSLAVE_D;
		end
	end
end

always @ *
begin
	case (state)
		ADDR_S: begin
			HSLAVE = HSLAVE_A;
		end
		DATA_S: begin
			HSLAVE = HSLAVE_D;
		end
	endcase
end


always @ *
begin
	case (HSLAVE)
		7'b000_0001: begin
			HREADY_S = HREADY_S0;
			HRESP_S  = HRESP_S0;
			HRDATA_S = HRDATA_S0;
		end
		7'b000_0010: begin
			HREADY_S = HREADY_S1;
			HRESP_S  = HRESP_S1;
			HRDATA_S = HRDATA_S1;
		end
		7'b000_0100: begin
			HREADY_S = HREADY_S2;
			HRESP_S  = HRESP_S2;
			HRDATA_S = HRDATA_S2;
		end
		7'b000_1000: begin
			HREADY_S = HREADY_S3;
			HRESP_S  = HRESP_S3;
			HRDATA_S = HRDATA_S3;
		end
		7'b001_0000: begin
			HREADY_S = HREADY_S4;
			HRESP_S  = HRESP_S4;
			HRDATA_S = HRDATA_S4;
		end
		7'b010_0000: begin
			HREADY_S = HREADY_S5;
			HRESP_S  = HRESP_S5;
			HRDATA_S = HRDATA_S5;
		end
		7'b100_0000: begin
			HREADY_S = HREADY_S6;
			HRESP_S  = HRESP_S6;
			HRDATA_S = HRDATA_S6;
		end
		default:begin
			HREADY_S = 1'b1;
			HRESP_S  = `OKAY;
			HRDATA_S = {`AHB_DATA_WIDTH{1'b0}};
		end
	endcase
end

endmodule
