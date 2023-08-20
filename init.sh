#!/bin/bash

ARCHIVE_PATH="https://ysyx.oscc.cc/slides/resources/archive"
test -e nangate45 || (wget -O - $ARCHIVE_PATH/nangate45.tar.bz2 | tar xfj -)
