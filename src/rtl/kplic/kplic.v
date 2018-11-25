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

//===============================================================||
// File Name: 		kplic.v					 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		KRV-m platform level interrupt controller||
// History:   							 ||
//===============================================================||

`include "ahb_defines.vh"
`include "kplic_defines.vh"

module kplic (

//global signals
input wire kplic_clk,				//KPLIC clock
input wire kplic_rstn,				//KPLIC reset, active low
input wire [`INT_NUM - 1 : 0] external_int,	//external interrupt sources
output wire kplic_int,				//interrupt notification to core

//AHB INTERFACE
input wire HCLK,
input wire HRESETn,
input wire HSEL,
input wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR,
input wire HWRITE,
input wire [1:0] HTRANS,
input wire [2:0] HBURST,
input wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA,
output wire HREADY,
output wire [1:0] HRESP,
output wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA
);

wire [`INT_NUM - 1 : 0] valid_int_req;
wire int_claim;
wire [`KPLIC_DATA_WIDTH - 1 : 0] target_priority;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group0;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group1;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group2;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group3;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group4;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group5;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group6;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group7;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_pending_status;
wire [`INT_WIDTH - 1 : 0] mppi;
wire valid_reg_access;
wire [`AHB_ADDR_WIDTH - 1 : 0] ip_addr;
wire kplic_reg_wr1_rd0;
wire [`KPLIC_DATA_WIDTH - 1 : 0] kplic_reg_write_data;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_type;
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_enable;
wire [`INT_NUM - 1  : 0] int_completion;
wire [`KPLIC_DATA_WIDTH - 1 : 0] kplic_reg_read_data;


ahb2regbus u_ahb2regbus(
	//AHB IF
	.HCLK			(kplic_clk),
	.HRESETn		(kplic_rstn),
	.HSEL			(HSEL),
	.HADDR			(HADDR),
	.HWRITE			(HWRITE),
	.HTRANS			(HTRANS),
	.HBURST			(HBURST),
	.HWDATA			(HWDATA),
	.HREADY			(HREADY),
	.HRESP			(HRESP),
	.HRDATA			(HRDATA),
	//IP reg bus
	.ip_read_data		(kplic_reg_read_data),
	.ip_write_data		(kplic_reg_write_data),
	.ip_addr		(ip_addr),
	.valid_reg_access	(valid_reg_access),
	.ip_wr1_rd0		(kplic_reg_wr1_rd0)
);

 kplic_regs u_kplic_regs(
.kplic_clk			(kplic_clk),
.kplic_rstn			(kplic_rstn),
.valid_reg_access		(valid_reg_access),
.addr				(ip_addr[11:0]),
.rd_wr				(kplic_reg_wr1_rd0),
.write_data			(kplic_reg_write_data),
.int_pending_status		(int_pending_status),
.mppi				(mppi),
.int_type			(int_type),
.int_enable			(int_enable),
.target_priority		(target_priority),
.int_priority_group0		(int_priority_group0),
.int_priority_group1		(int_priority_group1),
.int_priority_group2		(int_priority_group2),
.int_priority_group3		(int_priority_group3),
.int_priority_group4		(int_priority_group4),
.int_priority_group5		(int_priority_group5),
.int_priority_group6		(int_priority_group6),
.int_priority_group7		(int_priority_group7),
.int_claim			(int_claim),
.int_completion			(int_completion),
.read_data			(kplic_reg_read_data)
);

genvar int_index;

generate
	for (int_index = 0; int_index < `INT_NUM; int_index = int_index + 1)
	begin : INT_GATEWAYX
		kplic_gateway u_kplic_gateway (
			.kplic_clk		(kplic_clk),
			.kplic_rstn		(kplic_rstn),
			.external_int		(external_int[int_index]),
			.int_enable		(int_enable[int_index]),
			.int_type		(int_type[int_index]),
			.int_completion		(int_completion[int_index]),
			.valid_int_req(valid_int_req[int_index])
			);
	end
endgenerate


kplic_core u_kplic_core(
.kplic_clk			(kplic_clk),
.kplic_rstn			(kplic_rstn),
.valid_int_req			(valid_int_req),
.int_claim			(int_claim),
.target_priority		(target_priority),
.int_priority_group0		(int_priority_group0),
.int_priority_group1		(int_priority_group1),
.int_priority_group2		(int_priority_group2),
.int_priority_group3		(int_priority_group3),
.int_priority_group4		(int_priority_group4),
.int_priority_group5		(int_priority_group5),
.int_priority_group6		(int_priority_group6),
.int_priority_group7		(int_priority_group7),
.int_pending_status		(int_pending_status),
.mppi				(mppi),
.int_to_target			(kplic_int)
);



endmodule
