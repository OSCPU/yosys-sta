#!/usr/bin/bash
# usage:
# $ bash synth.sh | tee ./result/gcd.log
set -e

export PROJ_PATH=$(cd "$(dirname "$0")";pwd)
export FOUNDRY_PATH=$PROJ_PATH/nangate45
export RTL_PATH=$PROJ_PATH/gcd
export RESULT_PATH=$PROJ_PATH/result

# preprocess
test -e $FOUNDRY_PATH/lib/merged.lib || bash $PROJ_PATH/mergelib.sh
test -e $RESULT_PATH || mkdir $RESULT_PATH

# run yosys
yosys $PROJ_PATH/yosys_gcd.tcl
