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
// File Name: 		fetch.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		instruction fetch                 	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================



`include "core_defines.vh"

module fetch (
//global signals
input wire cpu_clk,					// cpu clock
input wire cpu_rstn,					// cpu reset, active low
input wire [`ADDR_WIDTH - 1 : 0] boot_addr,		// boot address from SoC

//interface with dec
input wire jal_ex, 					// jal
input wire jalr_ex, 					// jalr
input wire fence_dec,					// fence
output reg [`ADDR_WIDTH - 1 : 0] pc_dec,		// Program counter value for the previous 1 instruction
input wire dec_valid, 					// stall IF stage
input wire dec_ready, 					// stall IF stage
output reg if_valid,					// indication of instruction valid
output reg [`INSTR_WIDTH - 1 : 0] instr_dec,		// instruction
input wire signed [`DATA_WIDTH - 1 : 0] src_data1_ex,	// source data 1 at EX stage
input wire signed [`DATA_WIDTH - 1 : 0] imm_ex,		// immediate at ex stage
input wire [`ADDR_WIDTH - 1 : 0] pc_ex,			// Program counter value for the previous 2 instruction

//interface with alu
input wire ex_ready,
input wire branch_taken_ex,				// branch condition met

//interface with imem_ctrl
output wire [`ADDR_WIDTH - 1 : 0] next_pc,		// Program counter value for imem addr
input wire instr_read_data_valid,			// instruction valid from imem		
input wire [`INSTR_WIDTH - 1 : 0] instr_read_data, 	// instruction from imem
input wire addr_AHB,

//interface with trap_ctrl
output reg [`ADDR_WIDTH - 1 : 0] pc,	
input wire mret,					// mret
output wire pc_misaligned,				// pc misaligned condition found at IF stage
output wire [`ADDR_WIDTH - 1 : 0] fault_pc,		// the misaligned pc recorded at IF stage
input wire trap,					// trap (interrupt or exception) 
input wire  [`ADDR_WIDTH - 1 : 0] vector_addr,		// vector address
input wire [`ADDR_WIDTH - 1 : 0] mepc			// epc for return from trap

);



//--------------------------------------------------------------------------------------//
//1: PC calculation
//--------------------------------------------------------------------------------------//


//--------------------------------------------------------------------------------------//
//An address adder is used to calculate the next pc based on the conditions listed below
//JAL
//JALR
//Branch
//normal
//--------------------------------------------------------------------------------------//

//if the IF is waiting for memory read,
// the jump/branch_taken/mret from the DEC/EX should be kept

reg jal_ex_r;
reg jalr_ex_r;
reg branch_taken_ex_r;
reg mret_r;
reg fence_dec_r;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		jal_ex_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		jal_ex_r <= 1'b0;
		else if(jal_ex)
		jal_ex_r <= 1'b1;
	end
end	

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		jalr_ex_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		jalr_ex_r <= 1'b0;
		else if(jalr_ex)
		jalr_ex_r <= 1'b1;
	end
end	

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		branch_taken_ex_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		branch_taken_ex_r <= 1'b0;
		else if(branch_taken_ex)
		branch_taken_ex_r <= 1'b1;
	end
end	

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		mret_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		mret_r <= 1'b0;
		else if(mret)
		mret_r <= 1'b1;
	end
end	

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		fence_dec_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		fence_dec_r <= 1'b0;
		else if(fence_dec)
		fence_dec_r <= 1'b1;
	end
end	



reg [`ADDR_WIDTH - 1 : 0] addr_adder_res;


always @ *
begin
	if(branch_taken_ex | jal_ex)			//branch or jal
	begin
		addr_adder_res = pc_ex + imm_ex;
	end
	else if(jalr_ex)		
	begin
		addr_adder_res = src_data1_ex + imm_ex;	//jalr
	end
	else if(instr_read_data_valid && dec_ready)
	begin
		addr_adder_res = pc + 4;				//normal case
	end
	else
	begin
		addr_adder_res = pc;			
	end
end

//register addr_adder_res when IF is wait for imem data valid
reg  [`ADDR_WIDTH - 1 : 0] addr_adder_res_r;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		addr_adder_res_r <= {`INSTR_WIDTH{1'b0}};	
	end
	else if(instr_read_data_valid && dec_ready)
	begin
		addr_adder_res_r <= {`INSTR_WIDTH{1'b0}};	
	end
	else if(branch_taken_ex || jal_ex || jalr_ex)
	begin
		addr_adder_res_r <= addr_adder_res;
	end
end

wire  [`ADDR_WIDTH - 1 : 0] addr_adder_res_c = (branch_taken_ex_r || jal_ex_r || jalr_ex_r )? addr_adder_res_r : addr_adder_res;

assign next_pc = trap ? vector_addr : ((!(dec_ready) || ((fence_dec || fence_dec_r) && !(instr_read_data_valid && dec_ready) && !branch_taken_ex))? pc: ((mret||mret_r) ? mepc : addr_adder_res_c));

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		pc <= boot_addr;
	end
	else
	begin
		if(instr_read_data_valid)
		pc <= next_pc;
	end
end

//--------------------------------------------------------------------------------------//
//Keep the flush signal when fetch is waiting for the memory data back
//--------------------------------------------------------------------------------------//
wire flush_if = jal_ex |jalr_ex | branch_taken_ex | trap | mret;
reg flush_if_r;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		flush_if_r <= 1'b0;
	end
	else 
	begin
		if(instr_read_data_valid && dec_ready)
		flush_if_r <= 1'b0;
		else if(flush_if)
		flush_if_r <= 1'b1;
	end
end	


//--------------------------------------------------------------------------------------//
//2: pass instruction fetched and pc to dec
//--------------------------------------------------------------------------------------//

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (~cpu_rstn)
	begin
		if_valid <= 1'b0;
		instr_dec <= {`INSTR_WIDTH{1'b0}};
		pc_dec <= boot_addr;
	end
	else
	begin
		if(flush_if || flush_if_r)
		begin
			if_valid <= 1'b0;
			instr_dec <= {`INSTR_WIDTH{1'b0}};
		end
		else if(dec_ready)
		begin
			if_valid <= instr_read_data_valid;
			instr_dec <= instr_read_data;
			pc_dec <= pc;
		end
	end
end

//--------------------------------------------------------------------------------------//
//3: check pc misaligned condition
//--------------------------------------------------------------------------------------//

assign pc_misaligned = (|pc[1:0]);
assign fault_pc = pc_misaligned ? pc : {`ADDR_WIDTH{1'b0}};


endmodule
