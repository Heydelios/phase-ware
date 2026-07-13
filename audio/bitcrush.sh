#!/usr/bin/env sh

set -x

err() {
	echo "$(color red)$@$(color off)" >&2
}
warn() {
	echo "$(color blue)$@$(color off)" >&2
}
die() {
	err $@
	exit 1
}
die() {
	warn "bitcrush [files]"
}

_bitcrush() {
	base_dir="$1"
	file_path="$2"

	mkdir -p "bitcrushed_sfx/$(dirname "$file_path")"
	ffmpeg -i "$base_dir/$file_path" -y -af 'acrusher=bits=8:samples=8' -loglevel 20 "bitcrushed_sfx/$file_path"
}

bitcrush_folder() {
	find "$1" -name '*.wav' -or -name '*.mp3' -or -name '*.ogg' |
	cut -d/ -f1 --complement | #remove leading "./"
	while read file; do
		_bitcrush "$1" "$file"
	done
}

bitcrush_folder raw
bitcrush_folder warioware_sfx
