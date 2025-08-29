#!/bin/bash

# Mount ARCADIA monorepository
ARC_DIR="$HOME/arcadia"
if [[ ! "$(ls -A "$ARC_DIR")" ]]; then
	echo "Mounting arcadia..."
	arc mount "$ARC_DIR"
	echo "Arcadia mounted"
fi

# Setup ya 
if ! which ya &>/dev/null ; then
	echo "Linking ya..."
	# Recommended option 1
	rm -f "$LOCAL_BIN/ya" &>/dev/null || true
	ln -s "$ARC_DIR/ya"  "$LOCAL_BIN/ya"

	# Recommended option 2
	# alias ya="$ARC_DIR/arcadia/ya"

	# save token localy to avoid issues with tmux (as per documentation)
	ya whoami --save-token  &>/dev/null
	echo "ya linked!"
fi

function bgo () {
	backendpy3="$ARC_DIR/taxi/backend-go/" 
	cd "$backendpy3" || true
	# service=$(find ./taxi/client-product/services/ -maxdepth 1 -d | fzf)
	service=$(find ./taxi/*/services/ -maxdepth 1 -d | fzf)
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
	read -r -p "Are you in the root of the project? y/n: " answer 

	if [[ ! $answer == "y" ]]; then
		return 1
	fi
	
	CONFIG_DIR="$HOME/Projects/ya_pyright"
	mkir -p "$CONFIG_DIR"
	# ya ide vscode-py --no-codegen -P "$CONFIG_DIR"
	ya ide vscode --py3 --no-codegen -P "$CONFIG_DIR"

	unset CONFIG_DIR
}

function yandex_pyright () {
	PYRIGHT_FILEPATH="$VIRTUAL_ENV/pyrightconfig.json" 
	if [[ ! -f "$PYRIGHT_FILEPATH" ]]; then 
		echo "Virtual environment is not active" >&2; 
		return 1; 
	fi;

	cp "$PYRIGHT_FILEPATH" "$(pwd)";

	echo "pyrightconfig.json file copied from the VIRTUAL_ENV"
}

function branches () {
	branch=$(arc branch | sed 's/[ \*]//g' | fzf --reverse)
	[ ! -z "$branch" ] && arc checkout "$branch" || echo "Branch was not picked"
}
