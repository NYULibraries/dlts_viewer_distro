#!/bin/bash

die () {
  echo "file: ${0} | line: ${1} | step: ${2} | message: ${3}";
  exit 1;
}

while getopts ":b:h" opt; do
  case $opt in
    b)
      echo $OPTARG
      [ -d $OPTARG ] || die "Build direcotry does not exist." 
      BUILD=$OPTARG
      ;;
    h)
      echo " "
      echo " Usage: ./migrate.sh -c example.conf"
      echo " "
      echo " Options:"
      echo "   -h           Show brief help"
      echo "   -b           build realpath"
      echo "   -c <file>    Specify the configuration file to use (e.g., -c example.conf)."
      echo " "
      exit 0
      ;;
  esac
done

[ -d $BUILD ] || die "Build directory ${BUILD} does not exist."

if [ -d $BUILD/sites/all/modules/dlts_image ] && [ -d $BUILD/sites/all/libraries/openlayers ]
  then 

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/books.cfg $BUILD/sites/all/libraries/openlayers/build/books.cfg

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTS.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/DLTS.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSZoomIn.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSZoomIn.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSZoomOut.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSZoomOut.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSZoomPanel.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSZoomPanel.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSZoomOutPanel.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSZoomOutPanel.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSZoomInPanel.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSZoomInPanel.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSScrollWheel.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Control/DLTSScrollWheel.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/DLTSMouseWheel.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Handler/DLTSMouseWheel.js

    cp $BUILD/sites/all/modules/dlts_image/js/openlayers/OpenURL.js $BUILD/sites/all/libraries/openlayers/lib/OpenLayers/Layer/OpenURL.js

    cd $BUILD/sites/all/libraries/openlayers/build

    echo Building OpenLayers inside ${BUILD}
    
    ./build.py -c none books.cfg
    
    # go back to the directory the script was ran
    cd -
    
fi
