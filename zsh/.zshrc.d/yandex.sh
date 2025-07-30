#!/bin/bash

# Aliases
# alias bpy="cd \$ARC_DIR/taxi/backend-py3/"
# alias bgo="cd \$ARC_DIR/taxi/backend-go/"

function bgo () {
	backendpy3="$ARC_DIR/taxi/backend-go/" 
	cd "$backendpy3" || true
	service=$(find ./services/ -maxdepth 1 -d | fzf)
	if [[ -n "$service" ]]; then
		cd "$service" || true
  fi
}

function bpy () {
	backendpy3="$ARC_DIR/taxi/backend-py3/" 
	cd "$backendpy3" || true
	service=$(find ./services/ -maxdepth 1 -d | fzf)
	if [[ -n "$service" ]]; then
		cd "$service" || true
  fi
}

function yandex_setup_arc_access () {
	skotty setup
	arc
}

function yandex_create_taxi_corp_python_env () {
	mkdir -p ~/.venvs || true
	pushd "$ARC_DIR" || true
	ya ide venv \
		--venv-root ~/.venvs/taxi-python \
		-r "$(arc root)/taxi/taxi-python" \
		--target-platform=default-darwin-arm64
	popd || return 1
}

function yandex_create_pyright_config () {
	read -p "Are you in the root of the project? y/n: " answer 

	if [[ ! $answer == "y" ]]; then
		return 1
	fi
	
	CONFIG_DIR="$HOME/Projects/ya_pyright"
	mkir -p "$CONFIG_DIR"
	# ya ide vscode-py --no-codegen -P "$CONFIG_DIR"
	ya ide vscode --py3 --no-codegen -P "$CONFIG_DIR"

	unset CONFIG_DIR
}
