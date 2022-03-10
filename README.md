# Local Backup
This simple script is used to backup data with [restic](https://restic.net/) in a local folder. This script doesn't implement back-up features, it is only a wrapper that simplify the work of doing a backup with restic.

You can easily make the script run automatically to have automatic backups in a specified location.

You can easily use different copies of this scrpit (with its configuration files) in order to do different backups in different repositories.

## Installation
- `git clone` or `download` this repository
- edit configuration files
    - `include-file.txt` is a list of files/directories you want to backup, one per line
    - `exclude-file.txt` is a list of files/directories you want to exclude from the ones included in the previous file
    - `password.txt` is the password of your restic repository (previously setted up, see [restic manual](https://restic.readthedocs.io/en/stable/)). Note: I backup my data in an encrypted external drive, and since every restic command require to insert the repository password, I prefer to keep the password in a file in order to not have to insert it multiple times when doing a back-up, without problems in security. Consider that if you use it in different (non-encrypted) context.
- `$ chmod +x run-backup.sh`

## Quick Start
In order to use this script you have to init a new restic repository in a local folder with: 

`$ restic init --repo <location>`

then you use that location to store your backups. After you have defined the list of files you want to backup in the configuration files, simply run:

`$ ./run-backup.sh <location>`

where location is the place where your restic repository is.

## Useful Commands
Some useful commands from [restic manual](https://restic.readthedocs.io/en/stable/):

- `$ restic -r <location> check` to check repository consistency
- `$ restic -r <location> snapshots` to list all snapshots in your repository
- `$ restic -r <location> forget <snap-id> --prune` to delete a snapshot, after this is better to check repository consistency
- `$ restic -r <location> restore <snap-id> --target /tmp/restore-work` to restore a snapshot

more details and more commands are on official restic website.
