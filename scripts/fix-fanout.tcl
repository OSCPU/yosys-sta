set PROJ_PATH "[file dirname [info script]]/.."
set SDC_FILE   [lindex $argv 0]
set NETLIST_V  [lindex $argv 1]
set DESIGN     [lindex $argv 2]
set NETLIST_FIXED_V [lindex $argv 3]

db_init -lib_path $PROJ_PATH/nangate45/lib/merged.lib
db_init -sdc_path $SDC_FILE
tech_lef_init -path $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.tech.lef
lef_init -path $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef

verilog_init -path $NETLIST_V -top $DESIGN
run_no_fixfanout -config $PROJ_PATH/scripts/fix-fanout.json
netlist_save -path $NETLIST_FIXED_V -exclude_cell_names {}
