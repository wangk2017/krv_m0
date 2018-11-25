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
// File Name: 		kplic_regs.v				 ||
// Author:    		Kitty Wang				 ||
// Description:   						 ||
//	      		kplic registers                          ||
// History:   							 ||
//                      2017/10/18 				 ||
//                      First version				 ||
//===============================================================||

`include "kplic_defines.vh"
module kplic_regs (
//global signals
input wire kplic_clk,						//KPLIC clock
input wire kplic_rstn,						//KPLIC reset, active low

//interface with AHB2regbus
input wire valid_reg_access,					//valid reg access
input wire [11:0] addr,						//reg access address
input wire rd_wr,						//reg access cmd, wr=1; rd=0
input wire [`KPLIC_DATA_WIDTH - 1 : 0] write_data,		//reg write data
output wire [`KPLIC_DATA_WIDTH - 1 : 0] read_data,		//reg read data

//interface with kplic_gateway
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_type,		//int type, edge_triggered=1, level_sensitive=0
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_enable,		//int enable, enabled=1, disabled=0
output reg [`INT_NUM - 1  : 0] int_completion,			//int completion

//interface with kplic_core
input wire [`KPLIC_DATA_WIDTH - 1 : 0] int_pending_status,	//int_pending status
input wire [`INT_WIDTH - 1 : 0] mppi,			//the max priority pending interrupt
output reg [`KPLIC_DATA_WIDTH - 1 : 0] target_priority,		//target priority
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group0,	//int priority for int3~int0
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group1,	//int priority for int7~int4
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group2,	//int priority for int11~int8
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group3,	//int priority for int17~int12
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group4,	//int priority for int21~int16
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group5,	//int priority for int23~int20
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group6,	//int priority for int27~int24
output reg [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group7,	//int priority for int31~int28
output wire int_claim						//int claim
);


//-------------------------------------------------------------------//
//1: Register address decode
//-------------------------------------------------------------------//
wire int_type_sel;
wire int_enable_sel;
wire int_pending_status_sel;
wire target_priority_sel;
wire int_completion_sel;
wire mppi_sel;
wire int_priority_group0_sel;
wire int_priority_group1_sel;
wire int_priority_group2_sel;
wire int_priority_group3_sel;
wire int_priority_group4_sel;
wire int_priority_group5_sel;
wire int_priority_group6_sel;
wire int_priority_group7_sel;

assign int_type_sel = (addr == `KPLIC_INT_TYPE_OFFSET);
assign int_enable_sel = (addr == `KPLIC_INT_ENABLE_OFFSET);
assign int_pending_status_sel = (addr == `KPLIC_INT_PENDING_STATUS_OFFSET);
assign target_priority_sel = (addr == `KPLIC_TARGET_PRIORITY_OFFSET);
assign int_completion_sel =(addr == `KPLIC_INT_COMPLETION_OFFSET); 
assign mppi_sel = (addr == `KPLIC_MPPI_OFFSET);
assign int_priority_group0_sel = (addr == `KPLIC_INT_PRIORITY_GROUP0_OFFSET);
assign int_priority_group1_sel = (addr == `KPLIC_INT_PRIORITY_GROUP1_OFFSET);
assign int_priority_group2_sel = (addr == `KPLIC_INT_PRIORITY_GROUP2_OFFSET);
assign int_priority_group3_sel = (addr == `KPLIC_INT_PRIORITY_GROUP3_OFFSET);
assign int_priority_group4_sel = (addr == `KPLIC_INT_PRIORITY_GROUP4_OFFSET);
assign int_priority_group5_sel = (addr == `KPLIC_INT_PRIORITY_GROUP5_OFFSET);
assign int_priority_group6_sel = (addr == `KPLIC_INT_PRIORITY_GROUP6_OFFSET);
assign int_priority_group7_sel = (addr == `KPLIC_INT_PRIORITY_GROUP7_OFFSET);

//-------------------------------------------------------------------//
//2: reg read / write
//-------------------------------------------------------------------//
wire valid_reg_read;
wire valid_reg_write;
assign valid_reg_read = valid_reg_access & !rd_wr;
assign valid_reg_write = valid_reg_access & rd_wr;

//individual int type : 0--level sensitive; 1--edge triggered
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_type <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_type_sel && valid_reg_write)
		begin
			int_type <= write_data;
		end
		else
		begin
			int_type <= int_type;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_type_read_data;
assign int_type_read_data = int_type_sel ? int_type : {`KPLIC_DATA_WIDTH{1'b0}};

//individual int enable : 0--disabled; 1--enabled
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_enable <= {`KPLIC_DATA_WIDTH{1'b1}};
	end
	else
	begin
		if (int_enable_sel && valid_reg_write)
		begin
			int_enable <= write_data;
		end
		else
		begin
			int_enable <= int_enable;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_enable_read_data;
assign int_enable_read_data = int_enable_sel ? int_enable : {`KPLIC_DATA_WIDTH{1'b0}};


//int_pending_status
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_pending_status_read_data;
assign int_pending_status_read_data = int_pending_status_sel ? int_pending_status : {`KPLIC_DATA_WIDTH{1'b0}};

//target priority                                
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		target_priority <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (target_priority_sel && valid_reg_write)
		begin
			target_priority <= write_data;
		end
		else
		begin
			target_priority <= target_priority;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] target_priority_read_data;
assign target_priority_read_data = target_priority_sel ? target_priority : {`KPLIC_DATA_WIDTH{1'b0}};

//mppi
wire [`KPLIC_DATA_WIDTH - 1 : 0] mppi_read_data;
assign mppi_read_data = mppi_sel ? {27'h0,mppi} : {`KPLIC_DATA_WIDTH{1'b0}};

//completion
reg valid_completion;
//int completion                                             
reg [`INT_WIDTH - 1 : 0] completion_intid;
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		completion_intid <= {`INT_WIDTH{1'b0}};
	end
	else
	begin
		if (valid_reg_write && int_completion_sel)
		begin
			completion_intid <= write_data[`INT_WIDTH - 1 : 0];
		end
		else
		begin
			completion_intid <= completion_intid;
		end
	end
end

always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		valid_completion <= 1'b0;
	end
	else
	begin
		if(valid_reg_write && int_completion_sel && (write_data[`INT_WIDTH - 1 : 0] < `INT_NUM))
		begin
			valid_completion <= 1'b1;
		end
		else
		begin
			valid_completion <= 1'b0;
		end
	end
end

integer i;

always @ *
begin
	for (i=0; i<`INT_NUM; i=i+1)
	begin
		if(valid_completion && (i==completion_intid))
			int_completion[i] = 1'b1;
		else
			int_completion[i] = 1'b0; 
	end
end

//int_priority_group0                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group0 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group0_sel && valid_reg_write)
		begin
			int_priority_group0 <= write_data;
		end
		else
		begin
			int_priority_group0 <= int_priority_group0;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group0_read_data;
assign int_priority_group0_read_data = int_priority_group0_sel ? int_priority_group0 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group1                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group1 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group1_sel && valid_reg_write)
		begin
			int_priority_group1 <= write_data;
		end
		else
		begin
			int_priority_group1 <= int_priority_group1;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group1_read_data;
assign int_priority_group1_read_data = int_priority_group1_sel ? int_priority_group1 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group2                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group2 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group2_sel && valid_reg_write)
		begin
			int_priority_group2 <= write_data;
		end
		else
		begin
			int_priority_group2 <= int_priority_group2;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group2_read_data;
assign int_priority_group2_read_data = int_priority_group2_sel ? int_priority_group2 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group3                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group3 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group3_sel && valid_reg_write)
		begin
			int_priority_group3 <= write_data;
		end
		else
		begin
			int_priority_group3 <= int_priority_group3;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group3_read_data;
assign int_priority_group3_read_data = int_priority_group3_sel ? int_priority_group3 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group4                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group4 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group4_sel && valid_reg_write)
		begin
			int_priority_group4 <= write_data;
		end
		else
		begin
			int_priority_group4 <= int_priority_group4;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group4_read_data;
assign int_priority_group4_read_data = int_priority_group4_sel ? int_priority_group4 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group5                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group5 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group5_sel && valid_reg_write)
		begin
			int_priority_group5 <= write_data;
		end
		else
		begin
			int_priority_group5 <= int_priority_group5;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group5_read_data;
assign int_priority_group5_read_data = int_priority_group5_sel ? int_priority_group5 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group6                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group6 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group6_sel && valid_reg_write)
		begin
			int_priority_group6 <= write_data;
		end
		else
		begin
			int_priority_group6 <= int_priority_group6;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group6_read_data;
assign int_priority_group6_read_data = int_priority_group6_sel ? int_priority_group6 : {`KPLIC_DATA_WIDTH{1'b0}};

//int_priority_group7                               
always @ (posedge kplic_clk or negedge kplic_rstn)
begin
	if (!kplic_rstn)
	begin
		int_priority_group7 <= {`KPLIC_DATA_WIDTH{1'b0}};
	end
	else
	begin
		if (int_priority_group7_sel && valid_reg_write)
		begin
			int_priority_group7 <= write_data;
		end
		else
		begin
			int_priority_group7 <= int_priority_group7;
		end
	end
end
wire [`KPLIC_DATA_WIDTH - 1 : 0] int_priority_group7_read_data;
assign int_priority_group7_read_data = int_priority_group7_sel ? int_priority_group7 : {`KPLIC_DATA_WIDTH{1'b0}};


//read data
assign read_data = {32{valid_reg_read}} &
		       (int_type_read_data 		|
			int_enable_read_data 		|
			int_pending_status_read_data 	|
			target_priority_read_data 	|
			mppi_read_data 			|
			int_priority_group0_read_data 	|
			int_priority_group1_read_data 	|
			int_priority_group2_read_data 	|
			int_priority_group3_read_data 	|
			int_priority_group4_read_data 	|
			int_priority_group5_read_data 	|
			int_priority_group6_read_data 	|
			int_priority_group7_read_data) ;

assign int_claim = valid_reg_read & mppi_sel;

endmodule
