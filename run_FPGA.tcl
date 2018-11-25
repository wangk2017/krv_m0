# Microsemi Tcl Script
# libero
# Date: Sat Nov 24 00:28:54 2018
# Directory /root/root_work/krv_m0
# File /root/root_work/krv_m0/exported.tcl


new_project -location {./fpga} -name {fpga} -project_description {} -block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 -use_enhanced_constraint_flow 1 -hdl {VERILOG} -family {SmartFusion2} -die {M2S025} -package {256 VF} -speed {STD} -die_voltage {1.2} -part_range {COM} -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} -adv_options {IO_DEFT_STD:LVCMOS 2.5V} -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} -adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:COM} -adv_options {VCCI_1.2_VOLTR:COM} -adv_options {VCCI_1.5_VOLTR:COM} -adv_options {VCCI_1.8_VOLTR:COM} -adv_options {VCCI_2.5_VOLTR:COM} -adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:COM} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/ahb/ahb_arbiter.v} \
         -hdl_source {./src/rtl/ahb/ahb_decoder.v} \
         -hdl_source {./src/rtl/ahb/ahb.v} \
         -hdl_source {./src/rtl/ahb/ahb2apb.v} \
         -hdl_source {./src/rtl/ahb/ahb2regbus.v} \
         -hdl_source {./src/rtl/ahb/DAHB.v} \
         -hdl_source {./src/rtl/ahb/IAHB.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/apb/apb_ss.v} \
         -hdl_source {./src/rtl/apb/apb3.v} \
         -hdl_source {./src/rtl/apb/gpio_in.v} \
         -hdl_source {./src/rtl/apb/gpio_out.v} \
         -hdl_source {./src/rtl/apb/timer.v} \
         -hdl_source {./src/rtl/apb/uart.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/common/debug_cnt.v} \
         -hdl_source {./src/rtl/common/light_led.v} \
         -hdl_source {./src/rtl/common/sync_fifo.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/core/alu.v} \
         -hdl_source {./src/rtl/core/core.v} \
         -hdl_source {./src/rtl/core/dec.v} \
         -hdl_source {./src/rtl/core/dmem_ctrl.v} \
         -hdl_source {./src/rtl/core/fetch.v} \
         -hdl_source {./src/rtl/core/gprs.v} \
         -hdl_source {./src/rtl/core/imem_ctrl.v} \
         -hdl_source {./src/rtl/core/imm_gen.v} \
         -hdl_source {./src/rtl/core/mcsr.v} \
         -hdl_source {./src/rtl/core/pg_ctrl.v} \
         -hdl_source {./src/rtl/core/reset_comb.v} \
         -hdl_source {./src/rtl/core/trap_ctrl.v} \
         -hdl_source {./src/rtl/core/wb_ctrl.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/inc/ahb_defines.vh} \
         -hdl_source {./src/rtl/inc/core_defines.vh} \
         -hdl_source {./src/rtl/inc/kplic_defines.vh} \
         -hdl_source {./src/rtl/inc/top_defines.vh} 
refresh 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/core_timer/core_timer_regs.v} \
         -hdl_source {./src/rtl/core_timer/core_timer.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/kplic/kplic_core.v} \
         -hdl_source {./src/rtl/kplic/kplic_gateway.v} \
         -hdl_source {./src/rtl/kplic/kplic_regs.v} \
         -hdl_source {./src/rtl/kplic/kplic.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/soc/krv_m.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/rtl/tcm/dtcm.v} \
         -hdl_source {./src/rtl/tcm/itcm.v} 
import_files \
         -convert_EDN_to_HDL 0 \
         -hdl_source {./src/Actel_DirectCore/Clock_gen.v} \
         -hdl_source {./src/Actel_DirectCore/coreahbtoapb3_ahbtoapbsm.v} \
         -hdl_source {./src/Actel_DirectCore/coreahbtoapb3_apbaddrdata.v} \
         -hdl_source {./src/Actel_DirectCore/coreahbtoapb3_penablescheduler.v} \
         -hdl_source {./src/Actel_DirectCore/coreahbtoapb3.v} \
         -hdl_source {./src/Actel_DirectCore/coreapb3_iaddr_reg.v} \
         -hdl_source {./src/Actel_DirectCore/coreapb3_muxptob3.v} \
         -hdl_source {./src/Actel_DirectCore/coreapb3.v} \
         -hdl_source {./src/Actel_DirectCore/coregpio.v} \
         -hdl_source {./src/Actel_DirectCore/coregpioin.v} \
         -hdl_source {./src/Actel_DirectCore/coretimer.v} \
         -hdl_source {./src/Actel_DirectCore/CoreUART.v} \
         -hdl_source {./src/Actel_DirectCore/CoreUARTapb.v} \
         -hdl_source {./src/Actel_DirectCore/fifo_256x8_g4.v} \
         -hdl_source {./src/Actel_DirectCore/Rx_async.v} \
         -hdl_source {./src/Actel_DirectCore/Tx_async.v} 
set_root -module {krv_m::work} 
import_component -file {/root/root_work/krv_m0/src/component/work/flash_ss/flash_ss.cxf} 
import_component -file {/root/root_work/krv_m0/src/component/work/flash_ss_MSS/flash_ss_MSS.cxf} 
import_component -file {/root/root_work/krv_m0/src/component/work/sram_4Kx32/sram_4Kx32.cxf} 
import_files \
         -convert_EDN_to_HDL 0 \
         -io_pdc {./constraint/user.pdc} 
run_tool -name {CONSTRAINT_MANAGEMENT} 
organize_tool_files -tool {PLACEROUTE} -file {./fpga/constraint/io/user.pdc} -module {krv_m::work} -input_type {constraint} 
save_project 
update_and_run_tool -name {PROGRAMDEVICE} 
