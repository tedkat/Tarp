package Tarp::Format::Record::Xlists;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus /;

with 'Tarp::Format::Record';

has xlist_course_id  => ( is => 'rw', required => 1, isa => 'Str' );
has section_id       => ( is => 'rw', required => 1, isa => 'Str' );
has status           => ( is => 'rw', required => 1, isa => BasicStatus );

sub columns { qw/xlist_course_id section_id status/ }
sub key { return join( '^', map { $_[0]->$_ } qw/xlist_course_id section_id/); }

__PACKAGE__->meta->make_immutable;

1;
