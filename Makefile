PROJ_PATH = $(shell pwd)

DESIGN = gcd
SDC_FILE = $(PROJ_PATH)/example/gcd.sdc
RTL_FILES = $(shell find $(PROJ_PATH)/example -name "*.v")

NETLIST_FILE = $(PROJ_PATH)/result/syn/$(DESIGN).v
TIMING_RPT = $(PROJ_PATH)/result/sta/$(DESIGN).rpt

init:
	bash -c "$$(wget -O - https://ysyx.oscc.cc/slides/resources/scripts/init-yosys-sta.sh)"

syn: $(NETLIST_FILE)
$(NETLIST_FILE): $(SDC_FILE) $(RTL_FILES)
	mkdir -p $(@D)
	echo tcl yosys.tcl $(DESIGN) $(SDC_FILE) \"$(RTL_FILES)\" | yosys -s - | tee $(@D)/yosys.log

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SDC_FILE) $(NETLIST_FILE)
	LD_LIBRARY_PATH=bin/ ./bin/iSTA $(PROJ_PATH)/sta.tcl $(DESIGN) $(SDC_FILE) $(NETLIST_FILE)

clean:
	-rm -rf result/

.PHONY: init syn sta clean
