//------------------------------------------------------------------------//
//this file is used as a model of the power gating save restore 
//------------------------------------------------------------------------//
	initial
	begin
	@(posedge DUT.u_pg_ctrl.daughter_sleep)
	force DUT.u_core.u_fetch.pc = 32'h0001_1000;
	@(negedge DUT.u_pg_ctrl.daughter_sleep) 
	release DUT.u_core.u_fetch.pc;
	end

//gprs
reg [31:0] saved_pc;
reg [31:0] saved_X1;
reg [31:0] saved_X2;
reg [31:0] saved_X3;
reg [31:0] saved_X4;
reg [31:0] saved_X5;
reg [31:0] saved_X6;
reg [31:0] saved_X7;
reg [31:0] saved_X8;
reg [31:0] saved_X9;
reg [31:0] saved_X10;
reg [31:0] saved_X11;
reg [31:0] saved_X12;
reg [31:0] saved_X13;
reg [31:0] saved_X14;
reg [31:0] saved_X15;
//csrs

reg [25:0]saved_misa ;
reg [0:0] saved_mstatus_mie ;
reg [29:0]saved_mtvec_base;
reg [1:0] saved_mtvec_mode;
reg [0:0] saved_mip_meip ;
reg [0:0] saved_mie_meie ;
reg [31:0]saved_mepc ;
reg [31:0]saved_mcause ;
reg [31:0]saved_mtval ;
reg [31:0]saved_dtcm_start_addr ;
reg [0:0] saved_tcm_ctrl_dtcm_en;

always @ (posedge cpu_clk)
begin
	if(DUT.u_pg_ctrl.save)
	begin
		saved_pc <= DUT.u_core.u_fetch.pc;
		saved_X1 <= DUT.u_core.u_dec.gprs_inst.gprs_X[1];
		saved_X2 <= DUT.u_core.u_dec.gprs_inst.gprs_X[2];
		saved_X3 <= DUT.u_core.u_dec.gprs_inst.gprs_X[3];
		saved_X4 <= DUT.u_core.u_dec.gprs_inst.gprs_X[4];
		saved_X5 <= DUT.u_core.u_dec.gprs_inst.gprs_X[5];
		saved_X6 <= DUT.u_core.u_dec.gprs_inst.gprs_X[6];
		saved_X7 <= DUT.u_core.u_dec.gprs_inst.gprs_X[7];
		saved_X8 <= DUT.u_core.u_dec.gprs_inst.gprs_X[8];
		saved_X9 <= DUT.u_core.u_dec.gprs_inst.gprs_X[9];
		saved_X10 <= DUT.u_core.u_dec.gprs_inst.gprs_X[10];
		saved_X11 <= DUT.u_core.u_dec.gprs_inst.gprs_X[11];
		saved_X12 <= DUT.u_core.u_dec.gprs_inst.gprs_X[12];
		saved_X13 <= DUT.u_core.u_dec.gprs_inst.gprs_X[13];
		saved_X14 <= DUT.u_core.u_dec.gprs_inst.gprs_X[14];
		saved_X15 <= DUT.u_core.u_dec.gprs_inst.gprs_X[15];
		saved_misa  		<= DUT.u_core.u_mcsr.misa;
		saved_mstatus_mie 	<= DUT.u_core.u_mcsr.mstatus_mie;
		saved_mtvec_base	<= DUT.u_core.u_mcsr.mtvec_base;	
		saved_mtvec_mode	<= DUT.u_core.u_mcsr.mtvec_mode;
		saved_mip_meip 		<= DUT.u_core.u_mcsr.meip;
		saved_mie_meie 		<= DUT.u_core.u_mcsr.meie;
		saved_mepc 		<= DUT.u_core.u_trap_ctrl.mepc;
		saved_mcause 		<= DUT.u_core.u_trap_ctrl.mcause;
		saved_mtval 		<= DUT.u_core.u_trap_ctrl.mtval;
		saved_dtcm_start_addr 	<= DUT.u_core.u_mcsr.dtcm_start_addr;
		saved_tcm_ctrl_dtcm_en	<= DUT.u_core.u_mcsr.dtcm_en;
	end
end

initial
begin
	@(posedge DUT.u_pg_ctrl.restore)
	
		force DUT.u_core.u_fetch.pc = saved_pc;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[1] = saved_X1;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[2] = saved_X2;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[3] = saved_X3;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[4] = saved_X4;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[5] = saved_X5;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[6] = saved_X6;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[7] = saved_X7;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[8] = saved_X8;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[9] = saved_X9;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[10] = saved_X10;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[11] = saved_X11;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[12] = saved_X12;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[13] = saved_X13;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[14] = saved_X14;
		force DUT.u_core.u_dec.gprs_inst.gprs_X[15] = saved_X15;
		force DUT.u_core.u_mcsr.misa		= saved_misa  		;
		force DUT.u_core.u_mcsr.mstatus_mie	= saved_mstatus_mie 	;
		force DUT.u_core.u_mcsr.mtvec_base	= saved_mtvec_base	;	
		force DUT.u_core.u_mcsr.mtvec_mode	= saved_mtvec_mode	;
		force DUT.u_core.u_mcsr.meip		= saved_mip_meip 	;
		force DUT.u_core.u_mcsr.meie		= saved_mie_meie 	;
		force DUT.u_core.u_trap_ctrl.mepc	= saved_mepc 		;
		force DUT.u_core.u_trap_ctrl.mcause	= saved_mcause 		;
		force DUT.u_core.u_trap_ctrl.mtval	= saved_mtval 		;
		force DUT.u_core.u_mcsr.dtcm_start_addr	= saved_dtcm_start_addr ;
		force DUT.u_core.u_mcsr.dtcm_en		= saved_tcm_ctrl_dtcm_en;

	
	@(negedge DUT.u_pg_ctrl.restore)
	
		release DUT.u_core.u_fetch.pc;
		release DUT.u_core.u_dec.gprs_inst.gprs_X[1];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[2];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[3];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[4];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[5];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[6];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[7];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[8];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[9];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[10];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[11];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[12];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[13];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[14];
		release DUT.u_core.u_dec.gprs_inst.gprs_X[15];
		release DUT.u_core.u_mcsr.misa		;
		release DUT.u_core.u_mcsr.mstatus_mie	;
		release DUT.u_core.u_mcsr.mtvec_base	;	
		release DUT.u_core.u_mcsr.mtvec_mode	;
		release DUT.u_core.u_mcsr.meip		;
		release DUT.u_core.u_mcsr.meie		;
		release DUT.u_core.u_trap_ctrl.mepc	;
		release DUT.u_core.u_trap_ctrl.mcause	;
		release DUT.u_core.u_trap_ctrl.mtval	;
		release DUT.u_core.u_mcsr.dtcm_start_addr;
		release DUT.u_core.u_mcsr.dtcm_en	 ;
end



