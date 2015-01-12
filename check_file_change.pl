#!/bin/bash

# ######################################################## #
# Nagios Plugin to check file changes                      #
# ######################################################## #
# version: 1.0                                             #
# author: João Andrade (joaodeaps@gmail.com)               #
# ######################################################## #

# Constants
MSG_OK="OK - No change in file"
MSG_WARNING="WARNING - File changed!"
MSG_UNKNOWN="UNKNOWN - Error! Is argument a path to a file?"

# Exit Codes
STATE_OK=0
STATE_WARNING=1
STATE_UNKNOWN=3

# Variables
FILE_EXISTS=0
FILE=$1

# Main #######################################################

# Check if it is a file
if [ ! -f $FILE ]; then
	echo $MSG_UNKNOWN
	exit $STATE_UNKNOWN
fi

# Save to FILE_NAME AND TMP_FILE the name of the file and the temporary file path
FILE_NAME=$(basename $FILE)
TMP_FILE="/var/tmp/$FILE_NAME"

# Hexadecimal value of the file
FILE_HEX=$(openssl dgst -md5 -hex $FILE | cut -d' ' -f 2)

# Check if it is the first time the file is being checked
# If already exists a file with the same name in the "/var/tmp/" folder, it means
# that the file already been used
if [ -f $TMP_FILE ]; then
	# Hexadecimal value of the last check to the file
	TMP_HEX=$(<$TMP_FILE)

	# Compare if the two hexadecimal values are igual
	# and returns the corresponding message
	if [ "$TMP_HEX" == "$FILE_HEX" ]; then
		echo $MSG_OK
		exit $STATE_OK 
	else
		echo $MSG_WARNING
		exit $STATE_WARNING
	fi
		
else
	# Creates the new temporary file with the new hexadecimal value of the file
	echo $FILE_HEX > $TMP_FILE
	echo $MSG_OK
	exit $STATE_OK
fi
