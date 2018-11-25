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
TEST_CSRRWI(2,0x0,0x8,mstatus);
TEST_CSRRWI_WO(3,0x0,0x8,mstatus);

#test mtvec
TEST_CSRRWI(4,0x10,0x1b,mtvec);
TEST_CSRRWI_WO(5,0x10,0x1b,mtvec);


TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
