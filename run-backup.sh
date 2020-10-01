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
DEFAULTY=false

# Function used to print the help
help() {
  cat <<HELP
Usage: ./$(basename $0) <restic-repo-path> [options]

Run the restic backup routine.

Options:
  -y | --yes        To accept all requests by default.
HELP
}

# Function used to check the repository integrity after each operation.
# @in: string to print before the check
check_repo () {
    echo $1
    restic -r $REPO --password-file=$PWDFILE check
    echo $'\n\n'
}

# ----------------------------------- MAIN ----------------------------------- #
# Optional parameters
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -y|--yes)
      DEFAULTY=true
      shift
      ;;
    *) # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Mandatory parameters
if [ "$#" -ne 1 ]; then
    help
    exit 1
fi

REPO=$1

# check if path in input is a restic repo
restic -r $REPO snapshots --password-file=$PWDFILE &> /dev/null
if [ "$?" -ne 0 ]; then
    echo "error: $REPO could be not a restic repository, try with a check"
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
if [[ ! $DEFAULTY ]]; then
    echo -n "Do you want to clean the repository (keep last $KEEPLAST)? [y/N]: "
    read choice junk
    echo $'\n\n'
fi

if [[ $DEFAULTY || "$choice" = y || "$choice" = Y ]]; then
    echo "-> Cleaning..."
    restic -r $REPO forget --password-file=$PWDFILE \
    --keep-last $KEEPLAST --prune
    echo $'\n\n'
    check_repo "-> Checking repository after cleaning..."
fi

# PRINT CURRENT SNAPSHOTS
echo "-> Current Snapshots:"
restic -r $REPO --password-file=$PWDFILE snapshots