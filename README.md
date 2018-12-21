# krv_m0

1: Introduction

The krv_m0 is a RISCV 32-bit micro-controller subsystem. It consists of a riscv 32-b 5-stage pipeline CPU Core with two tightly-coupled-memory for instruction/data acceleration, a platform level interrupt controller (KPLIC) and standard AHB interconnect for easy application-related extensions. The KRV-m core uses clock/operand gating and power gating technology to save power.


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

1) RV32I Compliance verification

krv_m0 uses the riscv-tests rv32ui for compliance check

$ git clone https://github.com/riscv/riscv-tests

$ cd riscv-tests

$ git submodule update --init --recursive

Hack the env/p/link.ld with text start from 0x00000000

  . = 0x00000000;
  .text.init : { *(.text.init) }
  
cd isa

make rv32ui XLEN=32

revert the hack in env/p/link.ld

go to the krv_m0 dir

make all_riscv_hex

edit tb/sim_inc/tb_defines.vh with all commented except riscv

make all_riscv_tests

The TB will check the value of gp(GPRS3), if it is 0x1 after entering write_tohost, it will display Pass, or it will display Fail.

All the sim log will be found in out/



2) Zephyr Hello world

krv_m0 test uses the board m2gl025_miv for some tiny setting changes.

In {ZEPHYR_DIR}/boards/riscv32/m2gl025_miv/board.h 

#define uart_miv_port_0_clk_freq    25000000

In {ZEPHYR_DIR}/boards/riscv32/m2gl025_miv/m2gl025_miv_defconfig

CONFIG_UART_MIV_PORT_0_BAUD_RATE=9600

In {ZEPHYR_DIR}/soc/riscv32/riscv-privilege/miv/Kconfig.defconfig.series

config RISCV_ROM_BASE_ADDR

	hex
	default 0x00000000

Compile zephyr

cd samples/hello_world/

cmake -GNinja -Bbuild -H. -DBOARD=m2gl025_miv

cd build

ninja

Run simulation

Go back to krv_m0

make zephyr.hex

edit tb/sim_inc/tb_defines.vh with all commented except zephyr 

make comp

make zephyr.sim

the output is stored in out/uart_tx_data.txt


3) Zephyr philosopher

Compile zephyr

cd samples/philosopher/

cmake -GNinja -Bbuild -H. -DBOARD=m2gl025_miv

cd build

ninja

Run simulation

Go back to krv_m0

make zephyr_phil.hex

edit tb/sim_inc/tb_defines.vh with all commented except zephyr_phil

make comp

make zephyr_phil.sim

the output is stored in out/uart_tx_data_phil.txt

4) Zephyr synchronization

Compile zephyr

cd samples/synchronization/

cmake -GNinja -Bbuild -H. -DBOARD=m2gl025_miv

cd build

ninja

Run simulation

Go back to krv_m0

make zephyr_sync.hex

edit tb/sim_inc/tb_defines.vh with all commented except zephyr_sync

make comp

make zephyr_sync.sim

the output is stored in out/uart_tx_data_sync.txt

4: RUN FPGA

krv_m0 uses the Micro-semi SmartFusion2, and the flash is filled with content of zephyr hello world with uart baud rate=9600 and system_clk=25MHz.


go to krv_m0 dir

libero&

connect the flashpro5 and open the putty and set the baud rate to 9600

select the script of run_FPGA.tcl


I met some problem while import the component and need to manually do some fix.

turn to design hierarchy, under krv_m, double click the flash_ss, for the rom used, select the krv_m0/bin_file/zephyr.sim.mem for its content.

 under itcm, double click the sram_4Kx32, and OK after the generate window appears.

Then click on the Run PROGRAM Action under design flow.

After some minutes, the FPGA Programming Action finished. Press the reset button on the board, and the zephyr hello world output will be displayed in the putty window.


