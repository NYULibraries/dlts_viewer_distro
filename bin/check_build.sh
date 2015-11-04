#!/bin/bash

BUILD_ROOT=$1

BUILD_URI=$2

STATUS=`curl -s -o /dev/null -w "%{http_code}" $BUILD_URI`

echo Base URL $BUILD_URI reported status $STATUS

drush status --root=$BUILD_ROOT --uri=$BUILD_URI --user=1

drush features-list --root=$BUILD_ROOT --uri=$BUILD_URI --user=1

drush uli --root=$BUILD_ROOT --uri=$BUILD_URI --user=1

exit 0
