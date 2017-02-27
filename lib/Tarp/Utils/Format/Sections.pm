package Tarp::Utils::Format::Sections;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ CourseStatus OptionalDateStr /;

with 'Tarp::Utils::Format';

has section_id  => ( is => 'rw', required => 1, isa => 'Str' );
has course_id   => ( is => 'rw', required => 1, isa => 'Str' );
has name        => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => CourseStatus );

has start_date  => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );
has end_date    => ( is => 'rw', isa => OptionalDateStr, default => '', lazy => 1, coerce => 1 );

sub file   { return 'sections.csv'; }
sub header { return qw/section_id course_id name status start_date end_date/; }
sub key {
    my $self = shift;
    return $self->section_id;
}



__PACKAGE__->meta->make_immutable;

1;
