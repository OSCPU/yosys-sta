export PROJ_PATH = $(shell pwd)
export FOUNDRY_PATH = $(PROJ_PATH)/nangate45
export RTL_PATH = $(PROJ_PATH)/gcd
export RESULT_PATH = $(PROJ_PATH)/result

$(shell mkdir -p $(RESULT_PATH))

init:
	test -e nangate45 || (wget -O - https://ysyx.oscc.cc/slides/resources/archive/nangate45.tar.bz2 | tar xfj -)

syn:
	yosys yosys_gcd.tcl | tee $(RESULT_PATH)/yosys.log

.PHONY: init syn
