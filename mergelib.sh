$PROJ_PATH/mergeLib.pl nangate45_merged   \
 $FOUNDRY_PATH/lib/NangateOpenCellLibrary_typical.lib    \
 $FOUNDRY_PATH/lib/fakeram45_32x64.lib                   \
 $FOUNDRY_PATH/lib/fakeram45_64x7.lib                    \
 $FOUNDRY_PATH/lib/fakeram45_64x15.lib                   \
 $FOUNDRY_PATH/lib/fakeram45_64x21.lib                   \
 $FOUNDRY_PATH/lib/fakeram45_64x32.lib                   \
 $FOUNDRY_PATH/lib/fakeram45_64x96.lib                   \
 $FOUNDRY_PATH/lib/fakeram45_256x34.lib                  \
 $FOUNDRY_PATH/lib/fakeram45_256x95.lib                  \
 $FOUNDRY_PATH/lib/fakeram45_256x96.lib                  \
 $FOUNDRY_PATH/lib/fakeram45_512x64.lib                  \
 $FOUNDRY_PATH/lib/fakeram45_1024x32.lib                 \
 $FOUNDRY_PATH/lib/fakeram45_2048x39.lib                 \
 > $FOUNDRY_PATH/lib/merged.lib.tmp

$PROJ_PATH/removeDontUse.pl \
 $FOUNDRY_PATH/lib/merged.lib.tmp               \
 "TAPCELL_X1 FILLCELL_X1 AOI211_X1 OAI211_X1"   \
 > $FOUNDRY_PATH/lib/merged.lib
