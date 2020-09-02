#!/usr/bin/perl -w -pn

s/(\e|\033)(\[(\d+(?>(;\d+)*))?m)?//g;
END{print "\n";} 
