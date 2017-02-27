package Tarp::Utils::Format::GroupMembership;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ GroupMembershipStatus /;

with 'Tarp::Utils::Format';

has group_id    => ( is => 'rw', required => 1, isa => 'Str' );
has user_id     => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => GroupMembershipStatus );

sub file   { return 'groups_membership.csv'; }
sub header { return qw/group_id user_id status/; }
sub key {
    my $self = shift;
    return join( '^', map { $self->$_ } qw/group_id user_id/);
}

__PACKAGE__->meta->make_immutable;

1;
