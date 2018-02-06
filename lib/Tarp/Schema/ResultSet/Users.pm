package Tarp::Schema::ResultSet::Users;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'tmpUsers'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
