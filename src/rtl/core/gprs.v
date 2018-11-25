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
// File Name: 		gprs.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		general purpose register          	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================
`include "core_defines.vh"
module gprs (
//global signals
input cpu_clk,					//cpu clock
input cpu_rstn,					//cpu reset, active low

//1x write point
input wr_valid,					//write valid
input [`DATA_WIDTH - 1 : 0] wr_data, 		//write data
input [`RD_WIDTH - 1 : 0] rd_wb,		//rd in WB stage

//2x read point
input [`RS1_WIDTH - 1 : 0] rs1_dec,		//source 1 index in DEC stage
output [`DATA_WIDTH - 1 : 0] gprs_data1,	//source 1 data from gprs
input [`RS2_WIDTH - 1 : 0] rs2_dec,		//source 2 index in DEC stage
output [`DATA_WIDTH - 1 : 0] gprs_data2 	//source 2 data from gprs

);

//----------------------------------------//
//Register File
//----------------------------------------//
wire [`DATA_WIDTH - 1 : 0] gprs_X [31:0];
reg wr_en [31:1];

integer i;
always @ *
begin
	for(i=1; i<32; i=i+1)
	begin
		wr_en[i] = wr_valid && (i==rd_wb);
	end
end

genvar gprs_index;

generate 
	for (gprs_index = 0; gprs_index <32; gprs_index = gprs_index + 1)
	begin : GPRS_X
		if (gprs_index == 0)
		begin
		gpr0 u_gpr0 (
			     .rd_data 	(gprs_X[gprs_index])
		);
		end
		else
		begin
		gpr u_gpr (.clk		(cpu_clk),
			   .rstn	(cpu_rstn),
			   .wr_en 	(wr_en[gprs_index]),
			   .wr_data	(wr_data),
			   .rd_data	(gprs_X[gprs_index])
				);
		end
	end
endgenerate

assign gprs_data1 = gprs_X[rs1_dec];
assign gprs_data2 = gprs_X[rs2_dec];


endmodule


module gpr0 (
output wire [`DATA_WIDTH - 1 : 0] rd_data
);
assign rd_data = {`DATA_WIDTH {1'b0}};


endmodule

module gpr (
input clk,
input rstn,
input wr_en,
input [`DATA_WIDTH - 1 : 0]wr_data,
output reg [`DATA_WIDTH - 1 : 0] rd_data
);

always @ (posedge clk or negedge rstn)
begin
	if (!rstn)
	begin
		rd_data <= {`DATA_WIDTH {1'b0}};
	end
	else
	begin
		if (wr_en)
		begin
			rd_data <= wr_data;
		end
	end
end

endmodule

