//===============================================================||
// File Name: 		core_timer.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		KRV-m core timer			 ||
// History:   							 ||
//===============================================================||

`include "ahb_defines.vh"
`include "core_defines.vh"

module core_timer (

//global signals
output wire core_timer_int,				//interrupt notification to core

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

wire valid_reg_access;
wire [`AHB_ADDR_WIDTH - 1 : 0] ip_addr;
wire core_timer_reg_wr1_rd0;
wire [`AHB_DATA_WIDTH - 1 : 0] core_timer_reg_write_data;
wire [`AHB_DATA_WIDTH - 1 : 0] core_timer_reg_read_data;


ahb2regbus #(.IP_REG_START_OFFSET (16'h4000), .IP_REG_END_OFFSET(16'hbffc), .IP_OFFSET_RANGE_R (16), .IP_OFFSET_RANGE_L(0)) u_ahb2regbus(
	//AHB IF
	.HCLK			(HCLK),
	.HRESETn		(HRESETn),
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
	.ip_read_data		(core_timer_reg_read_data),
	.ip_write_data		(core_timer_reg_write_data),
	.ip_addr		(ip_addr),
	.valid_reg_access	(valid_reg_access),
	.ip_wr1_rd0		(core_timer_reg_wr1_rd0)
);

 core_timer_regs u_core_timer_regs(
.HCLK			(HCLK),
.HRESETn		(HRESETn),
.valid_reg_access		(valid_reg_access),
.addr				(ip_addr[15:0]),
.rd_wr				(core_timer_reg_wr1_rd0),
.write_data			(core_timer_reg_write_data),
.read_data			(core_timer_reg_read_data),
.timer_int			(core_timer_int)
);


endmodule
