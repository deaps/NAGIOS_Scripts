#!/bin/bash

# ######################################################## #
# Nagios Plugin to check last root login                   #
# ######################################################## #
# version: 1.0                                             #
# author: João Andrade (joaodeaps@gmail.com)               #
# ######################################################## #

# Constants
MSG_OK="OK - root last login:"
MSG_WARNING="WARNING - root has logged in again:"
MSG_UNKNOWN="UNKNOWN - unknown error"

# Exit Codes
STATE_OK=0
STATE_WARNING=1
STATE_UNKNOWN=3

# Variables
LAST_LOGIN_CMD=$(lastlog -u root)
TMP_FILE="/var/tmp/root_last_login"
TMP_FILE2="/var/tmp/root_lastlog_result"

# Main #######################################################

# Checks if temporary file exists
# If not, its creates with the result of "lastlog -u root" comand
if [ ! -f $TMP_FILE ]; then
	
	echo $LAST_LOGIN_CMD > $TMP_FILE
	# Saves in the LOGIN_DATE variables the date
	LOGIN_DATE=$(cat $TMP_FILE | cut -d' ' -f7,8,9,10,11,12)
	echo "$MSG_OK $LOGIN_DATE"
	exit $STATE_OK
else
	LOGIN_DATE=$(cat $TMP_FILE | cut -d' ' -f7,8,9,10,11,12)
	
	# To check the last login and compare it to the last login date,
	# This new date will be saved to a file and then compared the files
	# if they are equal.
	echo $LAST_LOGIN_CMD > $TMP_FILE2
	NEW_LOGIN_DATE=$(cat $TMP_FILE2 | cut -d' ' -f7,8,9,10,11,12)
		
	if [ "$LOGIN_DATE" == "$NEW_LOGIN_DATE" ]; then
		echo "$MSG_OK $LOGIN_DATE"
		exit $STATE_OK
	else
		# If date is different, save the new date in primary 
		# temporary file and returns warning exit code with warning message
		echo $LAST_LOGIN_CMD > $TMP_FILE
		echo "$MSG_WARNING $NEW_LOGIN_DATE"
		exit $STATE_WARNING
	fi

	# If it reach this line, return the Unknown exit code
	echo $MSG_UNKNOWN
	exit $STATE_UNKNOWN
fi
