#!/bin/sh
filesdir=$1
searchstr=$2

if [ "$#" -ne 2 ] || [ -d "filesdir" ]; then
    echo "usage: finder.sh <directory to search for> <item to search>"
    exit 1
fi

num_files=$(ls $filesdir -1 | wc -l)
num_lines=$(grep -r "$searchstr" $filesdir/* | wc -l)
echo "The number of files are $num_files and the number of matching lines are $num_lines"
