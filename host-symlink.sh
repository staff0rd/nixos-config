#!/usr/bin/env bash

HOST=`hostname`
if [[ ! -z "$1" ]]; then
	HOST=$1
fi

if [[ ! -e "/home/stafford/git/nixos-config/hosts/$HOST/configuration.nix" ]]; then
	echo "FAIL"
	exit 1
fi

ln -f "/home/stafford/git/nixos-config/hosts/$HOST/configuration.nix" .