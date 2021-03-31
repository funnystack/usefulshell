#!/bin/bash
### grep text in jars

if [ $# -lt 2 ];then
    echo 'Usage : jargrep text path'
    exit 1;
fi

LOOK_FOR=$1
LOOK_FOR=`echo ${LOOK_FOR//\./\/}`
folder=$2
echo "find '$LOOK_FOR' in $folder "
for i in `find $2 -name "*jar"`
do
    unzip -p $i | grep "$LOOK_FOR" > /dev/null
    if [ $? = 0   ]
    then
        echo "==> Found \"$LOOK_FOR\" in $i"
    fi
done