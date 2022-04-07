#!/usr/bin/perl
#****************************************************************************
# script::name= between.pl
# script::desc= Acts as a filter to print out certain lines that are between
#               two regular expressions. The flags that control the behavior
#               of this script are the following:
#
# script::author=
# script::cvs= $Id: between.pl.rca 1.2 Fri Mar 26 13:57:36 2010 jdamon Experimental $
# script::changed= $Date: Fri Mar 26 13:57:36 2010 $
# script::modusr= $Author: jdamon $
# script::notes=
#               1. -start | -s : Specifies the starting regular expression. This is
#                  the only 'required' command line argument except for the file that
#                  you wish to read in.
#               2. -end | -e   : Specifies the ending regular expression. Once a line
#                  is read in that matches this regular expression, the script stops
#                  printing out lines unless the -multiple option is specified.
#               3. -file | -f  : The file that you want to read in.
#
#               4. -multiple|-m: Allows you to print out multiple sets of lines
#                  between the regular expressions.
#
#               5. -include    : Allows you to also print out the starting and
#                  ending lines in addition to the lines between the starting
#                  and ending regular expressions.
#
#               6.
#
#
#
#
# script::todo=
#****************************************************************************


#*******************************  LIBRARIES  ********************************

use Getopt::Long;
use Pod::Usage;
use strict;

#****************************  GLOBAL VARIABLES  ****************************

my %opts;

my @bad_args;
my @files;

my $file;
my $read_stdin;

#*********************************  CODE   **********************************

Getopt::Long::Configure('no_auto_abbrev', 'pass_through');
GetOptions(\%opts,
           "start|s=s",
           "end|e=s",
           "excludeend",
           "excludestart",
           "o=s",
           "multiple|m",
           "file|f=s@",
           "0",
           "include|i",
           "help|h",
           "man",
          );
pod2usage(2) if( $opts{help} );
pod2usage(VERBOSE=>2) if( $opts{man} );

if( ! defined $opts{start} ) {
    print STDERR "Error: you must specify '-start START_REGEX'\n";
    pod2usage(2);
}
if( $#bad_args >= 0 ) {
    print STDERR "The following command line arguments are bad:\n";
    foreach my $badarg ( @bad_args ) {
        print "$badarg\n";
    }
    pod2usage(2);
}
if ( $opts{0} ) {
    $opts{separator}="\0";
} else {
    $opts{separator}="---\n";
}
#if( $#files >= 0 ) {
if( defined $opts{file} && ref $opts{file} eq "ARRAY" && $#{$opts{file} } >= 0 ) {
    if( exists($opts{file}) && ref($opts{file}) eq "ARRAY" ) {
        $opts{file} = [ @{$opts{file}} , @files ];
    } else {
        $opts{file} = [ @files ];
    }
} elsif( ! defined $opts{file} && !eof(*STDIN) ) {
    Read_File( *STDIN, \%opts );
    $read_stdin = 1;

} elsif( ! defined $opts{file} ) {
    if( $#ARGV < 0 ) {
        print STDERR "Error: you must specify '-file FILE'\n";
    }
}

if( ! $read_stdin ) {
    foreach $file ( @{$opts{file} } ){
        open(FILE, $file ) ||
            die "Error: unable to open file '$file'\n";
        Read_File(*FILE, \%opts );
        close(FILE);
    }
}

#******************************  SUBROUTINES  *******************************

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# sub::name= Bad_Cmdline_Args
# sub::desc= Adds bad command line arguments to a global array.
#
# sub::args=
#              1. (SCALAR)    : the questionable command line arg.
# sub::return=
# sub::notes=
#              None
# sub::todo=
#              None
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# sub Bad_Cmdline_Args($)
# {
#     if( $_[0] !~ /^-.*/ ) {
#         push(@files, $_[0]);
#     } else {
#         push(@bad_args, $_[0] );
#     }
# }


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# sub::name= Read_File
# sub::desc= Reads the file and performs the filtering of lines based on
#            starting regular expressions and ending regular expressions.
# sub::args=
#              1. (GLOB)      : Filehandle that we will read from
#              2. (HASH REF)  : Reference to hash containing all command
#                               line arguments
# sub::return=
# sub::notes=
#              None
# sub::todo=
#              1. Verify that start pattern works.......................DONE!
#              2. Verify that end pattern shuts off.....................DONE!
#              3. Verify that -include includes start line..............DONE!
#              4. Verify that -multiple works for multiple lines........DONE!
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub Read_File(*\%)
{
    local *FH = shift;
    my $opts  = shift;

    my $state;
    my $last;
    my $exclude;
    my $multiple;

    if( defined( $opts->{multiple} ) ) {
        $last = 0;
    } else {
        $last = 1;
    }
    $exclude  = ($opts->{include} ? 0 : 1 );
    $multiple = $opts->{multiple};
    while(<FH> ) {
        $DB::signal = 1 if( m/^x_/ );
        if( !defined($state) && $_ !~ m/$opts->{start}/ ) {
            next;
        } elsif( !defined($state) && $_ =~ m/$opts->{start}/ ) {
            if( !$exclude ) {
                if ( $opts->{excludestart} ){}
                else {
                    print ;
                }
            }
            $state = "middle";
        } elsif( $state eq "middle" && $_ !~ /$opts->{end}/ ) {
            print ;
        } elsif( $state eq "middle" &&  ( defined $opts->{end} && $_ =~ /$opts->{end}/ ))   {
            if( !$exclude ) {
                if ( $opts->{excludeend} ) {}
                else {
                    print ;
                }
            }
            undef( $state );
            if( !$multiple ) {
                last;
            } else {
                print "$opts->{separator}";
            }
        } elsif( $state eq "middle" ) {
            print ;
        } else {

        }
    }
}


1;

__END__

=head1 NAME

between.pl - print out lines between regular expressions.

=head1 SYNOPSIS

=over 12

=item B<between.pl>

B<-start[|-s]> I<REGEX>
[B<-end|-e>  I<REGEX>]
[B<-multiple|-m>]
[B<-include|-i>]
[B<-h>|B<-help>|B<-man>]

=back

=head1 OPTIONS AND ARGUMENTS

=over 8

=item B<-start|-s> I<REGEX>

Use this regex to start selective filtering

=item [B<-end |-e>] I<REGEX>

Use regex to determine place to stop printing lines

=item [B<-multiple|-m>]

Allow filtering of multiple sections

=item [B<-include>]

Include starting and end lines that match regexes

=item [B<-0>]

Separate fields using null character

=item [B<-help|-h>]

Display usage information

=item [B<-man>]

Display man pages for B<between.pl>

=back

=head1 DESCRIPTION

B<between.pl> acts as a filter for text files by printing out lines
in a file that are between two regular expressions. This provides
a means of grabbing a section of text that is somewhere in the
middle of a file that is between two lines that can be recognized
by means of a regular expression.

The additional flags help in adding functionality that determines
behavior regarding how the filtering is administered.

The I<-end> option tells the filtering to just print out all lines
between the I<-start> regular expression and the end of the file.
By turning this on you will STOP printing out lines that come
after the line that matches this ending regular expression. Note:
if you make a mistake in how you specify the I<-end> regular
expression then you might not actually match the line 
that stops the printing of lines. In this scenario, you will
see output that looks as if you never specified I<-end> to 
begin with.

The I<-multiple> option allows the user to print out multiple
sections of lines that are between the starting and ending
regular expression.

The I<-include> option allows you to also print out the line
that matches the starting and ending regular expressions. Without
this option the lines that match the regular expression are I<NOT>
printed out

=back

=head1 EXAMPLE

1. An example of this would be in reading a simple .dat file 
that might be read into gnuplot

  Gnuplot INput (sample.dat)
----------------------------------
...                      Beginning of the file
  TEMP        Power
X
 0.0          9.3835E-07
 5.0000E+00   9.4891E-07
 1.0000E+01   9.5944E-07
Y
...                      End of the file


To parse this file you could use the following command line
invocation of B<between.pl>


between.pl -s '^X\s*$' -e '^Y\s*Y' -f sample.dat > output.dat

2. Removing all full line comments from a perl script


between.pl -s '^\s*(#.*)?$' -f perlfile.pl > no_comments.pl


=back

=head1 AUTHOR

Jimi Damon  <jdamon@sonicwall.com>
