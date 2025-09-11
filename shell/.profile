#!/bin/bash

# Setup Rust and Cargo
cargopath="$HOME/.cargo"
if [[ -d $cargopath ]]; then
	cargo_env="${cargopath}/env"
	if [[ -e $cargo_env ]]; then
		. "$cargo_env"
	fi
	export PATH="${cargopath}/bin:$PATH"
fi
