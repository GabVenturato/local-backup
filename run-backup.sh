#!/bin/bash
# Gabriele Venturato - 13/08/2018
# Simple script to run a backup of linux system partition to external drive.
# This script uses the tool "restic" to perform the backup. It is a simple 
# wrapper of that tool, to simplify the process (based on my personal 
# preferences).

FILESFROM=include-file.txt
FILESEXCLUDE=exclude-file.txt
PWDFILE=password.txt
KEEPLAST=10

# Function used to check the repository integrity after each operation.
# @in: string to print before the check
check_repo () {
    echo $1
    restic -r $REPO --password-file=$PWDFILE check
    echo $'\n\n'
}

# ------------------------------------ MAIN ------------------------------------
if [ "$#" -ne 1 ]; then
    echo "usage: run-backup.sh <restic-repo-path>"
    exit 1
fi

REPO=$1

# check if path in input is a restic repo
restic -r $REPO snapshots --password-file=$PWDFILE &> /dev/null
if [ "$?" -ne 0 ]; then
    echo "error: $REPO is not a restic repository"
    exit 1
fi

# CHECK BEFORE BACKUP
check_repo "-> Checking repository before backup..."

# DO BACKUP
echo "-> Doing the backup..."
restic -r $REPO backup --verbose \
--password-file=$PWDFILE \
--files-from $FILESFROM \
--exclude-file=$FILESEXCLUDE \
2> errors.log.txt
echo $'\n\n'

# CHECK AFTER BACKUP
check_repo "-> Checking repository after backup..."

# WANT TO CLEAN?
echo -n "Do you want to clean the repository (keep last $KEEPLAST)? [y/N]: "
read choice junk
echo $'\n\n'

if test "$choice" = y -o "$choice" = Y
then
    echo "-> Cleaning..."
    restic -r $REPO forget --password-file=$PWDFILE \
    --keep-last $KEEPLAST --prune
    echo $'\n\n'
    check_repo "-> Checking repository after cleaning..."
fi

# PRINT CURRENT SNAPSHOTS
echo "-> Current Snapshots:"
restic -r $REPO --password-file=$PWDFILE snapshots