#!/bin/bash

function run_formatters {
    # make hooks-format 1>/dev/null
    # local files_to_commit=$(arc diff --name-status --cached . | grep -v "^D.*" | awk '{$1=""; print substr($0,2)}' | sed "s|^taxi/backend-go/||")
    # if [[ -n "${files_to_commit}" ]]; then
    #     echo "${files_to_commit}" | xargs arc add
    # fi
		# ya tool tt format "$HOME/arcadia/taxi"
		ya tool tt format -s true
}


run_formatters

function main {
    echo >&2 "'Ya tool tt fromat -s true' runs"
    run_formatters
    echo >&2 "Formatting completed"
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
