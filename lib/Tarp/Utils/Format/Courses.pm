package Tarp::Utils::Format::Courses;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ CourseStatus DateStr /;

with 'Tarp::Utils::Format';

has course_id   => ( is => 'rw', required => 1, isa => 'Str' );
has short_name  => ( is => 'rw', required => 1, isa => 'Str' );
has long_name   => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => CourseStatus );

has account_id  => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has term_id     => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has start_date  => ( is => 'rw', isa => DateStr, default => '', lazy => 1, coerce => 1 );
has end_date    => ( is => 'rw', isa => DateStr, default => '', lazy => 1, coerce => 1 );


sub file   { return 'courses.csv'; }
sub header { return qw/course_id short_name long_name account_id term_id status/; }

__PACKAGE__->meta->make_immutable;

1;