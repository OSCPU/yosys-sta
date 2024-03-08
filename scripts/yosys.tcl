#===========================================================
#   set parameter
#===========================================================
set DESIGN                  [lindex $argv 0]
set VERILOG_FILES           [string map {"\"" ""} [lindex $argv 1]]
set NETLIST_SYN_V           [lindex $argv 2]
set VERILOG_INCLUDE_DIRS    ""
set RESULT_DIR              [file dirname $NETLIST_SYN_V]

set FOUNDARY_PATH           "[file dirname [info script]]/../nangate45"
set MERGED_LIB_FILE         "$FOUNDARY_PATH/lib/merged.lib"
set BLACKBOX_V_FILE         "$FOUNDARY_PATH/verilog/blackbox.v"
set CLKGATE_MAP_FILE        "$FOUNDARY_PATH/verilog/cells_clkgate.v"
set LATCH_MAP_FILE          "$FOUNDARY_PATH/verilog/cells_latch.v"
set BLACKBOX_MAP_TCL        "$FOUNDARY_PATH/blackbox_map.tcl"

set CLK_FREQ_MHZ            500
if {[info exists env(CLK_FREQ_MHZ)]} {
  set CLK_FREQ_MHZ          $::env(CLK_FREQ_MHZ)
} else {
  puts "Warning: Environment CLK_FREQ_MHZ is not defined. Use $CLK_FREQ_MHZ MHz by default."
}
set CLK_PERIOD_NS           [expr 1000.0 / $CLK_FREQ_MHZ]

set TIEHI_CELL_AND_PORT     "LOGIC1_X1 Z"
set TIELO_CELL_AND_PORT     "LOGIC0_X1 Z"
set MIN_BUF_CELL_AND_PORTS  "BUF_X1 A Z"

#===========================================================
#   main running
#===========================================================
yosys -import

# Don't change these unless you know what you are doing
set stat_ext    "_stat.rep"
set gl_ext      "_gl.v"
set abc_script  "+strash;ifraig;retime,-D,{D},-M,6;strash;dch,-f;map,-p,-M,1,{D},-f;topo;dnsize;buffer,-p;upsize;"

# Setup verilog include directories
set vIdirsArgs ""
if {[info exist VERILOG_INCLUDE_DIRS]} {
    foreach dir $VERILOG_INCLUDE_DIRS {
        lappend vIdirsArgs "-I$dir"
    }
    set vIdirsArgs [join $vIdirsArgs]
}



# read verilog files
foreach file $VERILOG_FILES {
    read_verilog -sv {*}$vIdirsArgs $file
}


# Read blackbox stubs of standard/io/ip/memory cells. This allows for standard/io/ip/memory cell (or
# structural netlist support in the input verilog
read_verilog $BLACKBOX_V_FILE

# Apply toplevel parameters (if exist
if {[info exist VERILOG_TOP_PARAMS]} {
    dict for {key value} $VERILOG_TOP_PARAMS {
        chparam -set $key $value $DESIGN
    }
}


# Read platform specific mapfile for OPENROAD_CLKGATE cells
if {[info exist CLKGATE_MAP_FILE]} {
    read_verilog $CLKGATE_MAP_FILE
}

# Use hierarchy to automatically generate blackboxes for known memory macro.
# Pins are enumerated for proper mapping
if {[info exist BLACKBOX_MAP_TCL]} {
    source $BLACKBOX_MAP_TCL
}

# generic synthesis
synth  -top $DESIGN

# Optimize the design
opt -purge

# technology mapping of latches
if {[info exist LATCH_MAP_FILE]} {
  techmap -map $LATCH_MAP_FILE
}

# technology mapping of flip-flops
dfflibmap -liberty $MERGED_LIB_FILE
opt -undriven

# Technology mapping for cells
abc -D [expr $CLK_PERIOD_NS * 1000] \
    -liberty $MERGED_LIB_FILE \
    -showtmp \
    -script $abc_script


# technology mapping of constant hi- and/or lo-drivers
hilomap -singleton \
        -hicell {*}$TIEHI_CELL_AND_PORT \
        -locell {*}$TIELO_CELL_AND_PORT

# replace undef values with defined constants
setundef -zero

# Splitting nets resolves unwanted compound assign statements in netlist (assign {..} = {..}
splitnets

# insert buffer cells for pass through wires
insbuf -buf {*}$MIN_BUF_CELL_AND_PORTS

# remove unused cells and wires
opt_clean -purge

# reports
tee -o $RESULT_DIR/synth_check.txt check
tee -o $RESULT_DIR/synth_stat.txt stat -liberty $MERGED_LIB_FILE

# write synthesized design
write_verilog -noattr -noexpr -nohex -nodec $NETLIST_SYN_V
