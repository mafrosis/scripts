#!/bin/bash

usage="autotag [-c compilation]"

# script to auto tag mp3's from filename

function capitalize {
	echo $(echo "$1" | sed 's/\(\<.\)\.*/\u\1/g')
}

MODE="album"

while getopts "c" options
do
	case $options in
		c ) MODE="compilation";;
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

ARTIST=${DIR%% - *}
YEAR=${DIR#* - }
YEAR=${YEAR%% - *}
ALBUM=${DIR##* - }

ALBUMARTIST=$ARTIST

# remove '(Disc N)' suffix from album
#ALBUM=${ALBUM%% (Disc *}

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $PWD -maxdepth 1 -name "*.mp3")
do
	NAME=${FILENAME##*/}
	TRCK=${NAME%% - *}

	echo "$NAME"

	# extract track num and title from each file
	if [ $MODE == "compilation" ]
	then
		ARTIST=${FILENAME% - *}
		ARTIST=${ARTIST##* - }
		TITLE=${NAME##* - }
		TITLE=${TITLE%.*}
	else
		TITLE=${NAME##* - }
		TITLE=${TITLE%.*}
	fi

	ARTIST=$(capitalize $ARTIST)
	TITLE=$(capitalize $TITLE)
	ALBUM=$(capitalize $ALBUM)
	ALBUMARTIST=$(capitalize $ALBUMARTIST)

	# set data into MP3 tags
	id3v2 --TIT2 "$TITLE" $FILENAME
	id3v2 --TRCK "$TRCK" $FILENAME
	id3v2 --TYER "$YEAR" $FILENAME
	id3v2 --TALB "$ALBUM" $FILENAME
	id3v2 --TPE1 "$ARTIST" $FILENAME
	id3v2 --TCOM "$ARTIST" $FILENAME
	id3v2 --TPE2 "$ALBUMARTIST" $FILENAME

done


# TIT2 TRCK TYER TCON TALB TPE1 TCOM APIC

