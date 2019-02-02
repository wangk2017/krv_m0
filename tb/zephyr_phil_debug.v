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


wire [31:0] mem_addr = DUT.u_core.u_dmem_ctrl.mem_addr;
wire mem_st = DUT.u_core.u_dmem_ctrl.store_mem;
wire st_data = DUT.u_core.u_dmem_ctrl.store_data_mem;

always @(posedge cpu_clk)
begin
	if((mem_addr==32'h40000) && mem_st)
	begin
		$display ("write to mem 40000");
		$display ("@time %t  !",$time);
		$display ("write data = %h",st_data);
		$display ("\n");
	end
end


//Play a trick to let the simulation run faster

initial
begin
#5;
$display ("=========================================================================== \n");
$display ("Here is a trick to force the baud rate higher to make the simulation faster \n");
$display ("you can turn off the trick in tb/zephyr_phil_debug.v by comment the force \n");
$display ("=========================================================================== \n");
force DUT.m_apb.uart_0.uart_0.baud_val = 13'h4;
end


wire test_end1;
assign test_end1 = dec_pc == 32'h00001ae4;
//assign test_end1 = 0;

integer fp_z;

initial
begin
$display ("=========================================================================== \n");
	$display ("simulation on zephyr sample philosophers\n");
$display ("=========================================================================== \n");
fp_z =$fopen ("./out/uart_tx_data_phil.txt","w");
@(posedge test_end1)
begin
	$fclose(fp_z);
	$display ("TEST_END\n");
	$display ("Print data is stored in out/uart_tx_data_phil.txt\n");
	$stop;
end
end

always @(posedge cpu_clk)
begin
	if(uart_tx_wr)
		begin
			$display ("UART Transmitt");
			$display ("UART TX_DATA is %h \n",uart_tx_data);
			$fwrite(fp_z, "%s", uart_tx_data);
		end

end
parameter MAIN 			= 32'h00000604;
parameter INITIALIZE 		= 32'h000009a8;
parameter PREPC 		= 32'h00000994;
parameter BSS_ZERO 		= 32'h00002178;
parameter DATA_COPY 		= 32'h00002198;
parameter CSTART 		= 32'h00002208;
parameter MEMSET 		= 32'h00001ee8;
parameter SOC_INTERRUPT_INIT 	= 32'h00001b2c;
parameter DRIVER 		= 32'h00002040;
parameter PLIC_INIT 		= 32'h00001be0;
parameter UART_MIV_INIT 	= 32'h00001ff0;
parameter UART_CONSOLE_INIT 	= 32'h00001bb0;
parameter SCHD_INIT 		= 32'h0000301c;
parameter SETUP_NEW_THREAD 	= 32'h00003324;
parameter NEW_THREAD		= 32'h000009c4;
parameter INIT_THREAD_BASE	= 32'h000035d8;
parameter ADD_TO_READY		= 32'h00002be4;
parameter K_SPIN_LOCK		= 32'h00002718;
parameter PRIQ_RB_ADD		= 32'h00002af8;
parameter UPDATE_CACHE		= 32'h00002728;
parameter SWAP			= 32'h00000228;
parameter BG_THREAD_MAIN	= 32'h000021c0;
parameter UART_MIV_POLL_OUT	= 32'h00001f64;
parameter PRINTK		= 32'h00001a9c;
parameter VPRINTK		= 32'h00001a6c;
parameter _VPRINTK		= 32'h0000169c;
parameter CHAR_OUT		= 32'h0000152c;
parameter CONSOLE_OUT		= 32'h00001b40;
parameter RESCHEDULE		= 32'h0000013c;
parameter THREAD_ENTRY_WRAPPER  = 32'h000009c0;
parameter THREAD_ENTRY		= 32'h00000ad8;
parameter PHIL			= 32'h000004a4;
parameter SLICE_SET 		= 32'h000027cc;
parameter PRINT_RET 		= 32'h00000650;
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

always @(posedge cpu_clk)
begin
	begin
		case (dec_pc)
		PRINT_RET:
		begin
			$display ("print return");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		SLICE_SET:
		begin
			$display ("k_sched_time_slice_set");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		PHIL:
		begin
			$display ("phil Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		MAIN:	//main
		begin
			$display ("Main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
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
		PRIQ_RB_ADD: // <_priq_rb_add>
		begin
			$display ("priq_rb_add Start");
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
		BG_THREAD_MAIN: //<bg_thread_main>
		begin
			$display ("bg_thread_main Start");
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
/*
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

