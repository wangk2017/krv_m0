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
// File Name: 		trap_ctrl.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		trap control unit	         	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

`include "core_defines.vh"

module trap_ctrl (
//global signals
input wire cpu_clk,					//cpu clock
input wire cpu_rstn,					//cpu reset, active low

//interface with kplic
input wire kplic_int,					//external interrupt request from kplic

//interface with core_timer
input wire timer_int,					//interrupt request from timer

//interface with fetch
input wire pc_misaligned,				//pc misaligned
input wire [`ADDR_WIDTH - 1 : 0] pc,			//pc
input wire [`ADDR_WIDTH - 1 : 0] fault_pc,		//fault pc
output wire exception_met,				//exception met
output wire trap,					//trap
output reg  [`ADDR_WIDTH - 1 : 0] vector_addr,		//vector address

//interface with dec
input wire load_x0,					//load x0 exception
input wire ecall,
input wire valid_mcsr_rd,				//valid mcsr read
input wire valid_mcsr_wr,				//valid mcsr write
input wire mcsr_set,					//mcsr set
input wire mcsr_clr,					//mcsr clear
input wire [`DATA_WIDTH - 1 : 0] write_data,		//mcsr write data

//interface with alu
input wire branch_taken_ex,				//branch taken

//interface with mcsr
input wire csr_illegal_access,				//illegal access
input wire [`INSTR_WIDTH - 1 : 0] illegal_instr,	//illegal instr
input wire mepc_sel,					//mepc address
input wire mcause_sel,					//mcause address
input wire mtval_sel,					//mtval address
input wire mstatus_mie,					//global interrupt enable for Machine Level
input wire meie,					//external interrupt enable in mie register
input wire mtie,					//timer interrupt enable in mie register
input wire [1:0] mtvec_mode,				//mtvec mode
input wire [31:0] mtvec_base,				//mtvec base
output wire valid_interrupt,				//valid interrupt
output reg meip,					//meip
output reg mtip,					//mtip
output reg [`ADDR_WIDTH - 1 : 0] mepc,			//mepc
output reg [`DATA_WIDTH - 1 : 0] mcause,		//mcause
output reg [`DATA_WIDTH - 1 : 0] mtval			//mtval

);


//-----------------------------------------------//
//synchronize the external interrupt from KPLIC
//-----------------------------------------------//
reg kplic_int_sync1;
reg kplic_int_sync2; 

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		kplic_int_sync1 <= 1'b0;
		kplic_int_sync2 <= 1'b0;
	end
	else
	begin
		kplic_int_sync1 <= kplic_int;
		kplic_int_sync2 <= kplic_int_sync1;
	end
end


//------------------------------------------------//
//record external interrupt in meip
//-----------------------------------------------//
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		meip <= 1'b0;
	end
	else
	begin
		meip <= kplic_int_sync2;
	end
end


//------------------------------------------------//
//record external interrupt in mtip
//-----------------------------------------------//
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		mtip <= 1'b0;
	end
	else
	begin
		mtip <= timer_int;
	end
end


//-----------------------------------------------//
//mepc
//-----------------------------------------------//
wire valid_wr;
assign valid_wr = valid_mcsr_wr;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		mepc <= {`ADDR_WIDTH{1'b0}};
	end
	else
	begin
		if(mepc_sel & valid_wr)	//soft control
		begin
			if(mcsr_set)
			begin
				mepc <= mepc | write_data;
			end
			else if(mcsr_clr)
			begin
				mepc <= mepc & (~write_data);
			end
			else
			begin
				mepc <= write_data;
			end
		end
		else				//hardware control
		begin
			if(exception_met)	//exception condition
			begin
				if(ecall)
				begin
					mepc <= pc - 4;
				end
				else
				begin
					mepc <= pc;
				end
			end
			else if (valid_interrupt)
			begin
				mepc <= pc;	//return to the first instr not executed
			end
			else 			 
			begin
				mepc <= mepc;		
			end
		end
	end
end


//-------------------------------------------//
//mcause
//-------------------------------------------//

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		mcause <= {`DATA_WIDTH{1'b1}}; 
	end
	else
	begin
		if(mcause_sel & valid_wr)	//soft control
		begin
			if(mcsr_set)
			begin
				mcause <= mcause | write_data;
			end
			else if(mcsr_clr)
			begin
				mcause <= mcause & (~write_data);
			end
			else
			begin
				mcause <= write_data;
			end
		end
		else
		begin
			if(exception_met)	//exception condition
			begin
				if(pc_misaligned)
				begin
					mcause <= `PC_MISALIGNED;
				end
				else if(load_x0)
				begin
					mcause <= `LOAD_ACCESS_FAULT;
				end
				else if(csr_illegal_access)
				begin
					mcause <= `ILLEGAL_INSTR;
				end
				else if(ecall)
				begin
					mcause <= `M_ECALL;
				end
			end
			else if(valid_timer_int)
			begin
				mcause <= `M_TIMER_INT;
			end
			else if(valid_interrupt)
			begin
				mcause <= `M_EXTER_INT;
			end
			else
			begin
				mcause <= mcause;
			end
		end
	end
end

//-------------------------------------------//
//mtval
//-------------------------------------------//

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if (!cpu_rstn)
	begin
		mtval <= {`DATA_WIDTH{1'b0}}; 
	end
	else
	begin
		if(mtval_sel & valid_wr)	//soft control
		begin
			if(mcsr_set)
			begin
				mtval <= mtval | write_data;
			end
			else if(mcsr_clr)
			begin
				mtval <= mtval & (~write_data);
			end
			else
			begin
				mtval <= write_data;
			end
		end
		else
		begin
			if(exception_met)	//exception condition
			begin
				if(pc_misaligned)
				begin
					mtval <= fault_pc;
				end
				else if(csr_illegal_access)
				begin
					mtval <= illegal_instr;
				end
			end
			else 
			begin
				mtval <= mtval;
			end
		end
	end
end


//-------------------------------------------//
//vector address
//-------------------------------------------//
always @ *
begin
	case (mtvec_mode)
		2'b00: begin
			vector_addr = mtvec_base;
		end
		2'b01: begin
			if(exception_met)						//for exception
			begin
				vector_addr = mtvec_base;
			end
			else								//for interrupt
			begin
				vector_addr = mtvec_base + (mcause << 2);
			end
		end
		default: begin
			vector_addr = mtvec_base;
		end
		
	endcase

end

//-------------------------------------------//
//trap condition
//-------------------------------------------//
//wire valid_timer_int;
assign valid_interrupt = mstatus_mie && meie && meip;

assign valid_timer_int = mstatus_mie && mtie && mtip;
assign exception_met = pc_misaligned | load_x0 | csr_illegal_access | ecall;
assign trap = exception_met | valid_interrupt | valid_timer_int;

endmodule
