#!/usr/bin/bash
# usage:
# $ bash synth.sh | tee ./result/gcd.log
set -e

export PROJ_PATH=/home/wh/yosys-nangate45-gcd
export FOUNDRY_PATH=$PROJ_PATH/nangate45
export RTL_PATH=$PROJ_PATH/gcd

# preprocess
test -e $FOUNDRY_PATH/lib/merged.lib || bash $PROJ_PATH/mergelib.sh
test -e $FOUNDRY_PATH/result || mkdir $FOUNDRY_PATH/result

# run yosys
yosys $PROJ_PATH/yosys_gcd.tcl
