set PERIOD 100.00
set CLK_HALF [expr $PERIOD/2.0]
# Constraint clock
create_clock -period $PERIOD -name clk -waveform [list 0 $CLK_HALF] -add [get_ports clk]
# Constraint I/O delay
set_input_delay -clock [get_clocks *] -add_delay $CLK_HALF [get_ports -filter { NAME !=  "clk" && DIRECTION == "IN" }]
set_output_delay -clock [get_clocks *] -add_delay $CLK_HALF [get_ports -filter { NAME =~  "*" && DIRECTION == "OUT" }]