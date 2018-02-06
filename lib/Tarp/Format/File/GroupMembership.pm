package Tarp::Format::File::GroupMembership;

use Moose;
use namespace::autoclean;

use Tarp::Format::Record::GroupMembership;

with 'Tarp::Format::File';

sub file   { 'groups_membership.csv' }
sub header { qw/group_id user_id status/ }
sub key    { qw/group_id user_id/ }

sub this_record { "Tarp::Format::Record::GroupMembership" }

__PACKAGE__->meta->make_immutable;

1;
