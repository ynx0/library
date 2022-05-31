#!/bin/bash
usage() { printf "Usage: $0 [-w] URBIT_PIER_DIRECTORY  \n(-w: flag to watch and live copy code)\n" 1>&2; exit 1; }

if [ $# -eq 0 ]; then
    usage
    exit 2
fi
PIER=$1
DIR=$(dirname $0)
EXCLUDE_FILE=$DIR/ignore_files.txt

while getopts "w" opt; do
    case ${opt} in
        w) WATCH_MODE="true"
           PIER=$2
           ;;
        *) usage
           ;;
    esac
done

# todo use watch -n or smtn
if [ -z "$WATCH_MODE" ]; then
    echo "Installed $DIR"
    rsync -r --exclude-from=$EXCLUDE_FILE * $PIER/home/
else
   echo "Watching for changes to copy to ${PIER}..."
   while [ 0 ]
   do
    sleep 0.8
    rsync -r --exclude-from=$EXCLUDE_FILE * $PIER/home/
   done
fi
