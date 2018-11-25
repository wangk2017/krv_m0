set_component flash_ss_FABOSC_0_OSC
# Microsemi Corp.
# Date: 2018-Nov-18 03:44:33
#

create_clock -ignore_errors -period 20 [ get_pins { I_RCOSC_25_50MHZ/CLKOUT } ]
create_clock -ignore_errors -period 1000 [ get_pins { I_RCOSC_1MHZ/CLKOUT } ]
