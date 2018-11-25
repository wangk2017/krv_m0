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

//===============================================================||
// File Name: 		kplic_core.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		kplic core                               ||
// History:   							 ||
//===============================================================||

`include "kplic_defines.vh"
module kplic_core (
//global signals
input wire kplic_clk,						//KPLIC clock
input wire kplic_rstn,						//KPLIC reset, active low

//interface with kplic_gateway
input wire [`INT_NUM - 1 : 0] valid_int_req,			//valid interrupt request

//interface with kplic_reg
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_pending_status,	//int_pending status
output reg [`INT_WIDTH - 1 : 0] mppi,			//the max priority pending interrupt
input wire [`KPLIC_DATA_WIDTH - 1 : 0] target_priority,		//target priority
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group0,	//int priority for int3~int0
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group1,	//int priority for int7~int4
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group2,	//int priority for int11~int8
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group3,	//int priority for int17~int12
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group4,	//int priority for int21~int16
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group5,	//int priority for int23~int20
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group6,	//int priority for int27~int24
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group7,	//int priority for int31~int28
input wire int_claim,						//int claim

//interface with core
output reg int_to_target					//interrupt request to target core
);


//----------------------------------------------------------------//
//1: int_pending_status register
//----------------------------------------------------------------//

integer i;
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		int_pending_status <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_claim)
		begin
			int_pending_status[mppi] <= 1'b0; 
		end
		else
		begin
			for (i=0; i<`INT_NUM; i=i+1)
			begin
				if (valid_int_req[i])
				begin
					int_pending_status[i] <= 1'b1; 
				end
				else
				begin
					int_pending_status[i] <= int_pending_status[i];
				end
			end
	end
	end
end

//----------------------------------------------------------------//
//2: individual int priority
//----------------------------------------------------------------//
wire [8*`INT_NUM - 1 : 0] all_int_priority;
assign all_int_priority = {int_priority_group7,int_priority_group6, int_priority_group5, int_priority_group4, int_priority_group3, int_priority_group2, int_priority_group1, int_priority_group0};

wire [7:0] int_priority [`INT_NUM - 1 : 0];

genvar int_index;
generate
	for (int_index = 0; int_index < `INT_NUM; int_index = int_index + 1)
	begin: INT_PRI
		assign int_priority[int_index] = all_int_priority[(8*int_index+7) : (8*int_index)];
	end
endgenerate

//----------------------------------------------------------------//
//3: pending interrupt priority
//----------------------------------------------------------------//
reg [7:0] valid_int_priority [`INT_NUM - 1 : 0];

always @ *
begin
	for (i=0; i<`INT_NUM; i=i+1)
	begin
		if(int_pending_status[i] | valid_int_req[i])
		valid_int_priority[i] = int_priority[i];
		else
		valid_int_priority[i] = 0;
	end
end


//----------------------------------------------------------------//
//4: find the max priority pending interrupt (mppi)
//----------------------------------------------------------------//


//krv-m support 32 interrupts, 5 rounds are needed to find the max
//priority pending interrupt

integer r1_index;
integer r2_index;
integer r3_index;
integer r4_index;
integer r5_index;

parameter ROUND1_NUM = `INT_NUM/2	;	//ROUND1_NUM=16
parameter ROUND2_NUM = ROUND1_NUM/2	;	//ROUND2_NUM=8
parameter ROUND3_NUM = ROUND2_NUM/2	;	//ROUND3_NUM=4
parameter ROUND4_NUM = ROUND3_NUM/2	;	//ROUND4_NUM=2
parameter ROUND5_NUM = ROUND4_NUM/2	;	//ROUND5_NUM=1

reg [`INT_WIDTH - 1 : 0] round1_win [ROUND1_NUM - 1 : 0];
reg [`INT_WIDTH - 1 : 0] round2_win [ROUND2_NUM - 1 : 0];
reg [`INT_WIDTH - 1 : 0] round3_win [ROUND3_NUM - 1 : 0];
reg [`INT_WIDTH - 1 : 0] round4_win [ROUND4_NUM - 1 : 0];
reg [`INT_WIDTH - 1 : 0] round5_win [ROUND5_NUM - 1 : 0];

//round1 compare
always @ *
begin
	for (r1_index = 0; r1_index < ROUND1_NUM; r1_index = r1_index+1)
		round1_win[r1_index] = (valid_int_priority[2*r1_index + 1] > valid_int_priority[2*r1_index])? (2*r1_index + 1) : (2*r1_index) ;
end

//round2 compare
always @ *
begin
	for (r2_index = 0; r2_index < ROUND2_NUM; r2_index = r2_index+1)
		round2_win[r2_index] = (valid_int_priority[round1_win[2*r2_index + 1]]> valid_int_priority[round1_win[2*r2_index]])? round1_win[2*r2_index + 1] : round1_win[2*r2_index];
end

//round3 compare
always @ *
begin
	for (r3_index = 0; r3_index < ROUND3_NUM; r3_index = r3_index+1)
		round3_win[r3_index] = (valid_int_priority[round2_win[2*r3_index + 1]] > valid_int_priority[round2_win[2*r3_index]])? (round2_win[2*r3_index + 1]) : (round2_win[2*r3_index]) ;
end

//round4 compare
always @ *
begin
	for (r4_index = 0; r4_index < ROUND4_NUM; r4_index = r4_index+1)
		round4_win[r4_index] = (valid_int_priority[round3_win[2*r4_index + 1]] > valid_int_priority[round3_win[2*r4_index]])? (round3_win[2*r4_index + 1]) : (round3_win[2*r4_index]) ;
end

//round5 compare
always @ *
begin
	for (r5_index = 0; r5_index < ROUND5_NUM; r5_index = r5_index+1)
		round5_win[r5_index] = (valid_int_priority[round4_win[2*r5_index + 1]] > valid_int_priority[round4_win[2*r5_index]])? (round4_win[2*r5_index + 1]) : (round4_win[2*r5_index]) ;
end

wire [`INT_WIDTH - 1 : 0] final_win;
assign final_win = round5_win[0];

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		mppi <= {`INT_WIDTH{1'b0}};
	end
	else
	begin
		mppi <= final_win;
	end
end

//----------------------------------------------------------------//
//5: interrupt notification to target
//----------------------------------------------------------------//
wire interrupt_level;
assign interrupt_level = valid_int_priority[final_win] > target_priority;

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		int_to_target <= 1'b0;
	end
	else
	begin
		int_to_target <= interrupt_level;
	end
end

endmodule
