package Tarp::Format::Record::Accounts;

use Moose;
use namespace::autoclean;

use Tarp::Utils::Types qw/ BasicStatus /;

with 'Tarp::Format::Record';

has account_id         => ( is => 'rw', required => 1, isa => 'Str' );
has name               => ( is => 'rw', required => 1, isa => 'Str' );
has status             => ( is => 'rw', required => 1, isa => BasicStatus );
has parent_account_id  => ( is => 'rw', isa => 'Str', default => '', lazy => 1 );

sub columns { qw/account_id parent_account_id name status/ }
sub key { return $_[0]->account_id; }

__PACKAGE__->meta->make_immutable;

1;
