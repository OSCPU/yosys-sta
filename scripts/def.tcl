set PROJ_PATH "[file dirname [info script]]/.."
set NETLIST_SYN_V [lindex $argv 0]
set DESIGN        [lindex $argv 1]
set DEF_FILE      [lindex $argv 2]

set LEF_FILES "\
  $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.tech.lef \
  $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef"

verilog_to_def -lef $LEF_FILES -verilog $NETLIST_SYN_V -top $DESIGN -def $DEF_FILE
