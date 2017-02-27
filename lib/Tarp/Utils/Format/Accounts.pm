package Tarp::Utils::Format::Accounts;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus /;

with 'Tarp::Utils::Format';

has account_id  => ( is => 'rw', required => 1, isa => 'Str' );
has name        => ( is => 'rw', required => 1, isa => 'Str' );
has status      => ( is => 'rw', required => 1, isa => BasicStatus );

has parent_account_id  => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );

sub file { return 'accounts.csv'; }
sub header { return qw/account_id parent_account_id name status/; }
sub key {
    my $self = shift;
    return $self->account_id;
}

__PACKAGE__->meta->make_immutable;

1;
