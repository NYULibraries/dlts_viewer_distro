#!/bin/bash

die () {
  echo $1
  exit 1
}

BUILD=$1

[ ! -z  $BUILD ] || die "Please provide build derectory path"

[ -d $BUILD ] || die "Build directory $BUILD does not exist"

[ ! `grep -q 'DRUPAL_ROOT' $BUILD/index.php` ] || die "${BUILD} does not look like a Drupal installation folder."

mv $BUILD/robots.txt $BUILD/robots.txt.bk

# remove any file that can easily "reveal" (not prevent) our Drupal set-up
rm $BUILD/*.txt

# we run on Apache; no need for IIS configuration file
rm $BUILD/web.config

# do the robot
mv $BUILD/robots.txt.bk $BUILD/robots.txt

# keep the file around
mv $BUILD/install.php $BUILD/install.php.off

# but no one should read it (unless super user)
chmod 000 $BUILD/install.php.off

exit 0
