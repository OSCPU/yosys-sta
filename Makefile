PROJ_PATH = $(shell pwd)

DESIGN = gcd
SDC_FILE = $(PROJ_PATH)/gcd/gcd.sdc
RTL_FILES = $(shell find $(PROJ_PATH)/gcd -name "*.v")

export FOUNDRY_PATH = $(PROJ_PATH)/nangate45
export RESULT_PATH = $(PROJ_PATH)/result/syn

$(shell mkdir -p $(RESULT_PATH))

init:
	test -e nangate45 || (wget -O - https://ysyx.oscc.cc/slides/resources/archive/nangate45.tar.bz2 | tar xfj -)

syn:
	echo tcl yosys.tcl $(DESIGN) $(SDC_FILE) \"$(RTL_FILES)\" | yosys -s - | tee $(RESULT_PATH)/yosys.log

.PHONY: init syn
