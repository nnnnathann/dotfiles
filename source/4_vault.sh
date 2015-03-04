#!/bin/bash

# INI Parser
. ~/.dotfiles/libs/bash_ini_parser/read_ini.sh

function get_mount_dir(){
	local base=$(basename $VAULT_FILE)
	local filename="${base%.*}"
	echo "/Volumes/$filename"
}

function vault_mount() {
	local mount_dir=$(get_mount_dir)
	if [ ! -d "$mount_dir" ]; then
		hdiutil attach $VAULT_FILE > /dev/null
	fi
}

function vault_dismount() {
	local mount_dir=$(get_mount_dir)
	local id=$(hdiutil info | grep "$mount_dir" | awk '{print $1}')
	if [ ! -z "$id" ]; then
		hdiutil detach $id > /dev/null
	fi
}

function vault_read() {
	function usage() {
		echo ""
		echo "Read variable value from locked .ini file"
		echo ""
		echo "  Usage: vault_read [section_name] [variable_name]"
		echo ""
	}
	if [ -z "$1" ]; then
		usage
		return
	fi
	if [ -z "$2" ]; then
		usage
		return
	fi
	vault_mount
	local mount_dir=$(get_mount_dir)
	read_ini "$mount_dir/vault.ini" $1
	var="INI__$1__$2"
	echo "${!var}"
	vault_dismount
}

function vault_read_trim {
	vault_read "$@" | cut -f3 -d' ' | tr -d '\n'
}

function vault_copy {
	vault_read "$@" | cut -f3 -d' ' | tr -d '\n' | pbcopy
}