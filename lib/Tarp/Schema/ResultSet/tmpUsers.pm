package Tarp::Schema::ResultSet::tmpUsers;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'Users'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
