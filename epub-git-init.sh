#!/bin/bash

usage="Usage: git-ebook-init [-v] [-h ebook-dir] file"

verbose=0

while getopts "vh:" options
do
	case $options in
		v ) verbose=1;;
		h ) EBOOK_HOME=$OPTARG;;
		\? ) echo $usage
			 exit 1;;
		* ) echo $usage
			exit 1;;
	esac
done
shift $((OPTIND-1))

IFS="$(echo -en "\n\r")"


# ensure we have an ebook storage root
if [ -z "$EBOOK_HOME" ]; then
	echo "You must either set environment variable EBOOK_HOME or supply the -h parameter"
	exit 1
elif [ ! -d "$EBOOK_HOME" ]; then
	mkdir -p "$EBOOK_HOME"
fi

# extract filename and clean any preceeding path
FILE=${1##*/}

# ensure the file exists
if [ ! -f "$1" ]; then
	echo "Cannot find or open $FILE."
	return 0
fi


# get the file's path relative to EBOOK_HOME - this includes $FILE
SRCPATH=$(find "$EBOOK_HOME" -name "$FILE" -type f)
NEWPATH=${SRCPATH#*"$EBOOK_HOME/"}

# create the correct path in our working directory
if [ ! -d "$EBOOK_HOME/working/$NEWPATH" ]; then
	mkdir -p "$EBOOK_HOME/working/$NEWPATH"
fi

# move to working directory and unzip epub; dont overwrite existing
cd "$EBOOK_HOME/working/$NEWPATH"
if [ $verbose -eq 1 ]; then
	unzip -n "$SRCPATH"
else
	unzip -n -qq "$SRCPATH"
fi

# handle gitrepo.tgz in epub
if [ -d ".git" ]; then
	rm -f .history.tgz
elif [ -f ".history.tgz" ] && [ ! -d ".git" ]; then
	tar xzf .history.tgz
	rm -f .history.tgz
fi

# remove any empty folders- git ignores them and they're not allowed in epub
for DIR in $(find . -type d)
do
	IS_EMPTY=$(ls -A "$DIR")
	if [ -z "$IS_EMPTY" ]; then
		rm -rf "$DIR"
	fi
done

# decide if we should init a new git repo
INIT_REPO=$(git status 2>&1 | awk '/^fatal/ {print 1}')
if [ -n "$INIT_REPO" ]; then
	# create a .gitignore file
	echo -e "*.jpg\n*.jpeg\n*.gif\n*.png\n*.bmp" > ".gitignore"

	# init git repo and commit
	if [ $verbose -eq 1 ]; then
		git init
		git add .
		git commit -m "book imported"
	else
		git init -q
		git add .
		git commit -q -m "book imported"
	fi
	echo "New book repo initialized at $PWD/"
else
	PWD=$(pwd)
	echo "Book repo exported at $PWD/"
fi


