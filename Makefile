PROJ_PATH = $(shell pwd)

DESIGN = gcd
SDC_FILE = $(PROJ_PATH)/gcd/gcd.sdc
RTL_FILES = $(shell find $(PROJ_PATH)/gcd -name "*.v")

export FOUNDRY_PATH = $(PROJ_PATH)/nangate45
export RESULT_PATH = $(PROJ_PATH)/result/syn

$(shell mkdir -p $(RESULT_PATH))

MERGED_LIB = $(FOUNDRY_PATH)/lib/merged.lib

$(MERGED_LIB):
	cd $(FOUNDRY_PATH)/lib && $(PROJ_PATH)/init/mergeLib.pl nangate45_merged `ls *.lib | grep -v merged` > $@.tmp
	cd $(FOUNDRY_PATH)/lib && $(PROJ_PATH)/init/removeDontUse.pl $@.tmp "TAPCELL_X1 FILLCELL_X1 AOI211_X1 OAI211_X1" > $@
	rm $@.tmp

init: $(MERGED_LIB)

syn:
	echo tcl yosys.tcl $(DESIGN) $(SDC_FILE) \"$(RTL_FILES)\" | yosys -s - | tee $(RESULT_PATH)/yosys.log

.PHONY: init syn
