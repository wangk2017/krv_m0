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
TEST_CSRRC(2,0x0,0x8,mstatus);
TEST_CSRRC_WO(3,0x0,0x8,mstatus);

#test misa 
TEST_CSRRC(4,0x40000100,0x03fffeff,misa);
TEST_CSRRC_WO(5,0x40000100,0x03fffeff,misa);

#test mie 
TEST_CSRRC(6,0x000,0x800,mie);
TEST_CSRRC_WO(7,0x000,0x800,mie);

#test mtvec
TEST_CSRRC(8,0x10,0xfffffffb,mtvec);
TEST_CSRRC_WO(9,0x10,0xfffffffb,mtvec);

#test mepc
TEST_CSRRC(10,0x800000e0,0xffffffff,mepc);
TEST_CSRRC_WO(11,0x800000e0,0xffffffff,mepc);

#test mcause
TEST_CSRRC(12,0xffffffff,0x0,mcause);
TEST_CSRRC_WO(13,0xffffffff,0x0,mcause);

#test mtval
#TEST_CSRRC(14,0x0,0xffffffff,mtval);
#TEST_CSRRC_WO(15,0x0,0xffffffff,mtval);

#test mvendorid
TEST_CSRRC_RO(16,0x0,mvendorid);

#test marchid
TEST_CSRRC_RO(17,0x0,marchid);

#test mimpid
TEST_CSRRC_RO(18,0x10000000,mimpid);

#test mhartid
TEST_CSRRC_RO(19,0x0,mhartid);

#test mip
TEST_CSRRC_RO(20,0x0,mip);

TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
