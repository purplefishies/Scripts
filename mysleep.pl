#!/usr/bin/perl


if( $#ARGV < 0 ) { 
    die "Usage: $0  TIME \n";
}


sleep( $ARGV[0] );
system("osascript -e 'tell application \"System Events\" to sleep'");
