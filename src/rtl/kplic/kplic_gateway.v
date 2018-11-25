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
// File Name: 		kplic_gateway.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		KPLIC                                    ||
//			individual int gateway			 ||
// History:   							 ||
//===============================================================||

`include "kplic_defines.vh"
module kplic_gateway (

//global signals
input wire kplic_clk,		//kplic clock
input wire kplic_rstn,		//kplic reset, active low

//interface with system int sources
input wire external_int,	//external interrupt input

//interface with kplic_reg
input wire int_enable,		//int enable, enable=1, disable=0
input wire int_type,		//int type, edge_triggered=1, level_sensitive=0
input wire int_completion,	//int completion

//interface with kplic_core
output wire valid_int_req	//valid int request to kplic core
);



//--------------------------------------------------------------//
//1: synchronizer for the external interrupt input
//--------------------------------------------------------------//
reg int_sync1, int_sync2;

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		{int_sync2, int_sync1} <= 2'b0;
	end
	else
	begin
		{int_sync2, int_sync1} <= {int_sync1, external_int};
	end
end

//--------------------------------------------------------------//
//2: edge-triggered int record
//--------------------------------------------------------------//

//record the edge-triggered interrupt pulse while the
//previous one is waiting for completion
reg [3:0] int_counter;
wire inc_int_counter;
wire dec_int_counter;

assign inc_int_counter = int_sync2;
assign dec_int_counter = valid_int_req;

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		int_counter <= 4'h0;
	end
	else
	begin
		if(int_type)		//int_counter is only used for edge-triggered interrupt
		begin
		case ({inc_int_counter, dec_int_counter})
			2'b00: int_counter <= int_counter;
			2'b01: int_counter <= int_counter - 4'h1;
			2'b10: int_counter <= int_counter + 4'h1;
			2'b11: int_counter <= int_counter;
		endcase
		end
		else			//for level-sensitive interrupt, the counter doesn't work 
		begin
			int_counter <= 4'h0;
		end
	end
end

//--------------------------------------------------------------//
//3: state control
//--------------------------------------------------------------//
localparam WAIT_FOR_INT = 1'b0;
localparam WAIT_FOR_COM = 1'b1;

reg state, next_state;

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if(!kplic_rstn)
	begin
		state <= WAIT_FOR_INT;
	end
	else
	begin
		state <= next_state;
	end
end

always @ *
begin
	case(state)
		WAIT_FOR_INT: begin
			if(valid_int_req)
				next_state = WAIT_FOR_COM;
			else
				next_state = WAIT_FOR_INT;
		end
		WAIT_FOR_COM: begin
			if(int_completion)
				next_state = WAIT_FOR_INT;
			else
				next_state = WAIT_FOR_COM;
		end
		default: begin
				next_state = WAIT_FOR_INT;
		end
		endcase
end


//--------------------------------------------------------------//
//4: generate int request to kplic_core
//--------------------------------------------------------------//
wire int_req;
assign int_req = int_type? (int_sync2 || (|int_counter)) : int_sync2;
assign valid_int_req = int_enable && int_req && (state==WAIT_FOR_INT);


endmodule
