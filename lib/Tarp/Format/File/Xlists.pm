package Tarp::Format::File::Xlists;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Xlists;

with 'Tarp::Format::File';

sub file   { 'xlists.csv' }
sub header { qw/xlist_course_id section_id status/ }
sub key    { qw/xlist_course_id section_id/ }

sub this_record { "Tarp::Format::Record::Xlists" }

__PACKAGE__->meta->make_immutable;

1;
