#!/usr/bin/env sh

# Split a full music mixdown into its individual clips.
#
# The master is assumed to be laid out as a fixed grid of "phrases", each an
# equal number of bars, each bar an equal number of beats. Given the tempo we
# can turn phrase ranges into exact timestamps and cut the clips out losslessly
# in musical time.
#
# The tempo is read from the file name, e.g. master-80bpm.ogg, so the same
# script works for masters rendered at any tempo. Pass one or more masters as
# arguments; with none it processes music/master-*bpm.ogg.

set -x

err() {
	echo "$(color red)$@$(color off)" >&2
}
warn() {
	echo "$(color blue)$@$(color off)" >&2
}
die() {
	err "$@"
	exit 1
}

# --- Song structure ----------------------------------------------------------
BEATS_PER_BAR=4
BARS_PER_PHRASE=2 # a phrase is 8 beats

# Which phrases make up each clip: "name first_phrase last_phrase" (1-indexed,
# inclusive). Edit this table to change the layout.
PHRASES="prelude 1 2
main 3 4
win 5 5
loss 6 6
speed_up 7 7"

# libvorbis quality for the re-encoded clips (0..10, higher is better).
QUALITY=8

split_master() {
	src="$1"
	[ -f "$src" ] || die "no such file: $src"

	name=$(basename "$src")
	# pull the integer before "bpm", e.g. master-80bpm.ogg -> 80
	bpm=$(printf '%s\n' "$name" | sed -n 's/.*[-_]\([0-9][0-9]*\)bpm.*/\1/p')
	[ -n "$bpm" ] || die "cannot read tempo from '$name' (expected e.g. master-80bpm.ogg)"

	out_dir=$(dirname "$src")

	# seconds per phrase = bars/phrase * beats/bar * (60 / bpm)
	phrase_dur=$(awk "BEGIN { print $BARS_PER_PHRASE * $BEATS_PER_BAR * 60 / $bpm }")

	# highest phrase index referenced, so we know how long the master should be
	last_phrase=$(printf '%s\n' "$PHRASES" | awk 'NF { if ($3 > m) m = $3 } END { print m }')
	expected=$(awk "BEGIN { print $last_phrase * $phrase_dur }")
	actual=$(ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 "$src")

	warn "$name: ${bpm}bpm, ${phrase_dur}s/phrase, expecting ${expected}s of audio"
	# warn (don't abort) if the master isn't as long as the layout expects: the
	# clips past the end would just come out empty.
	short=$(awk "BEGIN { print ($actual < $expected - $phrase_dur / $BARS_PER_PHRASE) ? 1 : 0 }")
	[ "$short" = 1 ] && warn "  !! master is only ${actual}s; some clips will be short or empty"

	printf '%s\n' "$PHRASES" | while read part first last; do
		[ -n "$part" ] || continue
		start=$(awk "BEGIN { print ($first - 1) * $phrase_dur }")
		dur=$(awk "BEGIN { print ($last - $first + 1) * $phrase_dur }")
		ffmpeg -i "$src" -y -ss "$start" -t "$dur" \
			-c:a libvorbis -q:a "$QUALITY" -loglevel 20 \
			"$out_dir/$part-${bpm}bpm.ogg"
	done
}

if [ $# -eq 0 ]; then
	set -- music/master-*bpm.ogg
fi

for f in "$@"; do
	split_master "$f"
done
