#! /bin/bash

PWD=$(pwd)

IFS="$(echo -en "\n\r")"

for FILEPATH in $(find $PWD -maxdepth 1 -name "*.sh")
do
	FILENAME=${FILEPATH##*/}
	ln -s $FILEPATH /home/mafro/bin/$FILENAME
done

