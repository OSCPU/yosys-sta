#===========================================================
#   set parameter
#===========================================================
set DESIGN                  [lindex $argv 0]
set FOUNDRY_PATH            $::env(FOUNDRY_PATH)
set RESULT_PATH             $::env(RESULT_PATH)
set SDC_FILE                [lindex $argv 1]
set VERILOG_FILES           [string map {"\"" ""} [lindex $argv 2]]

set MERGED_LIB_FILE         "$FOUNDRY_PATH/lib/merged.lib"
set BLACKBOX_V_FILE         "$FOUNDRY_PATH/verilog/blackbox.v" 
set CLKGATE_MAP_FILE        "$FOUNDRY_PATH/verilog/cells_clkgate.v" 
set LATCH_MAP_FILE          "$FOUNDRY_PATH/verilog/cells_latch.v" 
set BLACKBOX_MAP_TCL        "$FOUNDRY_PATH/blackbox_map.tcl" 
set CLOCK_PERIOD            "20.0" 

set TIEHI_CELL_AND_PORT     "LOGIC1_X1 Z" 
set TIELO_CELL_AND_PORT     "LOGIC0_X1 Z" 
set MIN_BUF_CELL_AND_PORTS  "BUF_X1 A Z" 

set VERILOG_INCLUDE_DIRS "\
"

#===========================================================
#   main running
#===========================================================
yosys -import

# Don't change these unless you know what you are doing
set stat_ext    "_stat.rep"
set gl_ext      "_gl.v"
set abc_script  "+read_constr,$SDC_FILE;strash;ifraig;retime,-D,{D},-M,6;strash;dch,-f;map,-p,-M,1,{D},-f;topo;dnsize;buffer,-p;upsize;"
#set abc_script  "+strash;ifraig;map,-p,-M,1,{D};topo;dnsize,-c;buffer,-c;upsize,-c;"

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
#synth  -top $DESIGN -flatten
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
abc -D [expr $CLOCK_PERIOD * 1000] \
    -constr "$SDC_FILE" \
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
tee -o $RESULT_PATH/synth_check.txt check
tee -o $RESULT_PATH/synth_stat.txt stat -liberty $MERGED_LIB_FILE

# write synthesized design
#write_verilog -norename -noattr -noexpr -nohex -nodec $RESULTS_DIR/1_1_yosys.v
write_verilog -noattr -noexpr -nohex -nodec $RESULT_PATH/$DESIGN.v
