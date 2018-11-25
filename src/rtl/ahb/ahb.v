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
// File Name: 		ahb.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		AHB bus 		        	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

`include "ahb_defines.vh"
module ahb (
input wire HCLK,
input wire HRESETn,


//Master0 
input wire HBUSREQ_from_M0,
input wire HLOCK_from_M0,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_from_M0,
input wire [1:0] HTRANS_from_M0,
input wire HWRITE_from_M0,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_from_M0,
output wire HGRANT_to_M0,
output wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_to_M0,
output wire [1:0] HRESP_to_M0,
output wire HREADY_to_M0,


//Master1
input wire HBUSREQ_from_M1,
input wire HLOCK_from_M1,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_from_M1,
input wire [1:0] HTRANS_from_M1,
input wire HWRITE_from_M1,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_from_M1,
output wire HGRANT_to_M1,
output wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_to_M1,
output wire [1:0] HRESP_to_M1,
output wire HREADY_to_M1,

//Master2
input wire HBUSREQ_from_M2,
input wire HLOCK_from_M2,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_from_M2,
input wire [1:0] HTRANS_from_M2,
input wire HWRITE_from_M2,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_from_M2,
output wire HGRANT_to_M2,
output wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_to_M2,
output wire [1:0] HRESP_to_M2,
output wire HREADY_to_M2,

//Slave0
output wire HSEL_to_S0,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S0,
output wire [1:0] HTRANS_to_S0,
output wire HWRITE_to_S0,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S0,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S0,
input wire [1:0] HRESP_from_S0,
input wire HREADY_from_S0,


//Slave1
output wire HSEL_to_S1,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S1,
output wire [1:0] HTRANS_to_S1,
output wire HWRITE_to_S1,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S1,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S1,
input wire [1:0] HRESP_from_S1,
input wire HREADY_from_S1,

//Slave2
output wire HSEL_to_S2,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S2,
output wire [1:0] HTRANS_to_S2,
output wire HWRITE_to_S2,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S2,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S2,
input wire [1:0] HRESP_from_S2,
input wire HREADY_from_S2,

//Slave3
output wire HSEL_to_S3,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S3,
output wire [1:0] HTRANS_to_S3,
output wire HWRITE_to_S3,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S3,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S3,
input wire [1:0] HRESP_from_S3,
input wire HREADY_from_S3,

//Slave4
output wire HSEL_to_S4,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S4,
output wire [1:0] HTRANS_to_S4,
output wire HWRITE_to_S4,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S4,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S4,
input wire [1:0] HRESP_from_S4,
input wire HREADY_from_S4,

//Slave5
output wire HSEL_to_S5,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S5,
output wire [1:0] HTRANS_to_S5,
output wire HWRITE_to_S5,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S5,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S5,
input wire [1:0] HRESP_from_S5,
input wire HREADY_from_S5,

//Slave6
output wire HSEL_to_S6,
output wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_to_S6,
output wire [1:0] HTRANS_to_S6,
output wire HWRITE_to_S6,
output wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_to_S6,
input wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_from_S6,
input wire [1:0] HRESP_from_S6,
input wire HREADY_from_S6
);

wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_S;
wire [1:0] HTRANS_S;
wire HWRITE_S;
wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_S;

assign HADDR_to_S0 = HADDR_S;
assign HTRANS_to_S0 = HTRANS_S;
assign HWRITE_to_S0 = HWRITE_S;
assign HWDATA_to_S0 = HWDATA_S;

assign HADDR_to_S1 = HADDR_S;
assign HTRANS_to_S1 = HTRANS_S;
assign HWRITE_to_S1 = HWRITE_S;
assign HWDATA_to_S1 = HWDATA_S;

assign HADDR_to_S2 = HADDR_S;
assign HTRANS_to_S2 = HTRANS_S;
assign HWRITE_to_S2 = HWRITE_S;
assign HWDATA_to_S2 = HWDATA_S;

assign HADDR_to_S3 = HADDR_S;
assign HTRANS_to_S3 = HTRANS_S;
assign HWRITE_to_S3 = HWRITE_S;
assign HWDATA_to_S3 = HWDATA_S;

assign HADDR_to_S4 = HADDR_S;
assign HTRANS_to_S4 = HTRANS_S;
assign HWRITE_to_S4 = HWRITE_S;
assign HWDATA_to_S4 = HWDATA_S;

assign HADDR_to_S5 = HADDR_S;
assign HTRANS_to_S5 = HTRANS_S;
assign HWRITE_to_S5 = HWRITE_S;
assign HWDATA_to_S5 = HWDATA_S;

assign HADDR_to_S6 = HADDR_S;
assign HTRANS_to_S6 = HTRANS_S;
assign HWRITE_to_S6 = HWRITE_S;
assign HWDATA_to_S6 = HWDATA_S;

wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_S;
wire [1:0] HRESP_S;
wire HREADY_S;

assign HRDATA_to_M0 = HRDATA_S;
assign HRESP_to_M0 = HRESP_S;
assign HREADY_to_M0 = HREADY_S;

assign HRDATA_to_M1 = HRDATA_S;
assign HRESP_to_M1 = HRESP_S;
assign HREADY_to_M1 = HREADY_S;

assign HRDATA_to_M2 = HRDATA_S;
assign HRESP_to_M2 = HRESP_S;
assign HREADY_to_M2 = HREADY_S;

ahb_arbiter u_ahb_arbiter (
.HCLK			(HCLK),
.HRESETn		(HRESETn),


//Master0 
.HBUSREQ_M0		(HBUSREQ_from_M0),
.HLOCK_M0		(HLOCK_from_M0),
.HADDR_M0		(HADDR_from_M0),
.HTRANS_M0		(HTRANS_from_M0),
.HWRITE_M0		(HWRITE_from_M0),
.HWDATA_M0		(HWDATA_from_M0),
.HGRANT_M0		(HGRANT_to_M0),


//Master1
.HBUSREQ_M1		(HBUSREQ_from_M1),
.HLOCK_M1		(HLOCK_from_M1),
.HADDR_M1		(HADDR_from_M1),
.HTRANS_M1		(HTRANS_from_M1),
.HWRITE_M1		(HWRITE_from_M1),
.HWDATA_M1		(HWDATA_from_M1),
.HGRANT_M1		(HGRANT_to_M1),

//Master2
.HBUSREQ_M2		(HBUSREQ_from_M2),
.HLOCK_M2		(HLOCK_from_M2),
.HADDR_M2		(HADDR_from_M2),
.HTRANS_M2		(HTRANS_from_M2),
.HWRITE_M2		(HWRITE_from_M2),
.HWDATA_M2		(HWDATA_from_M2),
.HGRANT_M2		(HGRANT_to_M2),


//to all slave (HADDR_S also needed by bus decoder) 
.HADDR_S		(HADDR_S),
.HTRANS_S		(HTRANS_S),
.HWRITE_S		(HWRITE_S),
.HWDATA_S		(HWDATA_S),
.HREADY_S		(HREADY_S)
);


ahb_decoder u_ahb_decoder(
.HCLK			(HCLK),
.HRESETn		(HRESETn),
.HTRANS_M		(HTRANS_S),
.HADDR_M		(HADDR_S),
.HSEL_S0		(HSEL_to_S0),
.HSEL_S1		(HSEL_to_S1),
.HSEL_S2		(HSEL_to_S2),
.HSEL_S3		(HSEL_to_S3),
.HSEL_S4		(HSEL_to_S4),
.HSEL_S5		(HSEL_to_S5),
.HSEL_S6		(HSEL_to_S6),
.HRDATA_S0		(HRDATA_from_S0),
.HRDATA_S1		(HRDATA_from_S1),
.HRDATA_S2		(HRDATA_from_S2),
.HRDATA_S3		(HRDATA_from_S3),
.HRDATA_S4		(HRDATA_from_S4),
.HRDATA_S5		(HRDATA_from_S5),
.HRDATA_S6		(HRDATA_from_S6),
.HRESP_S0		(HRESP_from_S0),
.HRESP_S1		(HRESP_from_S1),
.HRESP_S2		(HRESP_from_S2),
.HRESP_S3		(HRESP_from_S3),
.HRESP_S4		(HRESP_from_S4),
.HRESP_S5		(HRESP_from_S5),
.HRESP_S6		(HRESP_from_S6),
.HREADY_S0		(HREADY_from_S0),
.HREADY_S1		(HREADY_from_S1),
.HREADY_S2		(HREADY_from_S2),
.HREADY_S3		(HREADY_from_S3),
.HREADY_S4		(HREADY_from_S4),
.HREADY_S5		(HREADY_from_S5),
.HREADY_S6		(HREADY_from_S6),
.HRDATA_S		(HRDATA_S),
.HRESP_S		(HRESP_S),
.HREADY_S		(HREADY_S)
);

endmodule
