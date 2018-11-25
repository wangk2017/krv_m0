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
// File Name: 		pg_ctrl.v				||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		power gating control logic        	|| 
// History:   							||
//                      2017/11/06 				||
//                      First version				||
//===============================================================

`include "top_defines.vh"
module pg_ctrl (
input wire cpu_clk,
input wire cpu_rstn,
input wire wfi,
input wire kplic_int,

//clock-gating for light sleep
output wire cpu_clk_g,

//power-gating for deep sleep
output reg mother_sleep,
output reg daughter_sleep,
output reg isolation_on,
output reg pg_resetn,
output reg save,
output reg restore
);


//Logic Start

//synchronize the external interrupt from KPLIC
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


//--------------------------//
//Light Sleep Mode
//--------------------------//
reg light_sleep;
wire clock_on;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		light_sleep <= 1'b0;
	end
	else
	begin
		if(kplic_int_sync2 || clock_on)
		begin
			light_sleep <= 1'b0;
		end
		else if(wfi)
		begin
			light_sleep <= 1'b1;
		end
		else
		begin
			light_sleep <= light_sleep;
		end
	end
end


//clock-gating cell
//replace with the approriate clock-gating cell from the vendor library
/*
clock_gating_cell cpu_clk_gater (
.test		(test),
.EN		(!light_sleep),
.clock_in	(cpu_clk),
.clock_g	(cpu_clk_g)
);
*/

//`ifdef SIM
assign	cpu_clk_g = (~light_sleep) & cpu_clk;
//`endif

//--------------------------//
//Deep Sleep Mode
//--------------------------//

//light sleep counter 
//maximum count : 18-minute
reg [39:0] light_sleep_counter;	
wire threshold_reached;

assign threshold_reached = (light_sleep_counter == `THRESHOLD_ENTER_DEEP_SLEEP);

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		light_sleep_counter <= 40'h0;
	end
	else
	begin
		if(kplic_int_sync2 || save)
		begin
			light_sleep_counter <= 40'h0;
		end
		else if (threshold_reached)	//stop the counter when the threshold reached
		begin
			light_sleep_counter <= light_sleep_counter;
		end
		else if(light_sleep)
		begin
			light_sleep_counter <= light_sleep_counter + 40'h1;
		end
		else
		begin
			light_sleep_counter <= 40'h0;
		end
	end
end

//pg_state 
parameter IDLE 		= 4'b0000;
parameter SAVE 		= 4'b0001;
parameter ISO_ON	= 4'b0011;
parameter MOTHER_SLEEP  = 4'b0010;
parameter DAUGHTER_SLEEP= 4'b0110;
parameter MOTHER_WAKE   = 4'b0111;
parameter RESET		= 4'b0101;
parameter RESTORE	= 4'b0100;
parameter CLK_ON_ISO_OFF= 4'b1100;

reg [3:0] pg_state, next_pg_state;
reg [1:0] save_cnt;
reg [1:0] mother_sleep_cnt;
reg [1:0] mother_wake_cnt;
reg [3:0] reset_cnt;
reg [1:0] restore_cnt;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		pg_state <= IDLE;
	end
	else
	begin
		pg_state <= next_pg_state;
	end
end

always @ *
begin
	case(pg_state)
		IDLE: begin
			if(threshold_reached)
			begin
				next_pg_state = SAVE;
			end
			else
			begin
				next_pg_state = IDLE;
			end
		end
		SAVE: begin
			if(kplic_int_sync2)
			begin
				next_pg_state = IDLE;
			end
			else if(save_cnt == `SAVE_PERIOD)//assert the save signal for a certain period to make sure the right value sampled
			begin
				next_pg_state = ISO_ON;
			end
			else
			begin
				next_pg_state = SAVE;
			end
		end
		ISO_ON: begin
			if(kplic_int_sync2)
			begin
				next_pg_state = CLK_ON_ISO_OFF;
			end
			else
			begin
				next_pg_state = MOTHER_SLEEP;
			end
		end
		MOTHER_SLEEP: begin
			if(kplic_int_sync2)
			begin
				next_pg_state = RESET;
			end
			else if (mother_sleep_cnt == `MOTHER_SLEEP_PERIOD)
			begin
				next_pg_state = DAUGHTER_SLEEP;
			end
			else
			begin
				next_pg_state = MOTHER_SLEEP;
			end
		end
		DAUGHTER_SLEEP: begin
			if(kplic_int_sync2)
			begin
				next_pg_state = MOTHER_WAKE;
			end
			else
			begin
				next_pg_state = DAUGHTER_SLEEP;
			end
		end
		MOTHER_WAKE: begin
			if(mother_wake_cnt == `MOTHER_WAKE_PERIOD)
			begin
				next_pg_state = RESET;       
			end
			else
			begin
				next_pg_state = MOTHER_WAKE;
			end
		end
		RESET: begin
			if (reset_cnt == `PG_RESET_PERIOD)
			begin
				next_pg_state = RESTORE;
			end
			else
			begin
				next_pg_state = RESET;
			end
		end
		RESTORE: begin
			if(restore_cnt == `RESTORE_PERIOD)
			begin
				next_pg_state = CLK_ON_ISO_OFF;
			end
			else
			begin
				next_pg_state = RESTORE;
			end
		end
		CLK_ON_ISO_OFF: begin
				next_pg_state = IDLE;
		end
		default: begin
				next_pg_state = IDLE;
		end
	endcase
end

//save
wire save_i;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		save_cnt <= 2'h0;
	end
	else
	begin
		if(save_cnt == `SAVE_PERIOD)
		begin
			save_cnt <= 2'h0;
		end
		else if(save_i)
		begin
			save_cnt <= save_cnt + 2'h1;
		end
		else
		begin
			save_cnt <= 2'h0;
		end
	end
end

assign save_i = (next_pg_state == SAVE);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		save <= 1'b0;
	end
	else
	begin
		save <= save_i;
	end
end


//isolation

wire isolation_on_i;
assign isolation_on_i = (next_pg_state != IDLE) && (next_pg_state != CLK_ON_ISO_OFF) && (next_pg_state != SAVE);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		isolation_on <= 1'b0;
	end
	else
	begin
		isolation_on <= isolation_on_i;
	end
end



//deepsleep
//
wire mother_sleep_i;
wire daughter_sleep_i;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mother_sleep_cnt <= 2'h0;
	end
	else
	begin
		if(mother_sleep_cnt == `MOTHER_SLEEP_PERIOD)
		begin
			mother_sleep_cnt <= 2'h0;
		end
		else if(mother_sleep_i)
		begin
			mother_sleep_cnt <= mother_sleep_cnt + 2'h1;
		end
		else
		begin
			mother_sleep_cnt <= 2'h0;
		end
	end
end

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mother_wake_cnt <= 2'h0;
	end
	else
	begin
		if(mother_wake_cnt == `MOTHER_WAKE_PERIOD)
		begin
			mother_wake_cnt <= 2'h0;
		end
		else if(next_pg_state == MOTHER_WAKE)
		begin
			mother_wake_cnt <= mother_wake_cnt + 2'h1;
		end
		else
		begin
			mother_wake_cnt <= 2'h0;
		end
	end
end
assign mother_sleep_i = (next_pg_state == MOTHER_SLEEP) || (next_pg_state == DAUGHTER_SLEEP);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mother_sleep <= 1'b0;
	end
	else
	begin
		mother_sleep <= mother_sleep_i;
	end
end

assign daughter_sleep_i = (next_pg_state == DAUGHTER_SLEEP) || (next_pg_state == MOTHER_WAKE);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		daughter_sleep <= 1'b0;
	end
	else
	begin
		daughter_sleep <= daughter_sleep_i;
	end
end



//reset
wire reset_i;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		reset_cnt <= 3'h0;
	end
	else
	begin
		if(reset_cnt == `PG_RESET_PERIOD)
		begin
			reset_cnt <= 3'h0;
		end
		else if(reset_i)
		begin
			reset_cnt <= reset_cnt + 3'h1;
		end
		else
		begin
			reset_cnt <= 3'h0;
		end
	end
end

assign reset_i = (next_pg_state == RESET);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		pg_resetn <= 1'b1;
	end
	else
	begin
		pg_resetn <= !reset_i;
	end
end

//restore
wire restore_i;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		restore_cnt <= 2'h0;
	end
	else
	begin
		if(restore_cnt == `RESTORE_PERIOD)
		begin
			restore_cnt <= 2'h0;
		end
		else if(restore_i)
		begin
			restore_cnt <= restore_cnt + 2'h1;
		end
		else
		begin
			restore_cnt <= 2'h0;
		end
	end
end

assign restore_i = (next_pg_state == RESTORE);
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		restore <= 1'b0;
	end
	else
	begin
		restore <= restore_i;
	end
end

//clock on
assign clock_on = (pg_state == CLK_ON_ISO_OFF);

endmodule
