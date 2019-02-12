# krv_m0

1: Introduction
KRV-m0 is a RISCV-based 32-bit micro-controller subsystem. It consists of a RISCV processor Core with two tightly coupled memories for instruction and data acceleration, a machine timer and a platform level interrupt controller (KPLIC) for timer and external interrupts respectively and lite AHB interconnection with some APB peripherals.  krv_m0 uses clock-gating, operands gating and power gating to control power consumption. 

More details can be found in DOC dir: 
https://github.com/wangk2017/krv_m0/blob/master/DOC


Block Diagram

![krv_m0 block diagram](https://github.com/wangk2017/krv_m0/blob/master/img_dir/krv_m0%20block%20diagram.png)



2: Tools Setup

1)Simulation

krv_m0 uses the free iverilog for functional verification and gtkwave for debug. Below is how these tools are installed for ubuntu

$:sudo apt-get install iverilog

$:sudo apt-get install gtkwave

2)FPGA

Krv_m0 uses Microsemi_SmartFusion2. Refer to below links for tool download/install and license. 

 https://www.microsemi.com/product-directory/design-resources/1750-libero-soc#downloads
 
 https://www.microsemi.com/product-directory/design-resources/1750-libero-soc


3: Simulation

Firstly, please update the Makefile zephyr_dir and riscv_test_dir with your local zephyr and riscv_tests DIR

(1) RV32I Compliance verification

krv_m0 uses the riscv-tests rv32ui for compliance check

https://github.com/riscv/riscv-tests

edit tb/sim_inc/tb_defines.vh with all commented except riscv

	make comp
	make all_riscv_tests

The TB will check the value of gp(GPRS3), if it is 0x1 after entering write_tohost, it will display Pass, or it will display Fail.



(2) Boot OS Zephyr applications (Hello world/philosopher/synchronization)

krv_m0 test uses the board m2gl025_miv for some tiny setting changes for clock frequency, baud rate and ROM start address.

edit tb/sim_inc/tb_defines.vh with all commented except zephyr for hello world (or zephyr_phil for philosopher or zephyr_sync for synchronization) 

	make comp

	make zephyr.sim
or
	
	make zephyr_phil.sim

or

	make zephyr_sync.sim
	
the output is stored in out/uart_tx_data.txt for hello world and out/uart_tx_data_phil.txt for philosopher and out/uart_tx_data_sync.txt for synchronization



(3) Run benchmark of Dhrystone

edit tb/sim_inc/tb_defines.vh with all commented except dhrystone

	make comp
	
	make dhrystone.sim

the result is stored in out/uart_tx_data_dhrystone.txt


4: RUN FPGA

krv_m0 uses the Micro-semi SmartFusion2, and the flash is filled with content of zephyr hello world with uart baud rate=9600 and system_clk=25MHz.


go to krv_m0 dir

	libero&

connect the flashpro5 and open the putty and set the baud rate to 9600

	select the script of run_FPGA.tcl


I met some problem while import the component and need to manually do some fix.

	turn to design hierarchy,
	under krv_m, 
	double click the flash_ss, 
	for the rom used, select the krv_m0/bin_file/zephyr.sim.mem for its content.

	under itcm, 
	double click the sram_4Kx32, and OK after the generate window appears.

	Then click on the Run PROGRAM Action under design flow.

After some minutes, the FPGA Programming Action finished. Press the reset button on the board, and the zephyr hello world output will be displayed in the putty window.


