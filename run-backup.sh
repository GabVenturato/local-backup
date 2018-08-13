#!/bin/bash
# Gabriele Venturato - 13/08/2018
# Simple script to run a backup of linux system partition to external drive.
# This script uses the tool "restic" to perform the backup. It is a simple 
# wrapper of that tool, to simplify the process (based on my personal 
# preferences).

FILESFROM=include-file.txt
FILESEXCLUDE=exclude-file.txt
PWDFILE=password.txt

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
echo "Checking repository before backup..."
restic -r $REPO --password-file=$PWDFILE check
echo
echo

# DO BACKUP
restic -r $REPO backup --verbose \
--password-file=$PWDFILE \
--files-from $FILESFROM \
--exclude-file=$FILESEXCLUDE \
2> errors.log.txt
echo
echo

# CHECK AFTER BACKUP
echo "Checking repository after backup..."
restic -r $REPO --password-file=$PWDFILE check



