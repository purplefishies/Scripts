for i in $(dirs $PWD | grep -v Chess); do rsync -avHe ssh jdamon@paris:$i .; done

