<?php
/**
 * PHPUnit bootstrap file for WordPress plugin
 *
 * @package WP_Dev_Kit
 */

$_tests_dir = getenv( 'WP_TESTS_DIR' );
if ( ! $_tests_dir ) {
	$_tests_dir = '/tmp/wordpress-tests-lib';
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
 * Register and load the theme.
 *
 * @return void
 */
function _register_theme() {

	$theme_dir     = dirname( dirname( __FILE__ ) );
	$current_theme = basename( $theme_dir );

	register_theme_directory( dirname( $theme_dir ) );

	add_filter( 'pre_option_template', function() use ( $current_theme ) {
		return $current_theme;
	});
	add_filter( 'pre_option_stylesheet', function() use ( $current_theme ) {
		return $current_theme;
	});
}
tests_add_filter( 'muplugins_loaded', '_register_theme' );


// Start up the WP testing environment.
require $_tests_dir . '/includes/bootstrap.php';

// Load a custom UnitTestCase if available.
if ( file_exists( $_project_dir . '/tests/testcase.php' ) ) {
	require_once $_project_dir . '/tests/testcase.php';
}
unset( $_project_dir );
