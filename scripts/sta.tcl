set SDC_FILE   [lindex $argv 0]
set NETLIST_V  [lindex $argv 1]
set DESIGN     [lindex $argv 2]
set PDK        [lindex $argv 3]
set RESULT_DIR [file dirname $NETLIST_V]

source "[file dirname [info script]]/common.tcl"

set_design_workspace $RESULT_DIR
read_netlist $NETLIST_V
read_liberty $LIB_FILE
link_design $DESIGN
read_sdc  $SDC_FILE
report_timing -max_path 5
report_power -toggle 0.1
