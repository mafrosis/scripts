#!/bin/bash

usage="uzdir [-c createdir] path"

# script to unzip entire directory of zip files

CREATEDIR=0

while getopts "c" options
do
	case $options in
		c ) CREATEDIR=1;;
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

# set Input Field Separator to newline
IFS="$(echo -en "\n\r")"

for FILENAME in $(find $PWD -maxdepth 1 -name "*.zip")
do
	NAME=${FILENAME##*/}
	DIR=${NAME%.*}

	echo $DIR

	if [ $CREATEDIR -eq 1 ]
	then
		unzip -o -d $DIR $NAME
	else
		unzip -o $NAME
	fi

done

