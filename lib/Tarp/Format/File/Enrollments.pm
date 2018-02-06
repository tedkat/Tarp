package Tarp::Format::File::Enrollments;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Enrollments;

with 'Tarp::Format::File';

sub file   { 'enrollments.csv' }
sub header { qw/course_id section_id status user_id root_account associated_user_id role role_id/ }
sub key    { qw/course_id user_id role section_id associated_user_id/ }

sub this_record { "Tarp::Format::Record::Enrollments" }

__PACKAGE__->meta->make_immutable;

1;
