set SDC_FILE   [lindex $argv 0]
set NETLIST_V  [lindex $argv 1]
set DESIGN     [lindex $argv 2]
set PDK        [lindex $argv 3]
set NETLIST_FIXED_V [lindex $argv 4]

source "[file dirname [info script]]/common.tcl"
set JSON_FILE "$PROJ_HOME/scripts/fix-fanout.json"

db_init -lib_path $LIB_FILE
db_init -sdc_path $SDC_FILE
tech_lef_init -path $TECH_LEF_FILE
lef_init -path $STDCELL_LEF_FILE

verilog_init -path $NETLIST_V -top $DESIGN
no_config -config_json_path $JSON_FILE -max_fanout 30 -insert_buffer $INO_INSERT_BUF
run_no_fixfanout -config $JSON_FILE
netlist_save -path $NETLIST_FIXED_V -exclude_cell_names {} -add_space
