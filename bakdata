#!/bin/bash

# script to backup /home to removeable drive

# check drive is mounted, mount if not
#MOUNT=$(df | grep /dev/hdc1)
#if [ -z "$MOUNT" ]
#then
#	mount /media/backup
#fi

fsck -f /dev/sda1

mount /media/backup

# rsync the wiki into Stuff on /home/mafro
rsync -avP --delete /var/www/wiki /home/mafro/Stuff/

# sync entire home directory to backup
rsync -avP --log-file=/var/log/mafro/bakdata.log --delete /home /media/backup/

# only root can unmount
umount /media/backup

