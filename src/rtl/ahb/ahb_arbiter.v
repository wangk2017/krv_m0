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
// File Name: 		ahb_arbiter.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		AHB bus arbiter                   	|| 
// History:   							||
//                      2017/10/30 				||
//                      First version				||
//===============================================================

`include "ahb_defines.vh"
module ahb_arbiter (
input wire HCLK,
input wire HRESETn,


//Master0 
input wire HBUSREQ_M0,
input wire HLOCK_M0,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_M0,
input wire [1:0] HTRANS_M0,
input wire HWRITE_M0,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_M0,
output reg HGRANT_M0,


//Master1
input wire HBUSREQ_M1,
input wire HLOCK_M1,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_M1,
input wire [1:0] HTRANS_M1,
input wire HWRITE_M1,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_M1,
output reg HGRANT_M1,

//Master2
input wire HBUSREQ_M2,
input wire HLOCK_M2,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_M2,
input wire [1:0] HTRANS_M2,
input wire HWRITE_M2,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_M2,
output reg HGRANT_M2,


//to all slave (HADDR_S also needed by bus decoder) 
output reg [`AHB_ADDR_WIDTH - 1 : 0] HADDR_S,
output reg [1:0] HTRANS_S,
output reg HWRITE_S,
output reg [`AHB_DATA_WIDTH - 1 : 0] HWDATA_S,

input wire HREADY_S

);

//Logic Start
//
//arbitration
//Priority : master0 > master1 > master2
wire[2:0] HMASTER_A;
reg[2:0] HMASTER_D;
wire [2:0] req;
reg idle;
assign req = {HBUSREQ_M2, HBUSREQ_M1, HBUSREQ_M0};
assign HMASTER_A = {HGRANT_M2,HGRANT_M1,HGRANT_M0};

always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		HMASTER_D <= 3'b001;
	end
	else
	begin
		HMASTER_D <= HMASTER_A;
	end
end

always @ *
begin
	case (HMASTER_A)
		3'b001: idle = (HTRANS_M0 == `IDLE);// && !HLOCK_M0;
		3'b010: idle = (HTRANS_M1 == `IDLE);// && !HLOCK_M1;
		3'b100: idle = (HTRANS_M2 == `IDLE);// && !HLOCK_M2;
		default: idle = 1'b1;
	endcase

end


always @ (posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		HGRANT_M0 <= 1'b0;
		HGRANT_M1 <= 1'b1;
		HGRANT_M2 <= 1'b0;
	end
	else
	begin
		if(idle && HREADY_S)
		begin
			casex(req)
			3'b?01: begin
				HGRANT_M0 <= 1'b1;	
				HGRANT_M1 <= 1'b0;
				HGRANT_M2 <= 1'b0;
			end
			
			3'b?1?: begin
				HGRANT_M0 <= 1'b0;
				HGRANT_M1 <= 1'b1;	
				HGRANT_M2 <= 1'b0;
			end
			3'b100: begin
				HGRANT_M0 <= 1'b0;
				HGRANT_M1 <= 1'b0;	
				HGRANT_M2 <= 1'b1;
			end
			default: begin
				HGRANT_M0 <= 1'b0;	
				HGRANT_M1 <= 1'b1;
				HGRANT_M2 <= 1'b0;
			end
			endcase
		end
		else
		begin
			HGRANT_M0 <= HGRANT_M0;
			HGRANT_M1 <= HGRANT_M1;
			HGRANT_M2 <= HGRANT_M2;
		end
	end
end


always @ *
begin
	case (HMASTER_A)
		3'b001: begin
				HADDR_S = HADDR_M0;
				HTRANS_S = HTRANS_M0;
				HWRITE_S = HWRITE_M0;
		end
		3'b010: begin
				HADDR_S = HADDR_M1;
				HTRANS_S = HTRANS_M1;
				HWRITE_S = HWRITE_M1;
		end
		3'b100: begin
				HADDR_S = HADDR_M2;
				HTRANS_S = HTRANS_M2;
				HWRITE_S = HWRITE_M2;
		end
		default: begin
				HADDR_S = HADDR_M0;
				HTRANS_S = HTRANS_M0;
				HWRITE_S = HWRITE_M0;
		end
	endcase
end

always @ *
begin
	case (HMASTER_D)
		3'b001: begin
				HWDATA_S = HWDATA_M0;
		end
		3'b010: begin
				HWDATA_S = HWDATA_M1;
		end
		3'b100: begin
				HWDATA_S = HWDATA_M2;
		end
		default: begin
				HWDATA_S = HWDATA_M0;
		end
	endcase
end

endmodule
