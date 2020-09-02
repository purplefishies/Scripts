#!/usr/bin/perl



my $num = int(rand(10000));
my $url = "http://www.quotationspage.com/quote/$num.html";

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;

$ua->timeout(10);

my $response = LWP::UserAgent->new( $url );



print "";


