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
// File Name: 		mcsr.v					||
// Author:    		Kitty Wang				||
// Description: 						||
//	      		control and status registers      	|| 
//	      		@machine level
// History:   							||
//                      2017/9/26 				||
//                      First version				||
//                      2017/11/30				||
//                      Add TCM_CTRL/DTCM_START_ADDR		||
//===============================================================

`include "top_defines.vh"
`include "core_defines.vh"

module mcsr (
//global signals
input wire cpu_clk,					//cpu clock
input wire cpu_rstn,					//cpu reset, active low

//interface with dec for CSR access
input  wire [`INSTR_WIDTH - 1 : 0] instr_dec,		//instruction
input wire [11:0] csr_addr,				//csr access address
input wire mcsr_rd,					//mcsr read
input wire mcsr_wr,					//mcsr write
input wire valid_mcsr_rd,				//valid mcsr read
input wire valid_mcsr_wr,				//valid mcsr write
input wire mcsr_set,					//mcsr set
input wire mcsr_clr,					//mcsr clear
input wire [`DATA_WIDTH - 1 : 0] write_data,		//mcsr write data
output wire [`DATA_WIDTH - 1 : 0] read_data,		//mcsr read data

//interface with trap_ctrl
input wire meip,					//meip 
input wire mtip,					//mtip 
input wire [`ADDR_WIDTH - 1 : 0] mepc,			//mepc
input wire [`DATA_WIDTH - 1 : 0] mcause,		//mcause
input wire [`DATA_WIDTH - 1 : 0] mtval,			//mtval
input wire valid_interrupt,				//valid interrupt
input wire mret,					//mret
output wire mepc_sel,					//mepc address
output wire mcause_sel,					//mcause address
output wire mtval_sel,					//mtval address
output wire csr_illegal_access,				//illegal access
output wire [`INSTR_WIDTH - 1 : 0] illegal_instr,	//illegal instruction
output reg meie,					//meie
output reg mtie,					//mtie
output reg mstatus_mie,					//mstatus mie
output reg [1:0] mtvec_mode,				//mtvec mode
output reg [31:0] mtvec_base,				//mtvec base

//interface with mem_ctrl
output reg dtcm_en,					//dtcm enable
output reg [`ADDR_WIDTH - 1 : 0] dtcm_start_addr	//dtcm start address

);

//------------------------------------------------//
//Register address decode
//------------------------------------------------//
wire mvendorid_sel;
wire marchid_sel;
wire mimpid_sel;
wire mhartid_sel;
wire mstatus_sel;
wire misa_sel;
wire mie_sel;
wire mtvec_sel;
wire mip_sel;
wire tcm_ctrl_sel;
wire dtcm_start_addr_sel;

assign mvendorid_sel 	= (csr_addr == `MVENDORID_ADDR);
assign marchid_sel 	= (csr_addr == `MARCHID_ADDR);
assign mimpid_sel 	= (csr_addr == `MIMPID_ADDR);
assign mhartid_sel 	= (csr_addr == `MHARTID_ADDR);
assign mstatus_sel 	= (csr_addr == `MSTATUS_ADDR);
assign misa_sel 	= (csr_addr == `MISA_ADDR);
assign mie_sel 		= (csr_addr == `MIE_ADDR);
assign mtvec_sel 	= (csr_addr == `MTVEC_ADDR);
assign mepc_sel 	= (csr_addr == `MEPC_ADDR);
assign mcause_sel 	= (csr_addr == `MCAUSE_ADDR);
assign mtval_sel 	= (csr_addr == `MTVAL_ADDR);
assign mip_sel 		= (csr_addr == `MIP_ADDR);
assign tcm_ctrl_sel	= (csr_addr == `TCM_CTRL_ADDR);
assign dtcm_start_addr_sel	= (csr_addr == `DTCM_START_ADDR_ADDR);
//some dummy regs 
wire stvec_sel		= (csr_addr == `STVEC_ADDR);
wire satp_sel		= (csr_addr == `SATP_ADDR);
wire pmpcfg0_sel		= (csr_addr == `PMPCFG0_ADDR);
wire pmpaddr0_sel		= (csr_addr == `PMPADDR0_ADDR);
wire medeleg_sel		= (csr_addr == `MEDELEG_ADDR);
wire mideleg_sel		= (csr_addr == `MIDELEG_ADDR);

//------------------------------------------------//
//mcsr access check
//------------------------------------------------//

//1: access non-exist csr exception check
wire [`MCSR_N - 1 : 0] mcsr_sel;
assign mcsr_sel = {mvendorid_sel,marchid_sel,mimpid_sel,mhartid_sel,mstatus_sel,misa_sel,mie_sel,mtvec_sel,mepc_sel,mcause_sel,mtval_sel,mip_sel,tcm_ctrl_sel,dtcm_start_addr_sel,stvec_sel, satp_sel, pmpcfg0_sel, pmpaddr0_sel, medeleg_sel, mideleg_sel};
wire non_exist_csr_access;
assign non_exist_csr_access = (mcsr_rd | mcsr_wr) & (!(|mcsr_sel));
//2: write read-only csr exception check
wire wr_ro_csr;
assign wr_ro_csr = (mvendorid_sel | marchid_sel | mimpid_sel | mhartid_sel) & mcsr_wr;

//generate csr access exception and record the illegal instruction
assign csr_illegal_access = non_exist_csr_access | wr_ro_csr;
assign illegal_instr = csr_illegal_access ? instr_dec : {`INSTR_WIDTH{1'b0}};


//------------------------------------------------//
//mcsr read/write
//------------------------------------------------//

//1: misa -- Machine ISA Register
//default value: 0x4000_0100
reg [25:0] misa;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		misa <= 26'h000_0100;
	end
	else
	begin
		if (misa_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				misa <= misa | write_data[25:0];
			end
			else if(mcsr_clr)
			begin
				misa <= misa & (~write_data[25:0]);
			end
			else
			begin
				misa <= write_data[25:0];
			end
		end
		else
		begin
			misa <= misa;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] misa_rd_data;
assign misa_rd_data = (misa_sel)? {2'h1,4'h0,misa} : {`DATA_WIDTH{1'b0}};

//2: mvendorid -- Machine Vendor ID Register
// read only
wire [`DATA_WIDTH - 1 : 0] mvendorid_rd_data;
assign mvendorid_rd_data = {`DATA_WIDTH{1'b0}};	//non-commercial

//3: marchid -- Machine Architecture ID Register
// read only
// value wait for allocation by RISC-V Foundation
wire [`DATA_WIDTH - 1 : 0] marchid_rd_data;
assign marchid_rd_data = (marchid_sel) ? {1'h0,31'h0} : {`DATA_WIDTH{1'b0}}; //FIXME

//4: mimpid -- Machine Implementation ID Register
// read only
wire [`DATA_WIDTH - 1 : 0] mimpid_rd_data;
assign mimpid_rd_data = (mimpid_sel) ? {4'h1,28'h0} : {`DATA_WIDTH{1'b0}}; //M-serial

//5: mhartid -- Hart ID Register
// read only
wire [`DATA_WIDTH - 1 : 0] mhartid_rd_data;
assign mhartid_rd_data = {`DATA_WIDTH{1'b0}};

//6: mstatus -- Machine Status Register
// only MIE bit implemented for global interrupt enable
reg is_int;
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		is_int <= 1'b0;
	end
	else
	begin
		if(mret)
		begin
			is_int <= 1'b0;
		end
		else if(valid_interrupt)
		begin
			is_int <= 1'b1;
		end
	end
end

reg mstatus_mpie;

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mstatus_mpie <= 1'b0;
	end
	else
	begin
		if(mret && is_int)
		begin
			mstatus_mpie <= 1'b1;
		end
		else if(valid_interrupt)
		begin
			mstatus_mpie <= mstatus_mie;
		end
		else if(mstatus_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				mstatus_mpie <= mstatus_mpie | write_data[7];
			end
			else if(mcsr_clr)
			begin
				mstatus_mpie <= mstatus_mpie & (~write_data[7]);
			end
			else
			begin
				mstatus_mpie <= write_data[7];
			end
		end

	end
end

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mstatus_mie <= 1'b0;
	end
	else
	begin
		if(mret && is_int)
		begin
			mstatus_mie <= mstatus_mpie; //take the mpie after mret
		end
		else if(valid_interrupt)
		begin
			mstatus_mie <= 1'b0; //auto clear the mie after an valid interrupt taken
		end
		else if(mstatus_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				mstatus_mie <= mstatus_mie | write_data[3];
			end
			else if(mcsr_clr)
			begin
				mstatus_mie <= mstatus_mie & (~write_data[3]);
			end
			else
			begin
				mstatus_mie <= write_data[3];
			end
		end
		else
		begin
			mstatus_mie <= mstatus_mie;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] mstatus_rd_data;
assign mstatus_rd_data = (mstatus_sel) ? {24'h0,mstatus_mpie,3'h0,mstatus_mie,3'h0} : {`DATA_WIDTH{1'b0}}; 


//7: mtvec -- Machine Trap-Vector Base-Address Register

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		mtvec_mode <= 2'h0;
		mtvec_base <= `VECTOR_ENTRY;
	end
	else
	begin
		if(mtvec_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				mtvec_mode <= mtvec_mode | write_data[1:0];
				mtvec_base <= mtvec_base | write_data[31:2];
			end
			else if(mcsr_clr)
			begin
				mtvec_mode <= mtvec_mode & (~write_data[1:0]);
				mtvec_base <= mtvec_base & (~write_data[31:2]);
			end
			else
			begin
				mtvec_mode <= write_data[1:0];
				mtvec_base <= {write_data[31:2],2'h0};
			end
		end
		else
		begin
			mtvec_mode <= mtvec_mode;
			mtvec_base <= mtvec_base;
		end
	end
end
wire [`DATA_WIDTH - 1 : 0] mtvec_rd_data;
assign mtvec_rd_data = (mtvec_sel) ? {mtvec_base[31:2], mtvec_mode} : {`DATA_WIDTH{1'b0}}; 

//8: mip -- Machine Interrupt Pending Register
// only MEIP for external interrupt implemented

wire [`DATA_WIDTH - 1 : 0] mip_rd_data;
//assign mip_rd_data = (mip_sel) ? {20'h0, meip,3'h0, 1'b0, 7'h0} : {`DATA_WIDTH{1'b0}}; 
assign mip_rd_data = (mip_sel) ? {20'h0, meip,3'h0, mtip, 7'h0} : {`DATA_WIDTH{1'b0}}; 

//9: mie -- Machine Interrupt Enable  Register
//only MEIE for external interrupt implemented

always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		meie <= 1'b1;
		mtie <= 1'b1;
	end
	else
	begin
		if(mie_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				meie <= meie | write_data[11];
				mtie <= mtie | write_data[7];
			end
			else if(mcsr_clr)
			begin
				meie <= meie & (~write_data[11]);
				mtie <= mtie & (~write_data[7]);
			end
			else
			begin
				meie <= write_data[11];
				mtie <= write_data[7];
			end
		end
		else
		begin
			meie <= meie;
			mtie <= mtie;
		end
	end
end


wire [`DATA_WIDTH - 1 : 0] mie_rd_data;
assign mie_rd_data = (mie_sel) ? {20'h0, meie, 3'h0, mtie, 7'h0} : {`DATA_WIDTH{1'b0}}; 
//assign mie_rd_data = (mie_sel) ? {20'h0, meie, 3'h0, 1'b0, 7'h0} : {`DATA_WIDTH{1'b0}}; 

//10: mepc -- Machine Exception Program Counter
//maintained in the trap_ctrl block

wire [`DATA_WIDTH - 1 : 0] mepc_rd_data;
assign mepc_rd_data = (mepc_sel) ? mepc : {`DATA_WIDTH{1'b0}}; 

//11: mcause -- Machine Cause Register
//maintained in the trap_ctrl block

wire [`DATA_WIDTH - 1 : 0] mcause_rd_data;
assign mcause_rd_data = (mcause_sel) ? mcause : {`DATA_WIDTH{1'b0}}; 

//12: mtval -- Machine Trap Value Register
//maintained in the trap_ctrl block

wire [`DATA_WIDTH - 1 : 0] mtval_rd_data;
assign mtval_rd_data = (mtval_sel) ? mtval : {`DATA_WIDTH{1'b0}}; 

//13: dtcm_start_addr
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		dtcm_start_addr <= `DTCM_START_ADDR;
	end
	else
	begin
		if (dtcm_start_addr_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				dtcm_start_addr <= dtcm_start_addr | write_data;
			end
			else if(mcsr_clr)
			begin
				dtcm_start_addr <= dtcm_start_addr & (~write_data);
			end
			else
			begin
				dtcm_start_addr <= write_data;
			end
		end
		else
		begin
			dtcm_start_addr <= dtcm_start_addr;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] dtcm_start_addr_rd_data;
assign dtcm_start_addr_rd_data = (dtcm_start_addr_sel)? dtcm_start_addr : {`DATA_WIDTH{1'b0}};

//13: dtcm_en
always @ (posedge cpu_clk or negedge cpu_rstn)
begin
	if(!cpu_rstn)
	begin
		dtcm_en <= 1'h1;
	end
	else
	begin
		if (tcm_ctrl_sel & valid_mcsr_wr)
		begin
			if(mcsr_set)
			begin
				dtcm_en <= dtcm_en | write_data[0];
			end
			else if(mcsr_clr)
			begin
				dtcm_en <= dtcm_en & (~write_data[0]);
			end
			else
			begin
				dtcm_en <= write_data[0];
			end
		end
		else
		begin
			dtcm_en <= dtcm_en;
		end
	end
end

wire [`DATA_WIDTH - 1 : 0] tcm_ctrl_rd_data;
assign tcm_ctrl_rd_data = (tcm_ctrl_sel)? {31'h0, dtcm_en} : {`DATA_WIDTH{1'b0}};


//Combine csr read data
assign read_data = {`DATA_WIDTH{valid_mcsr_rd}} & 
		       (misa_rd_data |
			mvendorid_rd_data |
			marchid_rd_data |
			mimpid_rd_data |
			mhartid_rd_data |
			mstatus_rd_data |
			mtvec_rd_data |
			mip_rd_data |
			mie_rd_data |
			mepc_rd_data |
			mcause_rd_data |
			mtval_rd_data |
			dtcm_start_addr_rd_data |
			tcm_ctrl_rd_data
	   		);

endmodule
