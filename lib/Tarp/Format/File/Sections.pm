package Tarp::Format::File::Sections;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Sections;

with 'Tarp::Format::File';

sub file   { 'sections.csv' }
sub header { qw/section_id course_id name status start_date end_date/ }
sub key    { qw/section_id/ }

sub this_record { "Tarp::Format::Record::Sections" }

__PACKAGE__->meta->make_immutable;

1;
