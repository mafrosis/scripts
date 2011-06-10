#!/bin/bash

usage="mkm3u [-o overwrite] path"

# script to create an M3U playlist of all MP3s in a directory

OVERWRITE=0

while getopts "o" options
do
	case $options in
		o ) OVERWRITE=1;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done

# first extract the current directory name
PWD=$(pwd)
DIR=${PWD##*/}

echo $DIR

# check existing
if [ -f "$DIR.m3u" ] && [ $OVERWRITE = 0 ]
then
	echo "Already exists. Use -o to overwrite."
	exit 1
fi

# create new file
echo "#EXTM3U" > "$DIR.m3u"

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $PWD -maxdepth 1 -name "*.mp3" | sort -n)
do
	NAME=${FILENAME##*/}
	
	echo "$NAME"

	# extract the ID3v2 title tag
	TITLE=$(id3v2 -l "$FILENAME" | awk '/TIT2/ {sub("TIT2 \(Title/songname/content description\): ",""); print;}')

	# get the length of mp3 file
	LEN=$(mp3info -p "%S" "$FILENAME")

	echo "#EXTINF:$LEN,$TITLE" >> "$DIR.m3u"
	echo "$NAME" >> "$DIR.m3u"

done

