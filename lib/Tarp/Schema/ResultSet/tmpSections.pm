package Tarp::Schema::ResultSet::tmpSections;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'Sections'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
