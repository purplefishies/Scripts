#!/bin/bash

perl -ne 's/^\S+\s+([wb])\s+/$1/; if ( $1 eq "w" ) { print "White" ; } else { print "Black"; }' < $1
