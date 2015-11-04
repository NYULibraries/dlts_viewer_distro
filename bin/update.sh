#!/bin/bash

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

MAKE_FILE=$DIR/../mediacommons.make

# make sure the most recent changes to *.make file are in place
rm $MAKE_FILE

wget https://raw.githubusercontent.com/NYULibraries/mediacommons/master/mediacommons.make

exit 0
