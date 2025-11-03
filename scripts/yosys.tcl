# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#===========================================================
#   set parameter
#===========================================================
set DESIGN                  [lindex $argv 0]
set PDK                     [lindex $argv 1]
set VERILOG_FILES           [string map {"\"" ""} [lindex $argv 2]]
set NETLIST_SYN_V           [lindex $argv 3]
set VERILOG_INCLUDE_DIRS    ""
set RESULT_DIR              [file dirname $NETLIST_SYN_V]

source "[file dirname [info script]]/common.tcl"

set CLK_FREQ_MHZ            500
if {[info exists env(CLK_FREQ_MHZ)]} {
  set CLK_FREQ_MHZ          $::env(CLK_FREQ_MHZ)
} else {
  puts "Warning: Environment CLK_FREQ_MHZ is not defined. Use $CLK_FREQ_MHZ MHz by default."
}
set CLK_PERIOD_NS           [expr 1000.0 / $CLK_FREQ_MHZ]
set CLK_PERIOD_PS           [expr 1000.0 * $CLK_PERIOD_NS]

set LIBS [concat {*}[lmap lib $LIB_FILE {concat "-liberty" $lib}]]

#===========================================================
#   set parameter for ABC
#===========================================================

set buffering 1
set sizing 1
set SYNTH_STRATEGY "DELAY 4"

set driver  $INO_INSERT_BUF

# fF -> pF
set cap_load 1.6

# input pin cap of BUF
set max_FO 24
set max_TR 0

# Create SDC File
set sdc_file $RESULT_DIR/abc.sdc
set outfile [open ${sdc_file} w]
puts $outfile "set_driving_cell ${driver}"
puts $outfile "set_load ${cap_load}"
close $outfile


# Assemble Scripts (By Strategy)
set abc_rs_K    "resub,-K,"
set abc_rs      "resub"
set abc_rsz     "resub,-z"
set abc_rw_K    "rewrite,-K,"
set abc_rw      "rewrite"
set abc_rwz     "rewrite,-z"
set abc_rf      "refactor"
set abc_rfz     "refactor,-z"
set abc_b       "balance"

set abc_resyn2        "${abc_b}; ${abc_rw}; ${abc_rf}; ${abc_b}; ${abc_rw}; ${abc_rwz}; ${abc_b}; ${abc_rfz}; ${abc_rwz}; ${abc_b}"
set abc_share         "strash; multi,-m; ${abc_resyn2}"
set abc_resyn2a       "${abc_b};${abc_rw};${abc_b};${abc_rw};${abc_rwz};${abc_b};${abc_rwz};${abc_b}"
set abc_resyn3        "balance;resub;resub,-K,6;balance;resub,-z;resub,-z,-K,6;balance;resub,-z,-K,5;balance"
set abc_resyn2rs      "${abc_b};${abc_rs_K},6;${abc_rw};${abc_rs_K},6,-N,2;${abc_rf};${abc_rs_K},8;${abc_rw};${abc_rs_K},10;${abc_rwz};${abc_rs_K},10,-N,2;${abc_b},${abc_rs_K},12;${abc_rfz};${abc_rs_K},12,-N,2;${abc_rwz};${abc_b}"

set abc_choice        "fraig_store; ${abc_resyn2}; fraig_store; ${abc_resyn2}; fraig_store; fraig_restore"
set abc_choice2       "fraig_store; balance; fraig_store; ${abc_resyn2}; fraig_store; ${abc_resyn2}; fraig_store; ${abc_resyn2}; fraig_store; fraig_restore"

set abc_map_old_cnt			"map,-p,-a,-B,0.2,-A,0.9,-M,0"
set abc_map_old_dly     "map,-p,-B,0.2,-A,0.9,-M,0"
set abc_retime_area     "retime,-D,{D},-M,5"
set abc_retime_dly      "retime,-D,{D},-M,6"
set abc_map_new_area    "amap,-m,-Q,0.1,-F,20,-A,20,-C,5000"

set abc_area_recovery_1 "${abc_choice}; map;"
set abc_area_recovery_2 "${abc_choice2}; map;"

set map_old_cnt			    "map,-p,-a,-B,0.2,-A,0.9,-M,0"
set map_old_dly			    "map,-p,-B,0.2,-A,0.9,-M,0"
set abc_retime_area   	"retime,-D,{D},-M,5"
set abc_retime_dly    	"retime,-D,{D},-M,6"
set abc_map_new_area  	"amap,-m,-Q,0.1,-F,20,-A,20,-C,5000"

if {$buffering==1} {
  set max_tr_arg ""
  if { $max_TR != 0 } {
    set max_tr_arg ",-S,${max_TR}"
  }
  set abc_fine_tune		"buffer,-N,${max_FO}${max_tr_arg};upsize,{D};dnsize,{D}"
} elseif {$sizing} {
  set abc_fine_tune   "upsize,{D};dnsize,{D}"
} else {
  set abc_fine_tune   ""
}


set delay_scripts [list \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_dly}; scleanup;${abc_map_old_dly};retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_dly}; scleanup;${abc_choice2};${abc_map_old_dly};${abc_area_recovery_2}; retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_dly}; scleanup;${abc_choice};${abc_map_old_dly};${abc_area_recovery_1}; retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${abc_choice2};${abc_map_new_area};${abc_choice2};${abc_map_old_dly};retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  "+read_constr,${sdc_file};&get -n;&st;&dch;&nf;&put;&get -n;&st;&syn2;&if -g -K 6;&synch2;&nf;&put;&get -n;&st;&syn2;&if -g -K 6;&synch2;&nf;&put;&get -n;&st;&syn2;&if -g -K 6;&synch2;&nf;&put;&get -n;&st;&syn2;&if -g -K 6;&synch2;&nf;&put;&get -n;&st;&syn2;&if -g -K 6;&synch2;&nf;&put;buffer -c -N ${max_FO};topo;stime -c;upsize -c;dnsize -c;;stime,-p;print_stats -m" \
  ]

set area_scripts [list \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${abc_choice2};${abc_map_new_area};retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_resyn2};${abc_retime_area};scleanup;${abc_choice2};${abc_map_new_area};${abc_choice2};${abc_map_new_area};retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  \
  "+read_constr,${sdc_file};fx;mfs;strash;refactor;${abc_choice2};${abc_retime_area};scleanup;${abc_choice2};${abc_map_new_area};${abc_choice2};${abc_map_new_area};retime,-D,{D};&get,-n;&st;&dch;&nf;&put;${abc_fine_tune};stime,-p;print_stats -m" \
  "+read_constr,${sdc_file};strash;dch;map -B 0.9;topo;stime -c;buffer -c -N ${max_FO};upsize -c;dnsize -c;stime,-p;print_stats -m" \
  ]

set strategy_parts [split $SYNTH_STRATEGY]

proc synth_strategy_format_err { } {
  upvar area_scripts area_scripts
  upvar delay_scripts delay_scripts
  log -stderr "\[ERROR] Misformatted SYNTH_STRATEGY (\"$SYNTH_STRATEGY\")."
  log -stderr "\[ERROR] Correct format is \"DELAY|AREA 0-[expr [llength $delay_scripts]-1]|0-[expr [llength $area_scripts]-1]\"."
  exit 1
}

if { [llength $strategy_parts] != 2 } {
  synth_strategy_format_err
}

set strategy_type [lindex $strategy_parts 0]
set strategy_type_idx [lindex $strategy_parts 1]

if { $strategy_type != "AREA" && $strategy_type != "DELAY" } {
  log -stderr "\[ERROR] AREA|DELAY tokens not found. ($strategy_type)"
  synth_strategy_format_err
}

if { $strategy_type == "DELAY" && $strategy_type_idx >= [llength $delay_scripts] } {
  log -stderr "\[ERROR] strategy index ($strategy_type_idx) is too high."
  synth_strategy_format_err
}

if { $strategy_type == "AREA" && $strategy_type_idx >= [llength $area_scripts] } {
  log -stderr "\[ERROR] strategy index ($strategy_type_idx) is too high."
  synth_strategy_format_err
}

set strategy_name "$strategy_type-$strategy_type_idx"
if { $strategy_type == "DELAY" } {
  set strategy_script [lindex $delay_scripts $strategy_type_idx]
} else {
  set strategy_script [lindex $area_scripts $strategy_type_idx]
}

#===========================================================
#   main running
#===========================================================
yosys -import

# read verilog files
foreach file $VERILOG_FILES {
  read_verilog -sv $file
}

synth -top $DESIGN -flatten

share -aggressive

opt_clean -purge

dfflibmap {*}$LIBS

opt -undriven -purge

log "\[INFO\]: USING STRATEGY $strategy_name"

abc -D "$CLK_PERIOD_PS" \
  -constr "$sdc_file" \
  {*}$LIBS \
  -script "$strategy_script" \
  -showtmp

hilomap -singleton -hicell {*}$TIEHI_CELL_AND_PORT -locell {*}$TIELO_CELL_AND_PORT

setundef -zero

# Generate public names for the various nets, resulting in very long names that include
# the full heirarchy, which is preferable to the internal names that are simply
# sequential numbers such as `_000019_`. Renamed net names can be very long, such as:
#     manual_reset_gf180mcu_fd_sc_mcu7t5v0__dffq_1_Q_D_gf180mcu_ \
#     fd_sc_mcu7t5v0__nor3_1_ZN_A1_gf180mcu_fd_sc_mcu7t5v0__aoi21_ \
#     1_A2_A1_gf180mcu_fd_sc_mcu7t5v0__nand3_1_ZN_A3_gf180mcu_fd_ \
#     sc_mcu7t5v0__and3_1_A3_Z_gf180mcu_fd_sc_mcu7t5v0__buf_1_I_Z
autoname

splitnets -format __v -ports
opt_clean -purge

foreach l $LIB_FILE { read_liberty -lib $l }

tee -o $RESULT_DIR/synth_check.txt check -mapped
tee -o $RESULT_DIR/synth_stat.txt stat {*}$LIBS

write_verilog -noattr -noexpr -nohex -nodec -defparam $NETLIST_SYN_V
