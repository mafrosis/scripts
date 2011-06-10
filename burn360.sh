#!/bin/bash

echo "Burning: $1"

growisofs -use-the-force-luke=dao -use-the-force-luke=break:1913760 -dvd-compat -Z /dev/cdrom=$1

