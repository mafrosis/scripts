#!/bin/bash

usage="Usage: git-ebook-publish [-v] [-c] [-h ebook-dir]"

verbose=0
clean=0

while getopts "vch:" options
do
	case $options in
		v ) verbose=1;;
		c ) clean=1;;
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

# validate directory is an epub via mimetype check
if [ ! -f "mimetype" ] || [ "$(cat mimetype)" != "application/epub+zip" ]; then
	echo "This directory isn't a valid epub (Missing/invalid mimetype file)"
	exit 1
fi

# extract destination path from our current working directory
PWD=$(pwd)
EPUBNAME=${PWD##*/}
DESTFILE=${PWD#*"$EBOOK_HOME/working/"}
DESTPATH=${DESTFILE%/*}

# check destination file exists
if [ -f "$EBOOK_HOME/$DESTFILE" ]; then
	echo "Destination $EBOOK_HOME/$DESTFILE exists."
	echo "Overwrite? [y/N]"
	read OK
	if [ "$OK" != "y" ]; then
		exit 1
	fi

# check the destination directory exists
elif [ ! -d "$EBOOK_HOME/$DESTPATH" ]; then
	mkdir -p "$EBOOK_HOME/$DESTPATH"
fi


# include the git repo in the epub
if [ $clean -eq 0 ]; then
	# the git repo must be added to the manifest; check if it exists
	OPF_ENTRY=$(xmlstarlet sel -N x="http://www.idpf.org/2007/opf" -t -m "//x:item[@id='history']" -c . -n content.opf)

	if [ -z $OPF_ENTRY ]; then
		# add gitrepo.tgz to content.opf manifest using xmlstarlet
		xmlstarlet ed -L -N x="http://www.idpf.org/2007/opf" -s "/x:package/x:manifest" -t "elem" -n "item" -v "history" content.opf
		xmlstarlet ed -L -N x="http://www.idpf.org/2007/opf" -a "/x:package/x:manifest/x:item[.='history']" -t "attr" -n "id" -v "history" content.opf
		xmlstarlet ed -L -N x="http://www.idpf.org/2007/opf" -a "/x:package/x:manifest/x:item[.='history']" -t "attr" -n "href" -v ".history.tgz" content.opf
		xmlstarlet ed -L -N x="http://www.idpf.org/2007/opf" -a "/x:package/x:manifest/x:item[.='history']" -t "attr" -n "media-type" -v "application/x-gzip" content.opf
		xmlstarlet ed -L -N x="http://www.idpf.org/2007/opf" -u "/x:package/x:manifest/x:item[@id='history']" -v "" content.opf

		# commit the OPF change to the repo..
  		git add content.opf
		
		if [ $verbose -eq 1 ]; then
			git commit -m "included git history repo in the epub manifest"
		else
			git commit -q -m "included git history repo in the epub manifest"
		fi
	fi
	
	# compress .git directory into single file
	git gc -q
	tar czf .history.tgz .git .gitignore

	# zip create ebook of current directory
	if [ $verbose -eq 1 ]; then
		zip -X "$EPUBNAME" -xi mimetype
		zip -rX "$EPUBNAME" -xi $(ls -A | awk '!/mimetype|.git/ {print}')
	else
		zip -qX "$EPUBNAME" -xi mimetype
		zip -rqX "$EPUBNAME" -xi $(ls -A | awk '!/mimetype|.git/ {print}')
	fi

	# remove the compressed repo file
	rm -f .history.tgz

else
	# the git repo must be removed from the manifest
	xmlstarlet ed -N x="http://www.idpf.org/2007/opf" -d "//x:item[@id='history']" content.opf

	# zip create ebook of current directory
	if [ $verbose -eq 1 ]; then
		zip -X "$EPUBNAME" -xi mimetype
		zip -rX "$EPUBNAME" -xi $(ls | awk '!/mimetype/ {print}')
	else
		zip -qX "$EPUBNAME" -xi mimetype
		zip -rqX "$EPUBNAME" -xi $(ls | awk '!/mimetype/ {print}')
	fi

	# undo changes to the epub manifest
	git checkout content.opf
fi

# move epub to dest
mv "$EPUBNAME" "$EBOOK_HOME/$DESTFILE"
echo "Written to $EBOOK_HOME/$DESTFILE"


