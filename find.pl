#!/usr/bin/perl

use Getopt::Long;
use Date::Manip;
use File::Temp qw/tempfile/;
Getopt::Long::Configure("pass_through");

my %opts;
my $time;
my @data_args;

GetOptions(\%opts ,
           "before=s",
           "after=s",
          );


$opts{after_time} = Date::Manip::UnixDate($opts{after},'%s');
$opts{before_time} = Date::Manip::UnixDate($opts{before},'%s');
if( $opts{after} ) {
    ($opts{after_fh}, $opts{after_filename}) = tempfile("findXXXX",DIR=>"/tmp",UNLINK=>1);
     $time =  Date::Manip::UnixDate( $opts{after}, "%c" );
    `touch -d "$time" $opts{after_filename}`;
    push( @data_args, "-newer",$opts{after_filename} );
}
if( $opts{before} ) {
    ($opts{before_fh}, $opts{before_filename}) = tempfile("findXXXX",DIR=>"/tmp",UNLINK=>1);
    $time =  Date::Manip::UnixDate( $opts{before}, "%c" );
    `touch -d "$time" $opts{before_filename}`;
    push( @data_args, "\!","-newer",$opts{before_filename} );
}
if( -d $ARGV[0] ) {
    unshift(@data_args,shift(@ARGV));
    @ARGV = map { s/\*/\\*/g; $_;  } @ARGV;
}
#print "Running 'find  @data_args @ARGV'\n";
system("find  @ARGV @data_args ");
