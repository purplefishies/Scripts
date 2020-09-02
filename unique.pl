#!/usr/bin/perl
use Tie::IxHash;
if ( $ENV{USE_IXHASH} ) {
    tie(%h,'Tie::IxHash');
}

%h = map { chomp; $_ => $h{$_}++ }<>;
$,="\n";
print keys %h;
print "\n";
