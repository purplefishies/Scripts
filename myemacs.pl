#!/usr/bin/perl

$cmd = "emacs " . ( join " ", map { "\"$_\"" } @ARGV  ) . " -nw";

#print "$cmd\n";
exec("$cmd");
