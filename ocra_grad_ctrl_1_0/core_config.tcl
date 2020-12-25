set display_name {FLOCRA Gradient Core}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

core_parameter C_S00_AXI_DATA_WIDTH {AXI DATA WIDTH} {Width of the S00_AXIS data bus.}
core_parameter C_S00_AXI_ADDR_WIDTH {AXI ADDR WIDTH} {Width of the S00_AXIS address bus.}
core_parameter C_S_AXI_INTR_DATA_WIDTH {AXI IDATA WIDTH} {Width of the S_INTR_AXIS data bus.}
core_parameter C_S_AXI_INTR_ADDR_WIDTH {AXI IADDR WIDTH} {Width of the S_INTR_AXIS address bus.}

set bus [ipx::get_bus_interfaces -of_objects $core s00_axi]
set_property NAME s00_axi $bus
set_property INTERFACE_MODE slave $bus

set bus [ipx::get_bus_interfaces s00_axi_aclk]
set parameter [ipx::get_bus_parameters -of_objects $bus ASSOCIATED_BUSIF]
set_property VALUE s00_axi $parameter

set bus [ipx::get_bus_interfaces -of_objects $core s_axi_intr]
set_property NAME s_axi_intr $bus
set_property INTERFACE_MODE slave $bus

set bus [ipx::get_bus_interfaces s_axi_intr_aclk]
set parameter [ipx::get_bus_parameters -of_objects $bus ASSOCIATED_BUSIF]
set_property VALUE s_axi_intr $parameter