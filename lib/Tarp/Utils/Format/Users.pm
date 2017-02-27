package Tarp::Utils::Format::Users;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus /;

with 'Tarp::Utils::Format';

has user_id  => ( is => 'rw', required => 1, isa => 'Str' );
has login_id => ( is => 'rw', required => 1, isa => 'Str' );
has status   => ( is => 'rw', required => 1, isa => BasicStatus );

has password                   => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has authentication_provider_id => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has first_name                 => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has last_name                  => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has sortable_name              => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has short_name                 => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );
has email                      => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );

sub file   { return 'users.csv'; }
sub header { return qw/user_id login_id authentication_provider_id password first_name last_name sortable_name short_name email status/; }
sub key {
    my $self = shift;
    return $self->user_id;
}

__PACKAGE__->meta->make_immutable;

1;
