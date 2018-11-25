
#ifndef __TEST_MACROS_SCALAR_H
#define __TEST_MACROS_SCALAR_H


#-----------------------------------------------------------------------
# added by Kitty to test csr instructions
#-----------------------------------------------------------------------
#define TEST_CSRRW( testnum, init_val, wr_val, csr_name ) \
	test_ ## testnum: \
	li a0, wr_val; \
	li a3, init_val; \
    	li  TESTNUM, testnum; \
	csrrw t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrw t5,csr_name,t4; \
	bne t5,a0,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRW_WO( testnum, init_val, wr_val, csr_name ) \
	test_ ## testnum: \
	li a0, wr_val; \
	li a3, init_val; \
    	li  TESTNUM, testnum; \
	csrrw t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrw x0,csr_name,t4; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRS( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	or a4,a0,a3;\
    	li  TESTNUM, testnum; \
	csrrs t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRS_WO( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	or a4,a0,a3;\
    	li  TESTNUM, testnum; \
	csrrs t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrs x0,csr_name,a0; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRS_RO( testnum, init_val, csr_name ) \
	test_ ## testnum: \
	li a3, init_val; \
    	li  TESTNUM, testnum; \
	csrrs t4,csr_name,x0; \
	bne t4,a3,fail; \
	csrr t5,csr_name;\
	bne t5,a3,fail;\
	
#define TEST_CSRRC( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	not a5,a0; \
	and a4,a5,a3;\
    	li  TESTNUM, testnum; \
	csrrc t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRC_WO( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	not a5,a0; \
	and a4,a5,a3;\
    	li  TESTNUM, testnum; \
	csrrc t4,csr_name,a0; \
	bne t4,a3,fail; \
	csrrc x0,csr_name,a0; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRC_RO( testnum, init_val, csr_name ) \
	test_ ## testnum: \
	li a3, init_val; \
    	li  TESTNUM, testnum; \
	csrrc t4,csr_name,x0; \
	bne t4,a3,fail; \
	csrr t5,csr_name;\
	bne t5,a3,fail;\

	
#define TEST_CSRRWI( testnum, init_val, wr_val, csr_name ) \
	test_ ## testnum: \
    	li  TESTNUM, testnum; \
	csrrwi t4,csr_name,wr_val; \
	li a3, init_val; \
	bne t4,a3,fail; \
	csrrwi t5,csr_name,init_val; \
	li a0, wr_val; \
	bne t5,a0,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;
	
#define TEST_CSRRWI_WO( testnum, init_val, wr_val, csr_name ) \
	test_ ## testnum: \
    	li  TESTNUM, testnum; \
	csrrwi t4,csr_name,wr_val; \
	li a3, init_val; \
	bne t4,a3,fail; \
	csrrwi x0,csr_name,init_val; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRSI( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	or a4,a0,a3;\
    	li  TESTNUM, testnum; \
	csrrsi t4,csr_name,wr_mask; \
	bne t4,a3,fail; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;

#define TEST_CSRRCI( testnum, init_val, wr_mask, csr_name ) \
	test_ ## testnum: \
	li a0, wr_mask; \
	li a3, init_val; \
	not a5,a0; \
	and a4,a5,a3;\
    	li  TESTNUM, testnum; \
	csrrci t4,csr_name,wr_mask; \
	bne t4,a3,fail; \
	csrrw t5,csr_name,t4; \
	bne t5,a4,fail; \
	csrr t5,csr_name; \
	bne t5,t4,fail;
	

// ^ x30 is used in some other macros, to avoid issues we use x31 for upper word

#-----------------------------------------------------------------------
# Pass and fail code (assumes test num is in TESTNUM)
#-----------------------------------------------------------------------

#define TEST_PASSFAIL \
        bne x0, TESTNUM, pass; \
fail: \
        RVTEST_FAIL; \
pass: \
        RVTEST_PASS \


#-----------------------------------------------------------------------
# Test data section
#-----------------------------------------------------------------------

#define TEST_DATA

#endif
