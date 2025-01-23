set DESIGN                  [lindex $argv 0]
set NETLIST_V               [lindex $argv 1]
set RESULT_DIR              [file dirname $NETLIST_V]

set FOUNDARY_PATH           "[file dirname [info script]]/../nangate45"
set MERGED_LIB_FILE         "$FOUNDARY_PATH/lib/merged.lib"

yosys -import
read_verilog $NETLIST_V
read_liberty -lib $MERGED_LIB_FILE
hierarchy -check -top $DESIGN
tee -o $RESULT_DIR/synth_check_fixed.txt check -mapped
tee -o $RESULT_DIR/synth_stat_fixed.txt stat -liberty $MERGED_LIB_FILE
