#!/bin/bash

# ############################################################################ #
# ####################### # Coded by Eldar @ CRaFT4ik # ###################### #
# ###################### # craft4ik@gmail.com :: 2018 # ###################### #
# ############################################################################ #

USERNAME=${SUDO_USER:-$USER}

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
RULES_PATH="/etc/udev/rules.d/touchpad.rules"
STARTUP_PATH="/home/"$USERNAME"/.config/upstart/touchpad.conf"

RULES_CONTENT=$(cat "touchpad.rules" | awk -v x=$USERNAME -v y=$SCRIPT_PATH '{ gsub("\$USER", x); gsub("\$PATH", y); print $0; }')
STARTUP_CONTENT=$'start on startup\npre-start exec sleep 10\ntask\nexec /bin/bash '$SCRIPT_PATH'/script.sh'

if [[ -n "$1" && $1 = "-rm" ]]; then
	sudo rm -f $RULES_PATH
	sudo rm -f $STARTUP_PATH
	sudo bash script.sh -rm
	echo
	echo "Ok."
	exit
elif [[ -n "$1" && $1 = "-i" ]]; then
	sudo rm -f $RULES_PATH
	sudo touch $RULES_PATH
	sudo echo "$RULES_CONTENT" | sudo tee $RULES_PATH
	echo
	sudo rm -f $STARTUP_PATH
	sudo touch $STARTUP_PATH
	sudo echo "$STARTUP_CONTENT" | sudo tee $STARTUP_PATH
	echo
	echo "Was installed. Launching..."
	echo
	sudo bash script.sh
	echo
	echo "Was launched."
else
	echo $0 "--help"
	echo " Use -i for install the program."
	echo " Use -rm for uninstall the program."
	exit
fi
