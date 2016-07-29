#!/bin/bash

consolidate_history.rb $@

nfile=$(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m")
oldfiles=$(echo $(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m_*"))
wcnfile=$(wc -l $nfile | perl -pne 's/^(\d+)\s+.*$/$1/;' )
wcoldfiles=$(wc -l $oldfiles | grep total | perl -pne 's/^\s*(\d+)\s+.*$/$1/;')

#echo "Nfile:$nfile"
#echo "Oldfile:$oldfiles"
#echo "Oldfiles: $oldfiles"

if [[ $wcnfile == $wcoldfiles ]]; 
then
    #echo "Matching"
    #echo "rm $(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m_*")"
    rm $(chronic.rb "$@" "${HISTDIRECTORY}/bash_history_%Y_%m_*")
fi

echo "NFile: $nfile"
cd ${HISTDIRECTORY}
git add $nfile
git commit -m "ENH: added $nfile"
cd -

