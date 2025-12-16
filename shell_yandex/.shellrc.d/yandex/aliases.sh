#!/bin/bash


alias logbroker="ya tool logbroker"
# alias format="_format"
alias format="ya tool tt format"
alias update="ya project update gen"
alias check="ya tool tt check"
alias yatest="ya test"
alias style="ya test --style"


# DEPRECATED FOR NOW
_format () {
	echo "ya tool tt format $1 2>/dev/null"
	ya tool tt format "$1" 2>/dev/null
}
