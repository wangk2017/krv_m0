`include "top_defines.vh"
`include "core_defines.vh"
`include "kplic_defines.vh"
`include "ahb_defines.vh"
`include "tb_defines.vh"
`timescale 1ns/100ps

module krv_m_TB ();

`ifdef SIM
reg cpu_clk;
reg cpu_rstn;
reg HCLK;
reg HRESETn;
reg kplic_clk;
reg kplic_rstn;
`else
reg DEVRST_N;
wire cpu_clk;
wire cpu_rstn;
wire kplic_clk;
wire kplic_rstn;
`endif
reg [`INT_NUM - 1 : 0] external_int;


`ifdef SIM
wire HSEL_rom;
wire [`AHB_ADDR_WIDTH - 1 : 0] HADDR_rom;
wire HWRITE_rom;
wire [`AHB_DATA_WIDTH - 1 : 0] HWDATA_rom;
wire HREADY_rom;
wire [`AHB_DATA_WIDTH - 1 : 0] HRDATA_rom;

assign HSEL_rom = DUT.m_ahb.HSEL_to_S0;
assign HADDR_rom = DUT.m_ahb.HADDR_to_S0;
assign HWRITE_rom = DUT.m_ahb.HWRITE_to_S0;
assign HWDATA_rom = DUT.m_ahb.HWDATA_to_S0;


initial
begin
force DUT.m_ahb.HRDATA_from_S0 = HRDATA_rom; 
force DUT.m_ahb.HREADY_from_S0 = HREADY_rom; 
end

test_sram u_rom(
	.HCLK	(HCLK),
	.HRESETn(HRESETn),
	.HSEL	(HSEL_rom),
	.HADDR	(HADDR_rom),
	.HWRITE	(HWRITE_rom),
	.HWDATA	(HWDATA_rom),
	.HREADY	(HREADY_rom),
	.HRDATA	(HRDATA_rom)
);
`endif


krv_m DUT (
`ifndef SIM
	.DEVRST_N		(DEVRST_N),
`else
	.cpu_clk		(cpu_clk ),	
	.cpu_rstn		(cpu_rstn),
	.kplic_clk		(kplic_clk),
	.kplic_rstn		(kplic_rstn),
	.HCLK			(HCLK),
	.HRESETn		(HRESETn),
	.UART_RX		(1'b1),
	.GPIO_IN		(8'h0)
`endif
`ifdef DMA_DTCM_ACCESS
,
	.dma_dtcm_access	(1'b0),			
	.dma_dtcm_ready		(),
	.dma_dtcm_rd0_wr1	(1'b0),		
	.dma_dtcm_addr(32'h0),	
	.dma_dtcm_wdata(32'h0),	
	.dma_dtcm_rdata(),
	.dma_dtcm_rdata_valid()	
`endif
);

//clocks

`ifndef SIM
assign cpu_clk = DUT.cpu_clk;
assign cpu_rstn = DUT.cpu_rstn;
assign kplic_clk = DUT.cpu_clk;
assign kplic_rstn = DUT.cpu_rstn;
`else
	always 
	begin
	#20 cpu_clk <= ~cpu_clk;
	end
	
	always 
	begin
	#20 kplic_clk <= ~kplic_clk;
	end
	
	always 
	begin
	#20 HCLK <= ~HCLK;
	end
`endif
wire [31:0] dec_pc = DUT.u_core.u_fetch.pc_dec;

`ifdef PG_TEST
`include "pg_sr.v"
`endif

`ifdef DHRYSTONE
`include "dhrystone_debug.v"
`endif

`ifdef ZEPHYR
`include "zephyr_debug.v"
`endif

`ifdef ZEPHYR_PHIL
`include "zephyr_phil_debug.v"
`endif

`ifdef ZEPHYR_SYNC
`include "zephyr_sync_debug.v"
`endif
//external interrupts
initial 
begin

	`ifdef SIM
	kplic_clk <= 0;
	kplic_rstn <= 0;
	@(posedge kplic_clk);
	kplic_rstn <=1;
	`endif
end


wire test_end;
`ifdef RISCV
assign test_end = (dec_pc == 32'h48);
`else
assign test_end = 0; 
`endif

`ifdef ZEPHYR
integer fp;
integer i;

initial
begin
fp=$fopen("run.mem","w");
#10;
for (i=0; i<4096; i=i+1)
begin
	$fwrite(fp,"%b\n",u_rom.mem[i]);
end
$fclose(fp);
end
`endif

initial 
begin

`ifdef SIM
	cpu_clk <= 0;
	cpu_rstn <= 0;
	$readmemh("./hex_file/run.hex",u_rom.mem);
`else
	DEVRST_N <=0;
`endif
	
`ifdef SIM
	HCLK <= 0;
	HRESETn <=0;
	@(posedge cpu_clk);
	cpu_rstn <=1;
	HRESETn <= 1;
`else
	#10;
	DEVRST_N <=1;
`endif
	
	
	@(posedge test_end)
	begin
		@(posedge cpu_clk);
		$display ("||===========================================||");
		$display ("||===========================================||");
		$display ("||               TEST END                    ||");
		$display ("||===========================================||");
		$display ("||                                           ||");
		$display ("||===========================================||");
		$display ("||               TEST RESULT:                ||");
		$display ("||===========================================||");
		$display ("||===========================================||");
			if (DUT.u_core.u_dec.u_gprs.gprs_X[3] == 1)
			begin
				$display ("||===========================================||");
				$display ("||                                           ||");
				$display ("||            PC stops @ %x            ||",dec_pc);
				$display ("||                                           ||");
				$display ("||                  Run Pass !               ||");
				$display ("||                                           ||");
				$display ("||===========================================||");
			end
			else
			begin
				$display ("||===========================================||");
				$display ("||                                           ||");
				$display ("||                  Ooops......              ||");
				$display ("||                  Run Fail !               ||");
				$display ("||                                           ||");
				$display ("||===========================================||");
			end
		$stop;
	end
end

initial
begin
`ifndef RISCV
	repeat (1000000)
`else
	repeat (80000)
`endif
	begin
	@(posedge cpu_clk);
	end
	$display (" ||===================================||");
	$display (" ||===================================||");
	$display (" ||                                   ||");
	$display (" ||             Time Out!             ||");
	$display (" ||                                   ||");
	$display (" ||===================================||");
	$display (" ||===================================||");
	$stop;

end

`ifdef SIM
initial
begin
$dumpfile("./out/krv.vcd");
$dumpvars(0, krv_m_TB);
end
`endif

//signals for debug
wire [`DATA_WIDTH - 1 : 0] gprs_0  = DUT.u_core.u_dec.u_gprs.gprs_X[0];
wire [`DATA_WIDTH - 1 : 0] gprs_1  = DUT.u_core.u_dec.u_gprs.gprs_X[1];
wire [`DATA_WIDTH - 1 : 0] gprs_2  = DUT.u_core.u_dec.u_gprs.gprs_X[2];
wire [`DATA_WIDTH - 1 : 0] gprs_3  = DUT.u_core.u_dec.u_gprs.gprs_X[3];
wire [`DATA_WIDTH - 1 : 0] gprs_4  = DUT.u_core.u_dec.u_gprs.gprs_X[4];
wire [`DATA_WIDTH - 1 : 0] gprs_5  = DUT.u_core.u_dec.u_gprs.gprs_X[5];
wire [`DATA_WIDTH - 1 : 0] gprs_6  = DUT.u_core.u_dec.u_gprs.gprs_X[6];
wire [`DATA_WIDTH - 1 : 0] gprs_7  = DUT.u_core.u_dec.u_gprs.gprs_X[7];
wire [`DATA_WIDTH - 1 : 0] gprs_8  = DUT.u_core.u_dec.u_gprs.gprs_X[8];
wire [`DATA_WIDTH - 1 : 0] gprs_9  = DUT.u_core.u_dec.u_gprs.gprs_X[9];
wire [`DATA_WIDTH - 1 : 0] gprs_10 = DUT.u_core.u_dec.u_gprs.gprs_X[10];
wire [`DATA_WIDTH - 1 : 0] gprs_11 = DUT.u_core.u_dec.u_gprs.gprs_X[11];
wire [`DATA_WIDTH - 1 : 0] gprs_12 = DUT.u_core.u_dec.u_gprs.gprs_X[12];
wire [`DATA_WIDTH - 1 : 0] gprs_13 = DUT.u_core.u_dec.u_gprs.gprs_X[13];
wire [`DATA_WIDTH - 1 : 0] gprs_14 = DUT.u_core.u_dec.u_gprs.gprs_X[14];
wire [`DATA_WIDTH - 1 : 0] gprs_15 = DUT.u_core.u_dec.u_gprs.gprs_X[15];
wire [`DATA_WIDTH - 1 : 0] gprs_16 = DUT.u_core.u_dec.u_gprs.gprs_X[16];
wire [`DATA_WIDTH - 1 : 0] gprs_17 = DUT.u_core.u_dec.u_gprs.gprs_X[17];
wire [`DATA_WIDTH - 1 : 0] gprs_18 = DUT.u_core.u_dec.u_gprs.gprs_X[18];
wire [`DATA_WIDTH - 1 : 0] gprs_19 = DUT.u_core.u_dec.u_gprs.gprs_X[19];
wire [`DATA_WIDTH - 1 : 0] gprs_20 = DUT.u_core.u_dec.u_gprs.gprs_X[20];
wire [`DATA_WIDTH - 1 : 0] gprs_21 = DUT.u_core.u_dec.u_gprs.gprs_X[21];
wire [`DATA_WIDTH - 1 : 0] gprs_22 = DUT.u_core.u_dec.u_gprs.gprs_X[22];
wire [`DATA_WIDTH - 1 : 0] gprs_23 = DUT.u_core.u_dec.u_gprs.gprs_X[23];
wire [`DATA_WIDTH - 1 : 0] gprs_24 = DUT.u_core.u_dec.u_gprs.gprs_X[24];
wire [`DATA_WIDTH - 1 : 0] gprs_25 = DUT.u_core.u_dec.u_gprs.gprs_X[25];
wire [`DATA_WIDTH - 1 : 0] gprs_26 = DUT.u_core.u_dec.u_gprs.gprs_X[26];
wire [`DATA_WIDTH - 1 : 0] gprs_27 = DUT.u_core.u_dec.u_gprs.gprs_X[27];
wire [`DATA_WIDTH - 1 : 0] gprs_28 = DUT.u_core.u_dec.u_gprs.gprs_X[28];
wire [`DATA_WIDTH - 1 : 0] gprs_29 = DUT.u_core.u_dec.u_gprs.gprs_X[29];
wire [`DATA_WIDTH - 1 : 0] gprs_30 = DUT.u_core.u_dec.u_gprs.gprs_X[30];
wire [`DATA_WIDTH - 1 : 0] gprs_31 = DUT.u_core.u_dec.u_gprs.gprs_X[31];


endmodule

