package Tarp::Format::Record::GroupMembership;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ GroupMembershipStatus /;

with 'Tarp::Format::Record';

has group_id    => ( is => 'rw', required => 1, isa => 'Str' );
has user_id     => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => GroupMembershipStatus );

sub columns { qw/group_id user_id status/ }
sub key { return join( '^', map { $_[0]->$_ } qw/group_id user_id/); }

__PACKAGE__->meta->make_immutable;

1;
