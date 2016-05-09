package Tarp::Utils::Format::Xlists;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus /;

with 'Tarp::Utils::Format';

has xlist_course_id  => ( is => 'rw', required => 1, isa => 'Str' );
has section_id       => ( is => 'rw', required => 1, isa => 'Str' );
has status           => ( is => 'rw', required => 1, isa => BasicStatus );

sub file   { 'xlists.csv'; }
sub header { return qw/xlist_course_id section_id status/; }

__PACKAGE__->meta->make_immutable;

1;