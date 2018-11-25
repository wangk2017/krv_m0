
//Global defines
`define INSTR_WIDTH 32
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define SHAMT_WIDTH 5
`define MCSR_N 20
`define EMEM_BUFFER_WIDTH `DATA_WIDTH + `ADDR_WIDTH + 1

//Instruction format
`define OPCODE_RANGE 	6:0
`define RD_RANGE 	11:7
`define FUNCT3_RANGE 	14:12
`define RS1_RANGE 	19:15
`define RS2_RANGE 	24:20
`define FUNCT7_RANGE 	31:25
`define FUNCT12_RANGE 	31:20
`define IMM_11_0_RANGE 	31:20
`define IMM_11_5_RANGE 	31:25
`define IMM_4_0_RANGE 	11:7
`define IMM_31_12_RANGE 31:12

`define OPCODE_WIDTH 	7
`define RD_WIDTH 	5
`define FUNCT3_WIDTH 	3
`define RS1_WIDTH 	5
`define RS2_WIDTH 	5
`define FUNCT7_WIDTH 	7
`define FUNCT12_WIDTH 	12
`define IMM_11_0_WIDTH 	12
`define IMM_11_5_WIDTH 	7
`define IMM_4_0_WIDTH 	5
`define IMM_31_12_WIDTH 20

`define BREAK 7'h02

//OPCODE DEC
`define LUI 	7'b0110111
`define AUIPC 	7'b0010111
`define JAL 	7'b1101111
`define JALR	7'b1100111
`define BRANCH	7'b1100011
`define	LOAD	7'b0000011
`define	STORE	7'b0100011
`define	ALU_IR	7'b0010011
`define ALU_RR	7'b0110011
`define SYSTEM	7'b1110011
`define FENCE	7'b0001111
`define ECALL	7'b1110011

//BRANCH FUNCT3
`define	FUNCT3_BEQ 3'b000
`define	FUNCT3_BNE 3'b001
`define	FUNCT3_BLT 3'b100
`define	FUNCT3_BGE 3'b101
`define	FUNCT3_BLTU 3'b110
`define	FUNCT3_BGEU 3'b111

//LOAD/STORE FUNCT3
`define FUNCT3_LSB	3'b000
`define FUNCT3_LSH	3'b001
`define FUNCT3_LSW	3'b010
`define FUNCT3_LBU	3'b100
`define FUNCT3_LHU	3'b101

//ALU FUNCT3
`define FUNCT3_ADD	3'b000
`define FUNCT3_SLL	3'b001
`define FUNCT3_SLT	3'b010
`define FUNCT3_SLTU	3'b011
`define FUNCT3_XOR	3'b100
`define FUNCT3_SRL	3'b101
`define FUNCT3_OR	3'b110
`define FUNCT3_AND	3'b111

//SYSTEM FUNCT3
`define FUNCT3_PRIV	3'b000
`define FUNCT3_CSRRW 	3'b001
`define FUNCT3_CSRRS 	3'b010
`define FUNCT3_CSRRC 	3'b011
`define FUNCT3_CSRRWI 	3'b101
`define FUNCT3_CSRRSI 	3'b110
`define FUNCT3_CSRRCI	3'b111

//FENCE FUNCT3
`define FUNCT3_FENCE   3'b000
`define FUNCT3_FENCE_I 3'b001

//SYSTEM FUNCT12
`define FUNCT12_MRET	12'b0011_0000_0010
`define FUNCT12_WFI	12'b0001_0000_0101
`define FUNCT12_ECALL	12'b0000_0000_0000

//FUNCT7
`define FUNCT7_0 7'b0000000
`define FUNCT7_ARITH_SUB 7'b0100000
`define FUNCT7_MUL_DIV   7'b0000001

//EBREAK
`define EBREAK_UP	12'b0000_0000_0001
`define ECALL_UP	12'b0000_0000_0000

//CSRs
`define MVENDORID_ADDR 		12'hF11
`define MARCHID_ADDR 		12'hF12
`define MIMPID_ADDR 		12'hF13
`define MHARTID_ADDR 		12'hF14
`define MSTATUS_ADDR		12'h300
`define MISA_ADDR 		12'h301
`define MIE_ADDR		12'h304
`define	MTVEC_ADDR		12'h305
`define	MEPC_ADDR		12'h341
`define	MCAUSE_ADDR		12'h342
`define MTVAL_ADDR		12'h343
`define MIP_ADDR		12'h344
`define TCM_CTRL_ADDR		12'h500
`define DTCM_START_ADDR_ADDR   	12'h504

`define STVEC_ADDR		12'h105
`define SATP_ADDR		12'h180
`define PMPCFG0_ADDR		12'h3a0
`define PMPADDR0_ADDR		12'h3b0
`define MEDELEG_ADDR		12'h302
`define MIDELEG_ADDR		12'h303

`define MTIME_ADDR		16'hbff8
`define MTIMECMP_ADDR		16'h4000

//mcause encode
`define M_EXTER_INT		32'h8000_000B
`define M_TIMER_INT		32'h8000_0007
`define PC_MISALIGNED 		32'h0
`define ILLEGAL_INSTR		32'h2
`define LOAD_ACCESS_FAULT	32'h5
`define M_ECALL			32'hb
`define M_TIMER_INT		32'h8000_0007
