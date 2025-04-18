PROJ_PATH = $(shell pwd)
SHELL := /bin/bash

O ?= $(PROJ_PATH)
DESIGN ?= gcd
SDC_FILE ?= $(PROJ_PATH)/scripts/default.sdc
RTL_FILES ?= $(shell find $(PROJ_PATH)/example -name "*.v")
export CLK_FREQ_MHZ ?= 500
export CLK_PORT_NAME ?= clk
PDK = nangate45

RESULT_DIR = $(O)/result/$(DESIGN)-$(CLK_FREQ_MHZ)MHz
SCRIPT_DIR = $(PROJ_PATH)/scripts
NETLIST_SYN_V   = $(RESULT_DIR)/$(DESIGN).netlist.syn.v
NETLIST_FIXED_V = $(RESULT_DIR)/$(DESIGN).netlist.fixed.v
TIMING_RPT = $(RESULT_DIR)/$(DESIGN).rpt

init:
	bash -c "$$(wget -O - https://ysyx.oscc.cc/slides/resources/scripts/init-yosys-sta.sh)"

syn: $(NETLIST_SYN_V)
$(NETLIST_SYN_V): $(RTL_FILES) $(SCRIPT_DIR)/yosys.tcl
	mkdir -p $(@D)
	echo tcl $(SCRIPT_DIR)/yosys.tcl $(DESIGN) $(PDK) \"$(RTL_FILES)\" $@ | yosys -l $(@D)/yosys.log -s -

fix-fanout: $(NETLIST_FIXED_V)
$(NETLIST_FIXED_V): $(SCRIPT_DIR)/fix-fanout.tcl $(SDC_FILE) $(NETLIST_SYN_V)
	set -o pipefail && ./bin/iEDA -script $^ $(DESIGN) $(PDK) $@ 2>&1 | tee $(RESULT_DIR)/fix-fanout.log
	echo tcl $(SCRIPT_DIR)/yosys-area.tcl $(DESIGN) $(PDK) $@ | yosys -l $(@D)/yosys-fixed.log -s -

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SCRIPT_DIR)/sta.tcl $(SDC_FILE) $(NETLIST_FIXED_V)
	set -o pipefail && ./bin/iEDA -script $^ $(DESIGN) $(PDK) 2>&1 | tee $(RESULT_DIR)/sta.log

clean:
	-rm -rf result/

.PHONY: init syn fix-fanout sta clean
