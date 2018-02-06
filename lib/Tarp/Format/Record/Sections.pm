package Tarp::Format::Record::Sections;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ CourseStatus OptionalDateStr /;

with 'Tarp::Format::Record';

has section_id  => ( is => 'rw', required => 1, isa => 'Str' );
has course_id   => ( is => 'rw', required => 1, isa => 'Str' );
has name        => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => CourseStatus );

has start_date  => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );
has end_date    => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );

sub columns { qw/section_id course_id name status start_date end_date/ }
sub key { return $_[0]->section_id; }

__PACKAGE__->meta->make_immutable;

1;
