set PROJ_PATH     [file dirname [info script]]
set DESIGN        [lindex $argv 0]
set SDC_FILE      [lindex $argv 1]
set NETLIST_FILE  [lindex $argv 2]
set LIB_FILES     $PROJ_PATH/nangate45/lib/merged.lib

set_design_workspace $PROJ_PATH/result/sta/
read_netlist $NETLIST_FILE
read_liberty $LIB_FILES
link_design $DESIGN
read_sdc  $SDC_FILE
report_timing
