#!/bin/zsh

function activatev {
  envs_location="$HOME/.venvs"
  if [[ ! -d $envs_location ]]; then
    echo location "$envs_location" doesn\'t exist
		return 1
	fi
	target=$(ls -1 "$envs_location" | fzf)
  source "${envs_location}/${target}/bin/activate"
	if [[ "$?" -eq 0 ]]; then
		echo "Virtual environment was activated"
		return 0
	fi
  return 1
}

function prj {
  if [[ -z $1 ]]; then
    target=$(find ~/*Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf)
  else
    target=$(find ~/*Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf -q $1)
  fi;

  if [[ $? == 0 ]]; then
    cd $target; 
    activatev;
    target_name=$(echo $target | sed -E 's/(.*)\/(.*$)/\2/')
    tmux_session="prj_$target_name";
    tmux ls | grep "$tmux_session": &>/dev/null
    if [[ $? != 0 ]]; then
      tmux new -s $tmux_session bash -c nvim .;
    else
      tmux attach -t $tmux_session;
    fi;
  fi;
}

function prjfzf {
  OPTIND=1
  root="$HOME/Projects/"
  while getopts :n:r:h opt; do
    case $opt in 
      n)

        new_folder=${OPTARG}
        mkdir -p "$root"/"$new_folder"
        cd "$root"/"$new_folder"
        return 0
        ;;

      r)
        0=${OPTARG}
        # cd $root
        return 0
        ;;

      h)
        o=$OPTARG
        help="DESCRIPTION\nprj - A tool to manage all your projects\n\nOPTIONS\n\t-h    Display help\n
  -n    Create new folder and enter it\n
  -r    cd into the root folder for your porjects\n
        "
        printf $help
        return 0
        ;;

    esac
  done
  echo ENDING!!!
  target=$(find ~/Projects/ -maxdepth 2 -type d -not -name '\.*' |  fzf)
  cd $target
  nvim .
}

# VCS abstraction: list of supported version control systems (in priority order)
declare -a VCS_SYSTEMS=("git" "arc")

# Helper function to detect available VCS in current directory
_get_vcs() {
	local vcs
	for vcs in "${VCS_SYSTEMS[@]}"; do
		if $vcs status >/dev/null 2>&1; then
			echo "$vcs"
			return 0
		fi
	done
	return 1
}

# Generic branches function: works with any VCS that has the same interface
function branches () {
	local vcs
	vcs=$(_get_vcs)
	
	if [[ -z "$vcs" ]]; then
		echo "Error: Not a git or arc repository" >&2
		return 1
	fi
	
	local branch
	branch=$($vcs branch | sed 's/[ \*]//g' | fzf --reverse)
	
	if [[ -n "$branch" ]]; then
		$vcs checkout "$branch"
	else
		echo "Branch was not picked"
	fi
}


