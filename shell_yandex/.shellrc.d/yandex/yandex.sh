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

function yandex_pssh () {
	help_message=$(cat << _EOF_
Usage example:
yandex_pssh [-h, AVAILABLE_DATABASE]

AVAILABLE DATABASES ON TESTING:
1) corp_clients
_EOF_
)

	if [[ $1 == '-h' || $1 == '--help' ]]; then
		echo "$help_message"
		return 0
	elif [[ $1 == 'corp_clients' ]]; then 
		pssh db mongo -C mdb2qa0938nfba6p2dr3 corp_clients
	else
		echo "$help_message"
		return 0
	fi

}

function yatools () {
	commandslist=$(
		cat <<-_EOF_
		ya make -ttt	#tests
		ya tool tt test -vv --auto-env -F -R services/corp-clients	#tests
		ya tool tt format .	#formatting
		make smart-format	#formatting 
		make update	#build
		ya test -F "*by_corp*" -v --regular-tests --test-log-level debug  #tests    
		ya test --style #test #formatting
		_EOF_
	)

	# echo "$commandslist" | fzf | sed 's/[ \t]*#//' | vim -
	echo "$commandslist" | fzf | sed 's/[ \t]*#//'
}

function arcprj() {
	# Parse flags
	local show_go=true
	local show_python=true
	local root_mode=false
	while [[ $# -gt 0 ]]; do
		case $1 in
			--go)
				show_go=true
				show_python=false
				shift
				;;
			--python)
				show_go=false
				show_python=true
				shift
				;;
			--root)
				root_mode=true
				shift
				;;
			*)
				echo "Usage: arcprj [--go|--python|--root]"
				return 1
				;;
		esac
	done

	# Detect Arcadia root
	local arcadia_root
	if [[ "$PWD" == ~/arcadia* ]] || [[ "$PWD" == /*/arcadia* ]]; then
		# Extract arcadia root from current path
		arcadia_root="${PWD%%/arcadia*}/arcadia"
		if [[ ! -d "$arcadia_root" ]]; then
			arcadia_root="$HOME/arcadia"
		fi
	else
		arcadia_root="$HOME/arcadia"
	fi

	# Handle root mode
	if [[ "$root_mode" == true ]]; then
		# Interactive selection for root directories
		local root_options=(
			"[GO Root] backend-go"
			"[PY Root] backend-py3"
		)
		local selected
		selected=$(printf '%s\n' "${root_options[@]}" | fzf --prompt="Select backend root: ")

		if [[ -n "$selected" ]]; then
			local root_name="${selected#*\] }"
			local root_dir="$arcadia_root/taxi/$root_name"
			if [[ -d "$root_dir" ]]; then
				cd "$root_dir" || echo "Failed to navigate to $root_dir"
			else
				echo "Directory not found: $root_dir"
				return 1
			fi
		fi
		return 0
	fi

	# Navigate to taxi directory
	if [[ ! -d "$arcadia_root/taxi" ]]; then
		echo "Error: taxi directory not found in $arcadia_root. Make sure Arcadia is mounted."
		return 1
	fi
	cd "$arcadia_root/taxi" || return 1

	# Check if backend directories exist
	if [[ ! -d "backend-go" ]] && [[ ! -d "backend-py3" ]]; then
		echo "Error: Neither backend-go nor backend-py3 directories found in $arcadia_root/taxi. Make sure Arcadia is properly mounted."
		return 1
	fi

	# Collect services dynamically
	local all_services=()

	if [[ "$show_go" == true ]]; then
		# Find all Go services under backend-go/taxi/*/services/
		while IFS= read -r service; do
			all_services+=("[GO] $service")
		done < <(find backend-go/taxi/*/services -maxdepth 1 -type d 2>/dev/null)
	fi

	if [[ "$show_python" == true ]]; then
		# Find all Python services under backend-py3/services/
		while IFS= read -r service; do
			all_services+=("[PY] $service")
		done < <(find backend-py3/services -maxdepth 1 -type d 2>/dev/null)
	fi

	# Check if any services found
	if [[ ${#all_services[@]} -eq 0 ]]; then
		echo "No services found in $arcadia_root/taxi/"
		return 1
	fi

	# Interactive selection
	local selected
	selected=$(printf '%s\n' "${all_services[@]}" | fzf --prompt="Select project: ")

	if [[ -n "$selected" ]]; then
		local target="${selected#\[*\] }"
		cd "$target" || echo "Failed to navigate to $target"
	fi
}

function arcmount () {
	local name="${1:-arcadia}"
	local mount_dir="$PWD/$name"

	if ! command -v arc >/dev/null 2>&1; then
		echo "Error: arc command not found. Please ensure Arcadia tools are installed." >&2
		return 1
	fi

	if [[ -d "$mount_dir" ]] && [[ -n "$(ls -A "$mount_dir")" ]]; then
		echo "Error: Mount directory '$mount_dir' already exists and is not empty." >&2
		return 1
	fi

	mkdir -p "$mount_dir"

	local store_dir="$HOME/.arc/stores/$(basename "$mount_dir")"
	local obj_store="$HOME/.arc/shared_objects"
	mkdir -p "$store_dir" "$obj_store"

	echo "Mounting Arcadia to '$mount_dir'..."
	if arc mount "$mount_dir" --store "$store_dir" --object-store "$obj_store" --allow-other --vfs-version 2; then
		echo "Successfully mounted Arcadia instance in '$mount_dir'."
		echo "To switch to a different branch, cd '$mount_dir' and run 'arc checkout <branch>'"
	else
		echo "Error: Failed to mount Arcadia." >&2
		return 1
	fi
}
