
# change to root and then reboot into windows

#echo $0
#echo "${0}"

if [ $UID -ne 0 ]; then
	echo "Please enter root's password.."
	su -c "${0} grub-reboot $@"
	exit
fi

