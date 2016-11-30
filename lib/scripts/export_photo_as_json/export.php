<?php

/**
 * Assuming you have already a local copy of the site database, your settings.php should looks something like this:
 *
 * $databases['drupal6'] = array(
 *  'default' => array(
 *    'database' => 'db_name',
 *    'username' => 'your_user',
 *    'password' => 'your_password',
 *    'host' => '127.0.0.1',
 *    'port' => '',
 *    'driver' => 'mysql',
 *    'prefix' => 'prefix_',
 *  ),
 * );
 *
 *
 * Usage:
 * drush scr export.php --root=/Users/ortiz/tools/projects/dlts_viewer_distro/builds/viewer --user=1
 */

// We need extra memory
ini_set("memory_limit", "512M");

// http://docs.drush.org/en/master/bootstrap/
// http://api.drush.org/api/drush/includes%21bootstrap.inc/constant/DRUSH_BOOTSTRAP_DRUPAL_FULL/7.x
drush_bootstrap(DRUSH_BOOTSTRAP_DRUPAL_FULL);

function default_commands () {
  return array (
    array (
      'label' => t('TEST'),
      'callback' => array(
        'test',
      ),
    ),
  );
}

function prepare($caller) {

  global $settings;

  foreach (file_scan_directory(__DIR__ . '/include/', '/.*\.inc$/') as $include) include_once $include->uri;

  $settings = settings($caller);

  $install_file = $settings['script_path']['dirname'] . '/' . $settings['script_path']['filename'] . '.install';

  $info_file = $settings['script_path']['dirname'] . '/' . $settings['script_path']['filename'] . '.info';

  $includes = file_scan_directory( $settings['script_path']['dirname'], '/.*\.inc$/' );

  foreach ($includes as $include) include_once $include->uri;

}

function settings($caller) {

  $script = pathinfo($caller);

  //if ($environment = drush_get_option('environment')) {
    //if ( isset ( $settigs['mediacommons']['environments'][$environment] ) ) $settigs['mediacommons']['environment'] = $environment ;
  //}

  $settigs['script_path'] = $script;

  return $settigs ;

}

function run($task, array $commands = array()) {
  if (isset($commands[$task]) && isset($commands[$task]['callback'])) {
    foreach($commands[$task]['callback'] as $key => $callback) {
      if (function_exists($callback)) {
      	$callback();
      }
    }
  }
  else {
    drush_log('Unable to perform task', 'error');
    show_options($commands);
  }
}

function show_help(array $commands = array()) {
	drush_print('') ;
  foreach ($commands as $key => $option) {
    drush_print('[' . $key . '] ' . $option['label']);
  }
  drush_print('');
}

function show_options(array $commands = array()) {
  drush_print(t('Please type one of the following options to continue:'));
  show_help($commands);
  $handle = fopen ("php://stdin","r");
  $line = fgets($handle);
  run(trim($line), $commands);
}

function init(array $options = array()) {
  global $databases;
  if (!isset($databases['drupal6'])) {
    die(drush_set_error(dt('Unable to find Drupal 6 database.')));
  }
  $trace = debug_backtrace();
  $caller = (isset($trace[0]['file']) ? $trace[0]['file'] : __FILE__);
  $task = drush_get_option('task');
  //$default_commands = default_commands();
  //$commands = array_merge($default_commands, $options['commands']);
  $commands = $options['commands'];
  // Add exit command to end of the commands options
  $commands[] = array( 'label' => t('Exit'), 'callback' => array('drush_exit'));
  prepare($caller);
  if ($task) {
    foreach ($commands as $key => $command ) if ($commands[$key]['label'] == $task) $action = $key;
    if ($action) run($action, $commands);
    else drush_log('Unable to load task', 'error') ;
  }
  else show_options($commands);
}

$commands = array(
  array(
    'label' => t('Export Photo nodes as JSON document'),
    'callback' => array(
      'export_photos_nodes_as_json'
    ),
  ),
);

init(array('commands' => $commands));
