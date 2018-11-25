reg main_start;
reg init_start;
reg prepC_start;
reg sched_init_start;
reg setup_new_thread_start;
reg add_to_ready_start;
reg bg_to_main_start;
reg mem_addr_hit0;
reg mem_addr_hit1;
reg mem_addr_hit2;
reg mem_addr_hit4;
wire uart_tx_wr = !(DUT.m_apb.uart_0.uart_0.WEn || DUT.m_apb.uart_0.uart_0.csn);
wire[7:0] uart_tx_data = DUT.m_apb.uart_0.uart_0.data_in;


wire test_end1;
assign test_end1 = dec_pc == 32'h00001500;
//assign test_end1 = 0;

integer fp_z;

initial
begin
	$display ("zephyr sync\n");
fp_z =$fopen ("./out/uart_tx_data_sync.txt","w");
@(posedge test_end1)
begin
	$fclose(fp_z);
	$display ("TEST_END\n");
	$display ("Print data is stored in out/uart_tx_data_sync.txt\n");
	$stop;
end
end

always @(posedge cpu_clk)
begin
	if(uart_tx_wr)
		begin
/*
			$display ("UART Transmitt");
			$display ("UART TX_DATA is %h \n",uart_tx_data);
*/
			$fwrite(fp_z, "%s", uart_tx_data);
		end

end
parameter MAIN 			= 32'h000014d0;
parameter INITIALIZE 		= 32'h0000074c;
parameter PREPC 		= 32'h00000738;
parameter BSS_ZERO 		= 32'h00001488;
parameter DATA_COPY 		= 32'h000014a8;
parameter CSTART 		= 32'h0000151c;
parameter MEMSET 		= 32'h0000121c;
parameter SOC_INTERRUPT_INIT 	= 32'h00000e40;
parameter DRIVER 		= 32'h00001388;
parameter PLIC_INIT 		= 32'h00000f14;
parameter UART_MIV_INIT 	= 32'h00001338;
parameter UART_CONSOLE_INIT 	= 32'h00000ee4;
parameter SCHD_INIT 		= 32'h00001c4c;
parameter SETUP_NEW_THREAD 	= 32'h00001f68;
parameter NEW_THREAD		= 32'h00000768;
parameter INIT_THREAD_BASE	= 32'h00000768;
parameter ADD_TO_READY		= 32'h000019c8;
parameter K_SPIN_LOCK		= 32'h000016fc;
parameter PRIQ_DUMB_ADD		= 32'h00001964;
parameter UPDATE_CACHE		= 32'h0000170c;
parameter SWAP			= 32'h00000228;
parameter BG_THREAD_MAIN	= 32'h000014d0;
parameter UART_MIV_POLL_OUT	= 32'h000012ac;
parameter PRINTK		= 32'h00000db0;
parameter VPRINTK		= 32'h00000d80;
parameter _VPRINTK		= 32'h000009b0;
parameter CHAR_OUT		= 32'h00040010;
parameter CONSOLE_OUT		= 32'h00000e54;
parameter THREADA		= 32'h0000046c;
parameter THREADB		= 32'h00000448;
parameter RESCHEDULE		= 32'h0000013c;
parameter THREAD_ENTRY_WRAPPER  = 32'h00000764;
parameter THREAD_ENTRY		= 32'h00000814;
parameter INIT_STATIC_THREADS	= 32'h00002088;
parameter IMPL_K_THREAD_START  	= 32'h00001f10;

wire [31:0] mret_addr = DUT.u_core.u_fetch.mepc;
wire [31:0] mret_instr = DUT.u_core.u_fetch.mret;

always @ (posedge mret_instr)
begin
	
	$display ("mret from pc_dec= %h\n", dec_pc);
	$display ("@time %t  !",$time);
	$display ("\n");

end

always @ (mret_addr)
begin
	$display ("mepc changed");
	$display ("@time %t  !",$time);
	$display ("\n");
	$display ("mepc = %h \n",mret_addr);
end

always @(posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		main_start <= 1'b0;
	end
	else
	begin
		case (dec_pc)
		MAIN:	//main
		begin
			$display ("Main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			main_start <=  1'b1;
		end
		INITIALIZE: //initialize
		begin
			$display ("initialize Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			init_start <=  1'b1;
		end
		PREPC: //PrepC
		begin
			$display ("PrepC Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			init_start <=  1'b1;
		end
		BSS_ZERO:	//bss_zero
		begin
			$display ("bss_zero Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		DATA_COPY: //<_data_copy>
		begin
			$display ("data_copy Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		CSTART: //<_Cstart>
		begin
			$display ("Cstart Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		MEMSET: //<memset>
		begin
			$display ("memset Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		SOC_INTERRUPT_INIT: //<soc_interrupt_init>
		begin
			$display ("soc_interrupt_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		DRIVER: //<_sys_device_do_config_level>
		begin
			$display ("driver Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		PLIC_INIT:// <plic_init>
		begin
			$display ("plic_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		UART_MIV_INIT:// <uart_miv_init>
		begin
			$display ("uart_miv_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		UART_CONSOLE_INIT:// <uart_console_init>
		begin
			$display ("uart_console_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		SCHD_INIT: //<_sched_init>
		begin
			$display ("sched_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			sched_init_start <=  1'b1;
		end
		SETUP_NEW_THREAD: //<_setup_new_thread>
		begin
			$display ("setup_new_thread Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			setup_new_thread_start <=  1'b1;
		end
		NEW_THREAD:// <_new_thread>
		begin
			$display ("new_thread Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		INIT_THREAD_BASE:// <_init_thread_base>
		begin
			$display ("init_thread_base Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		ADD_TO_READY: //<_add_thread_to_ready_q>
		begin
			$display ("add_thread_to_ready_q Start");
			$display ("@time %t  !",$time);
			$display ("\n");
			add_to_ready_start <=  1'b1;
		end
		K_SPIN_LOCK:// <k_spin_lock.isra.1>
		begin
			$display ("k_spin_lock.isra.1 Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		PRIQ_DUMB_ADD: // <_priq_dumb_add>
		begin
			$display ("priq_dumb_add Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		UPDATE_CACHE: // <update_cache>
		begin
			$display ("update_cache Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		SWAP:// <__swap>
		begin
			$display ("swap Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		RESCHEDULE:
		begin
			$display ("reschedule Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		THREAD_ENTRY:
		begin
			$display ("thread_entry");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		INIT_STATIC_THREADS:
		begin
			$display ("init_static_threads");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		IMPL_K_THREAD_START:
		begin
			$display ("impl_k_thread_start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		BG_THREAD_MAIN: //<bg_thread_main>
		begin
			$display ("bg_thread_main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		THREADA: //<threadA>
		begin
			$display ("thread_a Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		THREADB: //<threadB>
		begin
			$display ("thread_b Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
/*
		UART_MIV_POLL_OUT:// <uart_miv_poll_out>
		begin
			$display ("uart_miv_poll_out");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
*/
		PRINTK:// <printk>
		begin
			$display ("printk");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		VPRINTK:// <vprintk>
		begin
			$display ("vprintk");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		_VPRINTK:// <_vprintk>
		begin
			$display ("_vprintk");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		CHAR_OUT:// <char_out>
		begin
			$display ("char_out");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
/*
		CONSOLE_OUT:// <console_out>
		begin
			$display ("console_out");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
*/

		endcase
	end
end

wire [31:0] mem_wdata = DUT.u_core.u_dmem_ctrl.mem_write_data;
wire [31:0] mem_rdata = DUT.u_core.u_dmem_ctrl.mem_read_data;
wire [31:0] mem_addr = DUT.u_core.u_dmem_ctrl.mem_addr;
wire [31:0] mem_wr = DUT.u_core.u_dmem_ctrl.store_mem;
wire [31:0] mem_rd = DUT.u_core.u_dmem_ctrl.load_mem;
wire [4:0] rd = DUT.u_core.u_dmem_ctrl.rd_mem;

always @(posedge cpu_clk)
begin
	if(mem_wr && (mem_addr==32'h000402b4))
	begin
			$display ("write memory 402b4");
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_wdata = %h  !",mem_wdata);
			$display ("@time %t  !",$time);
			$display ("\n");
	end
end

reg [31:0] thread_entry_wrapper_st_addr;
always @(posedge cpu_clk)
begin
	if(mem_addr_hit4)
			thread_entry_wrapper_st_addr <= 0;
	else if(mem_wr && (mem_wdata == THREAD_ENTRY_WRAPPER))
		begin
			thread_entry_wrapper_st_addr <= mem_addr;
			$display ("thread_entry_wrapper base addr write to memory");
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_wdata = %h  !",mem_wdata);
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end


reg [31:0] bg_thread_main_st_addr;
always @(posedge cpu_clk)
begin
	if(mem_addr_hit0)
			bg_thread_main_st_addr <= 0;
	else if(mem_wr && (mem_wdata == BG_THREAD_MAIN))
		begin
			bg_thread_main_st_addr <= mem_addr;
			$display ("bg_thread_main base addr write to memory");
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_wdata = %h  !",mem_wdata);
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end

reg [31:0] thread_a_st_addr;
always @(posedge cpu_clk)
begin
	if(mem_addr_hit1)
			thread_a_st_addr <= 0;
	else if(mem_wr && (mem_wdata == THREADA))
		begin
			thread_a_st_addr <= mem_addr;
			$display ("thread_a base addr write to memory");
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_wdata = %h  !",mem_wdata);
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end


reg [31:0] thread_b_st_addr;
always @(posedge cpu_clk)
begin
	if(mem_addr_hit2)
			thread_b_st_addr <= 0;
	else if(mem_wr && (mem_wdata == THREADB))
		begin
			thread_b_st_addr <= mem_addr;
			$display ("thread_b base addr write to memory");
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_wdata = %h  !",mem_wdata);
			$display ("@time %t  !",$time);
			$display ("\n");
		end
end



always @(posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mem_addr_hit0 <= 1'b0;
		mem_addr_hit1 <= 1'b0;
		mem_addr_hit2 <= 1'b0;
		mem_addr_hit4 <= 1'b0;
	end
	else
	begin
		if(mem_rd && (mem_addr ==bg_thread_main_st_addr ))
		begin
			mem_addr_hit0 <= 1'b1;
			$display ("bg_thread_main base addr read from memory");
		end
		else if(mem_rd && (mem_addr == thread_a_st_addr))
		begin
			mem_addr_hit1 <= 1'b1;
			$display ("thread_a base addr read from memory");
		end
		else if(mem_rd && (mem_addr == thread_b_st_addr))
		begin
			mem_addr_hit2 <= 1'b1;
			$display ("thread_b base addr read from memory");
		end
		else if(mem_rd && (mem_rdata == THREAD_ENTRY_WRAPPER))
		begin
			mem_addr_hit4 <= 1'b1;
			$display ("thread_entry_wrapper base addr read from memory");
		end
		else
		begin
			mem_addr_hit0 <= 1'b0;
			mem_addr_hit1 <= 1'b0;
			mem_addr_hit2 <= 1'b0;
			mem_addr_hit4 <= 1'b0;
		end
	end
end

always @(posedge cpu_clk)
begin
	if(mem_addr_hit0 || mem_addr_hit1 || mem_addr_hit2)
	begin
			$display ("mem_addr = %h  !",mem_addr);
			$display ("mem_rdata = %h  !",mem_rdata);
			$display ("rd = %h  !",rd);
			$display ("@time %t  !",$time);
			$display ("\n");
	end
end

