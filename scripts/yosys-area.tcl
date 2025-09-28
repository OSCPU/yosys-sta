set DESIGN                  [lindex $argv 0]
set PDK                     [lindex $argv 1]
set NETLIST_V               [lindex $argv 2]
set RESULT_DIR              [file dirname $NETLIST_V]

source "[file dirname [info script]]/common.tcl"

yosys -import
read_verilog $NETLIST_V
foreach l $LIB_FILES { read_liberty -lib $l }
hierarchy -check -top $DESIGN
tee -o $RESULT_DIR/synth_check_fixed.txt check -mapped
set libs [concat {*}[lmap lib $LIB_FILES {concat "-liberty" $lib}]]
tee -o $RESULT_DIR/synth_stat_fixed.txt stat {*}$libs
