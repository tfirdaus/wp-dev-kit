#!/bin/bash
set -ex

if [[ -e "phpcs.xml" ]]; then
	echo -e "\n🔋 Starting PHPCS..."
	if [[ ! -z "$1" ]]; then
		phpcs $1
	else
		phpcs . --extensions=php
	fi
fi
