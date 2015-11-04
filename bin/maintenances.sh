#!/bin/bash

die () {
  echo $1
  exit 1
}

containsElement () {
  local n=$#
  local value=${!n}
  for ((i=1;i < $#;i++)) {
    if [ "${!i}" == "${value}" ]; then
      echo "y"
      return 0
     fi
  }
  echo "n"
  return 1
}

# remove if a symlink in the same directory does not point to it
remove_if_symlink_does_not_link () {
  declare -a LINKS=();
  BASE=`pwd`
  # before going crazy, make sure the given path looks like a Drupal install directory
  MATCH=`grep -c 'DRUPAL_ROOT' $1/index.php` 
  if [ $MATCH -gt 0 ]
    then
      # find link dir
      for BUILD_NAME in `ls -1 | xargs -l readlink`
        do
          LINKS=("${LINKS[@]}" "$BASE/$BUILD_NAME")
        done
        if [ $(containsElement "${LINKS[@]}" "$1") != "y" ]; then
          rm -rf $1
        fi
  fi
}

disable_drupal_clean_url () {
  if [ -d $1 ]
    then
      MATCH=`grep -c 'DRUPAL_ROOT' $1/index.php`   
      if [ $MATCH -gt 0 ]
        then
          echo Disable clean URL for $1
          drush vset clean_url 0 --yes --root=$1
    fi
  fi
  return 1
}

export -f remove_if_symlink_does_not_link

export -f containsElement

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

TODAY=`date +%Y-%m-%d`

CONF_FILE=$DIR/../build.conf

CONF_PERM=`ls -l $CONF_FILE | awk '{print $1}'`

. $CONF_FILE

[ -d $BUILD_DIR ] || die "Build directory ${BUILD_DIR} does not exist"

cd $BUILD_DIR

# find link dir
for BUILD_NAME in `ls -1 | xargs -l readlink`
  do
    disable_drupal_clean_url $BUILD_DIR/$BUILD_NAME
done

# Find and remove 14 days old directories
find $BUILD_DIR/* -maxdepth 0 -type d -mtime +14 -exec bash -c 'remove_if_symlink_does_not_link $0' {} \;

exit 0

