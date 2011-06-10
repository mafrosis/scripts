#!/bin/sh

while [ $? -eq 0 ]
do
	nc -vlp 8080 -c'(read a b c; z=read; while [ ${#z} -gt 2 ]; do read z; done; f=`echo $b|sed 's/[^a-z0-9_:]//gi'`;h="HTTP/1.0";o="$h 200 OK\r\n";c="Content";echo `wol $f`)'

done

