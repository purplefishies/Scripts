#!/usr/bin/perl
#
# @brief  Git filter to implement rcs keyword expansion as seen in cvs and svn.
# @author Martin Turon
#
# Usage:
#    .git_filter/rcs-keywords.smudge file_path < file_contents
# 
# To add keyword expansion:
#    <project>/.gitattributes                    - *.c filter=rcs-keywords
#    <project>/.git_filters/rcs-keywords.smudge  - copy this file to project
#    <project>/.git_filters/rcs-keywords.clean   - copy companion to project
#    ~/.gitconfig                                - add [filter] lines below
#
# [filter "rcs-keywords"]
#	clean  = .git_filters/rcs-keywords.clean
#	smudge = .git_filters/rcs-keywords.smudge %f
#
# Copyright (c) 2009-2011 Turon Technologies, Inc.  All rights reserved.

$path = shift;
$path =~ /.*\/(.*)/;
$filename = $1;

if (0 == length($filename)) {
	$filename = $path;
}

# Need to grab filename and to use git log for this to be accurate.
$rev = `git log -- $path | head -n 3`;
$rev =~ /^Author:\s*(.*)\s*$/m;
$author = $1;
$author =~ /\s*(.*)\s*<.*/;
$name = $1;
$rev =~ /^Date:\s*(.*)\s*$/m;
$date = $1;
$rev =~ /^commit (.*)$/m;
$ident = $1;

while (<STDIN>) {
    s/\$Date[^\$]*\$/\$Date:   $date \$/;
    s/\$Author[^\$]*\$/\$Author: $author \$/;
    s/\$Id[^\$]*\$/\$Id: $filename | $date | $name \$/;
    s/\$File[^\$]*\$/\$File:   $filename \$/;
    s/\$Source[^\$]*\$/\$Source: $path \$/;
	s/\$Revision[^\$]*\$/\$Revision: $ident \$/;
} continue {
    print or die "-p destination: $!\n";
}