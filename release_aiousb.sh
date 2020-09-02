#!/bin/bash

nexttag=$( ~/incrementsw.rb)

echo "Incrementing to $nexttag"

git tag $nexttag
git push origin $nexttag

git push --delete origin latest
git tag -d latest
git tag latest
git push origin latest

git archive --format=tar.gz --prefix=AIOUSB-${nexttag}/ HEAD -o ${HOME}/AIOUSB-${nexttag}.tar.gz
upload_software.rb -u $(getkey FTPEmUserID ${HOME}/creds.txt ) -h $(getkey FTPEmHost ${HOME}/creds.txt ) -p $(getkey FTPEmPassword ${HOME}/creds.txt ) --file ${HOME}/AIOUSB-${nexttag}.tar.gz -L

