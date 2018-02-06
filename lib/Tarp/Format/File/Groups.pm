package Tarp::Format::File::Groups;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::Groups;

with 'Tarp::Format::File';

sub file   { 'groups.csv' }
sub header { qw/group_id name status account_id/ }
sub key    { qw/group_id account_id/ }

sub this_record { "Tarp::Format::Record::Groups" }

__PACKAGE__->meta->make_immutable;

1;
