#!/bin/bash

usage="getlandscape [-w 1024] [-r 1.2]"

MINWIDTH=1000
MINRATIO=1.2

while getopts "w:r:" options
do
	case $options in
		w ) MINWIDTH=$OPTARG;;
		r ) MINRATIO=$OPTARG;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done


# num decimal places
float_scale=2

function float_eval() {
	local stat=0
	local result=0.0
	if [[ $# -gt 0 ]]; then
		result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
		stat=$?
		if [[ $stat -eq 0 && -z "$result" ]]; then stat=1; fi
	fi
	echo $result
	return $stat
}

function float_cond() {
	local cond=0
	if [[ $# -gt 0 ]]; then
		cond=$(echo "$*" | bc -q 2>/dev/null)
		if [[ -z "$cond" ]]; then cond=0; fi
		if [[ "$cond" != 0 && "$cond" != 1 ]]; then cond=0; fi
	fi
	local stat=$((cond == 0))
	return $stat
}


IFS="$(echo -en "\n\r")"

if [ -f "$1" ]; then
	WH=$(identify -format '%w %h' $1)
	W=${WH% *}
	H=${WH#* }
	echo $W
	echo $H

else
	if [ -d "$(pwd)/tmp" ]; then
		rm -rf "$(pwd)/tmp"
	fi
	mkdir "$(pwd)/tmp"

	for FILENAME in $(find . -iname "*.jpg")
	do
		WH=$(identify -format '%w %h' "$FILENAME")
		W=${WH% *}
		H=${WH#* }
		
		# only accept landscape
		if [ $W -gt $H ]; then
			# calculate w:h ratio
			RATIO=$(float_eval "$W / $H")
			
			# only accept if over minimum width
			if [ "$W" -gt "$MINWIDTH" ]; then

				# only accept if over minimum ratio
				if float_cond "$RATIO > $MINRATIO"; then
					NEWFILE=${FILENAME##*/}
					cp "$FILENAME" "tmp/$NEWFILE"

				else
					# alert on large files which are under ratio
					echo "$FILENAME $W $RATIO"
				fi
			fi
		fi
	done
fi


