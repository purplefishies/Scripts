#!/usr/bin/perl
##
#
#
{
  package Point;
  use Moose;

  has 'x' => (isa => 'Int', is => 'rw', required => 1 );  
  has 'y' => (isa => 'Int', is => 'rw', required => 1 );

  sub clear {
    my $self = shift;
    print "Running parent Clear\n";
    $self->x(0);
    $self->y(0);
  }
}

{
  package Point3D;
  use Moose;
  extends 'Point';
  has 'z' => (isa => "Int", is => "rw", required => 1 );

   after 'clear' => sub {
     print "Running other clear\n";
     my $self = shift;
     $self->z(0);
   };

  before "clear" => sub {
    print "Before Clear\n";
  }
}


#
# Variables
#

my %opts;

#
# Main
#


# GetOptions(\%opts,
#            "file=s",
#           );





print "reached";
$b = new Point(x => 3, y => 3 );

$c = new Point3D( x=>1,y=>2,z=>3);


$c->clear();

print "";
