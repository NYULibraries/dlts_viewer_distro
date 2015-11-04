#!/bin/bash

die () {
  echo $1
  exit 1
}

SOURCE="${BASH_SOURCE[0]}"

# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where
  # the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DEBUG=""

while getopts ":c:hd" opt; do
  case $opt in
    c)
      [ -f $OPTARG ] || die "Configuration file does not exist." 
      CONF_FILE=$OPTARG
      ;;
    d)
      DEBUG="-d -v"
      ;;
    h)
      echo " "
      echo " Usage: ./migrate.sh -c example.conf"
      echo " "
      echo " Options:"
      echo "   -h           Show brief help"
      echo "   -c <file>    Specify the configuration file to use (e.g., -c example.conf)."
      echo " "
      exit 0
      ;;
  esac
done

[ $CONF_FILE ] || die "No configuration file provided."

# load configuration file
. $CONF_FILE

LIBRARY="$(dirname "$DIR")"/lib

[ -d $LIBRARY ] || die "Library directory ${LIBRARY} does not exist"

if [[ -f $BUILD_DIR/$BUILD_BASE_NAME/index.php ]]; then
  # check if this directory looks like Drupal 7
  MATCH=`grep -c 'DRUPAL_ROOT' $BUILD_DIR/$BUILD_BASE_NAME/index.php` 
  if [ $MATCH -gt 0 ]; then
    echo Linking build ${BUILD_DIR}/${BUILD_BASE_NAME}
    site_dirs=(modules themes)
    # find modules/themes and symlink them to the repo code
    for site_dir in "${site_dirs[@]}"
      do
        for dir in $LIBRARY/${site_dir}/*
          do
            base=${dir##*/}
            if [ -d ${BUILD_DIR}/${BUILD_BASE_NAME}/sites/all/${site_dir}/${base} ] && [ -d ${LIBRARY}/${site_dir}/${base} ]
              then
                rm -rf ${BUILD_DIR}/${BUILD_BASE_NAME}/sites/all/${site_dir}/${base}
                ln -s $LIBRARY/${site_dir}/${base} ${BUILD_DIR}/${BUILD_BASE_NAME}/sites/all/${site_dir}/${base}
            fi  
      done
    done
  fi
fi

exit 0
