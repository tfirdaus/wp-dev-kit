#!/bin/bash

# Get environment variables.
while IFS= read -r line; do
	export "$(echo -e "$line" | sed -e 's/[[:space:]]*$//' -e "s/'//g")"
done < <(cat .env | grep WP_) # Get the "DATABASE_" variables.

set -ex

run_phpunit() {
	echo -e "\n🔋 Starting PHPUnit."

	local WP_TEMP_DIR=${TMPDIR-/tmp}
	local WP_TESTS_DIR=${WP_TESTS_DIR-$WP_TEMP_DIR/wordpress-tests-lib}
	local WP_CORE_DIR=${WP_CORE_DIR:-$WP_TEMP_DIR/wordpress/}
	local PLUGINS_INSTALLED=()

	# Copy the config from the test config to allow us install WordPress Core
	if [[ ! -e "$WP_CORE_DIR"wp-config.php ]]; then
		cp $WP_TESTS_DIR/wp-tests-config.php "$WP_CORE_DIR"wp-config.php
	fi

	# Check if the wp-settings.php is present on the config file.
	if [[ -e "$WP_CORE_DIR"wp-config.php ]]; then
		if ! grep -Fxq "require_once(ABSPATH . 'wp-settings.php');" "$WP_CORE_DIR"wp-config.php; then
			sed -i -e "\$arequire_once(ABSPATH . 'wp-settings.php');" "$WP_CORE_DIR"wp-config.php
		fi
	else
		echo "⛔️ The wp-config.php file is not present."; exit 1
	fi

	# Install WordPress Core to allow us using wp-cli.
	if ! wp core is-installed --path=$WP_CORE_DIR &>/dev/null; then
		wp core install --path=$WP_CORE_DIR --allow-root --skip-email \
			--title=WordPress \
			--url=example.org \
			--admin_user=admin \
			--admin_password=password \
			--admin_email=admin@example.org
	fi

	# Get the list of WordPress Plugins
	IFS=',' read -ra WP_PLUGIN_SLUGS <<< "$WP_PLUGINS"
	if [[ ${WP_PLUGIN_SLUGS[*]} ]]; then
		for WP_PLUGIN_SLUG in "${WP_PLUGIN_SLUGS[@]}"; do
			if ! wp plugin is-installed $WP_PLUGIN_SLUG --path=$WP_CORE_DIR --allow-root; then
				PLUGINS_INSTALLED+=("$WP_PLUGIN_SLUG")
			else
				echo "⚠️ '${WP_PLUGIN_SLUG}' plugin already installed."
			fi
		done
	fi

	if [[ ${PLUGINS_INSTALLED[*]} ]]; then
		echo "🚥 Installing WordPress plugins..."
		wp plugin install "${PLUGINS_INSTALLED[@]}" --path=$WP_CORE_DIR --allow-root
	fi

	# Run PHPUnit
	phpunit
}
run_phpunit
