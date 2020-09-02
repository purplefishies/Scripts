#!/usr/bin/python
#
# A simple script for taking out the trash
#
#
from optparse import OptionParser
import os
import re

parser = OptionParser()

parser.add_option("-t","--trash",dest="trashdir",
                  help="Specify as Trashdir",
                  metavar="DIR"
                  )
(options,args) = parser.parse_args()

if options.trashdir:
    print "Found dir" + options.trashdir
else:
    if re.match("^.*darwin",os.uname()[0],re.I):
        print "Using Darwin and " + os.environ['HOME'] + "/.Trash"
    elif re.match("^.linux",os.uname()[0],re.I ):
        print "Using Linux"
    print "Using .Trash"




