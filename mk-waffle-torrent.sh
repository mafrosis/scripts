#!/bin/bash

usage="mkwaffles path"

# script to straight up create a mafro waffle torrent

if [ $# -ne 1 ]
then
	echo $usage
	exit 1
fi

mktorrent -a "http://tracker.waffles.fm/announce.php?passkey=63f4310b4e1ab195b63ed3a456ce6324b6b8f06e&uid=107350" -p -v -c mafro -n "$1" "$1"


