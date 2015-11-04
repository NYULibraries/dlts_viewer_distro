#!/bin/bash

# Don't use me! ... well, do it if you know what you are doing.
#
# In theory I should work; but in practice I'm almost certain that I will
# fail if you run me in a machine that does not looks like the one
# I'm intended to run it. So, don't use me if you are not sure, I can 
# easily get you into trouble.

die () {
  echo "file: ${0} | line: ${1} | step: ${2} | message: ${3}";
  exit 1;
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

while getopts ":e:hum" opt; do
 case $opt in
  u)
    UPDATE=true
    ;;
  m)
    MAINTENANCES=true
    ;;
  e)
    ENVIRONMENT=$OPTARG
    ;;
  h)
   echo " "
   echo " Usage: ./autobuild.sh"
   echo " "
   echo " Options:"
   echo "   -h           Show brief help"
   echo "   -u           Get the latest make file and do any other task before running jobs."   
   echo "   -m           Run some house cleaning before running job."   
   echo " "  
   exit 0
   ;;
  esac
done

# Get the latest make file and do any other task before running jobs
if [ $UPDATE ] ; then $DIR/update.sh ; fi

# Do some house cleaning before running job
if [ $MAINTENANCES ] ; then $DIR/maintenances.sh ; fi

projects=( tne alt-ac fieldguide imr intransition mediacommons )

for project in ${projects[*]}
  do
    $DIR/build.sh -c configs/${project}.conf -m mediacommons.make -e ${ENVIRONMENT} -k -s ;
    if [ $? -eq 0 ] ; 
      then
        echo "Successful: Build ${project}" ;
      else 
        echo ${LINENO} "build" "Fail: Build ${project}" ; 
    fi ;
done

exit 0

# Run a basic test and report if error
# ./bin/report_error.sh

exit 0
