#!/bin/bash

if [ ! -d thumbs ]; then
  mkdir thumbs/
fi

let i=0

for img in *.JPG; do
  ((i++))
  convert -resize 25% $img thumbs/$i.jpg
done


