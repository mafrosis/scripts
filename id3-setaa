#!/bin/bash

usage="setaa filepath [value]"

# script to recursively set album artist in a directoryi

DYNAMIC=1

if [ $# -eq 2 ]
then
	VALUE=$2
	DYNAMIC=0
fi


# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $1 -name "*.mp3")
do
	echo "$FILENAME"

	if [ $DYNAMIC -eq 0 ]
	then
		# set data into MP3 tags
		id3v2 --TPE2 "$2" $FILENAME
	else
		# extract artist and embed
		ARTIST=$(id3v2 -l $FILENAME | awk '/TPE1/ {sub("TPE1 \(Lead performer\(s\)/Soloist\(s\)\): ",""); print}')
		echo $ARTIST
		id3v2 --TPE2 "$ARTIST" $FILENAME
	fi
done


# TIT2 TRCK TYER TCON TALB TPE1 TCOM APIC

