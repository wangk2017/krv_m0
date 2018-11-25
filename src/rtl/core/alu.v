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
// File Name: 		alu.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		arithmetic and logic unit         	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

`include "core_defines.vh"
module alu (
//global signals
input wire cpu_clk,					// cpu clock
input wire cpu_rstn,					// cpu reset, active low


//interface with dec
input wire dec_valid,
output wire ex_ready,
input wire signed [`DATA_WIDTH - 1 : 0] src_data1_ex,	// source data 1 at EX stage
input wire signed [`DATA_WIDTH - 1 : 0] src_data2_ex,	// source data 2 at EX stage
input wire only_src2_used_ex,				// for lui
input wire use_alu_ex,					// alu used     
input wire alu_add_ex,					// add operation at EX stage
input wire alu_sub_ex,					// sub operation at EX stage
input wire alu_com_ex,					// com operation at EX stage
input wire alu_ucom_ex,					// unsigned com operation at EX stage
input wire alu_and_ex,					// and operation at EX stage
input wire alu_or_ex,					// or operation at EX stage
input wire alu_xor_ex,					// xor operation at EX stage
input wire alu_sll_ex,					// sll operation at EX stage
input wire alu_srl_ex,					// srl operation at EX stage
input wire alu_sra_ex,					// sra operation at EX stage
input wire alu_mul_ex,					// mul operation at EX stage
input wire alu_div_ex,					// div operation at EX stage
input wire alu_divu_ex,					// divu operation at EX stage
output wire [`DATA_WIDTH - 1 : 0] alu_result_ex,	// forwarding result at EX stage to DEC stage

input wire beq_ex,					// branch when rs1=rs2
input wire bne_ex,					// branch when rs1!=rs2
input wire blt_ex,					// branch when rs1<rs2
input wire bge_ex,					// branch when rs1>=rs2
input wire bltu_ex,					// branch when rs1<rs2, both treated as unsigned
input wire bgeu_ex,					// branch when rs1>=rs2,both treated as unsigned
output wire branch_taken_ex,				// branch condition met

input wire load_ex, 	  				// load instruction
input wire store_ex, 	    				// store instruction
input wire mem_H_ex,					// memory access halfword
input wire mem_B_ex,					// memory access byte
input wire mem_U_ex,					// load unsigned halfword/byte
input wire [`DATA_WIDTH - 1 : 0] store_data_ex, 	// store source data

input wire [`RD_WIDTH : 0] rd_ex,			// rd at EX stage

//interface with dmem_ctrl 
output reg ex_valid,					// alu result valid at MEM stage
input wire mem_ready,					// ready at MEM stage
output reg [`DATA_WIDTH - 1 : 0] alu_result_mem,	// alu result at MEM stage
output reg [`RD_WIDTH:0] rd_mem,			// rd at MEM stage
output reg load_mem, 					// load at MEM stage  
output reg store_mem,         				// store at MEM stage                        
output reg mem_H_mem,					// halfword access at MEM stage
output reg mem_B_mem,					// byte access at MEM stage
output reg mem_U_mem,					// unsigned load halfword/byte at MEM stage
output reg [`DATA_WIDTH - 1 : 0] store_data_mem,	// store data at MEM stage
output wire [`ADDR_WIDTH - 1 : 0] mem_addr_mem		// memory address at MEM stage
);



//--------------------------------------------------------------------------------//
//ALU operations
//--------------------------------------------------------------------------------//

//1: 32b Adder
wire signed [`DATA_WIDTH - 1 : 0] adder_src_data1;	//source data 1 for adder
wire signed [`DATA_WIDTH - 1 : 0] adder_src_data2;	//source data 2 for adder
wire signed [`DATA_WIDTH - 1 : 0] adder_result;		//result of adder
//gated the source operand when adder not used 
assign adder_src_data1 = (alu_add_ex | alu_sub_ex )? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign adder_src_data2 = alu_add_ex ? src_data2_ex : (alu_sub_ex ? (~src_data2_ex + 32'h1) : {`DATA_WIDTH {1'b0}});
assign adder_result = adder_src_data1 + adder_src_data2;


//2: 32b comparator for rs1 is little than rs2 
wire signed [`DATA_WIDTH - 1 : 0] com_src_data1;	//source data 1 for com
wire signed [`DATA_WIDTH - 1 : 0] com_src_data2;	//source data 2 for com
wire signed [`DATA_WIDTH - 1 : 0] com_result;		//result of com
assign com_src_data1 = alu_com_ex ? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign com_src_data2 = alu_com_ex ? src_data2_ex : {`DATA_WIDTH {1'b0}};
assign com_result = (com_src_data1 < com_src_data2);

//3: 32b unsigned comparator for rs1 is little than rs2  
wire [`DATA_WIDTH - 1 : 0] ucom_src_data1;		//source data 1 for ucom
wire [`DATA_WIDTH - 1 : 0] ucom_src_data2;		//source data 2 for ucom
wire [`DATA_WIDTH - 1 : 0] ucom_result;			//result of ucom
assign ucom_src_data1 = alu_ucom_ex ? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign ucom_src_data2 = alu_ucom_ex ? src_data2_ex : {`DATA_WIDTH {1'b0}};
assign ucom_result = (ucom_src_data1 < ucom_src_data2);

//4: and
wire signed [`DATA_WIDTH - 1 : 0] and_result;		//result of and
assign and_result = alu_and_ex ? src_data1_ex & src_data2_ex : {`DATA_WIDTH{1'b0}};

//5: or
wire signed [`DATA_WIDTH - 1 : 0] or_result;		//result of or
assign or_result = alu_or_ex ? src_data1_ex | src_data2_ex : {`DATA_WIDTH{1'b0}};

//6: xor
wire signed [`DATA_WIDTH - 1 : 0] xor_result;		//result of and
assign xor_result = alu_xor_ex ? src_data1_ex ^ src_data2_ex : {`DATA_WIDTH{1'b0}};



//7: shift left logically
//shift amount For shift operation
wire [`SHAMT_WIDTH - 1 : 0] shamt;
assign shamt = src_data2_ex[`SHAMT_WIDTH - 1 : 0];

wire signed [`DATA_WIDTH - 1 : 0] sll_result;		//result of sll
assign sll_result = alu_sll_ex ? src_data1_ex << shamt : {`DATA_WIDTH{1'b0}};

//8: shift right logically
wire signed [`DATA_WIDTH - 1 : 0] srl_result;		//result of srl
assign srl_result = alu_srl_ex ? src_data1_ex >> shamt : {`DATA_WIDTH{1'b0}};

//9: shift right arithmetically
reg signed [`DATA_WIDTH - 1 : 0] sra_result;		//result of sra
/*
assign sra_result = alu_sra_ex ?  ($signed(src_data1_ex)) >>> shamt : {`DATA_WIDTH{1'b0}};
*/
//FIXME seems >>> has no difference from >>, temporarily use case to solve the issue

always @*
begin
	if(alu_sra_ex)
	begin
		case(shamt)
		5'd0: sra_result = {src_data1_ex};
		5'd1: sra_result = {src_data1_ex[31],src_data1_ex[31:1]};
		5'd2: sra_result = {{2{src_data1_ex[31]}},src_data1_ex[31:2]};
		5'd3: sra_result = {{3{src_data1_ex[31]}},src_data1_ex[31:3]};
		5'd4: sra_result = {{4{src_data1_ex[31]}},src_data1_ex[31:4]};
		5'd5: sra_result = {{5{src_data1_ex[31]}},src_data1_ex[31:5]};
		5'd6: sra_result = {{6{src_data1_ex[31]}},src_data1_ex[31:6]};
		5'd7: sra_result = {{7{src_data1_ex[31]}},src_data1_ex[31:7]};
		5'd8: sra_result = {{8{src_data1_ex[31]}},src_data1_ex[31:8]};
		5'd9: sra_result = {{9{src_data1_ex[31]}},src_data1_ex[31:9]};
		5'd10: sra_result = {{10{src_data1_ex[31]}},src_data1_ex[31:10]};
		5'd11: sra_result = {{11{src_data1_ex[31]}},src_data1_ex[31:11]};
		5'd12: sra_result = {{12{src_data1_ex[31]}},src_data1_ex[31:12]};
		5'd13: sra_result = {{13{src_data1_ex[31]}},src_data1_ex[31:13]};
		5'd14: sra_result = {{14{src_data1_ex[31]}},src_data1_ex[31:14]};
		5'd15: sra_result = {{15{src_data1_ex[31]}},src_data1_ex[31:15]};
		5'd16: sra_result = {{16{src_data1_ex[31]}},src_data1_ex[31:16]};
		5'd17: sra_result = {{17{src_data1_ex[31]}},src_data1_ex[31:17]};
		5'd18: sra_result = {{18{src_data1_ex[31]}},src_data1_ex[31:18]};
		5'd19: sra_result = {{19{src_data1_ex[31]}},src_data1_ex[31:19]};
		5'd20: sra_result = {{20{src_data1_ex[31]}},src_data1_ex[31:20]};
		5'd21: sra_result = {{21{src_data1_ex[31]}},src_data1_ex[31:21]};
		5'd22: sra_result = {{22{src_data1_ex[31]}},src_data1_ex[31:22]};
		5'd23: sra_result = {{23{src_data1_ex[31]}},src_data1_ex[31:23]};
		5'd24: sra_result = {{24{src_data1_ex[31]}},src_data1_ex[31:24]};
		5'd25: sra_result = {{25{src_data1_ex[31]}},src_data1_ex[31:25]};
		5'd26: sra_result = {{26{src_data1_ex[31]}},src_data1_ex[31:26]};
		5'd27: sra_result = {{27{src_data1_ex[31]}},src_data1_ex[31:27]};
		5'd28: sra_result = {{28{src_data1_ex[31]}},src_data1_ex[31:28]};
		5'd29: sra_result = {{29{src_data1_ex[31]}},src_data1_ex[31:29]};
		5'd30: sra_result = {{30{src_data1_ex[31]}},src_data1_ex[31:30]};
		5'd31: sra_result = {{31{src_data1_ex[31]}},src_data1_ex[31:31]};
		endcase
	end
	else
	begin
		sra_result = {`DATA_WIDTH{1'b0}};
	end
end

//FIXME
//10: multiply
wire signed [`DATA_WIDTH - 1 : 0] mul_src_data1;	//source data 1 for mul
wire signed [`DATA_WIDTH - 1 : 0] mul_src_data2;	//source data 2 for mul
wire signed [`DATA_WIDTH - 1 : 0] mul_result;		//result of mul
//gated the source operand when mul not used 
assign mul_src_data1 = (alu_mul_ex )? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign mul_src_data2 = alu_mul_ex ? src_data2_ex : {`DATA_WIDTH {1'b0}};
assign mul_result = mul_src_data1 * mul_src_data2;

//FIXME
//11: divider
wire signed [`DATA_WIDTH - 1 : 0] div_src_data1;	//source data 1 for div
wire signed [`DATA_WIDTH - 1 : 0] div_src_data2;	//source data 2 for div
wire signed [`DATA_WIDTH - 1 : 0] div_result;		//result of div
//gated the source operand when div not used 
assign div_src_data1 = (alu_div_ex )? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign div_src_data2 = alu_div_ex ? src_data2_ex : 32'h1; 
assign div_result = div_src_data1/div_src_data2;

//FIXME
//12: unsigned divider
wire [`DATA_WIDTH - 1 : 0] divu_src_data1;	//source data 1 for divu
wire [`DATA_WIDTH - 1 : 0] divu_src_data2;	//source data 2 for divu
wire [`DATA_WIDTH - 1 : 0] divu_result;		//result of divu
//gated the source operand when divu not used 
assign divu_src_data1 = (alu_divu_ex )? src_data1_ex : {`DATA_WIDTH {1'b0}};
assign divu_src_data2 = alu_divu_ex ? src_data2_ex : 32'h1;
assign divu_result = divu_src_data1/divu_src_data2;
//alu result
wire signed [`DATA_WIDTH - 1 : 0] alu_result;

assign alu_result = adder_result | com_result | ucom_result | and_result | or_result |
xor_result | sll_result | srl_result | sra_result | mul_result | div_result | divu_result; 

//bypass the alu when the instruction is jump or lui
assign alu_result_ex = (only_src2_used_ex ? src_data2_ex : alu_result);

//--------------------------------------------------------------------------------//
//propagate result to MEM stage
//--------------------------------------------------------------------------------//
always@(posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		alu_result_mem <= {`DATA_WIDTH{1'b0}};
		ex_valid <= 1'b0;
	end
	else
	begin
	   if(mem_ready)
	   begin
		alu_result_mem <= alu_result_ex;
		ex_valid <= dec_valid & (use_alu_ex | only_src2_used_ex);           
	   end
	end
end

//--------------------------------------------------------------------------------//
//propagate information to MEM stage
//--------------------------------------------------------------------------------//
assign mem_addr_mem = alu_result_mem;
always@(posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		rd_mem <= 32;
		load_mem <= 1'b0;
		store_mem <= 1'b0;
		mem_H_mem <= 1'b0;
		mem_B_mem <= 1'b0;
		mem_U_mem <= 1'b0;
		store_data_mem <= {`DATA_WIDTH{1'b0}};
	end
	else
	begin
	   if(mem_ready)
	   begin
		rd_mem <= rd_ex;
		load_mem <= load_ex;
		store_mem <= store_ex;
		mem_H_mem <= mem_H_ex;
		mem_B_mem <= mem_B_ex;
		mem_U_mem <= mem_U_ex;
		store_data_mem <= store_data_ex;
	   end
	end
end

//Branch condition check
//alu not equal 0 
wire alu_neq0;
assign alu_neq0 = use_alu_ex && (|alu_result);

//alu equal 0 
wire alu_equ0;
assign alu_equ0 = ~alu_neq0;

wire branch_beq_taken;
wire branch_bne_taken;
wire branch_blt_taken;
wire branch_bge_taken;
wire branch_bltu_taken;
wire branch_bgeu_taken;
assign branch_beq_taken = beq_ex & (alu_equ0);
assign branch_bne_taken = bne_ex & (alu_neq0);
assign branch_blt_taken = blt_ex & (com_result);
assign branch_bge_taken = bge_ex & (!com_result);
assign branch_bltu_taken = bltu_ex & (ucom_result);
assign branch_bgeu_taken = bgeu_ex & (!ucom_result);
assign branch_taken_ex = branch_beq_taken | branch_bne_taken | branch_blt_taken | branch_bge_taken | branch_bltu_taken | branch_bgeu_taken;

assign ex_ready = mem_ready;
endmodule
