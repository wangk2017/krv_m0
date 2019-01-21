
//Global defines
`define SYNC_HCLK 1
`define BOOT_ADDR 32'h0000_0000
`define VECTOR_ENTRY 30'h0000_0000

//power gating
//`define THRESHOLD_ENTER_DEEP_SLEEP 40'hFF_FFFF_FFFF
//FIXME used for test
`define THRESHOLD_ENTER_DEEP_SLEEP 40'h00_0000_000F
`define SAVE_PERIOD	2'h1
`define PG_RESET_PERIOD	3'h3
`define RESTORE_PERIOD	2'h1
`define MOTHER_SLEEP_PERIOD	2'h1
`define MOTHER_WAKE_PERIOD	2'h1

//TCM defines
`define ITCM_START_ADDR 32'h0000_0000
`define ITCM_SIZE	32'h0000_4000
`define DTCM_START_ADDR 32'h0004_0000
`define DTCM_SIZE	32'h0000_4000

`define ASIC
`define SIM
`define PG_CTRL
