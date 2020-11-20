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
	# go in here only if file has not been generated yet
	if ! [ -f "$outfile" ]; then
		fps="$(ffprobe "$1" |& grep Video: | tr , '\n' | grep fps | cut -d ' ' -f 2)"
		if [[ "$fps" =~ "\." ]]; then
			echo get a proper video that has an integer amount of frames per \
				second otherwise this would becomes complicated
			exit 2
		fi
		# putting keyframes each 1s (30 frames)
		ffmpeg -y -i "$1" \
			-an \
			-c:v libx264 -x264-params "keyint=${fps}:min-keyint=${fps}" \
			-b:v ${bitrates[i]} \
			-maxrate ${bitrates[i]} \
			-bufsize ${bufsize[i]} \
			-vf "scale=-1:720" \
			"$outfile"
	fi
	let i++
done
