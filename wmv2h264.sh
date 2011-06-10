#!/bin/bash

usage="wmv2h264 [-p pass] [-b bitrate] [-m audio:video] filename.wmv"

LOG_PREFIX="$(basename $0):"

function print_time()
{
	tmp=$1
	hours=$(($tmp / 3600))
	tmp=$(($tmp % 3600))
	mins=$(printf "%02d" $(($tmp / 60)))
	secs=$(printf "%02d" $(($tmp % 60)))
	echo "$hours:$mins:$secs"
}

# use CABAC encoding
#	-coder ac
#
# use optimum no threads
#	-threads 0
#
# deblocking algorithm
#	-flags +loop
#
# limit no processed frames
#	-vframes 1000


while getopts "p:b:m:h" options
do
	case $options in
		p ) PASS=$OPTARG;;
		b ) BITRATE=$OPTARG;;
		m ) MAP=$OPTARG;;
		h ) echo $usage
			exit 1;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done

# handle mappings to multiple streams
if [ $MAP ]
then
	AUD_MAP=" -map 0:${MAP%%:*}"
	VID_MAP=" -map 0:${MAP#*:}"
fi

# parse off the final parameter as target file
shift $(($OPTIND-1))
TARGET="$*"


# run for a single encode if params are passed
if [ $PASS ]
then
	# move to directory of target video
	BASE=$(dirname "$1")
	SOURCE=$(basename "$1")
	cd "$BASE"

	SECONDS=0

	if [ $PASS -eq 1 ]
	then
		logger "$LOG_PREFIX ===== 1st pass ====="

		# 1st pass, no audio, H.264, fast preset, destroy output
		CMD="ffmpeg -i '$SOURCE' $VID_MAP -an -pass 1 -vcodec libx264 -vpre fastfirstpass -b $BITRATE -bt $BITRATE -f rawvideo -y /dev/null"

		echo $CMD
		logger "$LOG_PREFIX $CMD"
		eval $CMD

	elif [ $PASS -eq 2 ]
	then
		logger "$LOG_PREFIX ===== 2nd pass ====="

		# 2nd pass, 128k 48kHz AAC, H.264, HQ preset, CABAC, deblocking
		CMD="ffmpeg -i '$SOURCE' $VID_MAP$AUD_MAP -acodec libfaac -ab 128k -ar 48000 -pass 2 -vcodec libx264 -vpre hq -b $BITRATE -bt $BITRATE -threads 0 -coder ac -flags +loop '$SOURCE.mp4'"

		echo $CMD
		logger "$LOG_PREFIX $CMD"
		eval $CMD
	fi

	# print execution time
	TIME=$(print_time $SECONDS)
	logger "$LOG_PREFIX completed in $TIME"

else
	# handle file or directory
	if [ -f "$TARGET" ]
	then
		FILE="$TARGET"
	else
		# search for a file to encode
		FILE=$(find "$TARGET" -iname "[!.]*.wmv" | awk 'NR==1 {print}')

		# exit if nothing found
		if [ -z "$FILE" ]
		then
			logger "$LOG_PREFIX ============================================="
			logger "$LOG_PREFIX $TARGET"
			logger "$LOG_PREFIX Nothing to transcode"
			exit
		fi
	fi

	# use mplayer to extract video's info & bitrate
	IDENT=$(mplayer -identify "$FILE" -ao null -vo null -frames 0 2>/dev/null)
	INFO=$(echo "$IDENT" | awk '/VIDEO: /') 
	BITRATE=$(echo "$IDENT" | awk '/ID_VIDEO_BITRATE=/ {sub("ID_VIDEO_BITRATE=",""); print}')
	WIDTH=$(echo "$IDENT" | awk '/ID_VIDEO_WIDTH=/ {sub("ID_VIDEO_WIDTH=",""); print}')

	# log the search path, filename and movie info
	logger "$LOG_PREFIX ============================================="
	logger "$LOG_PREFIX $TARGET"
	if [ ! -f "$TARGET" ]
	then
		logger "$LOG_PREFIX ${FILE#$TARGET}"
	fi
	logger "$LOG_PREFIX $INFO"

	# call this script for 1st and 2nd passes
	if [ $MAP ]
	then
		wmv2h264 -b $BITRATE -p 1 -m $MAP "$FILE"
		wmv2h264 -b $BITRATE -p 2 -m $MAP "$FILE"
	else
		wmv2h264 -b $BITRATE -p 1 "$FILE"
		wmv2h264 -b $BITRATE -p 2 "$FILE"
	fi

	echo "Delete source file?"
	read ok
	if [ $ok ] && [ $ok == "y" ]
	then
		rm -rf "$FILE"
		logger "$LOG_PREFIX source file deleted"
	fi
fi


