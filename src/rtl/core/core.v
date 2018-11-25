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
// File Name: 		core.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		top of core 			     	|| 
// History:   							||
//===============================================================

`include "core_defines.vh"

module core (
//global signals 
	input wire cpu_clk,						//cpu clock
	input wire cpu_rstn,						//cpu reset, active low
	input wire [`ADDR_WIDTH - 1 : 0] boot_addr,			// boot address from SoC

//interface with pg_ctrl
	input wire pg_resetn,						//power gating reset, active low
	output wire wfi,						//WFI

//interface with kplic
	input wire kplic_int,						//kplic interrupt

//interface with core_timer
	input wire core_timer_int,					//core_timer interrupt

//instr_dec interface access itcm
	output wire instr_itcm_access,					//instruction interface access ITCM
	output wire [`ADDR_WIDTH - 1 : 0] instr_itcm_addr,		//instruction interface access ITCM address
	input wire [`DATA_WIDTH - 1 : 0] instr_itcm_read_data,		//instruction interface access ITCM read data
	input wire instr_itcm_read_data_valid,				//instruction interface access ITCM read data valid
	input wire itcm_auto_load,				//ITCM is in auto-load process

//instr_dec interface access dtcm
	output instr_dtcm_access,					//instruction interface access DTCM
	output [`ADDR_WIDTH - 1 : 0] instr_dtcm_addr,			//instruction interface access DTCM address
	input wire [`DATA_WIDTH - 1 : 0] instr_dtcm_read_data,		//instruction interface access DTCM read data
	input wire instr_dtcm_read_data_valid,				//instruction interface access DTCM read data valid

//data interface access itcm
	output wire data_itcm_access,					//data interface access ITCM
	input wire data_itcm_ready,					//ITCM is ready for data interface access
	output wire data_itcm_rd0_wr1,					//data interface access ITCM cmd, 0: read; 1: write	
	output wire [3:0] data_itcm_byte_strobe,			//data interface access ITCM byte strobe
	output wire [`DATA_WIDTH - 1 : 0]  data_itcm_write_data,	//data interface access ITCM write data	
	output wire [`ADDR_WIDTH - 1 : 0] data_itcm_addr,		//data interface access ITCM address	
	input wire [`DATA_WIDTH - 1 : 0] data_itcm_read_data,		//data interface access ITCM read data	
	input wire data_itcm_read_data_valid,				//data interface access ITCM read data valid	

//data interface access dtcm
	output wire data_dtcm_access,	      				//data interface access DTCM
	input wire data_dtcm_ready,					//DTCM is ready for data interface access
	output wire data_dtcm_rd0_wr1,					//data interface access DTCM cmd 0: read; 1: write	
	output wire [3:0] data_dtcm_byte_strobe,			//data interface access DTCM byte strobe    	
	output wire [`DATA_WIDTH - 1 : 0]  data_dtcm_write_data,	//data interface access DTCM write data		
	output wire [`ADDR_WIDTH - 1 : 0] data_dtcm_addr,		//data interface access DTCM address		
	input wire [`DATA_WIDTH - 1 : 0] data_dtcm_read_data,		//data interface access DTCM read data		
	input wire data_dtcm_read_data_valid,				//data interface access DTCM read data valid	

//with IAHB
	output wire IAHB_access,					//IAHB access 
	output wire [`ADDR_WIDTH - 1 : 0] IAHB_addr,			//IAHB access address         	
	input wire [`DATA_WIDTH - 1 : 0] IAHB_read_data,		//IAHB access read data
	input wire IAHB_read_data_valid,				//IAHB access read data valid

//with DAHB
	output wire DAHB_access,					//DAHB access 	
	output wire DAHB_rd0_wr1,					//DAHB access cmd 0: read; 1: write	
	output wire [3:0] DAHB_byte_strobe,				//DAHB access byte strobe
	output wire [`DATA_WIDTH - 1 : 0]  DAHB_write_data,		//DAHB access write data
	output wire [`ADDR_WIDTH - 1 : 0] DAHB_addr,			//DAHB access address	
	input wire DAHB_trans_buffer_full,				//DAHB access transfer buffer full
	input wire [`DATA_WIDTH - 1 : 0] DAHB_read_data,		//DAHB access read data
	input wire DAHB_read_data_valid					//DAHB access read data valid	

);


//---------------------------------------------//
//Wires declaration
//---------------------------------------------//

wire 					jal_dec;
wire 					jalr_dec;
wire signed [`DATA_WIDTH - 1 : 0] 	imm_dec;
wire signed [`DATA_WIDTH - 1 : 0] 	src_data1_dec;
wire 					fence_dec;
wire [`ADDR_WIDTH - 1 : 0] 		pc_dec;

wire [`RD_WIDTH:0] 			rd_ex;
wire signed [`DATA_WIDTH - 1 : 0]  	src_data1_ex;	
wire signed [`DATA_WIDTH - 1 : 0]  	src_data2_ex;	
wire signed [`DATA_WIDTH - 1 : 0] 	imm_ex;
wire					use_alu_ex  ;
wire					alu_add_ex  ;
wire					alu_sub_ex  ;
wire					alu_com_ex  ;
wire					alu_ucom_ex ;
wire					alu_and_ex  ;
wire					alu_or_ex   ;
wire					alu_xor_ex  ;
wire					alu_sll_ex  ;
wire					alu_srl_ex  ;
wire					alu_sra_ex  ;
wire					alu_mul_ex  ;
wire					alu_div_ex  ;
wire					alu_divu_ex  ;
wire 					beq_ex;
wire 					bne_ex;
wire 					blt_ex;
wire 					bge_ex;
wire 					bltu_ex;
wire 					bgeu_ex;
wire 					branch_taken_ex;
wire [`DATA_WIDTH - 1 : 0]		alu_result_ex;				
wire 					load_ex;
wire 					store_ex;
wire 					mem_H_ex;
wire 					mem_B_ex;
wire 					mem_U_ex;
wire [`DATA_WIDTH - 1 : 0] 		store_data_ex;
wire 					only_src2_used_ex;	
wire [`ADDR_WIDTH - 1 : 0] 		pc_ex;

wire [`DATA_WIDTH - 1 : 0]		data_mem;				
wire [`RD_WIDTH:0] 			rd_mem;
wire [`DATA_WIDTH - 1 : 0]		alu_result_mem;		
wire 					load_mem;
wire 					store_mem;
wire 					mem_H_mem;
wire 					mem_B_mem;
wire 					mem_U_mem;
wire [`DATA_WIDTH - 1 : 0]		store_data_mem;
wire [`ADDR_WIDTH - 1 : 0]		mem_addr_mem;
wire 					mem_wb_data_valid;

wire [`RD_WIDTH:0] 			rd_wb;
wire signed [`DATA_WIDTH - 1 : 0]	wr_data_wb;					
wire 					wr_valid_wb;
wire [`DATA_WIDTH - 1 : 0]		alu_result_wb;				
wire 					alu_result_valid_wb;
wire 					load_wb;	
wire [`DATA_WIDTH - 1 : 0] 		load_data_wb;
wire 					load_data_valid_wb;


 wire [11:0] 				mcsr_addr;
 wire 					mcsr_rd;
 wire 					mcsr_wr;
 wire 					valid_mcsr_rd;
 wire 					valid_mcsr_wr;
 wire 					mcsr_set;
 wire 					mcsr_clr;
 wire 					meip;		
 wire 					mtip;		
 wire 					meie;		
 wire 					mtie;		
 wire [`ADDR_WIDTH - 1 : 0] 		mepc;		
 wire [`DATA_WIDTH - 1 : 0] 		mcause;	
 wire [`DATA_WIDTH - 1 : 0] 		mtval;	
 wire [`DATA_WIDTH - 1 : 0] 		mcsr_write_data;
 wire [`DATA_WIDTH - 1 : 0] 		mcsr_read_data;
 wire 					dtcm_en;
 wire [`ADDR_WIDTH - 1 : 0] 		dtcm_start_addr;

wire [`ADDR_WIDTH - 1 : 0] 		pc;
wire 					pc_misaligned;
wire 					load_x0;
wire 					csr_illegal_access;
wire [`ADDR_WIDTH - 1 : 0] 		fault_pc;	 
wire 					trap;
wire 					exception_met;
wire 					ecall;
wire  [`ADDR_WIDTH - 1 : 0] 		vector_addr;
wire 					mret;
wire 					mepc_sel;
wire 					mcause_sel;
wire 					mtval_sel;
wire [`INSTR_WIDTH - 1 : 0] 		illegal_instr;
wire 					valid_interrupt;
wire 					mstatus_mie;
wire [1:0] 				mtvec_mode;
wire [31:0] 				mtvec_base;


//Wires for fetch and imem
wire [`INSTR_WIDTH - 1 : 0] 		instr_dec	;
wire 					instr_read_data_valid;	
wire [`INSTR_WIDTH - 1 : 0] 		instr_read_data;
wire 					addr_AHB;
wire [`ADDR_WIDTH - 1 : 0] 		next_pc;

wire if_valid;
wire dec_valid;
wire ex_valid;
wire dec_ready;
wire ex_ready;
wire mem_ready;
wire wb_ready;


//===========================================================================//
//There are below blocks in the core
//--reset_comb
//--imem_ctrl
//--fetch
//--dec	
//--alu
//--dmem_ctrl
//--wb_ctrl
//--mcsr
//--trap_ctrl
//===========================================================================//

//-----------------------------------------------------//
//reset comb
//-----------------------------------------------------//
wire comb_rstn;

reset_comb u_reset_comb (
	.cpu_rstn	(cpu_rstn),
	.pg_resetn	(pg_resetn),
	.comb_rstn	(comb_rstn)
);
//-----------------------------------------------------//
//imem_ctrl
//-----------------------------------------------------//
imem_ctrl u_imem_ctrl(
.cpu_clk			(cpu_clk),		
.cpu_rstn			(comb_rstn),		
.next_pc			(next_pc),
.pc				(pc),	
.addr_AHB			(addr_AHB),
.instr_read_data		(instr_read_data),
.instr_read_data_valid		(instr_read_data_valid),
.instr_itcm_access		(instr_itcm_access),	
.instr_itcm_addr		(instr_itcm_addr),
.instr_itcm_read_data		(instr_itcm_read_data),
.instr_itcm_read_data_valid	(instr_itcm_read_data_valid),
.itcm_auto_load			(itcm_auto_load),
.dtcm_en			(dtcm_en),
.dtcm_start_addr		(dtcm_start_addr),
.instr_dtcm_access		(instr_dtcm_access),	
.instr_dtcm_addr		(instr_dtcm_addr),
.instr_dtcm_read_data		(instr_dtcm_read_data),
.instr_dtcm_read_data_valid	(instr_dtcm_read_data_valid),
.IAHB_access			(IAHB_access),	
.IAHB_addr			(IAHB_addr),
.IAHB_read_data			(IAHB_read_data),
.IAHB_read_data_valid		(IAHB_read_data_valid)
);
//-----------------------------------------------------//
//fetch
//-----------------------------------------------------//
fetch u_fetch(
.cpu_clk		(cpu_clk),		
.cpu_rstn		(comb_rstn),		
.boot_addr		(boot_addr),
.next_pc		(next_pc),	
.pc		(pc),	
.addr_AHB			(addr_AHB),
.instr_read_data	(instr_read_data),
.instr_read_data_valid	(instr_read_data_valid),	
.pc_dec			(pc_dec),
.dec_valid		(dec_valid ),		
.if_valid		(if_valid ),		
.dec_ready		(dec_ready),		
.instr_dec		(instr_dec ),	
.imm_dec		(imm_dec),
.src_data1_dec		(src_data1_dec),
.jal_dec		(jal_dec), 
.jalr_dec		(jalr_dec), 
.fence_dec		(fence_dec),
.ex_ready		(ex_ready),		
.pc_ex			(pc_ex),
.branch_taken_ex	(branch_taken_ex),
.imm_ex			(imm_ex),
.mret			(mret),
.pc_misaligned 		(pc_misaligned),
.fault_pc		(fault_pc),
.trap			(trap),
.vector_addr		(vector_addr),
.mepc			(mepc)

);

//-----------------------------------------------------//
//dec
//-----------------------------------------------------//

dec u_dec (
.cpu_clk		(cpu_clk ),	
.cpu_rstn		(comb_rstn ),	
.if_valid		(if_valid ),		
.dec_ready		(dec_ready),		
.instr_dec		(instr_dec ),
.pc_dec			(pc_dec),
.jal_dec		(jal_dec), 
.jalr_dec		(jalr_dec), 
.imm_dec		(imm_dec),
.src_data1_dec		(src_data1_dec),
.fence_dec		(fence_dec),
.dec_valid		(dec_valid ),		
.ex_ready		(ex_ready),		
.alu_result_ex		(alu_result_ex),
.only_src2_used_ex 	(only_src2_used_ex),
.src_data1_ex		(src_data1_ex ),
.src_data2_ex		(src_data2_ex ),
.use_alu_ex  		(use_alu_ex ),
.alu_add_ex  		(alu_add_ex ),
.alu_sub_ex  		(alu_sub_ex ),
.alu_com_ex  		(alu_com_ex ),
.alu_ucom_ex 		(alu_ucom_ex ),
.alu_and_ex  		(alu_and_ex ),
.alu_or_ex   		(alu_or_ex ),
.alu_xor_ex  		(alu_xor_ex ),
.alu_sll_ex  		(alu_sll_ex ),
.alu_srl_ex  		(alu_srl_ex ),
.alu_sra_ex  		(alu_sra_ex ),
.alu_mul_ex  		(alu_mul_ex ),
.alu_div_ex  		(alu_div_ex ),
.alu_divu_ex  		(alu_divu_ex ),
.beq_ex			(beq_ex),
.bne_ex			(bne_ex),
.blt_ex			(blt_ex),
.bge_ex			(bge_ex),
.bltu_ex		(bltu_ex),
.bgeu_ex		(bgeu_ex),
.branch_taken_ex	(branch_taken_ex),
.load_ex		(load_ex),
.store_ex		(store_ex),
.mem_H_ex		(mem_H_ex),
.mem_B_ex		(mem_B_ex),
.mem_U_ex		(mem_U_ex),
.store_data_ex		(store_data_ex),
.pc_ex			(pc_ex),
.rd_ex			(rd_ex ), 
.imm_ex			(imm_ex),
.data_mem		(data_mem),
.rd_mem			(rd_mem ),	
.mem_wb_data_valid	(mem_wb_data_valid),
.load_mem		(load_mem),
.rd_wb			(rd_wb ),	
.wr_valid_wb		(wr_valid_wb ),	
.wr_data_wb		(wr_data_wb),
.mcsr_addr		(mcsr_addr),
.mcsr_rd		(mcsr_rd),
.mcsr_wr		(mcsr_wr),
.valid_mcsr_rd		(valid_mcsr_rd),
.valid_mcsr_wr		(valid_mcsr_wr),
.mcsr_set		(mcsr_set),
.mcsr_clr		(mcsr_clr),
.mcsr_write_data	(mcsr_write_data),
.mcsr_read_data		(mcsr_read_data),
.exception_met		(exception_met),
.ecall			(ecall),
.load_x0		(load_x0),
.mret			(mret),
.wfi			(wfi)
);

//-----------------------------------------------------//
//alu
//-----------------------------------------------------//

alu u_alu (
.cpu_clk		(cpu_clk ),				
.cpu_rstn		(comb_rstn),				
.alu_result_ex		(alu_result_ex),
.only_src2_used_ex 	(only_src2_used_ex),

.dec_valid		(dec_valid ),		
.ex_ready		(ex_ready),		
.src_data1_ex		(src_data1_ex ),
.src_data2_ex		(src_data2_ex ),	
.use_alu_ex		(use_alu_ex ),				
.alu_add_ex		(alu_add_ex ),				
.alu_sub_ex		(alu_sub_ex ),				
.alu_com_ex		(alu_com_ex ),				
.alu_ucom_ex		(alu_ucom_ex ),				
.alu_and_ex		(alu_and_ex ),				
.alu_or_ex		(alu_or_ex ),				
.alu_xor_ex		(alu_xor_ex ),				
.alu_sll_ex		(alu_sll_ex ),				
.alu_srl_ex		(alu_srl_ex ),				
.alu_sra_ex		(alu_sra_ex ),				
.alu_mul_ex  		(alu_mul_ex ),
.alu_div_ex  		(alu_div_ex ),
.alu_divu_ex  		(alu_divu_ex ),
.beq_ex			(beq_ex),
.bne_ex			(bne_ex),
.blt_ex			(blt_ex),
.bge_ex			(bge_ex),
.bltu_ex		(bltu_ex),
.bgeu_ex		(bgeu_ex),
.branch_taken_ex	(branch_taken_ex),
.rd_ex			(rd_ex ),			
.load_ex		(load_ex),
.store_ex		(store_ex),
.mem_H_ex		(mem_H_ex),
.mem_B_ex		(mem_B_ex),
.mem_U_ex		(mem_U_ex),
.store_data_ex		(store_data_ex),
.alu_result_mem		(alu_result_mem ),				
.ex_valid		(ex_valid ),				
.mem_ready		(mem_ready),		
.rd_mem			(rd_mem),				
.load_mem		(load_mem),
.store_mem		(store_mem),
.mem_H_mem		(mem_H_mem),
.mem_B_mem		(mem_B_mem),
.mem_U_mem		(mem_U_mem),
.store_data_mem		(store_data_mem),
.mem_addr_mem		(mem_addr_mem)
);

//-----------------------------------------------------//
//dmem_ctrl
//-----------------------------------------------------//
dmem_ctrl u_dmem_ctrl (
.cpu_clk			(cpu_clk ),				
.cpu_rstn			(comb_rstn),				
.load_mem			(load_mem),
.store_mem			(store_mem),
.mem_H_mem			(mem_H_mem),
.mem_B_mem			(mem_B_mem),
.mem_U_mem			(mem_U_mem),
.store_data_mem			(store_data_mem),
.mem_addr_mem			(mem_addr_mem),
.alu_result_mem			(alu_result_mem ),		
.ex_valid			(ex_valid ),				
.mem_ready			(mem_ready),		
.data_mem			(data_mem),
.mem_wb_data_valid	(mem_wb_data_valid),
.rd_mem				(rd_mem),		
.wb_ready			(wb_ready),		
.load_wb 			(load_wb),			
.alu_result_wb			(alu_result_wb ),				
.alu_result_valid_wb		(alu_result_valid_wb ),				
.load_data_wb			(load_data_wb ),				
.load_data_valid_wb		(load_data_valid_wb ),				
.rd_wb				(rd_wb ),	

.data_itcm_access		(data_itcm_access),
.data_itcm_ready		(data_itcm_ready),
.data_itcm_rd0_wr1		(data_itcm_rd0_wr1),
.data_itcm_byte_strobe		(data_itcm_byte_strobe),
.data_itcm_addr			(data_itcm_addr),
.data_itcm_write_data		(data_itcm_write_data),
.data_itcm_read_data		(data_itcm_read_data),
.data_itcm_read_data_valid	(data_itcm_read_data_valid),

.dtcm_en			(dtcm_en),
.dtcm_start_addr		(dtcm_start_addr),
.data_dtcm_access		(data_dtcm_access),
.data_dtcm_ready		(data_dtcm_ready),
.data_dtcm_rd0_wr1		(data_dtcm_rd0_wr1),	
.data_dtcm_byte_strobe		(data_dtcm_byte_strobe),
.data_dtcm_write_data		(data_dtcm_write_data),
.data_dtcm_addr			(data_dtcm_addr),
.data_dtcm_read_data		(data_dtcm_read_data),
.data_dtcm_read_data_valid	(data_dtcm_read_data_valid),

.DAHB_access			(DAHB_access),
.DAHB_rd0_wr1			(DAHB_rd0_wr1),	
.DAHB_byte_strobe		(DAHB_byte_strobe),
.DAHB_write_data		(DAHB_write_data),
.DAHB_addr			(DAHB_addr),
.DAHB_trans_buffer_full		(DAHB_trans_buffer_full),
.DAHB_read_data			(DAHB_read_data),
.DAHB_read_data_valid		(DAHB_read_data_valid)

);

//-----------------------------------------------------//
//wb_ctrl
//-----------------------------------------------------//
wb_ctrl u_wb_ctrl (
.cpu_clk			(cpu_clk ),				
.cpu_rstn			(comb_rstn),				
.wb_ready			(wb_ready),		
.load_wb 			(load_wb),			
.alu_result_wb			(alu_result_wb ),				
.alu_result_valid_wb		(alu_result_valid_wb ),				
.load_data_wb			(load_data_wb ),				
.load_data_valid_wb		(load_data_valid_wb ),	
.wr_valid_wb			(wr_valid_wb ),	
.wr_data_wb			(wr_data_wb)
);

//-----------------------------------------------------//
//mcsr
//-----------------------------------------------------//
mcsr u_mcsr(
.cpu_clk		(cpu_clk),		
.cpu_rstn		(comb_rstn),	
.instr_dec		(instr_dec ),	
.csr_addr		(mcsr_addr),
.mcsr_rd		(mcsr_rd),
.mcsr_wr		(mcsr_wr),
.valid_mcsr_rd		(valid_mcsr_rd),
.valid_mcsr_wr		(valid_mcsr_wr),
.mcsr_set		(mcsr_set),
.mcsr_clr		(mcsr_clr),
.write_data		(mcsr_write_data),
.read_data		(mcsr_read_data),
.valid_interrupt	(valid_interrupt),
.meip			(meip),		
.mtip			(mtip),		
.mepc			(mepc),	
.mcause			(mcause),	
.mtval			(mtval),	
.mepc_sel		(mepc_sel),
.mcause_sel		(mcause_sel),
.mtval_sel		(mtval_sel),
.csr_illegal_access	(csr_illegal_access),
.illegal_instr		(illegal_instr ),	
.mstatus_mie		(mstatus_mie),
.meie			(meie),
.mtie			(mtie),
.mtvec_mode		(mtvec_mode),
.mtvec_base		(mtvec_base),
.dtcm_en		(dtcm_en),
.dtcm_start_addr	(dtcm_start_addr)

);

//-----------------------------------------------------//
//trap_ctrl
//-----------------------------------------------------//
trap_ctrl u_trap_ctrl (
.cpu_clk		(cpu_clk),		
.cpu_rstn		(comb_rstn),	
.branch_taken_ex	(branch_taken_ex),
.pc_misaligned 		(pc_misaligned),
.pc			(pc),	
.fault_pc		(fault_pc),
.load_x0		(load_x0),
.csr_illegal_access	(csr_illegal_access),
.illegal_instr		(illegal_instr ),	
.kplic_int		(kplic_int),
.timer_int		(core_timer_int),
.valid_mcsr_rd		(valid_mcsr_rd),
.valid_mcsr_wr		(valid_mcsr_wr),
.mcsr_set		(mcsr_set),
.mcsr_clr		(mcsr_clr),
.write_data		(mcsr_write_data),
.mepc_sel		(mepc_sel),
.mcause_sel		(mcause_sel),
.mtval_sel		(mtval_sel),
.mstatus_mie		(mstatus_mie),
.meie			(meie),
.mtie			(mtie),
.mtvec_mode		(mtvec_mode),
.mtvec_base		(mtvec_base),
.valid_interrupt	(valid_interrupt),
.meip			(meip),				
.mtip			(mtip),		
.mepc			(mepc),
.mcause			(mcause),	
.mtval			(mtval),	
.trap			(trap),
.exception_met		(exception_met),
.ecall			(ecall),
.vector_addr		(vector_addr)
);



endmodule
