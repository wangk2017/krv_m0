# See LICENSE for license details.

#*****************************************************************************
# csrrw.S
#-----------------------------------------------------------------------------
#
# Test csrrw instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

#test mstatus  
TEST_CSRRW(2,0x0,0x8,mstatus);
TEST_CSRRW_WO(3,0x0,0x8,mstatus);

#test misa 
TEST_CSRRW(4,0x40000100,0x43fffeff,misa);
TEST_CSRRW_WO(5,0x40000100,0x43fffeff,misa);

#test mie 
TEST_CSRRW(6,0x000,0x800,mie);
TEST_CSRRW_WO(7,0x000,0x800,mie);

#test mtvec
TEST_CSRRW(8,0x10,0xfffffffb,mtvec);
TEST_CSRRW_WO(9,0x10,0xfffffffb,mtvec);

#test mepc
TEST_CSRRW(10,0x800000e0,0xffffffff,mepc);
TEST_CSRRW_WO(11,0x800000e0,0xffffffff,mepc);

#test mcause
TEST_CSRRW(12,0xffffffff,0x0,mcause);
TEST_CSRRW_WO(13,0xffffffff,0x0,mcause);

#test mtval
#TEST_CSRRW(14,0x0,0xffffffff,mtval);
#TEST_CSRRW_WO(15,0x0,0xffffffff,mtval);


TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
