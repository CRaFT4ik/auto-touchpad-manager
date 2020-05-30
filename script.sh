#!/bin/bash

# ############################################################################ #
# ####################### # Coded by Eldar @ CRaFT4ik # ###################### #
# ###################### # craft4ik@gmail.com :: 2018 # ###################### #
# ############################################################################ #

# Useful commands:
# All device info: udevadm info -a -p $(udevadm info -q path -n /dev/input/mouse0)
# Plug in/out monitor: udevadm monitor

USERNAME=${SUDO_USER:-$USER}
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Check if the 'evtest' installed or not.

if ! [ -x "$(command -v evtest)" ]; then
	echo 'Please, install "evtest" first' >&2
	exit 1
fi

# Find all touchpads exept synaptic's touchpads.
touchpads=$(xinput list | grep -i "touchpad" | grep -i -v "synaptic")
touchpads_ids=$(echo "$touchpads" | awk -F "=" '{print $2}' | awk -F "\t" '{print $1}')

notify()
{
	mes=$([[ "$1" != "disable" ]] && echo "Touchpad is enabled" || echo "Touchpad is disabled")
	if [[ "$SUDO_USER" = "$USER" ]]; then
		su $USERNAME -c 'notify-send -u low -t 1000 -i "'$SCRIPT_PATH'/icon.png" '"\"$mes\""
	else
		notify-send -u low -t 1000 -i "$SCRIPT_PATH/icon.png" "$mes"
	fi
}

# Sleep until xinput will reload.
sleep 0.15s

if [ -z "$touchpads" ]; then
    echo "Touchpads are not detected!"
	exit
else
	echo "Touchpads detected:"
	echo "$touchpads"
fi

echo

# Detecting mouses.
# old code: mouses=$(xinput list | grep -i "mouse")
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && continue
        eval "$(udevadm info -q property --export -p $syspath)"
        ( [[ -z "$ID_SERIAL" ]] || [[ "$ID_INPUT" != 1 ]] || [[ "$ID_INPUT_KEY" != 1 ]] || [[ "$ID_INPUT_MOUSE" != 1 ]] ) && continue
        mouses=$mouses"$ID_SERIAL - /dev/$devname\n"
		unset ID_SERIAL ID_INPUT ID_INPUT_KEY ID_INPUT_MOUSE
done

if [ -z "$mouses" ]; then
    echo "Mouses are not detected!"

	for id in $touchpads_ids
	do
		xinput set-prop --type=int --format=8 $id 'Device Enabled' 1
	done

	notify "enable"
else
	echo "Mouses detected:"
	echo -e -n "$mouses" | awk -F" - " 'NR>1{arr[$1]++}END{for (a in arr) print " -> " a}'

	if [[ "$1" != "-rm" ]]; then
		for id in $touchpads_ids
		do
			xinput set-prop --type=int --format=8 $id 'Device Enabled' 0
		done

		notify "disable"
	else
		for id in $touchpads_ids
		do
			xinput set-prop --type=int --format=8 $id 'Device Enabled' 1
		done

		notify "enable"
	fi
fi
