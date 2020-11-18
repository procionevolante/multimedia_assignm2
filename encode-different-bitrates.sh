#!/bin/bash

if [ $# -ne 1 ]; then
	echo USAGE: $0 [video_file] > /dev/stderr
	exit 1
fi

# basename: same name without extensions (ex "video.mp4" --> "video").
# (basically we remove the last 4 characters)
# ${#0} = length of $0
# $((expression)) = mathematical evaluation of expression
basename="$(echo "$1" | cut -c 1-$((${#1}-4)))"
bitrates=( 800k 400k )
bufsize=( 500k 400k )
i=0
while [ $i -lt ${#bitrates[@]} ]; do
	outfile="${basename}-${bitrates[i]}.mp4"
	# go in here only if file has not been generated
	if ! [ -f "$outfile" ]; then
		# putting keyframes each 1s (24 frames)
		ffmpeg -y -i "$1" \
			-c:a copy \
			-c:v libx264 -x264-params 'keyint=24:min-keyint=24' \
			-b:v ${bitrates[i]} \
			-maxrate ${bitrates[i]} \
			-bufsize ${bufsize[i]} \
			-vf "scale=-1:720" \
			"$outfile"
	fi
	let i++
done
