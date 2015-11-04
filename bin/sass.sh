#!/bin/bash

THEMES=$1"/sites/all/themes"

for theme in `find $THEMES -maxdepth 1 -type d` 
  do
    if [ -f $theme/config.rb ] 
      then
        cd $theme
          bundle install --path vendor/bundle
          compass compile --force .
          rm -rf vendor
        cd -
    fi
done

exit 0
