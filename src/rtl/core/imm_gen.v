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
// File Name: 		imm_gen.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		immediate generation              	|| 
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//===============================================================

`include "core_defines.vh"

module imm_gen (
input wire [`INSTR_WIDTH - 1 : 0] instr,	//instruction
input wire imm_is_I_type,			//instruction is I type			
input wire imm_is_S_type,			//instruction is S type
input wire imm_is_B_type,			//instruction is B type
input wire imm_is_J_type,			//instruction is J type
input wire imm_is_U_type,			//instruction is U type
output reg [`DATA_WIDTH - 1 : 0] imm		//the immediate
);

//-----------------------------------------------------//
//immediate generated based on the instruction type
//-----------------------------------------------------//

wire [4:0] imm_type;
assign imm_type = {imm_is_I_type,imm_is_S_type,imm_is_B_type,imm_is_J_type,imm_is_U_type};

always @ *
begin
	case (imm_type)
	5'b00001: imm = {instr[31:12],12'b0};								//U type
	5'b00010: imm =	{{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};	 		//J type
	5'b00100: imm = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};	 		//B type
	5'b01000: imm = {{21{instr[31]}},instr[30:25],instr[11:7]};				 	//S type
	5'b10000: imm = {{21{instr[31]}},instr[30:20]}; 						//I type
	default : imm = 32'b0;
	endcase
end

endmodule

