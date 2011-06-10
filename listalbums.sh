#!/bin/bash

usage="listalbums"

# script to recursively list all albums in directory

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $1 -name "01*.mp3")
do

	NAME=${FILENAME##*/}
	ARTIST=$(id3v2 -l $FILENAME | awk '/TPE1/ {sub("TPE1 \(Lead performer\(s\)/Soloist\(s\)\): ",""); print}')
	ALBUM=$(id3v2 -l $FILENAME | awk '/TALB/ {sub("TALB \(Album/Movie/Show\ title\): ",""); print}')

	echo "$ARTIST - $ALBUM"

done


# TIT2 TRCK TYER TCON TALB TPE1 TCOM APIC

