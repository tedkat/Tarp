package Tarp::Format::File::Terms;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Terms;

with 'Tarp::Format::File';

sub file   { 'terms.csv' }
sub header { qw/term_id name status start_date end_date/ }
sub key    { qw/term_id/ }

sub this_record { "Tarp::Format::Record::Terms" }

__PACKAGE__->meta->make_immutable;

1;
