set_component flash_ss_CCC_0_FCCC
# Microsemi Corp.
# Date: 2018-Nov-18 03:44:31
#

create_clock -period 1000 [ get_pins { CCC_INST/RCOSC_1MHZ } ]
create_generated_clock -multiply_by 25 -source [ get_pins { CCC_INST/RCOSC_1MHZ } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
