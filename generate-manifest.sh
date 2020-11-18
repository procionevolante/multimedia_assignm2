#!/bin/sh

if [ $# -lt 1 ]; then
	echo USAGE: $0 [file.mp4] > /dev/stderr
	exit 1
fi

echo "len($outdir)=${#outdir}"
MP4Box -dash 2000 \
	-rap -frag-rap \
	-profile onDemand \
	-out "$outdir/output.mpd" "$@"
# it's important that the output file has the .mpd extension otherwise
# MP4Box does strange things
