#!/bin/bash

# Global variables
START_TIME=`date +%s`
CONTINUE=1
CMD_FILE="cmd.txt"
SSH_FILE="ssh.txt"
# Check if sshpass is installed
if [ -z "$({ dpkg -l | grep sshpass; })" ]; then
	# sshpass is not installed
	echo "This script requires sshpass (install with 'apt-get install sshpass' on ubuntu/debian)."
	CONTINUE=0
fi

if [ "${CONTINUE}" -eq 1 ]; then
	# Check for cmd file
	if [ -n "${1}" ]; then
		# Filename was passed into the script
		CMD_FILE="${1}"
	fi
	# Check if cmd file exists
	if [ ! -f "${CMD_FILE}" ]; then
		# Cmd file doesn't exist
		echo "${CMD_FILE} not found."
		CONTINUE=0
	fi
fi

if [ "${CONTINUE}" -eq 1 ]; then
	# Check for ssh file
	if [ -n "${2}" ]; then
		# Filename was passed into the script
		SSH_FILE="${2}"
	fi
	# Check if ssh file exists
	if [ ! -f "${SSH_FILE}" ]; then
		# ssh file doesn't exist
		echo "${SSH_FILE} not found."
		CONTINUE=0
	fi
fi

if [ "${CONTINUE}" -eq 1 ]; then
	# No errors
	# Initialize variables
	SCRIPT_LOGFILE="ssh_$(date +%y-%m-%d-%s).log"
	CMDS=$(cat "${CMD_FILE}")
	CURRENT_LINE_COUNT=0
	TOTAL_LINE_COUNT=0

	# Read the vps file line by line to get the total line count
	while IFS= read -r CURRENT_LINE
	do
		# Check if the current line is blank
		if [ -n "${CURRENT_LINE}" ]; then
			# Count up all non-blank lines
			TOTAL_LINE_COUNT=`expr $TOTAL_LINE_COUNT + 1`
		fi
	done <"${SSH_FILE}"

	# Read the vps file line by line for processing
	while IFS= read -r CURRENT_LINE
	do
		# Check if the current line is blank
		if [ -n "${CURRENT_LINE}" ]; then
			# The current line is not blank
			CURRENT_LINE_COUNT=`expr $CURRENT_LINE_COUNT + 1`
			# Split the current line into separate variables by spaces
			ITEM_COUNT=1
			for SPLIT_LINE in $(echo ${CURRENT_LINE} | tr " " "\n")
			do
				# Determine which variable needs to be populated
				case ${ITEM_COUNT} in
					1) SSH_HOSTNAME="${SPLIT_LINE}" ;;
					2) SSH_USERNAME="${SPLIT_LINE}" ;;
					3) SSH_PASSWORD="${SPLIT_LINE}" ;;
				esac
				ITEM_COUNT=`expr $ITEM_COUNT + 1`
			done

			# Display the current time and hostname (and write to log as well)
			echo "==================================================" >> ${SCRIPT_LOGFILE}
			echo "[${CURRENT_LINE_COUNT}/${TOTAL_LINE_COUNT}] $(date +%r) - ${SSH_HOSTNAME}" | tee -a ${SCRIPT_LOGFILE}
			echo "==================================================" >> ${SCRIPT_LOGFILE}
			# Connect to ssh and run cmds
			sshpass -p ${SSH_PASSWORD} ssh -n -o StrictHostKeyChecking=no ${SSH_USERNAME}@${SSH_HOSTNAME} ${CMDS} >> ${SCRIPT_LOGFILE} 2>&1
		fi
	done <"${SSH_FILE}"
	# Calculate the total time the script was running for
	TOTAL_SECONDS=$((`date +%s`-START_TIME))
	if [ "$(($TOTAL_SECONDS / 3600))" -gt 0 ]; then
		TOTAL_TIME="$(($TOTAL_SECONDS / 3600))h"
	fi
	if [ "$((($TOTAL_SECONDS / 60) % 60))" -gt 0 ]; then
		if [ -z "${TOTAL_TIME}" ]; then
			TOTAL_TIME="$((($TOTAL_SECONDS / 60) % 60))m"
		else
			TOTAL_TIME="${TOTAL_TIME} $((($TOTAL_SECONDS / 60) % 60))m"
		fi
	fi
	if [ "$(($TOTAL_SECONDS % 60))" -gt 0 ]; then
		if [ -z "${TOTAL_TIME}" ]; then
			TOTAL_TIME="$(($TOTAL_SECONDS % 60))s"
		else
			TOTAL_TIME="${TOTAL_TIME} $(($TOTAL_SECONDS % 60))s"
		fi
	fi
	# Write final msg
	echo "Finished." && echo "Total Runtime: ${TOTAL_TIME}" && echo "Output logged to ${SCRIPT_LOGFILE}"
fi
