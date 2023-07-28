PROJ_PATH = $(shell pwd)

DESIGN ?= gcd
SDC_FILE ?= $(PROJ_PATH)/example/gcd.sdc
RTL_FILES ?= $(shell find $(PROJ_PATH)/example -name "*.v")
export CLK_FREQ_MHZ ?= 500

RESULT_DIR = $(PROJ_PATH)/result/$(DESIGN)-$(CLK_FREQ_MHZ)MHz
NETLIST_V  = $(RESULT_DIR)/$(DESIGN).netlist.v
TIMING_RPT = $(RESULT_DIR)/$(DESIGN).rpt

init:
	bash -c "$$(wget -O - https://ysyx.oscc.cc/slides/resources/scripts/init-yosys-sta.sh)"

syn: $(NETLIST_V)
$(NETLIST_V): $(RTL_FILES) yosys.tcl
	mkdir -p $(@D)
	echo tcl yosys.tcl $(DESIGN) \"$(RTL_FILES)\" $(NETLIST_V) | yosys -l $(@D)/yosys.log -s -

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SDC_FILE) $(NETLIST_V)
	LD_LIBRARY_PATH=bin/ ./bin/iSTA $(PROJ_PATH)/sta.tcl $(DESIGN) $(SDC_FILE) $(NETLIST_V)

clean:
	-rm -rf result/

.PHONY: init syn sta clean
