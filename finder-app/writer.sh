#!/bin/sh
writefile=$1
writestr=$2

if [ "$#" -ne 2 ]
then 
    echo "usage: writer.sh <path to file> <string to write>"
    exit 1
fi

mkdir -p "$(dirname "$writefile")"
touch $writefile
cat <<EOF > $writefile
$writestr
EOF
