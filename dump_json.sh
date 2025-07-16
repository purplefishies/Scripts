#!/bin/sh
perl -MJSON -MYAML=Dump -e '$j=JSON->new->allow_nonref;print Dump $j->decode(<>);'

 

# thing
