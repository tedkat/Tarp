package Tarp::Utils::Format::Groups;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ GroupStatus /;

with 'Tarp::Utils::Format';

has group_id    => ( is => 'rw', required => 1, isa => 'Str' );
has name        => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => GroupStatus );

has account_id  => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );

sub file   { return 'groups.csv'; }
sub header { return qw/group_id name status account_id/; }

__PACKAGE__->meta->make_immutable;

1;