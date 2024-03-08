PROJ_PATH = $(shell pwd)

DESIGN ?= gcd
SDC_FILE ?= $(PROJ_PATH)/example/gcd.sdc
RTL_FILES ?= $(shell find $(PROJ_PATH)/example -name "*.v")
export CLK_FREQ_MHZ ?= 500

RESULT_DIR = $(PROJ_PATH)/result/$(DESIGN)-$(CLK_FREQ_MHZ)MHz
SCRIPT_DIR = $(PROJ_PATH)/scripts
NETLIST_SYN_V   = $(RESULT_DIR)/$(DESIGN).netlist.syn.v
NETLIST_FIXED_V = $(RESULT_DIR)/$(DESIGN).netlist.fixed.v
SYN_DEF = $(RESULT_DIR)/$(DESIGN).syn.def
FIXED_DEF = $(RESULT_DIR)/$(DESIGN).fixed.def
TIMING_RPT = $(RESULT_DIR)/$(DESIGN).rpt

init:
	bash -c "$$(wget -O - https://ysyx.oscc.cc/slides/resources/scripts/init-yosys-sta.sh)"

syn: $(NETLIST_SYN_V)
$(NETLIST_SYN_V): $(RTL_FILES) $(SCRIPT_DIR)/yosys.tcl
	mkdir -p $(@D)
	echo tcl $(SCRIPT_DIR)/yosys.tcl $(DESIGN) \"$(RTL_FILES)\" $@ | yosys -l $(@D)/yosys.log -s -

def: $(SYN_DEF)
$(SYN_DEF): $(SCRIPT_DIR)/def.tcl $(NETLIST_SYN_V)
	LD_LIBRARY_PATH=bin/ ./bin/iEDA $^ $(DESIGN) $@ | tee $(RESULT_DIR)/gen-def.log

fix-fanout: $(NETLIST_FIXED_V)
$(NETLIST_FIXED_V): $(SCRIPT_DIR)/fix-fanout.tcl $(SDC_FILE) $(SYN_DEF)
	LD_LIBRARY_PATH=bin/ ./bin/iEDA -script $^ $@ 2>&1 | tee $(RESULT_DIR)/fix-fanout.log

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SCRIPT_DIR)/sta.tcl $(SDC_FILE) $(NETLIST_FIXED_V)
	LD_LIBRARY_PATH=bin/ ./bin/iEDA -script $^ $(DESIGN) 2>&1 | tee $(RESULT_DIR)/sta.log

clean:
	-rm -rf result/

.PHONY: init syn def fix-fanout sta clean
