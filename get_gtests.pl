#!/usr/bin/perl

if ( $#ARGV < 0 ) { 
    die "Usage: $0 GTEST\n";
} 

#print "cmd: $ARGV[0]\n";
# open(CMD,$ARGV

open(CMD,"$ARGV[0] --gtest_list_tests| ");
@lines = map { chomp($_); $_ } <CMD>;
close(CMD);
my ($prefix,$test);

my @tests;
for ($i = 0 ; $i <= $#lines ; $i ++ ) {
    if ( $lines[$i] =~ /^([A-z0-9-\.]+)/ ) {
        $prefix = $1;
    } elsif ( $lines[$i] =~ /^\s+([A-z0-9-]\w+)/ ) {
        $test = $1;
        push(@tests,"${prefix}${test}");
    }
}
$, = "\n";
print @tests,"";
