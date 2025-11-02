set VTS [list L]

set FOUNDARY_PATH "$PROJ_HOME/pdk/icsprout55"
set STDCELL_PATH  "$FOUNDARY_PATH/IP/STD_cell/ics55_LLSC_H7C_V1p10C100"

proc get_lib_path {VT} {
  global STDCELL_PATH
  return "$STDCELL_PATH/ics55_LLSC_H7C${VT}/liberty/ics55_LLSC_H7C${VT}_typ_tt_1p2_25_nldm.lib"
}

proc get_stdcell_lef_path {VT} {
  global STDCELL_PATH
  return "$STDCELL_PATH/ics55_LLSC_H7C${VT}/lef/ics55_LLSC_H7C${VT}_ieda.lef"
}

set LIB_FILES           [lmap v $VTS {get_lib_path $v}]
set STDCELL_LEF_FILES   [lmap v $VTS {get_stdcell_lef_path $v}]
set TECH_LEF_FILE       "$FOUNDARY_PATH/prtech/techLEF/N551P6M_ieda.lef"

set _VT [lindex $VTS 0]
set TIEHI_CELL_AND_PORT "TIEHIH7${_VT} Z"
set TIELO_CELL_AND_PORT "TIELOH7${_VT} Z"
set MIN_BUF_CELL_AND_PORTS  "BUFX0P5H7${_VT} A Y"
set INO_INSERT_BUF      "BUFX0P5H7${_VT}"

set DONT_USE_CELLS [list  \
  "DFFRQNX1H7L"  \
  "DFFRQNX2H7L"  \
  "LAT*"  \
]
