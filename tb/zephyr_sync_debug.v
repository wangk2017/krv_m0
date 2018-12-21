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

//Play a trick to let the simulation run faster

initial
begin
#5;
$display ("=========================================================================== \n");
$display ("Here is a trick to force the baud rate higher to make the simulation faster \n");
$display ("you can turn off the trick in tb/zephyr_debug.v by comment the force \n");
$display ("=========================================================================== \n");
force DUT.m_apb.uart_0.uart_0.baud_val = 13'h4;
end



wire test_end1;
assign test_end1 = dec_pc == 32'h0000df8;
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
			$display ("UART Transmitt");
			$display ("UART TX_DATA is %h \n",uart_tx_data);
			$fwrite(fp_z, "%s", uart_tx_data);
		end

end
parameter MAIN 			= 32'h000014d0;
parameter SWAP			= 32'h00000228;
parameter BG_THREAD_MAIN	= 32'h000014d4;
parameter THREADA		= 32'h0000046c;
parameter THREADB		= 32'h00000448;
parameter HL			= 32'h000003c8;
parameter RESCHEDULE		= 32'h0000013c;

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
		HL: //<threadB>
		begin
			$display ("helloLoop Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
	endcase
	end
end

