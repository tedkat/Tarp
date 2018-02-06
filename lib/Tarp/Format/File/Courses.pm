package Tarp::Format::File::Courses;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Courses;

with 'Tarp::Format::File';

sub file   { 'courses.csv' }
sub header { qw/course_id short_name long_name account_id term_id status start_date end_date/ }
sub key    { qw/course_id/ }

sub this_record { "Tarp::Format::Record::Courses" }

__PACKAGE__->meta->make_immutable;

1;
