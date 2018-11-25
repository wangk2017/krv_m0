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
// File Name: 		krv_m.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		top of krv-m			     	|| 
// History:   							||
//                      2017/10/23 				||
//                      First version				||
//===============================================================

`include "top_defines.vh"
`include "core_defines.vh"
`include "kplic_defines.vh"
`include "ahb_defines.vh"

module krv_m (
`ifndef ASIC 
input  DEVRST_N,
`else
input  cpu_clk,
input  cpu_rstn,
input  HCLK,
input  HRESETn,
input  kplic_clk,
input  kplic_rstn,
`endif
input [7:0] GPIO_IN,
output [7:0] GPIO_OUT,
input UART_RX,
output UART_TX,
output LED1_red,
output LED1_green,
output LED2_red,
output LED2_green
//interface with DMA for dtcm access
`ifdef DMA_DTCM_ACCESS
,
input  dma_dtcm_access,			
output dma_dtcm_ready,
input  dma_dtcm_rd0_wr1,		
input  [`ADDR_WIDTH - 1 : 0] dma_dtcm_addr,	
input  [`DATA_WIDTH - 1 : 0] dma_dtcm_wdata,	
output [`DATA_WIDTH - 1 : 0] dma_dtcm_rdata,
output dma_dtcm_rdata_valid	
`endif

);

`ifndef ASIC 
wire cpu_clk;
wire cpu_rstn;
wire HCLK = cpu_clk;
wire HRESETn = cpu_rstn;
wire kplic_clk = cpu_clk;
wire kplic_rstn = cpu_rstn;
`endif
`ifndef DMA_DTCM_ACCESS
wire dma_dtcm_access = 1'b0;			
wire dma_dtcm_ready;
wire dma_dtcm_rd0_wr1 = 1'b0;
wire [`ADDR_WIDTH - 1 : 0] dma_dtcm_addr = 32'h0;
wire [`DATA_WIDTH - 1 : 0] dma_dtcm_wdata = 32'h0;
wire [`DATA_WIDTH - 1 : 0] dma_dtcm_rdata;
wire dma_dtcm_rdata_valid;	
`endif
	wire cpu_clk_g;
	wire kplic_int;
	wire core_timer_int;
	wire DAHB_HGRANT;
	wire DAHB_HREADY;
	wire [1:0] DAHB_HRESP;
	wire [`AHB_DATA_WIDTH - 1 : 0] DAHB_HRDATA;
	wire DAHB_HBUSREQ;
	wire DAHB_HLOCK;
	wire [1:0] DAHB_HTRANS;
	wire [`AHB_ADDR_WIDTH - 1 : 0] DAHB_HADDR;
	wire DAHB_HWRITE;
	wire [2:0] DAHB_HSIZE;
	wire [2:0] DAHB_HBURST;
	wire [3:0] DAHB_HPROT;
	wire [`AHB_DATA_WIDTH - 1 : 0] DAHB_HWDATA;
	wire DAHB_access;	
	wire DAHB_rd0_wr1;		
	wire [3:0] DAHB_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0] DAHB_write_data;
	wire [`ADDR_WIDTH - 1 : 0] DAHB_addr;
	wire DAHB_trans_buffer_full;
	wire [`DATA_WIDTH - 1 : 0] DAHB_read_data;
	wire DAHB_read_data_valid;

	wire instr_itcm_access;
	wire [`ADDR_WIDTH - 1 : 0] instr_itcm_addr;
	wire [`DATA_WIDTH - 1 : 0] instr_itcm_read_data;
	wire instr_itcm_read_data_valid;

	wire instr_dtcm_access;
	wire [`ADDR_WIDTH - 1 : 0] instr_dtcm_addr;
	wire [`DATA_WIDTH - 1 : 0] instr_dtcm_read_data;
	wire instr_dtcm_read_data_valid;

	wire IAHB_ready;
	wire itcm_auto_load;
	wire [`ADDR_WIDTH - 1 : 0 ] itcm_auto_load_addr;

	wire data_itcm_access;
	wire data_itcm_ready;
	wire data_itcm_rd0_wr1;	
	wire [3:0] data_itcm_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0] data_itcm_write_data;
	wire [`ADDR_WIDTH - 1 : 0] data_itcm_addr;
	wire [`DATA_WIDTH - 1 : 0] data_itcm_read_data;
	wire data_itcm_read_data_valid;
	  
	wire data_dtcm_access;
	wire data_dtcm_ready;
	wire data_dtcm_rd0_wr1;	
	wire [3:0] data_dtcm_byte_strobe;
	wire [`DATA_WIDTH - 1 : 0]  data_dtcm_write_data;
	wire [`ADDR_WIDTH - 1 : 0] data_dtcm_addr;
	wire [`DATA_WIDTH - 1 : 0] data_dtcm_read_data;
	wire data_dtcm_read_data_valid;
	  
	wire IAHB_HGRANT;
	wire IAHB_HBUSREQ;
	wire IAHB_HLOCK;
	wire IAHB_HREADY;
	wire [1:0] IAHB_HRESP;
	wire [`AHB_DATA_WIDTH - 1 : 0] IAHB_HRDATA;
	wire [1:0] IAHB_HTRANS;
	wire [`AHB_ADDR_WIDTH - 1 : 0] IAHB_HADDR;
	wire IAHB_HWRITE;
	wire IAHB_access;	
	wire [`ADDR_WIDTH - 1 : 0] IAHB_addr;
	wire [`DATA_WIDTH - 1 : 0] IAHB_read_data;
	wire IAHB_read_data_valid;

	 wire HSEL_kplic;
	 wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_kplic;
	 wire HWRITE_kplic;
	 wire [1:0] HTRANS_kplic;
	 wire [2:0] HBURST_kplic;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_kplic;
	 wire HREADY_kplic;
	 wire [1:0] HRESP_kplic;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_kplic;

	 wire HSEL_core_timer;
	 wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_core_timer;
	 wire HWRITE_core_timer;
	 wire [1:0] HTRANS_core_timer;
	 wire [2:0] HBURST_core_timer;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_core_timer;
	 wire HREADY_core_timer;
	 wire [1:0] HRESP_core_timer;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_core_timer;


	 wire HSEL_apb;
	 wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_apb;
	 wire HWRITE_apb;
	 wire [1:0] HTRANS_apb;
	 wire [2:0] HBURST_apb;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_apb;
	 wire HREADY_apb;
	 wire [1:0] HRESP_apb;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_apb;


	 wire HSEL_flash;
	 wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_flash;
	 wire HWRITE_flash;
	 wire [1:0] HTRANS_flash;
	 wire [2:0] HBURST_flash;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_flash;
	 wire HREADY_flash;
	 wire [1:0] HRESP_flash;
	 wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_flash;


	wire wfi;
	wire mother_sleep;
	wire daughter_sleep;
	wire isolation_on;
	wire pg_resetn;
	wire save;
	wire restore;

	wire timer_int;

	wire  [`INT_NUM - 1 : 0] external_int = {31'h0, timer_int};
	
//-----------------------------------------------------//
//-----------------------------------------------------//
`ifdef PG_CTRL
pg_ctrl u_pg_ctrl(
	.cpu_clk		(cpu_clk),
	.cpu_rstn		(cpu_rstn),
	.wfi			(wfi),
	.kplic_int		(kplic_int),
	.cpu_clk_g		(cpu_clk_g),
	.mother_sleep		(mother_sleep),
	.daughter_sleep		(daughter_sleep),
	.isolation_on		(isolation_on),
	.pg_resetn		(pg_resetn),
	.save			(save),
	.restore		(restore)
);
`else
assign cpu_clk_g = cpu_clk;
assign pg_resetn = 1'b1;
`endif
	
//-----------------------------------------------------//
//-----------------------------------------------------//
core u_core (
	.cpu_clk				(cpu_clk_g),
	.cpu_rstn				(cpu_rstn),
	.pg_resetn				(pg_resetn),
	.boot_addr				(`BOOT_ADDR),
	.kplic_int				(kplic_int),	
	.core_timer_int				(core_timer_int),	
	.wfi					(wfi),

	.instr_itcm_addr			(instr_itcm_addr),
	.instr_itcm_access			(instr_itcm_access),
	.instr_itcm_read_data			(instr_itcm_read_data),
	.instr_itcm_read_data_valid		(instr_itcm_read_data_valid),
	.itcm_auto_load				(itcm_auto_load),

	.data_itcm_rd0_wr1			(data_itcm_rd0_wr1),
	.data_itcm_byte_strobe			(data_itcm_byte_strobe),
	.data_itcm_access			(data_itcm_access),
	.data_itcm_ready			(data_itcm_ready),
	.data_itcm_addr				(data_itcm_addr),
	.data_itcm_write_data			(data_itcm_write_data),
	.data_itcm_read_data			(data_itcm_read_data),
	.data_itcm_read_data_valid		(data_itcm_read_data_valid),

	.instr_dtcm_addr			(instr_dtcm_addr),
	.instr_dtcm_access			(instr_dtcm_access),
	.instr_dtcm_read_data			(instr_dtcm_read_data),
	.instr_dtcm_read_data_valid		(instr_dtcm_read_data_valid),

	.data_dtcm_rd0_wr1			(data_dtcm_rd0_wr1),
	.data_dtcm_byte_strobe			(data_dtcm_byte_strobe),
	.data_dtcm_access			(data_dtcm_access),
	.data_dtcm_ready			(data_dtcm_ready),
	.data_dtcm_addr				(data_dtcm_addr),
	.data_dtcm_write_data			(data_dtcm_write_data),
	.data_dtcm_read_data			(data_dtcm_read_data),
	.data_dtcm_read_data_valid		(data_dtcm_read_data_valid),

	.IAHB_access				(IAHB_access),	
	.IAHB_addr				(IAHB_addr),
	.IAHB_read_data				(IAHB_read_data),
	.IAHB_read_data_valid			(IAHB_read_data_valid),

	.DAHB_access				(DAHB_access),	
	.DAHB_rd0_wr1				(DAHB_rd0_wr1),
	.DAHB_byte_strobe			(DAHB_byte_strobe),
	.DAHB_write_data			(DAHB_write_data),
	.DAHB_addr				(DAHB_addr),
	.DAHB_trans_buffer_full			(DAHB_trans_buffer_full),
	.DAHB_read_data				(DAHB_read_data),
	.DAHB_read_data_valid			(DAHB_read_data_valid)

);

//-----------------------------------------------------//
//-----------------------------------------------------//
itcm u_itcm(
	.clk		(cpu_clk_g),
	.rstn		(cpu_rstn),
	.instr_itcm_addr		(instr_itcm_addr),
	.instr_itcm_access		(instr_itcm_access),
	.instr_itcm_read_data		(instr_itcm_read_data),
	.instr_itcm_read_data_valid	(instr_itcm_read_data_valid),

	.data_itcm_rd0_wr1		(data_itcm_rd0_wr1),
	.data_itcm_byte_strobe		(data_itcm_byte_strobe),
	.data_itcm_access		(data_itcm_access),
	.data_itcm_ready		(data_itcm_ready),
	.data_itcm_addr			(data_itcm_addr),
	.data_itcm_write_data	(data_itcm_write_data),
	.data_itcm_read_data		(data_itcm_read_data),
	.data_itcm_read_data_valid	(data_itcm_read_data_valid),

	.IAHB_ready	(IAHB_ready),
	.IAHB_read_data	(IAHB_read_data),
	.IAHB_read_data_valid	(IAHB_read_data_valid),
	.itcm_auto_load	(itcm_auto_load),
	.itcm_auto_load_addr	(itcm_auto_load_addr)

);

//-----------------------------------------------------//
//-----------------------------------------------------//
dtcm u_dtcm (
	.clk			(cpu_clk_g),
	.rstn			(cpu_rstn),
	.data_dtcm_access	(data_dtcm_access),
	.data_dtcm_ready	(data_dtcm_ready),
	.data_dtcm_rd0_wr1	(data_dtcm_rd0_wr1),
	.data_dtcm_byte_strobe		(data_dtcm_byte_strobe),
	.data_dtcm_addr		(data_dtcm_addr),
	.data_dtcm_wdata	(data_dtcm_write_data),
	.data_dtcm_rdata	(data_dtcm_read_data),
	.data_dtcm_rdata_valid	(data_dtcm_read_data_valid),
	.instr_dtcm_addr	(instr_dtcm_addr),
	.instr_dtcm_access	(instr_dtcm_access),
	.instr_dtcm_rdata	(instr_dtcm_read_data),
	.instr_dtcm_rdata_valid(instr_dtcm_read_data_valid),
	.dma_dtcm_access	(dma_dtcm_access),
	.dma_dtcm_ready		(dma_dtcm_ready),
	.dma_dtcm_rd0_wr1	(dma_dtcm_rd0_wr1),
	.dma_dtcm_addr		(dma_dtcm_addr),
	.dma_dtcm_wdata		(dma_dtcm_wdata),
	.dma_dtcm_rdata		(dma_dtcm_rdata),
	.dma_dtcm_rdata_valid	(dma_dtcm_rdata_valid)

);

IAHB u_IAHB_master(
	.HCLK		(HCLK),
	.HRESETn	(HRESETn),
	.HBUSREQ	(IAHB_HBUSREQ),
	.HLOCK		(IAHB_HLOCK),
	.HGRANT		(IAHB_HGRANT),
	.HREADY		(IAHB_HREADY),
	.HRESP		(IAHB_HRESP),
	.HRDATA		(IAHB_HRDATA),
	.HTRANS		(IAHB_HTRANS),
	.HADDR		(IAHB_HADDR),
	.HWRITE		(IAHB_HWRITE),
	.IAHB_access	(IAHB_access),	
	.IAHB_addr	(IAHB_addr),
	.IAHB_read_data	(IAHB_read_data),
	.IAHB_read_data_valid	(IAHB_read_data_valid),
	.IAHB_ready	(IAHB_ready),
	.itcm_auto_load	(itcm_auto_load),
	.itcm_auto_load_addr	(itcm_auto_load_addr)
);

//-----------------------------------------------------//
//-----------------------------------------------------//
DAHB u_DAHB_master(
	.HCLK		(HCLK),
	.HRESETn	(HRESETn),
	.HBUSREQ	(DAHB_HBUSREQ),
	.HGRANT		(DAHB_HGRANT),
	.HREADY		(DAHB_HREADY),
	.HRESP		(DAHB_HRESP),
	.HRDATA		(DAHB_HRDATA),
	.HLOCK		(DAHB_HLOCK),
	.HTRANS		(DAHB_HTRANS),
	.HADDR		(DAHB_HADDR),
	.HWRITE		(DAHB_HWRITE),
	.HSIZE		(DAHB_HSIZE),
	.HBURST		(DAHB_HBURST),
	.HPROT		(DAHB_HPROT),
	.HWDATA		(DAHB_HWDATA),
	.cpu_clk	(cpu_clk_g),
	.cpu_resetn	(cpu_rstn),
	.DAHB_access	(DAHB_access),	
	.DAHB_rd0_wr1	(DAHB_rd0_wr1),		
	.DAHB_write_data	(DAHB_write_data),
	.DAHB_addr	(DAHB_addr),
	.DAHB_trans_buffer_full	(DAHB_trans_buffer_full),
	.DAHB_read_data	(DAHB_read_data),
	.DAHB_read_data_valid	(DAHB_read_data_valid)
);

//-----------------------------------------------------//
//-----------------------------------------------------//
ahb m_ahb(
.HCLK			(HCLK),
.HRESETn		(HRESETn),

//Master0
.HBUSREQ_from_M0	(IAHB_HBUSREQ),
.HLOCK_from_M0		(IAHB_HLOCK),
.HADDR_from_M0		(IAHB_HADDR),
.HTRANS_from_M0		(IAHB_HTRANS),
.HWRITE_from_M0		(1'b0),
.HWDATA_from_M0		(32'h0),
.HGRANT_to_M0		(IAHB_HGRANT),
.HRDATA_to_M0		(IAHB_HRDATA),
.HRESP_to_M0		(IAHB_HRESP),
.HREADY_to_M0		(IAHB_HREADY),

//Master1 
.HBUSREQ_from_M1	(DAHB_HBUSREQ),
.HLOCK_from_M1		(DAHB_HLOCK),
.HADDR_from_M1		(DAHB_HADDR),
.HTRANS_from_M1		(DAHB_HTRANS),
.HWRITE_from_M1		(DAHB_HWRITE),
.HWDATA_from_M1		(DAHB_HWDATA),
.HGRANT_to_M1		(DAHB_HGRANT),
.HRDATA_to_M1		(DAHB_HRDATA),
.HRESP_to_M1		(DAHB_HRESP),
.HREADY_to_M1		(DAHB_HREADY),

//Master2
.HBUSREQ_from_M2	(1'b0),
.HLOCK_from_M2		(1'b0),
.HADDR_from_M2		(32'h0),
.HTRANS_from_M2		(2'h0),
.HWRITE_from_M2		(1'b0),
.HWDATA_from_M2		(32'h0),
.HGRANT_to_M2		(),
.HRDATA_to_M2		(),
.HRESP_to_M2		(),
.HREADY_to_M2		(),

//Slave0
.HSEL_to_S0		(HSEL_kplic),
.HADDR_to_S0		(HADDR_kplic),
.HTRANS_to_S0		(HTRANS_kplic),
.HWRITE_to_S0		(HWRITE_kplic),
.HWDATA_to_S0		(HWDATA_kplic),
.HRDATA_from_S0		(HRDATA_kplic),
.HRESP_from_S0		(HRESP_kplic),
.HREADY_from_S0		(HREADY_kplic),


//Slave1
.HSEL_to_S1		(HSEL_core_timer),
.HADDR_to_S1		(HADDR_core_timer),
.HTRANS_to_S1		(HTRANS_core_timer),
.HWRITE_to_S1		(HWRITE_core_timer),
.HWDATA_to_S1		(HWDATA_core_timer),
.HRDATA_from_S1		(HRDATA_core_timer),
.HRESP_from_S1		(HRESP_core_timer),
.HREADY_from_S1		(HREADY_core_timer),
/*
.HSEL_to_S1		(),
.HADDR_to_S1		(),
.HTRANS_to_S1		(),
.HWRITE_to_S1		(),
.HWDATA_to_S1		(),
.HRDATA_from_S1		(32'h0),
.HRESP_from_S1		(2'h0),
.HREADY_from_S1		(1'b1),

*/

//Slave2
.HSEL_to_S2		(),
.HADDR_to_S2		(),
.HTRANS_to_S2		(),
.HWRITE_to_S2		(),
.HWDATA_to_S2		(),
.HRDATA_from_S2		(32'h0),
.HRESP_from_S2		(2'h0),
.HREADY_from_S2		(1'b1),

//Slave3
.HSEL_to_S3		(),
.HADDR_to_S3		(),
.HTRANS_to_S3		(),
.HWRITE_to_S3		(),
.HWDATA_to_S3		(),
.HRDATA_from_S3		(32'h0),
.HRESP_from_S3		(2'h0),
.HREADY_from_S3		(1'b1),

//Slave4
.HSEL_to_S4		(),
.HADDR_to_S4		(),
.HTRANS_to_S4		(),
.HWRITE_to_S4		(),
.HWDATA_to_S4		(),
.HRDATA_from_S4		(32'h0),
.HRESP_from_S4		(2'h0),
.HREADY_from_S4		(1'b1),

//Slave5
.HSEL_to_S5		(HSEL_apb	),
.HADDR_to_S5		(HADDR_apb	),
.HTRANS_to_S5		(HTRANS_apb	),
.HWRITE_to_S5		(HWRITE_apb	),
.HWDATA_to_S5		(HWDATA_apb	),
.HRDATA_from_S5		(HRDATA_apb	),
.HRESP_from_S5		(HRESP_apb	),
.HREADY_from_S5		(HREADY_apb	),

//Slave6
.HSEL_to_S6		(HSEL_flash	),
.HADDR_to_S6		(HADDR_flash	),
.HTRANS_to_S6		(HTRANS_flash	),
.HWRITE_to_S6		(HWRITE_flash	),
.HWDATA_to_S6		(HWDATA_flash	),
.HRDATA_from_S6		(HRDATA_flash	),
.HRESP_from_S6		(HRESP_flash	),
.HREADY_from_S6		(HREADY_flash	)
);

apb_ss m_apb(
    .GPIO_IN		(GPIO_IN	),
    .GPIO_OUT		(GPIO_OUT	),
    .UART_RX		(UART_RX	),
    .UART_TX		(UART_TX	),
    .timer_int		(timer_int	),
    .HCLK		(HCLK),
    .HRESETn		(HRESETn),
    .HREADY		(1'b1),
    .HSEL		(HSEL_apb	),
    .HADDR		(HADDR_apb	),
    .HTRANS		(HTRANS_apb	),
    .HWRITE		(HWRITE_apb	),
    .HWDATA		(HWDATA_apb	),
    .HRDATA		(HRDATA_apb	),
    .HRESP		(HRESP_apb	),
    .HREADYOUT		(HREADY_apb	)
);

debug_cnt #(.CNT_WIDTH(1)) test_uart (
.clk	(HCLK),
.rstn	(HRESETn),
.cnt_en	(!UART_TX),
.LED1	(),
.LED2	(LED1_red)
);

debug_cnt #(.CNT_WIDTH(1)) test_itcm (
.clk	(cpu_clk),
.rstn	(cpu_rstn),
.cnt_en	(!itcm_auto_load),
.LED1	(),
.LED2	(LED2_red)
);

light_led u_ll (
.clk		(cpu_clk_g),
.rstn		(cpu_rstn),
.switch1	(1'b1	),
.switch2	(1'b1	),
.LED_red	(LED2_green	),
.LED_green	(LED1_green	)
);


`ifndef ASIC
flash_ss flash_ss(
    .DEVRST_N				(DEVRST_N),
    .FAB_RESET_N			(1'b1),
    .FIC_0_AHB_S_HADDR			(HADDR_flash),
    .FIC_0_AHB_S_HMASTLOCK		(0),
    .FIC_0_AHB_S_HREADY			(1),
    .FIC_0_AHB_S_HSEL			(HSEL_flash),
    .FIC_0_AHB_S_HSIZE			(3'h2),
    .FIC_0_AHB_S_HTRANS			(HTRANS_flash),
    .FIC_0_AHB_S_HWDATA			(HWDATA_flash),
    .FIC_0_AHB_S_HWRITE			(HWRITE_flash),
    .MSS_INT_F2M			(16'h0),
    
    .FIC_0_AHB_S_HRDATA			(HRDATA_flash),
    .FIC_0_AHB_S_HREADYOUT		(HREADY_flash),
    .FIC_0_AHB_S_HRESP			(HRESP_flash),
    .FIC_0_CLK				(cpu_clk),
    .FIC_0_LOCK				(),
    .INIT_DONE				(),
    .MSS_READY				(cpu_rstn),
    .POWER_ON_RESET_N			()

);

`else
/*
flash_ss flash_ss(
);
ASIC flash
*/
`endif


//-----------------------------------------------------//
//-----------------------------------------------------//
kplic u_kplic (
.kplic_clk		(kplic_clk),
.kplic_rstn		(kplic_rstn),
.external_int		(external_int),
.kplic_int		(kplic_int),

	.HCLK		(HCLK),
	.HRESETn	(HRESETn),
	.HSEL		(HSEL_kplic),
	.HADDR		(HADDR_kplic),
	.HWRITE		(HWRITE_kplic),
	.HTRANS		(HTRANS_kplic),
	.HBURST		(HBURST_kplic),
	.HWDATA		(HWDATA_kplic),
	.HREADY		(HREADY_kplic),
	.HRESP		(HRESP_kplic),
	.HRDATA		(HRDATA_kplic)
);
core_timer u_core_timer (
	.core_timer_int		(core_timer_int),
	.HCLK		(HCLK),
	.HRESETn	(HRESETn),
	.HSEL		(HSEL_core_timer),
	.HADDR		(HADDR_core_timer),
	.HWRITE		(HWRITE_core_timer),
	.HTRANS		(HTRANS_core_timer),
	.HBURST		(HBURST_core_timer),
	.HWDATA		(HWDATA_core_timer),
	.HREADY		(HREADY_core_timer),
	.HRESP		(HRESP_core_timer),
	.HRDATA		(HRDATA_core_timer)
);


endmodule
