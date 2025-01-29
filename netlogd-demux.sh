#!/bin/sh
# $1 logdir

set -e

mkdir -p "$1"

while true; do
    read file
    read data
    echo $data >> "$1/$file.log"
done
