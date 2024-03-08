set PROJ_PATH "[file dirname [info script]]/.."
set SDC_FILE   [lindex $argv 0]
set DEF_FILE   [lindex $argv 1]
set NETLIST_FIXED_V [lindex $argv 2]

db_init -lib_path $PROJ_PATH/nangate45/lib/merged.lib
db_init -sdc_path $SDC_FILE
tech_lef_init -path $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.tech.lef
lef_init -path $PROJ_PATH/nangate45/lef/NangateOpenCellLibrary.macro.mod.lef

def_init -path $DEF_FILE
run_no_fixfanout -config $PROJ_PATH/scripts/fix-fanout.json
#def_save -path fix_fanout_result.def
netlist_save -path $NETLIST_FIXED_V -exclude_cell_names {}
