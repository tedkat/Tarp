package Tarp::Schema::ResultSet::Sections;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'tmpSections'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
