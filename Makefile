PROJ_PATH = $(shell pwd)

DESIGN = gcd
SDC_FILE = $(PROJ_PATH)/example/gcd.sdc
RTL_FILES = $(shell find $(PROJ_PATH)/example -name "*.v")

NETLIST_FILE = $(PROJ_PATH)/result/syn/$(DESIGN).v
TIMING_RPT = $(PROJ_PATH)/result/sta/$(DESIGN).rpt

MERGED_LIB = $(PROJ_PATH)/nangate45/lib/merged.lib
init: $(MERGED_LIB)
$(MERGED_LIB):
	cd $(@D) && $(PROJ_PATH)/init/mergeLib.pl nangate45_merged `ls *.lib | grep -v merged` > $@.tmp
	cd $(@D) && $(PROJ_PATH)/init/removeDontUse.pl $@.tmp "TAPCELL_X1 FILLCELL_X1 AOI211_X1 OAI211_X1" > $@
	rm $@.tmp

syn: $(NETLIST_FILE)
$(NETLIST_FILE): $(SDC_FILE) $(RTL_FILES)
	mkdir -p $(@D)
	echo tcl yosys.tcl $(DESIGN) $(SDC_FILE) \"$(RTL_FILES)\" | yosys -s - | tee $(@D)/yosys.log

sta: $(TIMING_RPT)
$(TIMING_RPT): $(SDC_FILE) $(NETLIST_FILE)
	cd bin && LD_LIBRARY_PATH=lib/ ./iSTA $(PROJ_PATH)/sta.tcl $(DESIGN) $(SDC_FILE) $(NETLIST_FILE)

clean:
	-rm -rf result/

.PHONY: init syn sta clean
