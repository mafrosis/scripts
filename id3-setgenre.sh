#!/bin/bash

# script to recursively set genre in a directory

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $1 -name "*.mp3")
do
	echo "$FILENAME"

	# set data into MP3 tags
	id3v2 --TCON "$2" $FILENAME

done



# TIT2 TRCK TYER TCON TALB TPE1 TCOM APIC

