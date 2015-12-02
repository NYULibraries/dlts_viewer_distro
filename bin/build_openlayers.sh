#!/bin/bash

die () {
  echo ${0};
  exit 1;
}

while getopts ":b:h" opt; do
  case $opt in
    b)
      echo $OPTARG
      [ -d $OPTARG ] || die "Build directory does not exist."
      BUILD=$OPTARG
      ;;
    h)
      echo " "
      echo " Usage: ./bin/build_openlayers.sh -b /www/site/example"
      echo " "
      echo " Options:"
      echo "   -h           Show brief help"
      echo "   -b           build realpath"
      echo " "
      exit 0
      ;;
  esac
done

[ -d $BUILD ] || die "Build directory ${BUILD} does not exist."

JS_PATH=${BUILD}/sites/all/modules/dlts_viewer/js/openlayers

LIB_PATH=${BUILD}/sites/all/libraries/openlayers

if [ -d ${JS_PATH} ] && [ -d ${LIB_PATH} ]
  then 
    cp ${JS_PATH}/books.cfg ${LIB_PATH}/build/books.cfg
    cp ${JS_PATH}/DLTS.js ${LIB_PATH}/lib/OpenLayers/DLTS.js
    cp ${JS_PATH}/DLTSZoomIn.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSZoomIn.js
    cp ${JS_PATH}/DLTSZoomOut.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSZoomOut.js
    cp ${JS_PATH}/DLTSZoomPanel.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSZoomPanel.js
    cp ${JS_PATH}/DLTSZoomOutPanel.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSZoomOutPanel.js
    cp ${JS_PATH}/DLTSZoomInPanel.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSZoomInPanel.js
    cp ${JS_PATH}/DLTSScrollWheel.js ${LIB_PATH}/lib/OpenLayers/Control/DLTSScrollWheel.js
    cp ${JS_PATH}/DLTSMouseWheel.js ${LIB_PATH}/lib/OpenLayers/Handler/DLTSMouseWheel.js
    cp ${JS_PATH}/OpenURL.js ${LIB_PATH}/lib/OpenLayers/Layer/OpenURL.js
    cd ${LIB_PATH}/build
    echo "Building OpenLayers inside ${BUILD}"
    ./build.py -c none books.cfg
    cd -
fi

exit 0
