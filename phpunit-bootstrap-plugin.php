<?php
/**
 * PHPUnit bootstrap file for WordPress plugin
 *
 * @package WP_Chimp/Tests
 * @since 0.1.0
 */

global $_plugin_dep_files;
global $_project_files;

$_plugin_dep_files = array();
$_project_files = array();

$_tmp_dir = getenv( 'TMPDIR' );
if ( ! $_tmp_dir ) {
	$_tmp_dir = '/tmp';
}

$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! $_tests_dir ) {
	$_tests_dir = $_tmp_dir . '/wordpress-tests-lib';
}

$_core_dir = getenv( 'WP_CORE_DIR' );
if ( ! $_core_dir ) {
	$_core_dir = $_tmp_dir . '/wordpress/';
}

// Load Composer development dependency.
$_composer_dir = dirname( __DIR__ ) . '/vendor';
if ( file_exists( $_composer_dir . '/antecedent/patchwork/Patchwork.php' ) ) {
	require_once $_composer_dir . '/antecedent/patchwork/Patchwork.php';
}
if ( file_exists( $_composer_dir . '/autoload.php' ) ) {
	require_once $_composer_dir . '/autoload.php';
}

if ( ! file_exists( $_tests_dir . '/includes/functions.php' ) ) {
	throw new Exception( "Could not find $_tests_dir/includes/functions.php, have you run bin/install-wp-tests.sh ?" );
}

// Give access to tests_add_filter() function.
require_once $_tests_dir . '/includes/functions.php';

/**
 * Get the main plugin / project files
 *
 * @var string
 */
$_project_dir = getcwd();
foreach ( glob( $_project_dir . '/*.php' ) as $_project_file_candidate ) {
	$_project_file_src = file_get_contents( $_project_file_candidate );
	if ( preg_match( '/Plugin\s*Name\s*:/', $_project_file_src ) ) {
		$_project_files[] = $_project_file_candidate;
		break;
	}
}

// Abort if we cannot find the file with the metablock.
if ( ! isset( $_project_files ) ) {
	throw new Exception( 'Unable to locate a file containing a plugin metadata block.' );
}
unset( $_project_dir, $_project_file_candidate, $_project_file_src, $_composer_dir );

/**
 * Get the plugin dependencies
 *
 * @var array
 */
$_plugin_deps = glob( $_core_dir . 'wp-content/plugins/*' );
foreach ( $_plugin_deps as $_plugin_candidate ) {
	if ( ! is_dir( $_plugin_candidate ) ) {
		continue;
	}
	foreach ( glob( $_plugin_candidate . '/*.php' ) as $_plugin_file_candidate ) {
		$_plugin_file_src = file_get_contents( $_plugin_file_candidate );
		if ( preg_match( '/Plugin\s*Name\s*:/', $_plugin_file_src ) ) {
			$_plugin_dep_files[] = $_plugin_file_candidate;
			break;
		}
	}
}
unset( $_plugin_deps, $_plugin_candidate, $_plugin_file_candidate, $_plugin_file_src );

/**
 * Load the plugins
 *
 * @return void
 */
function manually_load_plugin() {

	/**
	 * Load the plugin dependencies
	 *
	 * @var array
	 */
	global $_plugin_dep_files;
	if ( is_array( $_plugin_dep_files ) && ! empty( $_plugin_dep_files ) ) {
		foreach ( $_plugin_dep_files as $dep_file ) {
			require_once $dep_file;
		}
	}

	/**
	 * Load the project files
	 *
	 * @var array
	 */
	global $_project_files;
	if ( is_array( $_project_files ) && ! empty( $_project_files ) ) {
		foreach ( $_project_files as $project_file ) {
			require_once $project_file;
		}
	}
	unset( $_plugin_dep_files, $_project_files );
}
tests_add_filter( 'muplugins_loaded', 'manually_load_plugin' );

// Start up the WP testing environment.
require $_tests_dir . '/includes/bootstrap.php';
