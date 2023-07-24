set clk_port_name clk
set clk_freq_MHz 500
set clk_io_pct 0.2

set clk_port [get_ports $clk_port_name]
create_clock -name core_clock -period [expr 1000 / $clk_freq_MHz] $clk_port
