set_component flash_ss_MSS
# Microsemi Corp.
# Date: 2018-Nov-18 03:44:28
#

create_clock -period 160 [ get_pins { MSS_ADLIB_INST/CLK_CONFIG_APB } ]
set_false_path -ignore_errors -through [ get_pins { MSS_ADLIB_INST/CONFIG_PRESET_N } ]
