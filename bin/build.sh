#!/bin/bash

die () {
  echo "file: ${0} | line: ${1} | step: ${2} | message: ${3}" ;
  rm ${DIR}/../temp/${BUILD_BASE_NAME}.build.pid ;
  exit 1 ;
}

tell () { 
  echo "file: ${0} | line: ${1} | step: ${2} | command: ${3}";
}

function is_drupal_online () {
  DRUSH_STATUS_COMMAND="${DRUSH} -d -v core-status \
    --root=${BUILD_DIR}/${BUILD_NAME}              \
    --uri=${BASE_URL}                              \
    --user=1"

  DRUPAL_DATABASE_CONNECTION_OK="Successfully connected to the Drupal database"
  DRUPAL_BOOTSTRAP_OK="Drupal bootstrap                :  Successful"

  # Using $(echo $DRUSH_STATUS_COMMAND) to remove extra whitespace
  tell ${LINENO} 'is_drupal_online()' "$(echo $DRUSH_STATUS_COMMAND)"

  # NOTE: 2>&1 doesn't work when put into DRUSH_STATUS_COMMAND string, so have to
  #   do the redirect here.
  SITE_ONLINE=`${DRUSH_STATUS_COMMAND} 2>&1`

  if [[ $SITE_ONLINE =~ $DRUPAL_DATABASE_CONNECTION_OK ]] && \
     [[ $SITE_ONLINE =~ $DRUPAL_BOOTSTRAP_OK ]]
     then return 0
     else return 1
   fi
}

SOURCE="${BASH_SOURCE[0]}"

# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it 
  # relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done

TODAY=`date +%Y%m%d`

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DEBUG=""

ENVIRONMENT="local"

# Don't waste time; if MongoDB PHP extension is not installed, die!!!
PHPTEST=`php -info | grep mongo`

if [ -z "$PHPTEST" ]; then die ${LINENO} "test" "Fail: This project needs MongoDB PHP extension."; fi ;

while getopts ":e:c:m:hdflsikt" opt; do
 case $opt in
  c)
   [ -f $OPTARG ] || die "Configuration file does not exist." 
   CONF_FILE=$OPTARG
   ;;
  m)
    [ -f $OPTARG ] || die "Make file does not exist."
    MAKE_FILE=$OPTARG
    ;;
  e)
    ENVIRONMENT=$OPTARG
    ;;
  d)
    DEBUG='-d -v'
    ;;
  f)
    FORCE_OVERWRITE=true
    ;;
  l)
    LEGACY_DRUSH=true
    ;;
  s)
    SASS=true
    ;;
  k)
    COOKIES=true
    ;;
  t)
    SIMULATE=true
    ;;    
  h)
   echo " "
   echo " Usage: ./build.sh -m example.make -c example.conf"
   echo " "
   echo " Options:"
   echo "   -h           Show brief help"
   echo "   -e           Set the environment variable (default to local) if not set."
   echo "   -k           Allow site to share cookies accross domain"   
   echo "   -s           Find SASS based themes and compile"   
   echo "   -c <file>    Specify the configuration file to use (e.g., -c example.conf)."
   echo "   -m <file>    Specify the make file to use (e.g., -m example.make)."
   echo "   -t           Tell all relevant actions (don't actually change the system)."
   echo " "  
   exit 0
   ;;
  esac
done

# https://jira.nyu.edu/browse/DLTSVIEWER-16
# Our web server php is lower than version 5.4, which causes bin/drush to break.
if [ $LEGACY_DRUSH ]
then
    DRUSH=$(which drush)
else
    DRUSH=$DIR/drush
fi

tell ${LINENO} 'Set DRUSH' "\$DRUSH=${DRUSH}"

[ $CONF_FILE ] || die "No configuration file provided."

[ $MAKE_FILE ] || die "No make file provided."

# load configuration file
. $CONF_FILE

TEMP_DIR=${DIR}/../temp

STEP_0="mkdir ${TEMP_DIR}" ;

if [ ! -d $TEMP_DIR ] ; then if [ ! $SIMULATE ] ; then eval $STEP_0 ; else tell ${LINENO} 1 "${TEMP_DIR}" ; fi ; fi ;

echo $$ > ${DIR}/../temp/${BUILD_BASE_NAME}.build.pid

# Drupal need a valid email for user account
DRUPAL_ACCOUNT_MAIL_VALID=$(echo ${DRUPAL_ACCOUNT_MAIL} | grep -E "^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$")

if [ "x${DRUPAL_ACCOUNT_MAIL_VALID}" = "x" ]; then die ${LINENO} "test" "Fail: Drupal need a valid email for site account (${DRUPAL_ACCOUNT_MAIL})."; fi ;

# Drupal need a valid email for site account
DRUPAL_SITE_MAIL_VALID=$(echo ${DRUPAL_SITE_MAIL} | grep -E "^(([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))\.)*([-a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~]+|(\"([][,:;<>\&@a-zA-Z0-9\!#\$%\&\'*+/=?^_\`{\|}~-]|(\\\\[\\ \"]))+\"))@\w((-|\w)*\w)*\.(\w((-|\w)*\w)*\.)*\w{2,4}$")

if [ "x${DRUPAL_SITE_MAIL_VALID}" = "x" ]; then die ${LINENO} "test" "Fail: Drupal need a valid email for site account (${DRUPAL_ACCOUNT_MAIL})."; fi ;

[ -w $BUILD_DIR ] || die ${LINENO} "test" "Unable to write to ${BUILD_DIR} directory." ;

STEP_1="mkdir ${BUILD_DIR}" ;

if [ ! -d $BUILD_DIR ] ; then if [ ! $SIMULATE ] ; then eval $STEP_1 ; else tell ${LINENO} 1 "${STEP_1}" ; fi ; fi ;

# read password from configuration file; if not available or empty assing $TODAY as a temporary password
if [ -z ${DRUPAL_ACCOUNT_PASS} -a ${DRUPAL_ACCOUNT_PASS}=="" ]; then DRUPAL_ACCOUNT_PASS=${TODAY} ; fi ;
  
echo "Prepare new site using ${MAKE_FILE}." ;

# Step 2: Download and prepare for the installation using make file
STEP_2="${DRUSH} ${DEBUG} make --prepare-install -y ${MAKE_FILE} ${BUILD_DIR}/${BUILD_NAME} --uri=${BASE_URL} --environment=${ENVIRONMENT} --strict=0" ;

# drush make --prepare-install command will fail with error
# "Base path [PATH] already exists." if ${BUILD_DIR}/${BUILD_NAME} already exists.
# -f will force overwrite of this existing directory.
if [ $FORCE_OVERWRITE ]
then
  RM_CMD="rm -fr ${BUILD_DIR}/${BUILD_NAME}"

  if [ ! $SIMULATE ]
  then
    echo '`-f` force overwrite option was set'
    echo "${RM_CMD}"
    eval $RM_CMD
  else
    tell ${LINENO} 'FORCE_OVERWRITE' "${RM_CMD}"
  fi
fi

if [ ! $SIMULATE ] ; then eval $STEP_2 ; else tell ${LINENO} 2 "${STEP_2}" ; fi ;

if [ $? -eq 0 ] ; then echo "Successful: Downloaded and prepared for the installation using make ${MAKE_FILE} and configuration ${CONF_FILE}." ; else die ${LINENO} 2 "Fail: Download and prepare for the installation using make make ${MAKE_FILE} and configuration ${CONF_FILE}." ; fi ;

if [ ! $SIMULATE ] ; then [ -d $BUILD_DIR/$BUILD_NAME ] || die ${LINENO} 2 "Unable to install new site, build ${BUILD_DIR}/${BUILD_NAME} does not exist." ; fi

# link to the lastes build if BUILD_BASE_NAME it's different from BUILD_NAME
if [ ! $SIMULATE ] ; then 
  if [ $BUILD_BASE_NAME != $BUILD_NAME ]; then
    if [ -L ${BUILD_DIR}/${BUILD_BASE_NAME} ]; then echo "Build linked" ; else ln -s ${BUILD_DIR}/${BUILD_NAME} ${BUILD_DIR}/${BUILD_BASE_NAME}  ; fi ;  
    # build base name its a link?
    if [[ -h $BUILD_DIR/$BUILD_BASE_NAME ]]; then
      cd $BUILD_DIR
      rm $BUILD_DIR/$BUILD_BASE_NAME
      ln -s $BUILD_NAME $BUILD_BASE_NAME
      cd -
    fi
    
  fi
fi

 # Step 3: Reuse code that has been linked in the lib folder
STEP_3="${DIR}/link_build.sh -c ${CONF_FILE}" ;

if [ ! $SIMULATE ] ; 
  then 
    eval $STEP_3 ;    
    cp -r ${DIR}/../lib/profiles/viewer ${BUILD_DIR}/${BUILD_BASE_NAME}/profiles/viewer
    if [ $? -eq 0 ] ; then echo "Successful: Reuse code that has been linked in the lib folder." ; else die ${LINENO} 3 "Fail: Reuse code that has been linked in the lib folder." ; fi ;
  else 
    tell ${LINENO} 3 "${STEP_3}" ;
fi ;

echo "Install new site" ;

# Step 4: Run the site installation
STEP_4="${DRUSH} ${DEBUG} -y site-install ${DRUPAL_INSTALL_PROFILE_NAME} --site-name='${DRUPAL_SITE_NAME}' --account-pass="${DRUPAL_ACCOUNT_PASS}" --account-name=${DRUPAL_ACCOUNT_NAME} --account-mail=${DRUPAL_ACCOUNT_MAIL} --site-mail=${DRUPAL_SITE_MAIL} --db-url=${DRUPAL_SITE_DB_TYPE}://${DRUPAL_SITE_DB_USER}:${DRUPAL_SITE_DB_PASS}@${DRUPAL_SITE_DB_ADDRESS}/${DRUPAL_DB_NAME} --root=${BUILD_DIR}/${BUILD_NAME} --environment=${ENVIRONMENT} --strict=0"

echo $STEP_4 ;

if [ ! $SIMULATE ] ; 
  then 
    eval $STEP_4 ;
    if [ $? -eq 0 ] ; then echo "Successful: Ran the site installation." ; else die ${LINENO} 4 "Fail: Run the site installation" ; fi ;
  else 
    tell ${LINENO} 4 "${STEP_4}" ;
fi ;

if [ ! $SIMULATE ] ; then if is_drupal_online ; then echo "Successful: Drupal is online" ; else die ${LINENO} "test" "Fail: Drupal is offline." ; fi ; fi; 

if [ ! $SIMULATE ]
then
    if [ [ -f $BUILD_DIR/$BUILD_NAME/sites/default/settings.php ] ; then
      chmod 775 $BUILD_DIR/$BUILD_NAME/sites/default/settings.php ;
      if [ $? -eq 0 ] ; then echo "Successful: Change ${BUILD_DIR}/${BUILD_NAME}/sites/default/settings.php permission to 775." ; else die ${LINENO} "test" "Fail: Change ${BUILD_DIR}/${BUILD_NAME}/sites/default/settings.php permission to 775." ; fi ;
    fi ;

    if [ -d $BUILD_DIR/$BUILD_NAME/sites/default ] ; then
      chmod 775 $BUILD_DIR/$BUILD_NAME/sites/default ;
      if [ $? -eq 0 ] ; then echo "Successful: Change ${BUILD_DIR}/${BUILD_NAME}/sites/default permission to 775." ; else die ${LINENO} "test" "Fail: Change ${BUILD_DIR}/${BUILD_NAME}/sites/default permission to 775." ; fi ;
    fi ;

    if [ -d $BUILD_DIR/$BUILD_NAME/sites/all/libraries/openlayers ] ; then
      # Build OpenLayers library
      sh ${DIR}/build_openlayers.sh -b ${BUILD_DIR}/${BUILD_NAME}
      if [ $? -eq 0 ] ; then echo "Successful: Build OpenLayers library from source." ; else die ${LINENO} "test" "Fail: Build OpenLayers library from source.." ; fi ;
    fi ;
fi

# Step 5: Remove text files and rename install.php to install.php.off
STEP_5="${DIR}/cleanup.sh ${BUILD_DIR}/${BUILD_NAME}" ;

if [ ! $SIMULATE ] ; 
  then 
    eval $STEP_5 ; 
  if [ $? -eq 0 ] ; then echo "Successful: Remove text files and rename install.php to install.php.off." ; else die ${LINENO} 5 "Fail: Remove text files and rename install.php to install.php.off." ; fi ;
  else 
    tell ${LINENO} 5 "${STEP_5}" ; 
fi ;

# Step 6: Find SASS config.rb and compile the CSS file
STEP_6="${DIR}/sass.sh ${BUILD_DIR}/${BUILD_NAME}" ;
 
if [ ! $SIMULATE ] ; 
  then 
    if [ $SASS ] ;
      then  
        eval $STEP_6 ; 
        if [ $? -eq 0 ] ; then echo "Successful: Find SASS config.rb and compile the CSS file." ; else die ${LINENO} 6 "Fail: Find SASS config.rb and compile the CSS file." ; fi ;
      fi ;
  else
    tell ${LINENO} 6 "${STEP_6}" ;
fi

# Step 7: Share cookies
STEP_7="${DIR}/cookies.sh -c ${CONF_FILE} -b ${BUILD_DIR}/${BUILD_NAME}"
if [ ! $SIMULATE ] ; 
  then
    if [ $COOKIES ] ; 
      then 
        eval $STEP_7 ; 
        if [ $? -eq 0 ] ; then echo "Successful: Share cookies." ; else die ${LINENO} 7 "Fail: Share cookies." ; fi ;
    fi ;
  else 
    tell ${LINENO} 7 "${STEP_7}" ;
fi ;

if [ ! $SIMULATE ] ; 
  then
    # do a quick status check
    $DIR/check_build.sh $BUILD_DIR/$BUILD_NAME $BASE_URL
    chmod 755 $BUILD_DIR/$BUILD_NAME/sites/default/settings.php
    chmod 755 $BUILD_DIR/$BUILD_NAME/sites/default
    chmod -R 2777 $BUILD_DIR/$BUILD_NAME/sites/default/files
fi ;

rm ${DIR}/../temp/${BUILD_BASE_NAME}.build.pid

exit 0
