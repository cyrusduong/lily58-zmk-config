#!/bin/bash

# Escilate this script if it is not sudo
if [ $EUID != 0 ]; then
	sudo "$0" "$@"
	return $?
fi

# Define the source files
BASEDIR=$(dirname "$0")
LEFT_FILE="$BASEDIR/left.uf2"
RIGHT_FILE="$BASEDIR/right.uf2"

# Define the destination directory on the USB device
DESTINATION="/mnt/nano" # Change this to the appropriate mount point of your USB device
DEVICE="/dev/sda"       # Change this to the appropriate mount point of your USB device

# Function to copy files
copy_file() {
	if [ -e "$1" ]; then
		echo "Copying $1 to $DESTINATION"
		rsync -v --progress "$1" "$DESTINATION/"
		echo "Copy completed."
	else
		echo "File $1 not found!"
	fi
}

# Function to check for USB devices and copy files
check_and_copy() {
	local file=$1
	local message=$2

	echo "$message"
	echo "Waiting for connection..."

	while true; do
		# Check for the USB device
		device=$(lsblk -o PATH,LABEL | grep "$DEVICE" | awk '{print $1}')
		if [ -n "$device" ]; then
			echo $res
			echo "Found $device"
			sudo mount "$DEVICE" "$DESTINATION"
			sleep 0.2
			copy_file "$file"
			break
		fi
		sleep 0.2 # Wait for 1 second before checking again
	done

	echo "Waiting for $DEVICE to unmount..."

	# Wait for nice nano to reboot and unmount
	while true; do
		device=$(lsblk -o PATH,LABEL | grep "sda" | awk '{print $1}')
		if [ ! -n "$device" ]; then
			break
		fi
		sleep 0.2
	done

	# Force unmount so we can reuse directory
	sudo umount -fl $DESTINATION
}

# Wait for the left keyboard
check_and_copy "$LEFT_FILE" "Please connect the left keyboard in device mode"

# Wait for the right keyboard
check_and_copy "$RIGHT_FILE" "Please connect the right keyboard in device mode"
echo "Done!"
