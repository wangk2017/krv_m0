reg mem_addr_hit;

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
assign test_end1 = dec_pc == 32'h000013d4;

integer fp_z;

initial
begin
$display ("=========================================================================== \n");
	$display ("simulation on zephyr sample hello world\n");
$display ("=========================================================================== \n");
	fp_z =$fopen ("./out/uart_tx_data.txt","w");
	@(posedge test_end1)
	begin
		$fclose(fp_z);
		$display ("TEST_END\n");
		$display ("Print data is stored in out/uart_tx_data.txt\n");
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

always @(posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
	end
	else
	begin
		case (dec_pc)
		32'h000003c8:	//main
		begin
			$display ("Main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000654: //initialize
		begin
			$display ("initialize Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000640: //PrepC
		begin
			$display ("PrepC Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001364:	//bss_zero
		begin
			$display ("bss_zero Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001384: //<_data_copy>
		begin
			$display ("data_copy Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h000013f4: //<_Cstart>
		begin
			$display ("Cstart Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h0000110c: //<memset>
		begin
			$display ("memset Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000d48: //<soc_interrupt_init>
		begin
			$display ("soc_interrupt_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001264: //<_sys_device_do_config_level>
		begin
			$display ("driver Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000dfc:// <plic_init>
		begin
			$display ("plic_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001214:// <uart_miv_init>
		begin
			$display ("uart_miv_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000dcc:// <uart_console_init>
		begin
			$display ("uart_console_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h000019e0: //<_sched_init>
		begin
			$display ("sched_init Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001b00: //<_setup_new_thread>
		begin
			$display ("setup_new_thread Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000670:// <_new_thread>
		begin
			$display ("new_thread Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001ca0:// <_init_thread_base>
		begin
			$display ("init_thread_base Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00001828: //<_add_thread_to_ready_q>
		begin
			$display ("add_thread_to_ready_q Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		00000228:// <__swap>
		begin
			$display ("swap Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h000013a8: //<bg_thread_main>
		begin
			$display ("bg_thread_main Start");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		32'h00000cb8:// <printk>
		begin
			$display ("printk");
			$display ("@time %t  !",$time);
			$display ("\n");
		end
		endcase
	end
end

