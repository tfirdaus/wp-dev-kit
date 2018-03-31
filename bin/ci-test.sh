#!/bin/bash

while IFS= read -r line; do
	export "$(echo -e "$line" | sed -e 's/[[:space:]]*$//' -e "s/'//g")"
done < <(cat .env | grep WP_) # Get the "WP_" variables.

while IFS= read -r line; do
	export "$(echo -e "$line" | sed -e 's/[[:space:]]*$//' -e "s/'//g")"
done < <(cat .env | grep DB_) # Get the "DB_" variables.

while IFS= read -r line; do
	export "$(echo -e "$line" | sed -e 's/[[:space:]]*$//' -e "s/'//g")"
done < <(cat .env | grep DOCKER_) # Get the "DOCKER_" variables.

set -ex

# List of services in the Docker Composer file location.
WORDPRESS_SERVICES=$(docker-compose -f $DOCKER_COMPOSE_FILE config --services | grep "wordpress-")

# Get the arguments passed and assigned to a variable.
FLUSH=0
SKIPS=''
for i in "$@"; do
	case $i in
		# Get the --flush argument.
		--flush)
	    	FLUSH=1
		;;
		# Get the --precommit argument.
		--precommit)
	    	PRECOMMIT=1
		;;
		# Get the --skips arguments.
		--skips=*)
			SKIPS="${i#*=}"
		shift
		;;
		*)
		# Unknown options
		;;
	esac
done

# Function to check if particular test is skipped
skip() {
	if [[ -z "${SKIPS##*$1*}" ]]; then
		echo 1;
	else
		echo 0;
	fi
}

# Function to check if STDOUT and put down the containers
status() {
	if [[ $1 -ne 0 ]]; then
		docker-compose -f $DOCKER_COMPOSE_FILE down --volumes --remove-orphans; exit 1
	elif [[ $1 == 'pass' ]] && [[ ! -z $(docker-compose -f $DOCKER_COMPOSE_FILE ps -q) ]]; then
		docker-compose -f $DOCKER_COMPOSE_FILE down
	fi
}

# Function to get changes between commits, commit and working tree, etc.
diff_files() {

	for i in "$@"; do
	case $i in
		-ext=*|--extensions=*)
		# RegEx to get the file extensions.
	    EXTENSIONS="${i#*=}"
	    shift
	    ;;
	esac
	done
	echo "$(git diff --cached --name-only --diff-filter=ACM | grep ${EXTENSIONS})"
}

# Function to evaluate codes with PHP Code Sniffers and WordPress Code Standards
test_phpcs() {

	docker-compose -f $DOCKER_COMPOSE_FILE run --rm wordpress-default bash -c "\
	echo 'Run PHPUnit in PHP 5.4' &&
	bash ${WP_PROJECT_DIR}dev-kit/bin/ci-phpcs.sh '${1}'"
}

# Functions to evaluate functions, classes and its methods with PHPUnit
test_phpunit() {

	for WP_SERVICE in $WORDPRESS_SERVICES; do
		docker-compose -f $DOCKER_COMPOSE_FILE run --rm $WP_SERVICE bash -c "\
		echo 'Run PHPUnit in $WP_SERVICE'; \
		bash ${WP_PROJECT_DIR}dev-kit/bin/install-wp-tests.sh $DB_NAME $DB_USER $DB_PASSWORD $DB_HOST latest true; \
		bash ${WP_PROJECT_DIR}dev-kit/bin/ci-phpunit.sh"
		status $?
	done
}

# Function to evaluate JavaScript code stanadrard ESLint
test_eslint() {

	docker-compose -f $DOCKER_COMPOSE_FILE run --rm wordpress-default bash -c "\
	bash ${WP_PROJECT_DIR}dev-kit/bin/ci-eslint.sh '${1}'"
	status $?
}

# Function to run all the test functions
run_test() {

	if [[ $( skip 'phpcs' ) == 0 ]]; then
		test_phpcs
	fi

	if [[ $( skip 'phpunit' ) == 0 ]]; then
		test_phpunit
	fi

	if [[ $( skip 'eslint' ) == 0 ]]; then
		test_eslint
	fi

	status 'pass'
}

# Function to run the test during precommit hook action.
#
# Compare to the `run_test` function above this
# function will only evaluate staged files
# in Git, instead of evaluating all the
# files.
run_precommit() {

	test_phpcs $(diff_files --ext=".php")
	test_phpunit

	test_eslint $(diff_files --ext=".jsx\{0,1\}$")

	status 'pass'
}

if [[ $FLUSH -eq 1 ]]; then
	docker-compose -f $DOCKER_COMPOSE_FILE down --volumes --remove-orphans
elif [[ $PRECOMMIT -eq 1 ]]; then
	run_precommit
else
	run_test
fi
