#!/bin/bash

#cmd="consolidate_history.rb $@"
#echo "CMD: $cmd"
consolidate_history.rb "$1"


nfile=$(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m")
oldfiles=$(echo $(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m_*"))
wcnfile=$(wc -l $nfile | perl -pne 's/^(\d+)\s+.*$/$1/;' )
wcoldfiles=$(cat $oldfiles | wc -l | perl -pne 's/^(\d+)\s+.*$/$1/;')

cd ${HISTDIRECTORY}
git add $oldfiles
git commit -m "TMP: old files"

#echo "Nfile:$nfile"
#echo "Oldfile:$oldfiles"
#echo "Oldfiles:$oldfiles"
#echo "WCNew:$wcnfile"
#echo "WCOld:$wcoldfiles"

if [[ $wcnfile -le $wcoldfiles ]]; 
then
    echo "Matching"
    echo "rm $(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m_*")"
    git rm -f $oldfiles
fi

#exit 1
#echo "NFile: $nfile"

git add $nfile
git commit -m "ENH: added $nfile"
cd -

