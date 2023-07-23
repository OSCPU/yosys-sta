export PROJ_PATH = $(shell pwd)
export FOUNDRY_PATH = $(PROJ_PATH)/nangate45
export RTL_PATH = $(PROJ_PATH)/gcd
export RESULT_PATH = $(PROJ_PATH)/result

$(shell mkdir -p $(RESULT_PATH))

MERGED_LIB = $(FOUNDRY_PATH)/lib/merged.lib

$(MERGED_LIB):
	cd $(FOUNDRY_PATH)/lib && $(PROJ_PATH)/init/mergeLib.pl nangate45_merged `ls *.lib | grep -v merged` > $@.tmp
	cd $(FOUNDRY_PATH)/lib && $(PROJ_PATH)/init/removeDontUse.pl $@.tmp "TAPCELL_X1 FILLCELL_X1 AOI211_X1 OAI211_X1" > $@
	rm $@.tmp

init: $(MERGED_LIB)

syn:
	yosys yosys_gcd.tcl | tee $(RESULT_PATH)/yosys.log

.PHONY: init syn
