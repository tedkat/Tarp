package Tarp::Schema::ResultSet::tmpCourses;
use Moose;
use namespace::autoclean;

extends 'DBIx::Class::ResultSet';

with 'Tarp::Schema::Roles::ResultSet';

sub sister_rs { 'Courses'; }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
