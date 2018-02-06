package Tarp::Schema::ResultSet::tmpXlists;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'Xlists'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
