#!/bin/bash

set -ex

if [[ -e ".eslintrc" ]]; then
	echo -e "\n🔋 Starting ESLint..."
	npm install
	if [[ ! -z "$1" ]]; then
		"$(npm bin)"/eslint $1 -f compact
	else
		"$(npm bin)"/eslint . --ext .js,.jsx --f compact
	fi
fi
