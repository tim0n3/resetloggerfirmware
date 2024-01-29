#!/usr/bin/env bash
################################################################################
#                      Fulcrum Software Update                            #
################################################################################
# Author: Tim Forbes
# License: The Unlicense
# GitHub Repository: https://github.com/tim0n3/lazy-bash
################################################################################
# Description:
# Fulcrum Software Update is a bash script designed to automate updating 
# our fulcrum telemetry application. It simplifies the process of backing up
# the current install without data and upgrading to the latest build. This 
# script is provided "as is" without warranty or liability. Feel free to modify 
# and share it with the community, ensuring you credit the original author.
################################################################################
# Usage:
# - Make the script executable: chmod +x fulcrum_software_update.sh
# - Run the script: ./fulcrum_software_update.sh [options]
################################################################################
# Features:
# - [List key features and functionalities of the script]
# - [You can also include examples or use cases for better understanding]
################################################################################
# Dependencies:
# - [List any external dependencies or software required for the script to run]
# - [Include versions if necessary]
################################################################################
# Contributions:
# Contributions and bug reports are welcome! Please fork the repository, create
# a new branch, make your changes, and submit a pull request. For any issues or
# suggestions, please open an issue on GitHub.
################################################################################
# Support:
# If you encounter any problems or have questions, feel free to reach out to the
# author via the GitHub repository or by [provide contact information]. Your
# feedback is highly appreciated!
################################################################################
# License Information:
# This script is released under The Unlicense, a permissive public domain-like
# license that ensures the original author is credited. See the UNLICENSE file
# for more details. You can find a copy of The Unlicense in the root directory
# or visit the following link: https://unlicense.org/
################################################################################
# Disclaimer:
# Fulcrum Software Update comes with no warranty or guarantee of any kind. Use
# it at your own risk, and the author will not be held responsible for any
# unintended consequences or damages.
################################################################################
# Thank you for using Fulcrum Software Update! Happy updating!
################################################################################

# Uncomment this to enable debug mode
#set -x

# Define variables
#Change this to the path of your local Git repository
REPO_PATH="$HOME/usb01/pubsub"
# Change this to the path where you want to store backups
BACKUP_PATH="$HOME"
# Change this to the desired log file path
LOG_FILE="/var/log/git_update.log"
# Change this to the path of your local Git repository
DATA_PATH="$(find "$HOME/usb01" -type d -name "pubsub" -exec find {} -type d -name "data" \;)"
# Change this to the path of your local logs folder
LOGS_PATH="$(find "$HOME/usb01" -type d -name "pubsub" -exec find {} -type d -name "logs" \;)"

# Function to log messages to stderr and a log file
log() {
	local message="$1"
	echo "$(date +"%Y-%m-%d %T"): $message" >&2
	echo "$(date +"%Y-%m-%d %T"): $message" >> "$LOG_FILE"
}

# Function to check for errors and exit if any occur
check_error() {
	local exit_code="$?"
	if [ "$exit_code" -ne 0 ]; then
		log "Error: $1 (Exit code: $exit_code)"
		exit 1
	fi
}

# Function to create and set permissions for the script's log file

create_log(){
	# Create log file and set relevant permissions
	# Check if the file exists, and if not, create the file with chmod 666 permissions
	# [[ -e "$LOG_FILE" ]] || { touch "$LOG_FILE" && chmod 666 "$LOG_FILE" && echo "File $LOG_FILE created with permissions 666."; } && echo "File $LOG_FILE already exists."
	# If statement version
	if [[ ! -e "$LOG_FILE" ]]; then
		# Doesn't exist so create
		sudo touch "$LOG_FILE"
		sudo chmod 666 "$LOG_FILE"
		log "File $LOG_FILE has been created with global rw permissions."
	else
		# File exists so do nothing
		log " $LOG_FILE exists moving on."
	fi

}


# Function to create a backup (excluding data folder)
backup_repo() {
	log "Creating backup..."
	#tar -cvzf "$BACKUP_PATH/backup_$(date +"%Y%m%d_%H%M%S").tar.gz" --exclude="$REPO_PATH/data" "$REPO_PATH"
	tar -cvzf "$BACKUP_PATH/backup_$(date +"%Y%m%d_%H%M%S")_pubsub_dev.tar.gz" --exclude="$DATA_PATH" --exclude="$LOGS_PATH" "$REPO_PATH"
	check_error "Backup failed. Please review the error and fix the issue before updating the repository."
	log "Backup completed."
}

# Function to update the local Git repository
update_repo() {
	log "Updating local repository..."
	cd "$REPO_PATH" || check_error "Unable to change directory to $REPO_PATH"
	git fetch --all > "$BACKUP_PATH/git_fetch_log.txt" 2> "$BACKUP_PATH/git_fetch_error_log.txt"
	check_error "Git fetch failed. Please review the error and fix the issue before updating the repository."
	git reset --hard origin/pubsub_dev >> "$BACKUP_PATH/git_reset_log.txt" 2>> "$BACKUP_PATH/git_reset_error_log.txt"
	check_error "Git reset failed. Please review the error and fix the issue before updating the repository."
	log "Update completed."
}

# Main script
# Create log file to ensure all activity is logged
create_log
# Create a backup
# Ensure that there is logging incase the function fails-to \
# or doesn't execute at all. 
# Force exit with error code to stop the script from \
# updating the local repo without backing up.
backup_repo 
# Update the local Git repository
# Adding debug logging incase this function fails \
# hard exit with error code so that we know this script \
# has failed
update_repo 
# If everything is successful, exit
exit 0

#refreshloggerfirware || echo "Failed to call the main function" && exit 1
