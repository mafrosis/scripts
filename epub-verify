#!/bin/bash

# dependencies:
# http://code.google.com/p/epubcheck
# http://home.ccil.org/~cowan/XML/tagsoup

usage="Usage: git-ebook-verify [-q] [-f] [-t] [file]"

quiet=0
fix=0
tagsoup=0

while getopts "qft" options
do
	case $options in
		q ) quiet=1;;
		f ) fix=1;;
		t ) tagsoup=1;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done
shift $((OPTIND-1))

IFS="$(echo -en "\n\r")"

TMPDIR="/tmp/ebook-verify"


# if no params supplied
if [ $# -eq 0 ]; then

	# verify the current directory
	DIR=$(pwd)
	if [ $quiet -eq 0 ]; then
		echo "Directory: $DIR"
	fi

	# first publish to /tmp
	mkdir -p "$TMPDIR"
	OUTPUT=$(git-ebook-publish -h /tmp/ebook-verify)
	wait $!

	# get epub path from git-ebook-publish output
	EPUB=${OUTPUT#*Written to }

# if single param supplied
elif [ $# -eq 1 ]; then

	# check for fix parameter; only works when epub is extracted
	if [ $fix -eq 1 ]; then
		echo "The fix option is only available when the epub is extracted. Please run git-ebook-init first."
		exit 1
	fi

	if [ -f "$1" ]; then
		# extract filename and clean any preceeding path
		EPUB=${1##*/}
		if [ $quiet -eq 0 ]; then
			echo "File: $EPUB"
		fi
	else
		echo "Cannot find or open $EPUB."
		exit 1;
	fi

else
	echo $usage
	exit 1
fi


if [ $tagsoup -eq 1 ]; then
	# run all xhtml files through tagsoup
	for FILE in $(find . -iname "*.xhtml" -type f)
	do
		echo "Processing $FILE with tagsoup"
			
		# use tagsoup to beautify our awful markup
		java -jar "/usr/share/java/tagsoup-1.2.jar" --files "$FILE"
		mv "$FILE"_ "$FILE"
	done
fi


if [ $fix -eq 1 ]; then
	# load report from epubcheck
	REPORT=$(java -jar "/usr/share/java/epubcheck-1.2.jar" "$EPUB" 2>&1)

	# iterate each error; build list of files
	for ERROR in $(echo "$REPORT" | awk '/^ERROR/ {print}')
	do
		# trim out file path
		FILE=${ERROR#* }
		FILE=${FILE%%:*}
		
		# remove the preceding path to /tmp
		FILE=${FILE#*$EPUB/}

		# possibly a trailing line number too
		if [ -n "$(echo "$FILE" | awk '/\)$/ {print 1}')" ]; then
			FILE=${FILE%\(*}
		fi
		
		# append to filelist
		if [ -z "$FILELIST" ]; then
			FILELIST="$FILE"
		else
			FILELIST="$FILELIST\n$FILE"
		fi
	done

	# iterate each unique file which has issues
	for FILE in $(echo -e $FILELIST | uniq)
	do
		# do stuff based on the file's mimetype
		MIMETYPE=$(file --mime-type "$FILE")

		if [ -n $(echo $MIMETYPE | awk '/text\/html/ {print}') ]; then
			echo "Processing $FILE with tagsoup"
			
			# use tagsoup to beautify our awful markup
			#cat "$FILE" | java -jar "/usr/share/java/tagsoup-1.2.jar" > "$FILE"
			java -jar "/usr/share/java/tagsoup-1.2.jar" --files "$FILE"
			mv "$FILE"_ "$FILE"
		fi
	done

else
	# validate the epub
	java -jar "/usr/share/java/epubcheck-1.2.jar" "$EPUB"
fi

# cleanup /tmp
rm -rf "$TMPDIR"

